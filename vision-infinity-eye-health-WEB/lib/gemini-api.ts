const GEMINI_API_KEY = "AIzaSyDyhUhn4VrgUBzqZAXPuOgV5m2LQX6xnFc"
const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

export async function analyzeEyeImage(imageBase64: string): Promise<string> {
  try {
    // Enhance the prompt to ensure accurate health assessments and concise summaries

    const prompt = `Act as an ophthalmologist and analyze this eye image to detect any possible eye diseases or conditions. 
  
Please structure your response in two distinct sections:

1. BASIC MODE (for patients):
- Overall assessment in simple, non-technical language as a complete sentence that clearly identifies any condition present
- Brief explanation of any detected conditions
- General recommendations and lifestyle advice
- When to seek professional help
- Confidence level (as a percentage) of your assessment
- Clearly state the severity level (Healthy, Mild Concern, Moderate Concern, Severe Concern, or Critical)

2. ADVANCED MODE (for healthcare professionals):
- Detailed clinical findings
- Specific diagnosis with confidence level (as a percentage)
- Differential diagnoses to consider
- Detailed metrics (e.g., cup-to-disc ratio, vessel characteristics, etc.)
- Treatment recommendations with specific interventions
- Follow-up protocol suggestions
- Precision metrics (sensitivity/specificity estimates)

For both sections, include clear recommendations based on your findings.

Important: 
- Always include a confidence percentage (0-100%) for your assessment in both modes
- Be honest about limitations in image quality or diagnostic certainty
- If you detect any abnormality, even minor, clearly indicate it as a concern
- Use appropriate severity terminology (Healthy, Mild Concern, Moderate Concern, Severe Concern, or Critical)
- Only use "Healthy" or "Good" status with green indicators when the eye is completely normal
- Do not downplay potential issues - err on the side of caution
- Provide the overall assessment as a complete sentence without ellipses`

    const requestBody = {
      contents: [
        {
          parts: [
            { text: prompt },
            {
              inline_data: {
                mime_type: "image/jpeg",
                data: imageBase64,
              },
            },
          ],
        },
      ],
    }

    const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(requestBody),
    })

    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`)
    }

    const data = await response.json()

    // Extract the text from the response
    if (data.candidates && data.candidates[0] && data.candidates[0].content && data.candidates[0].content.parts) {
      return data.candidates[0].content.parts[0].text
    } else {
      throw new Error("Unexpected API response format")
    }
  } catch (error) {
    console.error("Error analyzing eye image:", error)
    throw error
  }
}

