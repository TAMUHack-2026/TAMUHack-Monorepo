from pydantic import BaseModel, Field, StringConstraints, PositiveFloat
from typing_extensions import Annotated
from typing import List


class ModelInput(BaseModel):
    height_in: float = Field(..., gt=0, description="Height in inches")
    weight_lbs: float = Field(..., gt=0, description="Weight in pounds")
    sex: Annotated[str, StringConstraints(to_lower=True, pattern="^(male|female)$")]
    breath_data: List[PositiveFloat] = Field(..., min_length=1, description="List of breath data measurements")
