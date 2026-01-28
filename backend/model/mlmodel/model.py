from asthma.inference import AsthmaRiskModel
from backend.model.mlmodel.asthma_preprocessing import summary_statisitcs
from COPD_Early_Prediction.run_predict import copd_risk
import numpy as np

def infer(height, weight, sex, age, breath_data, blow_duration):
    # Dummy implementation for inference
    #sex: 0 is female, 1 is male

    asthma_model = AsthmaRiskModel("asthma/asthma_model.joblib")

    asthma_data  = summary_statisitcs()
    asthma_data["age"] = age
    asthma_data["sex"] = 1 #male
    asthma_data["height_cm"] = height
    asthma_data["weight_kg"] = weight
    asthma_data["bmi"] = weight/(height**2)

    #asthma model output
    asthma_risk =  AsthmaRiskModel.predict_risk(asthma_data)["risk"]

    
    # copd code

    threshold = 0.1

    copd_risk = copd_risk(
        data_path = "./infer.xlsx",
        age = age,
        sex = sex,
        smoke = np.random.choice([0,1], p=[0.1,0.9]) # 10% of adults smoke roughly
    )

    copd_prob = copd_risk[2][1]
    copd_noprob = copd_risk[2][0]
    copd_class = copd_risk[0]
    
    return asthma_risk, copd_class



