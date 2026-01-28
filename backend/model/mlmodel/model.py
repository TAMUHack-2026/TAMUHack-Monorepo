from asthma.inference import AsthmaRiskModel
from backend.model.mlmodel.asthma_preprocessing import summary_statisitcs

def infer(height, weight, sex, age, breath_data, blow_duration):
    # Dummy implementation for inference
    #sex: 0 is female, 1 is male
    
    asthma_model = AsthmaRiskModel("asthma/asthma_model.joblib")
        
    data  = summary_statisitcs()
    data["age"] = age
    data["sex"] = 1 #male
    data["height_cm"] = height
    data["weight_kg"] = weight
    data["bmi"] = weight/(height**2)

    #asthma model output
    risk =  AsthmaRiskModel.predict_risk(data)["risk"]

    return risk



