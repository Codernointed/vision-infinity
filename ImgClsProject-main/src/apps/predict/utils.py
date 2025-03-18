from pathlib import Path
import base64


def get_base64_image(image_path: Path) -> str:
    """Convert an image file to a base64-encoded string."""
    if not image_path.exists():
        return ""

    with open(image_path, "rb") as img_file:
        return f"data:image/jpeg;base64,{base64.b64encode(img_file.read()).decode()}"
