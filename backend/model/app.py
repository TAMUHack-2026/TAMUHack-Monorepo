from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import Response
from fastapi.openapi.docs import get_swagger_ui_html
from dtos import ModelInput
from mlmodel import infer
import uvicorn

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)
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
    return infer(
            input_data.height_in,
            input_data.weight_lbs,
            input_data.sex,
            input_data.breath_data
    )


@app.get("/openapi.yaml", include_in_schema=False)
async def get_openapi_yaml():
    with open("static/openapi.yaml", "r") as f:
        return Response(content=f.read(), media_type="text/yaml")


@app.get("/swagger-ui.html", include_in_schema=False)
async def get_swagger_ui():
    return get_swagger_ui_html(
        openapi_url="/openapi.yaml",
        title="Swagger UI",
        swagger_js_url="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.31.0/swagger-ui-bundle.min.js",
        swagger_css_url="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.31.0/swagger-ui.min.css",
    )


app.include_router(api_router)
app.mount("/static", StaticFiles(directory="static"), name="static")
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8090)
