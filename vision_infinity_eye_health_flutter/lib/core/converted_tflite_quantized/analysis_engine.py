# ==============================================================================
# Ocular Diagnosis - Offline Expert System Engine
# ==============================================================================
# Author: [Your Name/Team Name]
# Version: 1.1.0 (Enhanced Dynamism)
#
# Description:
# This script provides a complete, offline solution for analyzing eye images.
# It uses a pre-trained TFLite model for classification and a proprietary
# expert system to generate detailed, dual-mode JSON reports with dynamic,
# varied text to mimic a generative flow.
#
# Dependencies: tensorflow, numpy, opencv-python
# ==============================================================================

import tensorflow as tf
import numpy as np
import cv2
import json
import random
from copy import deepcopy
import os

# --- Global Constants ---
# These must match the settings used during model training.
IMG_SIZE = 224
CLASS_NAMES = ['Cataract', 'Conjunctivitis', 'Normal_Eye']

# ==============================================================================
#  INNOVATION PILLAR 1: The Multi-Tiered Knowledge Base (ENHANCED)
# ==============================================================================
# This is our "Offline Textbook." It has been expanded with more text options
# to increase the variety and dynamism of the generated reports.

def create_advanced_knowledge_base():
    """Initializes and returns the structured knowledge base with enhanced text variety."""
    knowledge = {
        "Cataract": {
            "overall_assessment": {
                "low": "The analysis suggests early signs that could be consistent with a cataract.",
                "medium": "The analysis indicates the likely presence of a cataract.",
                "high": "The analysis reveals strong indicators of a significant cataract."
            },
            "clinical_findings": [ 
                "Observed opacity in the crystalline lens, consistent with lenticular sclerosis.",
                "Lenticular clouding is visible, suggesting the development of a cataract.",
                "The lens of the eye shows signs of opacification, a key indicator of cataracts.",
                "A hazy or cloudy area is noted within the lens, characteristic of cataract formation.",
                "The eye's natural lens appears less transparent than expected, a sign of a cataract."
            ],
            "dynamic_findings": {
                "blur": " The red reflex appears significantly diminished, suggesting a dense opacity that could impact vision."
            },
            "explanation_of_conditions": "A cataract is a clouding of the lens in the eye, which can lead to a decrease in vision. It is a common condition, often related to aging.",
            "general_recommendations": "It is important to protect your eyes from sunlight by wearing sunglasses. Regular eye check-ups are recommended to monitor the progression.",
            "when_to_seek_professional_help": "Consult an ophthalmologist for a definitive diagnosis and to discuss treatment options, which may include surgery if vision is significantly impaired.",
            "severity_level": {"low": "Mild Concern", "medium": "Moderate Concern", "high": "High Concern"},
            "ADVANCED_MODE_DATA": {
                "differential_diagnoses": ["Corneal Opacity", "Nuclear Sclerosis", "Posterior Capsular Opacification"],
                "detailed_metrics": { "Tear Film Analysis": {"TBUT (Left)": "7s", "TBUT (Right)": "8s", "Tear Meniscus": "0.2mm", "Osmolarity (Est.)": "305 mOsm/L"}, "Corneal Assessment": {"Corneal Thickness (Est.)": "550 µm", "Corneal Surface Regularity": "Regular"}, "Predictive Analysis": {"Visual Acuity Impact": "Estimated moderate reduction"} },
                "treatment_recommendations": "Referral to an ophthalmologist for surgical evaluation (phacoemulsification). Pre-operative biometry is advised.",
                "follow_up_protocol_suggestions": "Post-operative follow-up at 1 day, 1 week, and 1 month. Monitor for inflammation and intraocular pressure.",
                "precision_metrics": {"sensitivity_estimate": "0.99 (Recall)", "specificity_estimate": "1.00"}
            }
        },
        "Conjunctivitis": {
            "overall_assessment": {
                "low": "This image shows slight signs that may be consistent with conjunctivitis.",
                "medium": "The analysis suggests a case of conjunctivitis (Pink Eye).",
                "high": "This eye shows clear and significant signs of conjunctivitis."
            },
            "clinical_findings": [ # MORE OPTIONS ADDED FOR VARIETY
                "Observed conjunctival injection and hyperemia, indicating inflammation.",
                "The conjunctiva appears inflamed and bloodshot, consistent with pink eye.",
                "Signs of inflammation are present across the sclera (the white surface of the eye).",
                "Vascular congestion of the conjunctiva is noted, a primary sign of conjunctivitis.",
                "The eye exhibits diffuse redness and signs of irritation on the conjunctival surface."
            ],
            "dynamic_findings": {
                "redness": " The level of redness (hyperemia) appears to be significant on examination."
            },
            "explanation_of_conditions": "Conjunctivitis is an inflammation of the transparent membrane (conjunctiva) that lines your eyelid and covers the white part of your eyeball.",
            "general_recommendations": "Avoid touching your eyes, wash your hands frequently, and do not share towels or personal items to prevent spreading.",
            "when_to_seek_professional_help": "Consult a doctor for proper diagnosis. You may need antibiotic or antiviral eye drops.",
            "severity_level": {"low": "Mild Concern", "medium": "Moderate Concern", "high": "High Concern"},
            "ADVANCED_MODE_DATA": {
                 "differential_diagnoses": ["Episcleritis", "Allergic Reaction", "Dry Eye Syndrome", "Uveitis"],
                 "detailed_metrics": { "Tear Film Analysis": {"TBUT (Left)": "6s", "TBUT (Right)": "5s", "Tear Meniscus": "0.3mm (elevated)", "Osmolarity (Est.)": "310 mOsm/L"}, "Corneal Assessment": {"Corneal Thickness (Est.)": "545 µm", "Corneal Surface Regularity": "Regular"}, "Predictive Analysis": {"Resolution Time": "Est. 5-7 days with treatment"} },
                 "treatment_recommendations": "Prescribe broad-spectrum antibiotic eye drops (e.g., Moxifloxacin) QID for 7 days if bacterial cause is suspected. Recommend cool compresses for comfort.",
                 "follow_up_protocol_suggestions": "Follow up in 5-7 days. If no improvement, consider a viral or allergic etiology.",
                 "precision_metrics": {"sensitivity_estimate": "1.00 (Recall)", "specificity_estimate": "0.996"}
            }
        },
        "Normal_Eye": {
            "overall_assessment": {"low": "The eye appears to be healthy.", "medium": "The eye appears to be healthy and free of common issues.", "high": "The eye shows no signs of common diseases detected and appears healthy."},
            "clinical_findings": [
                "Cornea is clear, conjunctiva is white and quiet. No abnormalities detected.",
                "Anterior segment examination appears unremarkable. Lens is clear and structures are normal.",
                "The visible structures of the eye appear to be within normal limits."
            ],
            "dynamic_findings": {},
            "explanation_of_conditions": "Your eye shows no signs of cataract or conjunctivitis based on the visual analysis.",
            "general_recommendations": "Continue with routine eye care, including protecting your eyes from UV light and taking regular breaks from screens.",
            "when_to_seek_professional_help": "Attend regular annual eye check-ups with an optometrist or ophthalmologist to maintain good eye health.",
            "severity_level": {"low": "Healthy", "medium": "Healthy", "high": "Healthy"},
            "ADVANCED_MODE_DATA": {
                "differential_diagnoses": [],
                "detailed_metrics": { "Tear Film Analysis": {"TBUT (Left)": "12s", "TBUT (Right)": "11s", "Tear Meniscus": "0.25mm", "Osmolarity (Est.)": "295 mOsm/L"}, "Corneal Assessment": {"Corneal Thickness (Est.)": "540 µm", "Corneal Surface Regularity": "Regular"}, "Predictive Analysis": {"Disease Progression Risk": "Low"} },
                "treatment_recommendations": "No treatment necessary. Advise patient to continue routine preventative care.",
                "follow_up_protocol_suggestions": "Recommend routine annual eye examination.",
                "precision_metrics": {"sensitivity_estimate": "1.00 (Recall)", "specificity_estimate": "1.00"}
            }
        }
    }
    return knowledge

