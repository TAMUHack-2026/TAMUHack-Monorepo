import os
import torch

from utils.predict_utils import (
    load_spiro_encoder,
    preprocess_data,
    run_spiro_encoder,
    run_spiro_explainer,
    load_cb_model,
    run_spiro_predictor,
)

def copd_risk(data_path: str, age: int, sex: int, smoke: int):
    folders = ['weights']
    for folder in folders:
        if not os.path.exists(folder):
            os.makedirs(folder)


    torch.set_num_threads(8)

    processed_data = preprocess_data(
        input_path=data_path, age=age, sex=sex, smoke=smoke
    )

    device = torch.device("cpu") #

    # Run SpiroEncoder
    spiro_encoder_original_result, attention_weights, all_input_x = run_spiro_encoder(
        model=load_spiro_encoder(device_str='cuda', model_path="./weights/SpiroEncoder.pth"),
        data=processed_data,
        device=device
    )

    # Run SpiroExplainer
    spiro_explainer_result, image_base64, spiro_probs= run_spiro_explainer(
        model=load_cb_model(model_path="./weights/SpiroExplainer.cbm"),
        data=processed_data,
        threshold=0.1,
        spiro_encoder_original_result=spiro_encoder_original_result,
        attention_weights=attention_weights,
        all_input_x=all_input_x,
        is_show=False
    )

    # Run SpiroPredictor if necessary
    spiro_predictor_result = {}
    
    spiro_predictor = run_spiro_predictor(
        model=load_cb_model(model_path="./weights/SpiroPredictor.cbm"),
        data=processed_data
    )
    spiro_predictor_result = spiro_predictor[0][1:6]
    
    return spiro_explainer_result, spiro_predictor_result, spiro_probs 