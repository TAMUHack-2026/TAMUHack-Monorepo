

import numpy as np
import os

from COPD_Early_Prediction import copd_risk
from asthma_preprocessing import summary_statistics
from asthma import AsthmaRiskModel
from copd_preprocessing import process_excel_file


def infer(height, weight, sex, breath_data):
    # Dummy implementation for inference
    #sex: 0 is female, 1 is male

    height = height * 2.54
    weight = 0.453*weight

    age = 35
    

    asthma_model_path = os.path.join(
        os.path.dirname(__file__), 
        'asthma', 
        'asthma_model.joblib'
    )
    asthma_model = AsthmaRiskModel(asthma_model_path)

    asthma_data  = summary_statistics(breath_data)

    asthma_data["age"] = age
    asthma_data["sex"] = sex 
    asthma_data["height_cm"] = height
    asthma_data["weight_kg"] = weight
    asthma_data["bmi"] = weight/((height/100)**2)
    #asthma model output
    asthma_risk =  asthma_model.predict_risk(asthma_data)["risk"]
    # copd code

    #generating the dataset
    process_excel_file(breath_data)

    copd_result = copd_risk(
        data_path = "./mlmodel/COPD_Early_Prediction/infer.xlsx",
        age = age,
        sex = sex,
        smoke = np.random.choice([0,1], p=[0.1,0.9]) # 10% of adults smoke roughly
    )

    copd_prob = copd_result[2][0][1]
    copd_future_risks = copd_result[1]

    os.remove("./mlmodel/COPD_Early_Prediction/infer.xlsx")
    
    #finalizing the output:

    asthma_string = f"AsthmaRisk: {asthma_risk}|"
    copd_string = f"CopdRisk: {copd_prob}"
    copd_future = "|".join(
        f"{100 * x:.2f}%"
        for x in copd_future_risks
    )
        

    return asthma_string + copd_string  + copd_future
    











