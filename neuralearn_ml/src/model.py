# import os
# import pandas as pd
import torch
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer
)
from peft import PeftModel, PeftConfig

# Display entire pandas column width
# pd.set_option('display.max_colwidth', 150)

# Set the device (in this case, GPU)
device = "cuda:0"

# Load PEFT model and configuration
results = "/model/model/llama-2-7b-detoxify"
peft_config = PeftConfig.from_pretrained(results)

# Initialize tokenizer from PEFT config
tokenizer = AutoTokenizer.from_pretrained(
    peft_config.base_model_name_or_path, 
)
tokenizer.pad_token = tokenizer.eos_token

# Initialize the model from PEFT config
model = AutoModelForCausalLM.from_pretrained(
    peft_config.base_model_name_or_path,
    load_in_4bit=True,
    torch_dtype=torch.bfloat16,
)

# Initialize the finetuned Lora PEFT model
model = PeftModel.from_pretrained(model, results)
model = PeftModel.from_pretrained(model, results)

# Send the model to the specified device
model = model.to(device)

# Load the test dataframe
# test = pd.read_csv("test_en.csv")

# Compute the abstract colum median length
# median_string_length = test['abstract'].apply(len).median()


def generate(prompt):
    input_prompt = "<s>[INST]You are a helpful assistant designed to help people study machine learning. Be concise in your answers. " + prompt + "[/INST] "
    inputs = tokenizer(input_prompt, return_tensors="pt").to("cuda")

    MAX_LEN = 1024
    TOP_K = 50
    TOP_P = 0.9
    TEMPERATURE = 0.8
    REP_PENALTY = 1.2
    NO_REPEAT_NGRAM_SIZE = 10
    NUM_RETURN_SEQUENCES = 1

    output = model.generate(
        **inputs,
        do_sample=True,
        max_length=MAX_LEN,
        top_k=TOP_K,
        top_p=TOP_P,
        temperature=TEMPERATURE,
        repetition_penalty=REP_PENALTY,
        no_repeat_ngram_size=NO_REPEAT_NGRAM_SIZE,
        num_return_sequences=NUM_RETURN_SEQUENCES,
    )

    output_text = tokenizer.decode(output[0], skip_special_tokens=True)

    return output_text