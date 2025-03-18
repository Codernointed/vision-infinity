from typing import Literal, Tuple
from pathlib import Path
import io
from PIL import Image

import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms
import torchvision.models as models


models_path = Path(__file__).parent / "ai_models"

device = torch.device(
    "cuda:0"
    if torch.cuda.is_available()
    else "mps" if torch.backends.mps.is_available() else "cpu"
)


class CustomCNN(nn.Module):
    def __init__(self):
        super(CustomCNN, self).__init__()
        self.conv1 = nn.Conv2d(3, 32, kernel_size=3, padding=1)
        self.bn1 = nn.BatchNorm2d(32)
        self.conv2 = nn.Conv2d(32, 64, kernel_size=3, padding=1)
        self.bn2 = nn.BatchNorm2d(64)
        self.pool = nn.MaxPool2d(kernel_size=2, stride=2, padding=0)
        self.conv3 = nn.Conv2d(64, 128, kernel_size=3, padding=1)
        self.bn3 = nn.BatchNorm2d(128)
        self.fc1 = nn.Linear(128 * 4 * 4, 256)
        self.fc2 = nn.Linear(256, 10)

    def forward(self, x):
        x = self.pool(F.relu(self.bn1(self.conv1(x))))
        x = self.pool(F.relu(self.bn2(self.conv2(x))))
        x = self.pool(F.relu(self.bn3(self.conv3(x))))
        x = x.view(-1, 128 * 4 * 4)
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return x


class ImgClassifier:
    """
    Image classifier Class
    Classifies images using three models: ResNet-18, MobileNetV2, and a custom CNN.
    Classes: ["an airplane", "an automobile", "a bird", "a cat", "a deer", "a dog", "a frog", "a horse", "a ship", "a truck"]
    """

    def __init__(self):
        self.transfer_transform = transforms.Compose(
            [
                transforms.Resize((224, 224)),
                transforms.ToTensor(),
                transforms.Normalize(
                    [0.485, 0.456, 0.406], [0.229, 0.224, 0.225]
                ),  # ImageNet/Resnet normalization
            ]
        )
        self.custom_transform = transforms.Compose(
            [
                transforms.Resize((32, 32)),
                transforms.ToTensor(),
                transforms.Normalize(
                    (0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)
                ),  # CIFAR-10 normalization
            ]
        )

        self.classes = [
            "an airplane",
            "an automobile",
            "a bird",
            "a cat",
            "a deer",
            "a dog",
            "a frog",
            "a horse",
            "a ship",
            "a truck",
        ]

        mobilenet_v2 = models.mobilenet_v2(weights=None)
        mobilenet_v2.classifier[1] = torch.nn.Linear(
            mobilenet_v2.classifier[1].in_features, 10
        )
        mobilenet_v2.load_state_dict(torch.load(models_path / "mobilenetv2_mps.pth"))
        mobilenet_v2.to(device)
        mobilenet_v2.eval()
        self.mobilenet_v2 = mobilenet_v2

        resnet18 = models.resnet18(weights=None)
        resnet18.fc = torch.nn.Linear(resnet18.fc.in_features, 10)
        resnet18.load_state_dict(torch.load(models_path / "resnet18_mps.pth"))
        resnet18.to(device)
        resnet18.eval()
        self.resnet18 = resnet18

        custom_cnn = CustomCNN()
        custom_cnn.load_state_dict(torch.load(models_path / "custom_cnn_mps.pth"))
        custom_cnn.to(device)
        custom_cnn.eval()
        self.custom_cnn = custom_cnn

    def predict(
        self,
        img_bytes: bytes,
        model_name: Literal["resnet18", "mobilenet_v2", "custom_cnn"],
    ) -> Tuple[str, float]:
        """
        Performs image classification using a specified model.

        Args:
            img_bytes (bytes): The input image in bytes format
            model_name (Literal["resnet18", "mobilenet_v2", "custom_cnn"]): Name of the model to use for prediction.
                                                                    Must be one of "resnet18", "mobilenet_v2", or "custom_cnn"

        Returns:
            Tuple[str, float]: A tuple containing:
                - str: The predicted class label
                - float: The probability/confidence score for the prediction (between 0 and 1)

        Raises:
            ValueError: If an invalid model name is specified
        """
        model = getattr(self, model_name, None)
        if model is None:
            raise ValueError(f"Invalid model name: {model_name}")

        transform = (
            self.custom_transform
            if model_name == "custom_cnn"
            else self.transfer_transform
        )

        image = Image.open(io.BytesIO(img_bytes)).convert("RGB")

        img_tensor = transform(image).unsqueeze(0).to(device)
        with torch.no_grad():
            output = model(img_tensor)
            probabilities = F.softmax(output, dim=1)

        top_p, top_class = probabilities.topk(1, dim=1)
        idx = top_class.item()
        return self.classes[idx], top_p.item()