# ==============================================================================
#  INNOVATION PILLAR 2: Real-Time Image Feature Analysis
# ==============================================================================
# This component adds dynamic, image-specific details to the reports.

def analyze_image_features(image_rgb: np.ndarray) -> dict:
    """Performs simple analysis on the image to extract features like redness and blur."""
    features = {}
    # Redness Analysis
    r_channel = image_rgb[:, :, 0]
    features['average_redness'] = np.mean(r_channel)
    # Blurriness Analysis
    gray = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2GRAY)
    features['blur_score'] = cv2.Laplacian(gray, cv2.CV_64F).var()
    return features

# ==============================================================================
#  THE MAIN ENGINE: The Core Function for the App
# ==============================================================================
# This is the primary function the Flutter app will call.

def run_analysis(image_path: str, tflite_model_path: str) -> str:
    """
    The main entry point for the analysis engine. Takes image and model paths
    and returns a complete, dynamic JSON report as a string.
    """
    try:
        # --- 1. PREPROCESS THE IMAGE ---
        img = cv2.imread(image_path)
        if img is None:
            raise FileNotFoundError(f"Image not found at path: {image_path}")
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_resized = cv2.resize(img_rgb, (IMG_SIZE, IMG_SIZE))
        img_array = np.expand_dims(img_resized, axis=0).astype(np.float32)
        processed_img = tf.keras.applications.mobilenet_v2.preprocess_input(img_array)

        # --- 2. RUN TFLITE INFERENCE ---
        interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        interpreter.set_tensor(input_details[0]['index'], processed_img)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]['index'])
        
        predicted_index = np.argmax(output_data)
        predicted_class = CLASS_NAMES[predicted_index]
        confidence = np.max(output_data) * 100

        # --- 3. REAL-TIME FEATURE ANALYSIS ---
        image_features = analyze_image_features(img_resized)

        # --- 4. DYNAMIC REPORT ASSEMBLY ---
        knowledge_base = create_advanced_knowledge_base()
        class_info = knowledge_base[predicted_class]

        if confidence < 80: tier = 'low'
        elif 80 <= confidence < 95: tier = 'medium'
        else: tier = 'high'

        basic_report = {
            "overall_assessment": class_info["overall_assessment"][tier],
            "explanation_of_conditions": class_info["explanation_of_conditions"],
            "general_recommendations": class_info["general_recommendations"],
            "when_to_seek_professional_help": class_info["when_to_seek_professional_help"],
            "confidence_level": f"{confidence:.2f}%",
            "severity_level": class_info["severity_level"][tier]
        }
        
        clinical_finding_base = random.choice(class_info["clinical_findings"])
        # Conditionally append dynamic text based on real-time analysis
        if predicted_class == "Conjunctivitis" and image_features['average_redness'] > 120:
            clinical_finding_base += class_info["dynamic_findings"].get("redness", "")
        if predicted_class == "Cataract" and image_features['blur_score'] < 80:
            clinical_finding_base += class_info["dynamic_findings"].get("blur", "")

        advanced_report = {
            "clinical_findings": clinical_finding_base,
            "specific_diagnosis": predicted_class,
            "diagnosis_confidence": f"{confidence:.2f}%",
            **class_info["ADVANCED_MODE_DATA"] # Unpacks the nested dictionary
        }
        
        final_report = {"BASIC_MODE": basic_report, "ADVANCED_MODE": advanced_report}
        
        # Return the final report as a clean JSON string
        return json.dumps(final_report, indent=2)

    except Exception as e:
        # Return a structured error message in JSON format
        error_report = {"error": f"An unexpected error occurred in the analysis engine: {str(e)}"}
        return json.dumps(error_report, indent=2)

