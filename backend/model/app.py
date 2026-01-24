from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, conlist, confloat
import os
import swagger_ui_bundle
import uvicorn

app = FastAPI(
    title="Model API",
    version="0.0.1",
    openapi_url=None,      
    docs_url=None,     
    redoc_url=None     
)


class PredictRequest(BaseModel):
    height_in: confloat(gt=0)           
    weight_lbs: confloat(gt=0)          
    sex: str
    breath_data: conlist(confloat(gt=0), min_items=1)  


@app.post("/predict")
async def predict(data: PredictRequest):
    """
    Mock endpoint to receive user metrics and breath data.
    Returns a simple string confirming receipt.
    """
    try:
        return "Data received"
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/model.yaml")
async def get_model_spec():
    return FileResponse("model.yaml", media_type="application/yaml")

app.mount(
    "/swagger-ui",
    StaticFiles(directory=os.path.dirname(swagger_ui_bundle.__file__) + "/swagger_ui_bundle", html=True),
    name="swagger-ui"
)

@app.get("/ping")
async def ping():
    return "pong"

@app.get("/docs", response_class=HTMLResponse)
async def custom_swagger_ui():
    return f"""
    <!DOCTYPE html>
    <html>
      <head>
        <title>Swagger UI</title>
        <link href="/swagger-ui/swagger-ui.css" rel="stylesheet">
      </head>
      <body>
        <div id="swagger-ui"></div>
        <script src="/swagger-ui/swagger-ui-bundle.js"></script>
        <script>
          const ui = SwaggerUIBundle({{
            url: "/model.yaml",
            dom_id: '#swagger-ui'
          }});
        </script>
      </body>
    </html>
    """

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8090)    
