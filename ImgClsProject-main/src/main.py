from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse

from src.apps.predict.router import router as predict_router


app = FastAPI(title="Image Processing Suite")


app.mount("/src/static", StaticFiles(directory="src/static"), name="static")
app.mount(
    "/src/apps/predict/static",
    StaticFiles(directory="src/apps/predict/static"),
    name="predict_static",
)

app.include_router(predict_router, prefix="/predict")

templates = Jinja2Templates(directory="src/templates")


@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse(
        "index.html", {"request": request, "title": "Image Processing Suite"}
    )
