# NeuraLearn

An intuitive Flutter app harnessing a fine-tuned LLM to empower machine learning students with on-demand insights, course content search, and personalized study tools.

## Repository structure
`infra/` has all the code to run the model on a yandex cloud cluster. <br>
`neuralearn_backend/` has the server code for the project.<br>
`neuralearn_flutter/` has the Flutter app with a simple chat UI for iOS / Android.<br>
`neuralearn_ml/` has the vector datastores, model experimentation and all ML-related stuff.<br>

## Models
All the models we implemented are in our HuggingFace repository [here](https://huggingface.co/RNDRandoM/neuralearn-qlora-ft-7b/tree/main). All these models are based on LLaMa 2 7B and they are fine-tuned on our custom dataset.

