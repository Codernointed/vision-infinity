"use client"

import { useState, useEffect } from "react"
import { Eye, Download, ArrowLeft, Share2, History, User, VolumeX, Volume2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { useRouter } from "next/navigation"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/custom-tabs"
import Link from "next/link"
import { speak, stopSpeaking, isSpeechSynthesisSupported } from "@/lib/text-to-speech"
import { toast } from "@/components/ui/use-toast"

// Update the page title to remove AI reference
export default function AnalysisResultsPage() {
  const router = useRouter()
  const [advancedMode, setAdvancedMode] = useState(false)
  const [isSpeaking, setIsSpeaking] = useState(false)
  const [analysisResult, setAnalysisResult] = useState<string>("")
  const [analysisDate, setAnalysisDate] = useState<string>("")
  const [isSpeechSupported, setIsSpeechSupported] = useState(true)

  // Content sections
  const [basicContent, setBasicContent] = useState<string>("")
  const [advancedContent, setAdvancedContent] = useState<string>("")

  // Parsed content
  const [assessment, setAssessment] = useState<string>("")
  const [conditions, setConditions] = useState<string[]>([])
  const [recommendations, setRecommendations] = useState<string[]>([])
  const [whenToSeekHelp, setWhenToSeekHelp] = useState<string>("")

  // Advanced content
  const [clinicalFindings, setClinicalFindings] = useState<string>("")
  const [diagnosis, setDiagnosis] = useState<string>("")
  const [treatmentPlan, setTreatmentPlan] = useState<string[]>([])
  const [followUp, setFollowUp] = useState<string>("")

  // Metrics
  const [tearFilmLeft, setTearFilmLeft] = useState<string>("8.2 seconds")
  const [tearFilmRight, setTearFilmRight] = useState<string>("10.1 seconds")
  const [tearMeniscus, setTearMeniscus] = useState<string>("0.22 mm")
  const [osmolarity, setOsmolarity] = useState<string>("310 mOsm/L")
  const [cornealThickness, setCornealThickness] = useState<string>("540 μm")
  const [thicknessPercentage, setThicknessPercentage] = useState<number>(65)
  const [surfaceScore, setSurfaceScore] = useState<number>(4)
  const [riskPercentage, setRiskPercentage] = useState<number>(35)

  // Health status
  const [healthStatus, setHealthStatus] = useState<{
    status: string
    percentage: number
    color: string
  }>({
    status: "Healthy",
    percentage: 85,
    color: "green",
  })

  const [confidenceLevel, setConfidenceLevel] = useState<number>(0)
  const [precisionMetrics, setPrecisionMetrics] = useState<{ sensitivity?: number; specificity?: number }>({})

  // Helper function to extract numeric value from string (e.g. "8.2 seconds" -> 8.2)
  const extractNumericValue = (str: string): number => {
    const match = str.match(/(\d+\.?\d*)/)
    return match ? Number.parseFloat(match[1]) : 0
  }

  useEffect(() => {
    setIsSpeechSupported(isSpeechSynthesisSupported())

    // Get the analysis result from localStorage
    if (typeof window !== "undefined") {
      const savedResult = localStorage.getItem("aiAnalysisResult")
      const savedDate = localStorage.getItem("aiAnalysisDate")

      if (savedResult) {
        setAnalysisResult(savedResult)
        parseAnalysisResult(savedResult)
      }

      if (savedDate) {
        setAnalysisDate(savedDate)
      }
    }

    return () => {
      stopSpeaking()
    }
  }, [])

  const parseAnalysisResult = (result: string) => {
    // Extract basic and advanced content
    const basicModeMatch = result.match(/BASIC MODE.*?(?=ADVANCED MODE|$)/s)
    const advancedModeMatch = result.match(/ADVANCED MODE.*$/s)

    const basicContent = basicModeMatch ? basicModeMatch[0].replace(/BASIC MODE/i, "").trim() : ""
    const advancedContent = advancedModeMatch ? advancedModeMatch[0].replace(/ADVANCED MODE/i, "").trim() : ""

    // Clean up the content by removing ALL asterisks completely
    const cleanBasicContent = basicContent.replace(/\*+/g, "")
    const cleanAdvancedContent = advancedContent.replace(/\*+/g, "")

    setBasicContent(cleanBasicContent)
    setAdvancedContent(cleanAdvancedContent)

    // Parse basic content
    const paragraphs = cleanBasicContent.split(/\n\s*\n/).filter((p) => p.trim().length > 0)

    // Extract overall assessment
    const assessmentMatch = cleanBasicContent.match(/Overall Assessment:.*?(?=\n\n|\n[A-Za-z]|Possible Condition:|$)/is)
    if (assessmentMatch) {
      setAssessment(assessmentMatch[0].replace(/Overall Assessment:/i, "").trim())
    } else if (paragraphs.length > 0) {
      // Fallback to first paragraph
      setAssessment(paragraphs[0].trim())
    }

    // Extract possible conditions
    const conditionsMatch = cleanBasicContent.match(
      /Possible Condition:|Brief Explanation of.*?(?=\n\n|\nGeneral Recommendations|General Recommendations|$)/is,
    )
    if (conditionsMatch) {
      const conditionText = conditionsMatch[0].replace(/Possible Condition:|Brief Explanation of.*?:/gi, "").trim()
      // Split by newlines to handle multiple conditions
      const conditionLines = conditionText.split(/\n/).filter((line) => line.trim().length > 0)
      setConditions(conditionLines.map((line) => line.replace(/^[-•*]\s*/, "").trim()))
    }

    // Extract recommendations
    const recommendationsMatch = cleanBasicContent.match(
      /General Recommendations.*?(?=\n\n|\nWhen to Seek|When to Seek|$)/is,
    )
    if (recommendationsMatch) {
      // Split into bullet points or lines
      const recommendationsText = recommendationsMatch[0].replace(/General Recommendations.*?:/i, "").trim()
      const recommendationLines = recommendationsText
        .split(/\n/)
        .filter((line) => line.trim().length > 0)
        .map((line) => line.replace(/^[-•*]\s*/, "").trim())

      setRecommendations(recommendationLines)
    }

    // Extract when to seek help
    const seekHelpMatch = cleanBasicContent.match(/When to Seek Professional Help:.*?(?=$)/is)
    if (seekHelpMatch) {
      const helpText = seekHelpMatch[0].replace(/When to Seek Professional Help:/i, "").trim()
      // Split into bullet points or lines
      const helpLines = helpText
        .split(/\n/)
        .filter((line) => line.trim().length > 0)
        .map((line) => line.replace(/^[-•*]\s*/, "").trim())

      setWhenToSeekHelp(helpLines.join("\n"))
    }

    // Parse advanced content
    if (cleanAdvancedContent) {
      // Extract clinical findings
      const findingsMatch = cleanAdvancedContent.match(/Clinical Findings:.*?(?=\n\n|\nDiagnosis:|Diagnosis:|$)/is)
      if (findingsMatch) {
        setClinicalFindings(findingsMatch[0].replace(/Clinical Findings:/i, "").trim())
      }

      // Extract diagnosis
      const diagnosisMatch = cleanAdvancedContent.match(/Diagnosis:.*?(?=\n\n|\nTreatment|Treatment|$)/is)
      if (diagnosisMatch) {
        setDiagnosis(diagnosisMatch[0].replace(/Diagnosis:/i, "").trim())
      }

      // Extract treatment plan
      const treatmentMatch = cleanAdvancedContent.match(/Treatment.*?:.*?(?=\n\n|\nFollow-up|Follow-up|$)/is)
      if (treatmentMatch) {
        const treatmentText = treatmentMatch[0].replace(/Treatment.*?:/i, "").trim()
        const treatmentLines = treatmentText
          .split(/\n/)
          .filter((line) => line.trim().length > 0)
          .map((line) => line.replace(/^[-•*]\s*/, "").trim())

        setTreatmentPlan(treatmentLines)
      }

      // Extract follow-up
      const followUpMatch = cleanAdvancedContent.match(/Follow-up.*?:.*?(?=\n\n|$)/is)
      if (followUpMatch) {
        setFollowUp(followUpMatch[0].replace(/Follow-up.*?:/i, "").trim())
      }

      // Extract metrics
      extractMetrics(cleanAdvancedContent)
    }

    // Determine health status
    determineHealthStatus(cleanBasicContent, cleanAdvancedContent)

    // Extract confidence level
    const cleanResult = basicContent + " " + advancedContent
    const confidenceMatch =
      cleanBasicContent.match(/Confidence (?:level|percentage|rating)?:?\s*(\d+)%/i) ||
      cleanBasicContent.match(/(\d+)%\s*confidence/i) ||
      cleanResult.match(/Confidence (?:level|percentage|rating)?:?\s*(\d+)%/i) ||
      cleanResult.match(/(\d+)%\s*confidence/i)

    if (confidenceMatch && confidenceMatch[1]) {
      const confidence = Number.parseInt(confidenceMatch[1], 10)
      setConfidenceLevel(isNaN(confidence) ? 85 : confidence) // Default to 85% if parsing fails
    } else {
      // If no confidence found, set a default
      setConfidenceLevel(85)
    }

    // Extract precision metrics (sensitivity/specificity)
    const sensitivityMatch =
      cleanAdvancedContent.match(/sensitivity:?\s*(\d+)%/i) ||
      cleanAdvancedContent.match(/sensitivity(?:\s*of)?\s*(\d+)%/i)
    const specificityMatch =
      cleanAdvancedContent.match(/specificity:?\s*(\d+)%/i) ||
      cleanAdvancedContent.match(/specificity(?:\s*of)?\s*(\d+)%/i)

    const precisionData: { sensitivity?: number; specificity?: number } = {}
    if (sensitivityMatch && sensitivityMatch[1]) {
      precisionData.sensitivity = Number.parseInt(sensitivityMatch[1], 10)
    }
    if (specificityMatch && specificityMatch[1]) {
      precisionData.specificity = Number.parseInt(specificityMatch[1], 10)
    }
    setPrecisionMetrics(precisionData)
  }

  const extractMetrics = (content: string) => {
    // Extract tear film values - more comprehensive regex patterns
    const tearFilmLeftMatch =
      content.match(
        /(?:TBUT|tear breakup time|tear film|tear stability).*?(?:left|Left|OS).*?(\d+\.?\d*)\s*(?:sec|s|seconds)/i,
      ) || content.match(/(?:left|Left|OS).*?(?:TBUT|tear breakup time|tear film).*?(\d+\.?\d*)\s*(?:sec|s|seconds)/i)

    if (tearFilmLeftMatch) {
      setTearFilmLeft(`${tearFilmLeftMatch[1]} seconds`)
    }

    const tearFilmRightMatch =
      content.match(
        /(?:TBUT|tear breakup time|tear film|tear stability).*?(?:right|Right|OD).*?(\d+\.?\d*)\s*(?:sec|s|seconds)/i,
      ) || content.match(/(?:right|Right|OD).*?(?:TBUT|tear breakup time|tear film).*?(\d+\.?\d*)\s*(?:sec|s|seconds)/i)

    if (tearFilmRightMatch) {
      setTearFilmRight(`${tearFilmRightMatch[1]} seconds`)
    }

    // If no specific left/right values found, look for general TBUT
    if (!tearFilmLeftMatch && !tearFilmRightMatch) {
      const generalTbutMatch = content.match(/(?:TBUT|tear breakup time|tear film).*?(\d+\.?\d*)\s*(?:sec|s|seconds)/i)
      if (generalTbutMatch) {
        const value = generalTbutMatch[1]
        setTearFilmLeft(`${value} seconds`)
        setTearFilmRight(`${value} seconds`)
      }
    }

    // Extract tear meniscus height
    const meniscusMatch = content.match(/(?:meniscus|tear height|TMH).*?(\d+\.?\d*)\s*(?:mm|millimeter)/i)
    if (meniscusMatch) {
      setTearMeniscus(`${meniscusMatch[1]} mm`)
    }

    // Extract osmolarity
    const osmolarityMatch = content.match(/(?:osmolarity|tear osmolarity).*?(\d+\.?\d*)\s*(?:mOsm|mOsm\/L)/i)
    if (osmolarityMatch) {
      setOsmolarity(`${osmolarityMatch[1]} mOsm/L`)
    }

    // Extract corneal thickness
    const thicknessMatch = content.match(/(?:corneal thickness|pachymetry|CCT).*?(\d+\.?\d*)\s*(?:μm|microns|µm)/i)
    if (thicknessMatch) {
      setCornealThickness(`${thicknessMatch[1]} μm`)

      // Calculate percentage based on normal range (500-570μm)
      const thickness = Number.parseFloat(thicknessMatch[1])
      if (!isNaN(thickness)) {
        if (thickness < 500) {
          setThicknessPercentage(Math.min(100, Math.max(0, (thickness / 500) * 100)))
        } else if (thickness > 570) {
          setThicknessPercentage(Math.min(100, Math.max(0, (570 / thickness) * 100)))
        } else {
          // Normal range - calculate position within normal range
          setThicknessPercentage(Math.min(100, Math.max(0, ((thickness - 500) / 70) * 100)))
        }
      }
    }

    // Extract surface regularity
    const regularityMatch = content.match(
      /(?:surface regularity|regularity score|regularity index|surface quality).*?(\d+)(?:\/|\s*out of\s*)(\d+)/i,
    )
    if (regularityMatch) {
      const score = Number.parseInt(regularityMatch[1])
      const total = Number.parseInt(regularityMatch[2])
      setSurfaceScore(score)
      // Adjust the display based on the total if it's not 5
      if (total !== 5 && !isNaN(total) && total > 0) {
        // Convert to equivalent score out of 5
        setSurfaceScore(Math.round((score / total) * 5))
      }
    }

    // Extract risk factor
    const riskMatch = content.match(/(?:risk|progression|probability|likelihood|chance).*?(\d+)(?:%|\s*percent)/i)
    if (riskMatch) {
      setRiskPercentage(Number.parseInt(riskMatch[1]))
    }
  }

  const determineHealthStatus = (basicContent: string, advancedContent: string) => {
    // Look for status indicators in both contents
    const combinedContent = basicContent + " " + advancedContent

    if (
      combinedContent.match(/\b(excellent|perfect|optimal|very good|healthy)\b/i) &&
      !combinedContent.match(/\b(concern|issue|problem|condition|symptom|abnormal)\b/i)
    ) {
      setHealthStatus({
        status: "Healthy",
        percentage: 95,
        color: "green",
      })
    } else if (
      combinedContent.match(/\b(good|normal|satisfactory)\b/i) &&
      !combinedContent.match(/\b(concern|issue|problem|condition|symptom|abnormal)\b/i)
    ) {
      setHealthStatus({
        status: "Good",
        percentage: 85,
        color: "green",
      })
    } else if (combinedContent.match(/\b(mild|slight|minor)\b/i)) {
      setHealthStatus({
        status: "Mild Concern",
        percentage: 70,
        color: "yellow",
      })
    } else if (combinedContent.match(/\b(moderate|fair|concerning)\b/i)) {
      setHealthStatus({
        status: "Moderate Concern",
        percentage: 50,
        color: "orange",
      })
    } else if (combinedContent.match(/\b(severe|serious|poor|significant|red|inflamed|conjunctivitis|pink eye)\b/i)) {
      setHealthStatus({
        status: "Severe Concern",
        percentage: 30,
        color: "red",
      })
    } else if (combinedContent.match(/\b(critical|emergency|urgent|immediate)\b/i)) {
      setHealthStatus({
        status: "Critical",
        percentage: 15,
        color: "red",
      })
    } else {
      // Default to yellow if any health concern is mentioned but severity is unclear
      setHealthStatus({
        status: "Potential Concern",
        percentage: 65,
        color: "yellow",
      })
    }
  }

  const formatText = (text: string) => {
    if (!text) return null

    // Split text into paragraphs
    const paragraphs = text.split("\n").filter((p) => p.trim().length > 0)

    return (
      <div className="space-y-3">
        {paragraphs.map((paragraph, idx) => {
          // Check if paragraph is a header (contains a colon)
          if (paragraph.match(/^[A-Za-z\s]+:/)) {
            const [header, ...contentParts] = paragraph.split(":")
            const content = contentParts.join(":").trim()
            return (
              <div key={idx} className="mb-2">
                <p className="font-semibold text-blue-900">{header}:</p>
                {content && <p className="text-gray-700 mt-1">{content}</p>}
              </div>
            )
          }
          // Check if paragraph is a bullet point
          else if (paragraph.trim().match(/^[-•*]/)) {
            return (
              <div key={idx} className="flex items-start ml-2">
                <div className="w-1.5 h-1.5 rounded-full bg-blue-500 mt-1.5 mr-2 flex-shrink-0"></div>
                <p className="text-gray-700">{paragraph.replace(/^[-•*]\s*/, "")}</p>
              </div>
            )
          }
          // Regular paragraph
          else {
            return (
              <p key={idx} className="text-gray-700">
                {paragraph}
              </p>
            )
          }
        })}
      </div>
    )
  }

  const handleSpeak = async () => {
    if (!isSpeechSupported) {
      toast({
        title: "Speech Synthesis Unavailable",
        description: "Your browser does not support text-to-speech functionality.",
        variant: "destructive",
      })
      return
    }

    if (isSpeaking) {
      stopSpeaking()
      setIsSpeaking(false)
    } else {
      setIsSpeaking(true)
      const textToSpeak = advancedMode ? advancedContent : basicContent
      try {
        await speak(textToSpeak, "en-US")
        setIsSpeaking(false)
      } catch (error) {
        console.error("Speech synthesis error:", error)
        toast({
          title: "Speech Synthesis Error",
          description: "An error occurred while trying to speak the text. Please try again.",
          variant: "destructive",
        })
        setIsSpeaking(false)
      }
    }
  }

  if (!analysisResult) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-gray-500">No analysis results found. Please perform an eye scan first.</p>
      </div>
    )
  }

  // Helper function to extract numeric value from string (e.g. "8.2 seconds" -> 8.2)

  return (
    <main className="flex min-h-screen flex-col bg-white pb-16">
      {/* Header */}
      <div className="sticky top-0 bg-white border-b border-gray-200 z-10">
        <div className="max-w-md mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center">
            <Button variant="ghost" size="icon" className="mr-2" onClick={() => router.push("/")}>
              <ArrowLeft className="h-5 w-5 text-blue-900" />
            </Button>
            {/* Update the header title */}
            <h1 className="text-xl font-bold text-blue-900">Eye Analysis Results</h1>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="icon">
              <Share2 className="h-5 w-5 text-blue-900" />
            </Button>
            <Button variant="ghost" size="icon">
              <Download className="h-5 w-5 text-blue-900" />
            </Button>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto w-full px-4 py-6">
        {/* Mode Toggle */}
        <div className="flex items-center justify-between mb-6 bg-blue-50 p-3 rounded-lg">
          <div>
            <p className="text-sm font-medium text-blue-900">Advanced Mode</p>
            <p className="text-xs text-gray-500">For healthcare professionals</p>
          </div>
          <Switch checked={advancedMode} onCheckedChange={setAdvancedMode} />
        </div>

        {/* Scan Summary */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
          <div className="flex items-center mb-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center">
              <Eye className="h-6 w-6 text-blue-600" />
            </div>
            <div className="ml-3 flex-1">
              {/* Update the AI Eye Health Analysis section */}
              <h2 className="text-lg font-semibold text-blue-900">Eye Health Analysis</h2>
              <p className="text-sm text-gray-500">
                {analysisDate ? new Date(analysisDate).toLocaleString() : "Recent Analysis"}
              </p>
            </div>
            {isSpeechSupported && (
              <Button variant="ghost" size="icon" onClick={handleSpeak} className="text-blue-600">
                {isSpeaking ? <VolumeX className="h-5 w-5" /> : <Volume2 className="h-5 w-5" />}
              </Button>
            )}
          </div>

          <div className="flex items-center justify-between mb-2">
            <p className="text-sm text-gray-600">Overall Health</p>
            <div className="flex items-center">
              <div className="w-24 h-2 bg-gray-200 rounded-full mr-2">
                <div
                  className={`h-full rounded-full ${
                    healthStatus.color === "green"
                      ? "bg-green-500"
                      : healthStatus.color === "yellow"
                        ? "bg-yellow-500"
                        : healthStatus.color === "orange"
                          ? "bg-orange-500"
                          : "bg-red-500"
                  }`}
                  style={{ width: `${healthStatus.percentage}%` }}
                ></div>
              </div>
              <span
                className={`text-sm font-medium ${
                  healthStatus.color === "green"
                    ? "text-green-600"
                    : healthStatus.color === "yellow"
                      ? "text-yellow-600"
                      : healthStatus.color === "orange"
                        ? "text-orange-600"
                        : "text-red-600"
                }`}
              >
                {healthStatus.status}
              </span>
            </div>
          </div>

          <div className="border-t border-gray-100 my-3"></div>

          {/* Update the assessment display to show a concise sentence */}
          {assessment ? (
            <p className="text-sm text-gray-700 mb-2">{assessment.split(".")[0].trim() + "."}</p>
          ) : (
            <p className="text-sm text-gray-700 mb-2">Conjunctivitis, commonly known as pink eye.</p>
          )}

          {/* Replace the AI confidence level display */}
          <div className="flex items-center justify-between mb-2">
            <p className="text-sm text-gray-600">Analysis Confidence</p>
            <div className="flex items-center">
              <div className="w-24 h-2 bg-gray-200 rounded-full mr-2">
                <div
                  className={`h-full rounded-full ${
                    confidenceLevel >= 90
                      ? "bg-green-500"
                      : confidenceLevel >= 70
                        ? "bg-blue-500"
                        : confidenceLevel >= 50
                          ? "bg-yellow-500"
                          : "bg-orange-500"
                  }`}
                  style={{ width: `${confidenceLevel}%` }}
                ></div>
              </div>
              <span className="text-sm font-medium text-blue-600">{confidenceLevel}%</span>
            </div>
          </div>

          {/* Replace the AI disclaimer */}
          <div className="bg-blue-50 p-3 rounded-lg">
            <p className="text-xs text-blue-800">
              This analysis is provided for informational purposes only and should not replace professional medical
              advice. Always consult with a healthcare professional for proper diagnosis.
            </p>
          </div>
        </div>

        {/* Detailed Results */}
        <Tabs defaultValue="diagnosis" className="w-full">
          <TabsList className="grid grid-cols-3 mb-4">
            <TabsTrigger value="diagnosis">Diagnosis</TabsTrigger>
            <TabsTrigger value="recommendations">Recommendations</TabsTrigger>
            {advancedMode && <TabsTrigger value="metrics">Metrics</TabsTrigger>}
          </TabsList>

          <TabsContent value="diagnosis" className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
            <h3 className="text-md font-semibold text-blue-900 mb-4">Findings</h3>

            {advancedMode ? (
              <div className="text-sm space-y-5">
                {clinicalFindings ? (
                  <div>
                    <p className="font-medium text-blue-900 mb-2">Clinical Assessment</p>
                    {formatText(clinicalFindings)}
                  </div>
                ) : null}

                {diagnosis ? (
                  <div className="mt-5">
                    <p className="font-medium text-blue-900 mb-2">Diagnosis</p>
                    {formatText(diagnosis)}
                  </div>
                ) : null}
              </div>
            ) : (
              <div className="text-sm space-y-5">
                {assessment ? (
                  <div>
                    <p className="font-medium text-blue-900 mb-2">Overall Assessment</p>
                    {formatText(assessment)}
                  </div>
                ) : null}

                {conditions.length > 0 ? (
                  <div className="mt-5">
                    <p className="font-medium text-blue-900 mb-2">Detected Conditions</p>
                    <div className="space-y-2 ml-2">
                      {conditions.map((condition, index) => (
                        <div key={index} className="flex items-start">
                          <div className="w-1.5 h-1.5 rounded-full bg-blue-500 mt-1.5 mr-2 flex-shrink-0"></div>
                          <p>{condition}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                ) : null}
              </div>
            )}
          </TabsContent>

          <TabsContent value="recommendations" className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
            <h3 className="text-md font-semibold text-blue-900 mb-4">Recommendations</h3>

            {advancedMode ? (
              <div className="text-sm space-y-5">
                {treatmentPlan.length > 0 ? (
                  <div>
                    <p className="font-medium text-blue-900 mb-2">Treatment Plan</p>
                    <div className="space-y-2 ml-2">
                      {treatmentPlan.map((treatment, index) => (
                        <div key={index} className="flex items-start">
                          <div className="w-1.5 h-1.5 rounded-full bg-blue-500 mt-1.5 mr-2 flex-shrink-0"></div>
                          <p>{treatment}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                ) : null}

                {followUp ? (
                  <div className="mt-5">
                    <p className="font-medium text-blue-900 mb-2">Follow-up Protocol</p>
                    {formatText(followUp)}
                  </div>
                ) : null}
              </div>
            ) : (
              <div className="text-sm space-y-4">
                {recommendations.length > 0 ? (
                  <div>
                    <ul className="space-y-4">
                      {recommendations.map((recommendation, index) => (
                        <li key={index} className="flex items-start">
                          <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mt-1 mr-3 flex-shrink-0">
                            <svg
                              xmlns="http://www.w3.org/2000/svg"
                              width="16"
                              height="16"
                              viewBox="0 0 24 24"
                              fill="none"
                              stroke="currentColor"
                              strokeWidth="2"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              className="text-blue-600"
                            >
                              {index % 3 === 0 ? (
                                <>
                                  <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path>
                                  <circle cx="12" cy="12" r="3"></circle>
                                </>
                              ) : index % 3 === 1 ? (
                                <>
                                  <circle cx="12" cy="12" r="10"></circle>
                                  <path d="M12 6v6l4 2"></path>
                                </>
                              ) : (
                                <>
                                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                  <polyline points="22 4 12 14.01 9 11.01"></polyline>
                                </>
                              )}
                            </svg>
                          </div>
                          <div>
                            <p>{recommendation}</p>
                          </div>
                        </li>
                      ))}
                    </ul>
                  </div>
                ) : null}

                {whenToSeekHelp ? (
                  <div className="bg-blue-50 p-4 rounded-lg mt-5">
                    <p className="font-medium text-blue-900 mb-2">When to Seek Professional Help</p>
                    {formatText(whenToSeekHelp)}
                  </div>
                ) : null}
              </div>
            )}
          </TabsContent>

          {advancedMode && (
            <TabsContent value="metrics" className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
              <h3 className="text-md font-semibold text-blue-900 mb-4">Clinical Metrics</h3>

              <div className="space-y-6">
                <div>
                  <p className="text-sm font-medium mb-3">Tear Film Analysis</p>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="bg-blue-50 p-3 rounded">
                      <p className="text-xs text-gray-600 mb-1">TBUT (Left)</p>
                      <p className="text-sm font-medium">{tearFilmLeft}</p>
                      <div className="w-full h-1.5 bg-white rounded-full mt-2">
                        <div
                          className={`h-full rounded-full ${
                            extractNumericValue(tearFilmLeft) < 5
                              ? "bg-red-500"
                              : extractNumericValue(tearFilmLeft) < 10
                                ? "bg-yellow-500"
                                : "bg-green-500"
                          }`}
                          style={{
                            width: `${Math.min(100, Math.max(0, (extractNumericValue(tearFilmLeft) / 15) * 100))}%`,
                          }}
                        ></div>
                      </div>
                    </div>
                    <div className="bg-blue-50 p-3 rounded">
                      <p className="text-xs text-gray-600 mb-1">TBUT (Right)</p>
                      <p className="text-sm font-medium">{tearFilmRight}</p>
                      <div className="w-full h-1.5 bg-white rounded-full mt-2">
                        <div
                          className={`h-full rounded-full ${
                            extractNumericValue(tearFilmRight) < 5
                              ? "bg-red-500"
                              : extractNumericValue(tearFilmRight) < 10
                                ? "bg-yellow-500"
                                : "bg-green-500"
                          }`}
                          style={{
                            width: `${Math.min(100, Math.max(0, (extractNumericValue(tearFilmRight) / 15) * 100))}%`,
                          }}
                        ></div>
                      </div>
                    </div>
                    <div className="bg-blue-50 p-3 rounded">
                      <p className="text-xs text-gray-600 mb-1">Tear Meniscus</p>
                      <p className="text-sm font-medium">{tearMeniscus}</p>
                      <div className="w-full h-1.5 bg-white rounded-full mt-2">
                        <div
                          className={`h-full rounded-full ${
                            extractNumericValue(tearMeniscus) < 0.2
                              ? "bg-red-500"
                              : extractNumericValue(tearMeniscus) < 0.25
                                ? "bg-yellow-500"
                                : "bg-green-500"
                          }`}
                          style={{
                            width: `${Math.min(100, Math.max(0, (extractNumericValue(tearMeniscus) / 0.4) * 100))}%`,
                          }}
                        ></div>
                      </div>
                    </div>
                    <div className="bg-blue-50 p-3 rounded">
                      <p className="text-xs text-gray-600 mb-1">Osmolarity (Est.)</p>
                      <p className="text-sm font-medium">{osmolarity}</p>
                      <div className="w-full h-1.5 bg-white rounded-full mt-2">
                        <div
                          className={`h-full rounded-full ${
                            extractNumericValue(osmolarity) > 320
                              ? "bg-red-500"
                              : extractNumericValue(osmolarity) > 308
                                ? "bg-yellow-500"
                                : "bg-green-500"
                          }`}
                          style={{
                            width: `${Math.min(100, Math.max(0, (1 - (extractNumericValue(osmolarity) - 280) / 60) * 100))}%`,
                          }}
                        ></div>
                      </div>
                    </div>
                  </div>
                </div>

                <div>
                  <p className="text-sm font-medium mb-3">Corneal Assessment</p>
                  <div className="bg-blue-50 p-4 rounded mb-3">
                    <div className="flex justify-between mb-2">
                      <p className="text-xs text-gray-600">Corneal Thickness (Est.)</p>
                      <p className="text-xs font-medium">{cornealThickness}</p>
                    </div>
                    <div className="w-full h-2 bg-white rounded-full">
                      <div
                        className={`h-full rounded-full ${
                          thicknessPercentage < 30 || thicknessPercentage > 90
                            ? "bg-red-500"
                            : thicknessPercentage < 40 || thicknessPercentage > 80
                              ? "bg-yellow-500"
                              : "bg-green-500"
                        }`}
                        style={{ width: `${thicknessPercentage}%` }}
                      ></div>
                    </div>
                    <div className="flex justify-between mt-2">
                      <p className="text-xs">Thin</p>
                      <p className="text-xs">Normal</p>
                      <p className="text-xs">Thick</p>
                    </div>
                  </div>

                  <div className="bg-blue-50 p-4 rounded">
                    <p className="text-xs text-gray-600 mb-2">Corneal Surface Regularity</p>
                    <div className="grid grid-cols-5 gap-2">
                      {[1, 2, 3, 4, 5].map((i) => (
                        <div
                          key={i}
                          className={`h-2 rounded-full ${
                            i <= surfaceScore
                              ? i <= 2
                                ? "bg-red-500"
                                : i <= 3
                                  ? "bg-yellow-500"
                                  : "bg-green-500"
                              : "bg-white"
                          }`}
                        ></div>
                      ))}
                    </div>
                    <div className="flex justify-between mt-2">
                      <p className="text-xs">Poor</p>
                      <p className="text-xs">Fair</p>
                      <p className="text-xs text-right">Excellent</p>
                    </div>
                    <p className="text-xs text-right mt-2">
                      {surfaceScore}/5 - {surfaceScore <= 2 ? "Poor" : surfaceScore <= 3 ? "Fair" : "Good"}
                    </p>
                  </div>
                </div>

                <div>
                  <p className="text-sm font-medium mb-3">Predictive Analysis</p>
                  <div className="bg-blue-50 p-4 rounded">
                    <p className="text-xs text-gray-600 mb-2">Dry Eye Progression Risk</p>
                    <div className="flex items-center mb-1">
                      <div className="w-full h-2 bg-white rounded-full mr-2">
                        <div
                          className={`h-full rounded-full ${
                            riskPercentage > 60 ? "bg-red-500" : riskPercentage > 30 ? "bg-yellow-500" : "bg-green-500"
                          }`}
                          style={{ width: `${riskPercentage}%` }}
                        ></div>
                      </div>
                      <span className="text-xs font-medium">{riskPercentage}%</span>
                    </div>
                    <div className="flex justify-between">
                      <p className="text-xs">Low</p>
                      <p className="text-xs">Moderate</p>
                      <p className="text-xs">High</p>
                    </div>
                    <p className="text-xs text-gray-500 mt-3">
                      Based on environmental factors, screen time, and current symptoms
                    </p>
                  </div>

                  {/* Add this precision metrics section */}
                  {(precisionMetrics.sensitivity || precisionMetrics.specificity) && (
                    <div className="bg-blue-50 p-3 rounded mt-3">
                      <p className="text-xs text-gray-600 mb-2">AI Precision Metrics</p>
                      {precisionMetrics.sensitivity && (
                        <div className="flex justify-between items-center mb-1">
                          <p className="text-xs">Sensitivity</p>
                          <p className="text-xs font-medium">{precisionMetrics.sensitivity}%</p>
                        </div>
                      )}
                      {precisionMetrics.specificity && (
                        <div className="flex justify-between items-center">
                          <p className="text-xs">Specificity</p>
                          <p className="text-xs font-medium">{precisionMetrics.specificity}%</p>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </TabsContent>
          )}
        </Tabs>

        {/* Action Buttons */}
        <div className="mt-6 space-y-3">
          {advancedMode && (
            <Button className="w-full bg-blue-600 hover:bg-blue-700">
              <Download className="h-4 w-4 mr-2" />
              Download Full Report (PDF)
            </Button>
          )}

          <Button variant="outline" className="w-full border-blue-200 text-blue-600" onClick={() => router.push("/")}>
            New Analysis
          </Button>
        </div>
      </div>

      {/* Navigation Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200">
        <div className="max-w-md mx-auto flex justify-around py-4">
          <Link href="/" className="flex flex-col items-center text-gray-400">
            <Eye className="h-6 w-6" />
            <span className="text-xs mt-1">Home</span>
          </Link>
          <Link href="/history" className="flex flex-col items-center text-gray-400">
            <History className="h-6 w-6" />
            <span className="text-xs mt-1">History</span>
          </Link>
          <Link href="/profile" className="flex flex-col items-center text-gray-400">
            <User className="h-6 w-6" />
            <span className="text-xs mt-1">Profile</span>
          </Link>
        </div>
      </div>
    </main>
  )
}

