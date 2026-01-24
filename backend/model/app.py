from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from dtos import ModelInput
import uvicorn

app = FastAPI()
api_router = APIRouter(prefix="/model/api")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@api_router.get("/ping")
async def ping():
    return "pong"


@api_router.post("/predict")
async def predict(input_data: ModelInput):
    # Placeholder for prediction
    return "Prediction result"


app.include_router(api_router)
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8090)
