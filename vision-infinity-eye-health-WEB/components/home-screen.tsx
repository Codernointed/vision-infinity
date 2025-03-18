"use client"

import { useState, useEffect } from "react"
import { Bell, Eye, History, User, AlertCircle, Upload, BarChart2 } from "lucide-react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import ScanModal from "./scan-modal"
import EyeImageUpload from "./eye-image-upload"
import { Button } from "./ui/button"
import { Switch } from "./ui/switch"

export default function HomeScreen() {
  const router = useRouter()
  const [mode, setMode] = useState<"standard" | "advanced">("standard")
  const [isScanModalOpen, setIsScanModalOpen] = useState(false)
  const [lastScanDate, setLastScanDate] = useState<string | null>(null)
  const [eyeHealth, setEyeHealth] = useState<number>(98)
  const [analysisResult, setAnalysisResult] = useState<string>("")
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [showAnalysisResults, setShowAnalysisResults] = useState(false)

  // Extracted summary data
  const [healthStatus, setHealthStatus] = useState<string>("Healthy")
  const [healthColor, setHealthColor] = useState<string>("green")
  const [briefSummary, setBriefSummary] = useState<string>("")
  const [confidenceLevel, setConfidenceLevel] = useState<number>(0)

  useEffect(() => {
    // Check for saved analysis on component mount
    if (typeof window !== "undefined") {
      const savedResult = localStorage.getItem("aiAnalysisResult")
      const savedDate = localStorage.getItem("aiAnalysisDate")

      if (savedResult) {
        setAnalysisResult(savedResult)
        extractSummaryFromAnalysis(savedResult)
        setShowAnalysisResults(true)
      }

      if (savedDate) {
        setLastScanDate(savedDate)

        // Update eye health based on last scan date
        const lastScanTime = new Date(savedDate).getTime()
        const now = new Date().getTime()
        const daysSinceLastScan = Math.floor((now - lastScanTime) / (1000 * 60 * 60 * 24))

        // Gradually decrease eye health score if it's been a while since last scan
        if (daysSinceLastScan > 30) {
          setEyeHealth(Math.max(70, 98 - Math.floor(daysSinceLastScan / 10)))
        }
      }
    }
  }, [])

  const handleStartScan = () => {
    setIsScanModalOpen(true)
  }

  const handleModeChange = (checked: boolean) => {
    setMode(checked ? "advanced" : "standard")
  }

  // Update the function name to remove AI reference
  const handleAnalysisComplete = (result: string) => {
    setAnalysisResult(result)
    if (result) {
      // Save the analysis result to localStorage
      if (typeof window !== "undefined") {
        localStorage.setItem("aiAnalysisResult", result) // Keep using the original key for compatibility
        localStorage.setItem("aiAnalysisDate", new Date().toISOString())
      }
      extractSummaryFromAnalysis(result)
      setShowAnalysisResults(true)
    }
  }

  const handleAnalysisStart = () => {
    setIsAnalyzing(true)
    setShowAnalysisResults(false)
  }

  const handleViewFullResults = () => {
    router.push("/results/analysis")
  }

  // Update the extractSummaryFromAnalysis function to create a concise summary
  const extractSummaryFromAnalysis = (result: string) => {
    // Remove all asterisks
    const cleanResult = result.replace(/\*+/g, "")

    // Extract basic mode content
    const basicModeMatch = cleanResult.match(/BASIC MODE.*?(?=ADVANCED MODE|$)/s)
    const basicContent = basicModeMatch ? basicModeMatch[0].replace(/BASIC MODE/i, "").trim() : ""

    // Extract overall assessment
    const assessmentMatch = basicContent.match(/Overall Assessment:.*?(?=\n\n|\n[A-Za-z]|Possible Condition:|$)/is)
    let assessment = ""
    if (assessmentMatch) {
      assessment = assessmentMatch[0].replace(/Overall Assessment:/i, "").trim()
      // Get first complete sentence
      const firstSentence = assessment.split(".")[0] + "."
      assessment = firstSentence
    }

    // Extract confidence level
    const confidenceMatch =
      basicContent.match(/Confidence (?:level|percentage|rating)?:?\s*(\d+)%/i) ||
      basicContent.match(/(\d+)%\s*confidence/i) ||
      cleanResult.match(/Confidence (?:level|percentage|rating)?:?\s*(\d+)%/i) ||
      cleanResult.match(/(\d+)%\s*confidence/i)

    if (confidenceMatch && confidenceMatch[1]) {
      const confidence = Number.parseInt(confidenceMatch[1], 10)
      setConfidenceLevel(isNaN(confidence) ? 85 : confidence) // Default to 85% if parsing fails
    } else {
      // If no confidence found, set a default
      setConfidenceLevel(85)
    }

    // Set brief summary
    setBriefSummary(assessment)

    // Determine health status with better color coding
    if (
      cleanResult.match(/\b(excellent|perfect|optimal|very good|healthy)\b/i) &&
      !cleanResult.match(/\b(concern|issue|problem|condition|symptom|abnormal)\b/i)
    ) {
      setHealthStatus("Healthy")
      setHealthColor("green")
    } else if (
      cleanResult.match(/\b(good|normal|satisfactory)\b/i) &&
      !cleanResult.match(/\b(concern|issue|problem|condition|symptom|abnormal)\b/i)
    ) {
      setHealthStatus("Good")
      setHealthColor("green")
    } else if (cleanResult.match(/\b(mild|slight|minor)\b/i)) {
      setHealthStatus("Mild Concern")
      setHealthColor("yellow")
    } else if (cleanResult.match(/\b(moderate|fair|concerning)\b/i)) {
      setHealthStatus("Moderate Concern")
      setHealthColor("orange")
    } else if (cleanResult.match(/\b(severe|serious|poor|significant|red|inflamed|conjunctivitis|pink eye)\b/i)) {
      setHealthStatus("Severe Concern")
      setHealthColor("red")
    } else if (cleanResult.match(/\b(critical|emergency|urgent|immediate)\b/i)) {
      setHealthStatus("Critical")
      setHealthColor("red")
    } else {
      // Default to yellow if any health concern is mentioned but severity is unclear
      setHealthStatus("Potential Concern")
      setHealthColor("yellow")
    }
  }

  // Function to get confidence level color
  const getConfidenceColor = (level: number) => {
    if (level >= 90) return "text-green-600"
    if (level >= 70) return "text-blue-600"
    if (level >= 50) return "text-yellow-600"
    return "text-orange-600"
  }

  return (
    <div className="flex flex-col h-screen max-w-md mx-auto w-full bg-gray-50">
      {/* Header */}
      <header className="flex items-center justify-between px-4 py-3 bg-white shadow-sm">
        <div className="flex items-center">
          <Eye className="h-6 w-6 text-blue-600" />
          <span className="ml-2 text-lg font-semibold text-blue-900">Vision∞</span>
        </div>
        <div className="flex items-center space-x-4">
          <Button variant="ghost" size="icon" className="text-blue-600">
            <Bell className="h-5 w-5" />
          </Button>
          <Link href="/profile">
            <Button variant="ghost" size="icon" className="text-blue-600">
              <User className="h-5 w-5" />
            </Button>
          </Link>
        </div>
      </header>

      {/* Mode Toggle */}
      <div className="px-4 py-3 bg-white border-b border-gray-200">
        <div className="flex items-center justify-between">
          <span className="text-sm font-medium text-gray-700">Advanced Mode</span>
          <Switch checked={mode === "advanced"} onCheckedChange={handleModeChange} />
        </div>
        <p className="mt-1 text-xs text-gray-500">
          {mode === "advanced"
            ? "Access detailed metrics and professional features"
            : "Simple interface for quick scans and basic information"}
        </p>
      </div>

      {/* Main Content */}
      <div className="flex-1 px-4 py-6 overflow-y-auto">
        {!showAnalysisResults ? (
          <>
            {/* Scan Area */}
            <div className="bg-white rounded-3xl p-4 shadow-sm mb-6">
              <div className="relative aspect-[4/3] bg-gradient-to-br from-blue-900 to-blue-700 rounded-2xl overflow-hidden">
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="relative">
                    {/* Animated Eye Graphic */}
                    <div className="w-32 h-32 rounded-full border-2 border-blue-400/30 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 animate-[spin_8s_linear_infinite]"></div>
                    <div className="w-40 h-40 rounded-full border-2 border-blue-400/20 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 animate-[spin_12s_linear_infinite]"></div>
                    <div className="w-48 h-48 rounded-full border-2 border-blue-400/10 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 animate-[spin_16s_linear_infinite]"></div>

                    {/* Central Eye */}
                    <div className="relative w-24 h-24">
                      <div className="absolute inset-0 bg-blue-500/20 rounded-full blur-xl"></div>
                      <div className="absolute inset-2 bg-blue-400/30 rounded-full blur-md"></div>
                      <div className="absolute inset-4 bg-blue-300/40 rounded-full"></div>
                      <div className="absolute inset-8 bg-blue-200 rounded-full"></div>
                      <div className="absolute inset-10 bg-blue-100 rounded-full"></div>
                    </div>

                    {/* Scanning Lines */}
                    <div className="absolute top-0 left-0 w-full h-full">
                      {[...Array(8)].map((_, i) => (
                        <div
                          key={i}
                          className="absolute top-1/2 left-1/2 w-[200%] h-0.5 bg-gradient-to-r from-transparent via-blue-400/30 to-transparent"
                          style={{
                            transform: `translate(-50%, -50%) rotate(${i * 45}deg)`,
                          }}
                        ></div>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Scan Text */}
                <div className="absolute bottom-4 left-0 right-0 text-center">
                  <p className="text-blue-100 text-sm">Position your eyes within the frame</p>
                </div>
              </div>
            </div>

            {/* Scan Buttons */}
            <div className="space-y-4 mb-6">
              <Button
                className="w-full bg-blue-600 hover:bg-blue-700 text-white py-6 rounded-2xl font-medium text-lg shadow-lg transition-all duration-300 ease-in-out transform hover:scale-105 relative overflow-hidden group"
                onClick={handleStartScan}
              >
                <div className="absolute inset-0 bg-blue-500 opacity-0 group-hover:opacity-20 transition-opacity"></div>
                <div className="absolute -inset-1 bg-gradient-to-r from-blue-400 to-blue-600 opacity-30 group-hover:opacity-50 blur-xl transition-opacity"></div>
                <div className="relative flex items-center justify-center">
                  <Eye className="h-6 w-6 mr-2" />
                  Start Live Eye Scan
                </div>
              </Button>

              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-gray-50 text-gray-500">OR</span>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-sm p-4">
                <div>
                  <div className="flex items-center mb-2">
                    <Upload className="h-4 w-4 mr-2 text-blue-600" />
                    <p className="text-sm font-medium text-gray-700">Upload Eye Image</p>
                  </div>
                  <EyeImageUpload onAnalysisComplete={handleAnalysisComplete} onAnalysisStart={handleAnalysisStart} />
                </div>
              </div>
            </div>
          </>
        ) : (
          /* Analysis Results */
          <div className="bg-white rounded-xl shadow-sm p-4 mb-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-blue-900">Eye Analysis Results</h2>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowAnalysisResults(false)}
                className="text-blue-600 border-blue-200"
              >
                New Analysis
              </Button>
            </div>

            <div className="mb-4">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center">
                  <AlertCircle className="h-5 w-5 text-blue-600 mr-2" />
                  <p className="text-sm font-medium text-gray-700">Eye Health Assessment</p>
                </div>
                <span
                  className={`px-2 py-1 text-xs font-medium rounded-full ${
                    healthColor === "green"
                      ? "bg-green-100 text-green-800"
                      : healthColor === "yellow"
                        ? "bg-yellow-100 text-yellow-800"
                        : healthColor === "orange"
                          ? "bg-orange-100 text-orange-800"
                          : "bg-red-100 text-red-800"
                  }`}
                >
                  {healthStatus}
                </span>
              </div>

              <p className="text-sm text-gray-700 mb-3">{briefSummary}</p>

              {/* Confidence Level */}
              <div className="flex items-center mb-3 bg-gray-50 p-2 rounded-lg">
                <BarChart2 className="h-4 w-4 text-blue-600 mr-2" />
                <div className="flex-1">
                  <div className="flex justify-between items-center mb-1">
                    <p className="text-xs text-gray-600">Confidence</p>
                    <p className={`text-xs font-medium ${getConfidenceColor(confidenceLevel)}`}>{confidenceLevel}%</p>
                  </div>
                  <div className="w-full h-1.5 bg-gray-200 rounded-full">
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
                </div>
              </div>

              <p className="text-xs text-gray-500 italic mb-4">
                This is an assessment based on image analysis. Always consult with a healthcare professional.
              </p>

              <div className="mt-4">
                <Button className="w-full bg-blue-600 hover:bg-blue-700" onClick={handleViewFullResults}>
                  View Detailed Results
                </Button>
              </div>
            </div>
          </div>
        )}

        {/* Status Metrics */}
        <div className="mt-6 grid grid-cols-2 gap-4">
          <div className="bg-white p-4 rounded-xl shadow-sm">
            <div className="flex items-center space-x-2 mb-2">
              <History className="h-5 w-5 text-blue-600" />
              <h3 className="font-medium text-gray-700">Last Scan</h3>
            </div>
            <p className="text-2xl font-bold text-blue-900">
              {lastScanDate ? new Date(lastScanDate).toLocaleDateString() : "N/A"}
            </p>
          </div>
          <div className="bg-white p-4 rounded-xl shadow-sm">
            <div className="flex items-center space-x-2 mb-2">
              <Eye className="h-5 w-5 text-blue-600" />
              <h3 className="font-medium text-gray-700">Eye Health</h3>
            </div>
            <p className="text-2xl font-bold text-blue-900">{eyeHealth}%</p>
          </div>
        </div>

        {/* Recent Results */}
        <div className="mt-6">
          <h2 className="text-lg font-semibold text-blue-900 mb-3">Recent Results</h2>
          <div className="bg-white rounded-xl shadow-sm p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">March 15, 2025</p>
                <p className="text-base font-medium text-blue-900">Regular Check-up</p>
              </div>
              <span className="px-3 py-1 bg-green-100 text-green-700 text-xs font-medium rounded-full">Healthy</span>
            </div>
            <Link href="/results/1">
              <Button variant="link" className="mt-2 text-blue-600 p-0">
                View Details
              </Button>
            </Link>
          </div>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="bg-white border-t border-gray-200">
        <div className="flex justify-around py-4">
          <Link href="/" className="flex flex-col items-center text-blue-600">
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

      {/* Scan Modal */}
      {isScanModalOpen && <ScanModal onClose={() => setIsScanModalOpen(false)} />}
    </div>
  )
}

