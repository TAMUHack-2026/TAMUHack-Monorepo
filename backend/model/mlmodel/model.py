from asthma.inference import AsthmaRiskModel
from backend.model.mlmodel.asthma_preprocessing import summary_statistics
from COPD_Early_Prediction.run_predict import copd_risk
from copd_preprocessing import process_excel_file
import numpy as np

def infer(height, weight, sex, age, breath_data):
    # Dummy implementation for inference
    #sex: 0 is female, 1 is male

    asthma_model = AsthmaRiskModel("asthma/asthma_model.joblib")

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
        data_path = "./infer.xlsx",
        age = age,
        sex = sex,
        smoke = np.random.choice([0,1], p=[0.1,0.9]) # 10% of adults smoke roughly
    )

    copd_prob = copd_result[2][1]
    copd_noprob = copd_result[2][0]
    copd_class = copd_result[0]
    
    return asthma_risk, copd_class