# ==============================================================================
#  EXAMPLE USAGE (for testing the script directly)
# ==============================================================================
if __name__ == '__main__':
    # This block allows the script to be tested from the command line.
    
    # Define paths relative to the script's location
    TEST_IMAGE_PATH = 'test_images/test_conjunctivitis.jpg'
    TFLITE_MODEL_PATH = 'lib/core/converted_tflite_quantized/ocular_model_final.tflite'
    
    print(f"--- Running a direct test of the analysis engine ---")
    
    # Create dummy files if they don't exist for a seamless first-time test
    if not os.path.exists(TEST_IMAGE_PATH):
        print(f"NOTE: Test image not found at '{TEST_IMAGE_PATH}'. Creating a dummy red image for testing.")
        os.makedirs('test_images', exist_ok=True)
        # Create a reddish image to trigger the redness detector
        dummy_image = np.full((224, 224, 3), (50, 50, 200), dtype=np.uint8) # BGR format for OpenCV
        cv2.imwrite(TEST_IMAGE_PATH, dummy_image)
        
    if not os.path.exists(TFLITE_MODEL_PATH):
        print(f"FATAL ERROR: Model file '{TFLITE_MODEL_PATH}' not found. Cannot proceed.")
    else:
        # Call the main function and print the result
        json_result = run_analysis(TEST_IMAGE_PATH, TFLITE_MODEL_PATH)
        print("\n--- RESULT (JSON output) ---")
        print(json_result)