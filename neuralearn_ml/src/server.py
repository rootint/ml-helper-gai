# Thanks to https://gist.github.com/python273/563177b3ad5b9f74c0f8f3299ec13850 for streaming

from flask import Flask, Response, request
import threading
import queue

from langchain.vectorstores import FAISS
from langchain.prompts import PromptTemplate
from langchain.embeddings.gpt4all import GPT4AllEmbeddings
from langchain.llms import GPT4All
from langchain.llms import LlamaCpp
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
from langchain.callbacks.manager import CallbackManager

import argparse

parser = argparse.ArgumentParser(description='Parameters for server')
parser.add_argument('name', type=str)
parser.add_argument('port', type=str)
args = parser.parse_args()

app = Flask(__name__)

class ThreadedGenerator:
    def __init__(self):
        self.queue = queue.Queue()

    def __iter__(self):
        return self

    def __next__(self):
        item = self.queue.get()
        if item is StopIteration:
            raise item
        return item

    def send(self, data):
        self.queue.put(data)

    def close(self):
        self.queue.put(StopIteration)


class ChainStreamHandler(StreamingStdOutCallbackHandler):
    def __init__(self, gen):
        super().__init__()
        self.gen = gen

    def on_llm_new_token(self, token: str, **kwargs):
        self.gen.send(token)


def retrieve_info(query, db):
    """Retrieves the relevant data from the vector database."""
    similar_response = db.similarity_search(query, k=2)

    page_contents_array = [doc.page_content for doc in similar_response]

    return page_contents_array


def llm_thread(g, query):
    try:
        embedder = GPT4AllEmbeddings()
        callback_manager = CallbackManager([ChainStreamHandler(g)])

        # n_gpu_layers = 1
        # n_batch = 102

        llm = LlamaCpp(
            model_path=f"/uploaded_models/{args.name}",
            temperature=0.1,
            n_ctx=512,
            top_p=0.5,
            # n_gpu_layers=n_gpu_layers,
            # n_batch=n_batch,
            f16_kv=True,
            callback_manager=callback_manager,
            verbose=True,  # Verbose is required to pass to the callback manager
        )
        db = FAISS.load_local("/neuralearn/src/ml_papers_2", embedder)
        context = retrieve_info(query, db)
        print(context)
        prompt = PromptTemplate.from_template(
            """
        [INST] <<SYS>>You are a helpful, respectful and honest assistant who specializes in machine learning and answers as concisely as possible. Base your answers on the given context.<</SYS>>
        Context:{context}
        User question: {message}[/INST]
        """
        )

        prompt_no_ctx = PromptTemplate.from_template(
            """
        [INST] <<SYS>>You are a helpful, respectful and honest assistant who specializes in machine learning and answers as concisely as possible. Base your answers on the given context.<</SYS>>
        User question: {message}[/INST]
        """
        )

        # runnable = prompt | llm

        # runnable.invoke({"message": query, "context": context})
        
        runnable = prompt_no_ctx | llm

        runnable.invoke({"message": query})
    finally:
        g.close()


def chain(prompt):
    g = ThreadedGenerator()
    threading.Thread(target=llm_thread, args=(g, prompt)).start()
    return g


@app.route("/chain", methods=["POST", "GET"])
def _chain():
    return Response(chain(request.json["prompt"]), mimetype="text/plain")


if __name__ == "__main__":
    app.run(threaded=True, debug=True, port=args.port, host='0.0.0.0')