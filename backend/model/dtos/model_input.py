from pydantic import BaseModel
from typing import List


class ModelInput(BaseModel):
    height_in: float
    weight_lbs: float
    sex: str
    breath_data: List[float]
