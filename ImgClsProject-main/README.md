# CIFAR-10 Image Classification Project

A modern web application for classifying CIFAR-10 images using multiple deep learning models. This project was developed as part of the Digital Signal and Image Processing course (EL 463) at the University of Mines and Technology (UMaT).

## Overview

This application allows users to upload and classify images using three different neural network architectures:
- ResNet18
- MobileNetV2
- Custom CNN

The application features an intuitive user interface, real-time classification, and confidence scoring.

## Technologies Used

### Backend
- Python 3.11
- FastAPI
- PyTorch
- Torchvision
- Pillow (PIL)

### Frontend
- HTML/CSS
- JavaScript
- Bootstrap 5

## Project Structure

- `/data`: Contains CIFAR-10 dataset
- `/src`: Source code for the web application
  - `/apps/predict`: Prediction-specific code
    - `/static`: Static assets for the prediction interface
    - `/templates`: HTML templates for the prediction interface
    - `router.py`: API routes for image classification
    - `service.py`: Image classifier service
  - `/static`: Static assets for the main application
  - `/templates`: HTML templates for the main application
  - `main.py`: FastAPI application entrypoint
- `/notebooks`: Jupyter notebooks for model training
  - `resnet18.ipynb`: Training and evaluation of ResNet18 model
  - `mobilenetv2.ipynb`: Training and evaluation of MobileNetV2 model
  - `custom_cnn.ipynb`: Training and evaluation of custom CNN model

## Installation

1. Clone this repository
2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Run the application:

```bash
uvicorn src.main:app --reload
```

4. Open http://localhost:8000 in your browser

## Features

- **Multiple Model Support**: Choose between ResNet18, MobileNetV2, or a custom CNN for image classification
- **User-Friendly Interface**: Clean, intuitive design for a great user experience
- **Real-time Processing**: Instant classification results with confidence scores
- **Responsive Design**: Works on desktop and mobile devices

## Frontend Screenshots

![image](https://github.com/user-attachments/assets/28a94e1a-faca-4219-9a4e-5ce5ee912403)

![image](https://github.com/user-attachments/assets/25cba6ed-048c-4c0c-a419-f377f8835eef)


## Model Performance

The models have been trained on the CIFAR-10 dataset, which consists of 60,000 32x32 color images across 10 different classes.

## Team Members

- Group 3, EL4 UMaT 2025 Class

## Course Instructor

- Dr. Effah Ema - [UMaT Profile](https://www.umat.edu.gh/staffinfo/staffDetailed.php?contactID=171)

## Acknowledgments

- Canadian Institute for Advanced Research (CIFAR) for the dataset
- PyTorch team for the deep learning framework
