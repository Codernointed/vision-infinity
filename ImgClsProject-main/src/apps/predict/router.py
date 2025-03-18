from typing import Literal
import io
import base64
from PIL import Image

from fastapi import APIRouter, Request, File, UploadFile, Form
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from src.apps.predict.service import ImgClassifier


router = APIRouter()

templates = Jinja2Templates(directory="src/apps/predict/templates")

img_classifier = ImgClassifier()


@router.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse(
        "predict.html",
        {"request": request, "title": "Image Classification", "prediction": None},
    )


@router.post("/", response_class=HTMLResponse)
async def predict(
    request: Request,
    file: UploadFile = File(...),
    selected_model: Literal["custom_cnn", "resnet18", "mobilenet_v2"] = Form(
        "resnet18"
    ),
):
    image_bytes = await file.read()

    prediction = img_classifier.predict(image_bytes, selected_model)
    predicted_class = prediction[0].capitalize()
    confidence = prediction[1] * 100

    image = Image.open(io.BytesIO(image_bytes))
    image_data = io.BytesIO()
    image.save(image_data, format=image.format if image.format else "JPEG")
    encoded_img = base64.b64encode(image_data.getvalue()).decode("utf-8")
    img_format = image.format.lower() if image.format else "jpeg"

    return templates.TemplateResponse(
        "predict.html",
        {
            "request": request,
            "title": "Image Classification",
            "prediction": f"{predicted_class} (Confidence: {confidence:.2f}%)",
            "image": f"data:image/{img_format};base64,{encoded_img}",
            "used_model": selected_model,
        },
    )
