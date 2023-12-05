

from flask import Flask, Response, request
import threading
import queue

from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

from flask import Flask, request, jsonify, Response
from langchain.vectorstores import FAISS
from langchain.prompts import PromptTemplate
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
from langchain.embeddings.gpt4all import GPT4AllEmbeddings
from langchain.llms import GPT4All
from langchain.llms import LlamaCpp
from langchain.prompts import PromptTemplate
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
from langchain.callbacks.manager import CallbackManager


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
    similar_response = db.similarity_search(query, k=2)

    page_contents_array = [doc.page_content for doc in similar_response]

    return page_contents_array


def llm_thread(g, query):
    try:
        embedder = GPT4AllEmbeddings()
        callback_manager = CallbackManager([ChainStreamHandler(g)])

        n_gpu_layers = 1
        n_batch = 2048

        llm = LlamaCpp(
            model_path="llama2_v2.gguf",
            # model_path="orca2.gguf",
            temperature=0.1,
            n_ctx=2048,
            top_p=0.1,
            n_gpu_layers=n_gpu_layers,
            n_batch=n_batch,
            f16_kv=True,
            callback_manager=callback_manager,
            verbose=True,  # Verbose is required to pass to the callback manager
        )
        db = FAISS.load_local("ml_papers_2", embedder)
        context = retrieve_info(query, db)
        print(context)
        prompt = PromptTemplate.from_template(
            """
        [INST] <<SYS>>You are a helpful, respectful and honest assistant who specializes in machine learning and answers as concisely as possible. Base your answers on the given context.<</SYS>>
        Context:{context}
        User question: {message}[/INST]
        """
        )

        prompt_no_context = PromptTemplate.from_template(
            """
        <s>[INST] <<SYS>>
        You are a helpful, respectful and honest assistant who specializes in machine learning and answers as concisely as possible. 
        <</SYS>>

        {message} [/INST]
        """
        )

        runnable = prompt | llm

        runnable.invoke({"message": query, "context": context})
        

        # runnable = prompt_no_context | llm

        # runnable.invoke({"message": query})
    finally:
        g.close()


def chain(prompt):
    g = ThreadedGenerator()
    threading.Thread(target=llm_thread, args=(g, prompt)).start()
    return g


@app.route("/chain", methods=["POST"])
def _chain():
    return Response(chain(request.json["prompt"]), mimetype="text/plain")


if __name__ == "__main__":
    app.run(threaded=True, debug=True, port=1337)
