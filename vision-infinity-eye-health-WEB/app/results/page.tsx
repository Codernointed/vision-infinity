"use client"

import { useState, useEffect } from "react"
import { Eye, Download, ArrowLeft, Share2, History, User, VolumeX, Volume2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { useRouter, useSearchParams } from "next/navigation"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/custom-tabs"
import Link from "next/link"
import { speak, stopSpeaking, isSpeechSynthesisSupported } from "@/lib/text-to-speech"
import { toast } from "@/components/ui/use-toast"

// Mock data for different scan results
const scanResults = {
  1: {
    date: "May 4, 2025",
    time: "6:24 PM",
    status: "Healthy",
    resultSummary: "Your eyes appear healthy with no signs of issues. Keep up the good habits.",
    diagnosis: "No significant issues detected. Mild dryness observed.",
    recommendations: "Continue with regular eye care routine. Use artificial tears if needed.",
  },
  2: {
    date: "April 28, 2025",
    time: "9:15 AM",
    status: "Mild Dryness",
    resultSummary:
      "Your eyes show signs of mild dryness. Consider using artificial tears and taking more screen breaks.",
    diagnosis: "Mild dry eye syndrome detected. Slight redness in the left eye.",
    recommendations:
      "Use preservative-free artificial tears 3-4 times daily. Take regular screen breaks using the 20-20-20 rule.",
  },
  3: {
    date: "April 15, 2025",
    time: "2:30 PM",
    status: "Healthy",
    resultSummary: "Your eye health is good. Continue with your current eye care routine.",
    diagnosis: "Eyes appear healthy. No significant issues detected.",
    recommendations: "Maintain current eye care routine. Schedule next check-up in 6 months.",
  },
  4: {
    date: "March 30, 2025",
    time: "11:45 AM",
    status: "Moderate Redness",
    resultSummary:
      "Moderate redness detected in your eyes. Rest your eyes and avoid screens for a while. If symptoms persist, consult an eye doctor.",
    diagnosis: "Moderate conjunctival redness observed. Possible eye strain or allergic reaction.",
    recommendations:
      "Rest eyes for 30 minutes. Apply cool compress. If symptoms persist for more than 24 hours, consult an eye doctor.",
  },
}

export default function ResultsPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [advancedMode, setAdvancedMode] = useState(false)
  const [isSpeaking, setIsSpeaking] = useState(false)
  const [currentScan, setCurrentScan] = useState<any>(null)
  const [isSpeechSupported, setIsSpeechSupported] = useState(true)

  useEffect(() => {
    setIsSpeechSupported(isSpeechSynthesisSupported())
    const scanId = searchParams.get("id")
    if (scanId && scanResults[scanId as keyof typeof scanResults]) {
      setCurrentScan(scanResults[scanId as keyof typeof scanResults])
    } else {
      // If no valid ID is provided, use the most recent scan (ID 1)
      setCurrentScan(scanResults[1])
    }

    return () => {
      stopSpeaking()
    }
  }, [searchParams])

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
      const textToSpeak = `
        Scan results for ${currentScan.date} at ${currentScan.time}.
        Overall health: ${currentScan.status}.
        ${currentScan.resultSummary}
        Diagnosis: ${currentScan.diagnosis}
        Recommendations: ${currentScan.recommendations}
      `
      try {
        await speak(textToSpeak, "en-US") // Fallback to English
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

  if (!currentScan) return null

  return (
    <main className="flex min-h-screen flex-col bg-white pb-16">
      {/* Header */}
      <div className="sticky top-0 bg-white border-b border-gray-200 z-10">
        <div className="max-w-md mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center">
            <Button variant="ghost" size="icon" className="mr-2" onClick={() => router.push("/history")}>
              <ArrowLeft className="h-5 w-5 text-blue-900" />
            </Button>
            <h1 className="text-xl font-bold text-blue-900">Scan Results</h1>
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
              <h2 className="text-lg font-semibold text-blue-900">Eye Health Analysis</h2>
              <p className="text-sm text-gray-500">
                {currentScan.date} • {currentScan.time}
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
                <div className="h-full bg-green-500 rounded-full" style={{ width: "85%" }}></div>
              </div>
              <span className="text-sm font-medium text-green-600">{currentScan.status}</span>
            </div>
          </div>

          <div className="border-t border-gray-100 my-3"></div>

          <p className="text-sm text-gray-700 mb-2">{currentScan.resultSummary}</p>
        </div>

        {/* Detailed Results */}
        <Tabs defaultValue="diagnosis" className="w-full">
          <TabsList className="grid grid-cols-3 mb-4">
            <TabsTrigger value="diagnosis">Diagnosis</TabsTrigger>
            <TabsTrigger value="recommendations">Recommendations</TabsTrigger>
            {advancedMode && <TabsTrigger value="metrics">Metrics</TabsTrigger>}
          </TabsList>

          <TabsContent value="diagnosis" className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
            <h3 className="text-md font-semibold text-blue-900 mb-3">Findings</h3>
            <p className="text-sm text-gray-700">{currentScan.diagnosis}</p>

            {advancedMode && (
              <div className="mt-4">
                <div className="mb-4">
                  <div className="flex justify-between mb-1">
                    <p className="text-sm font-medium">Dry Eye Syndrome</p>
                    <p className="text-sm text-blue-600">Mild</p>
                  </div>
                  <p className="text-xs text-gray-600">Tear film breakup time: 8 seconds (left), 10 seconds (right)</p>
                </div>

                <div className="mb-4">
                  <div className="flex justify-between mb-1">
                    <p className="text-sm font-medium">Conjunctival Redness</p>
                    <p className="text-sm text-blue-600">Minimal</p>
                  </div>
                  <p className="text-xs text-gray-600">Bulbar redness score: 1.2/4.0</p>
                </div>

                <div className="mb-4">
                  <div className="flex justify-between mb-1">
                    <p className="text-sm font-medium">Corneal Integrity</p>
                    <p className="text-sm text-green-600">Normal</p>
                  </div>
                  <p className="text-xs text-gray-600">No epithelial defects detected</p>
                </div>

                <div>
                  <div className="flex justify-between mb-1">
                    <p className="text-sm font-medium">Intraocular Pressure (Est.)</p>
                    <p className="text-sm text-green-600">Normal Range</p>
                  </div>
                  <p className="text-xs text-gray-600">Estimated from scleral rigidity patterns</p>
                </div>
              </div>
            )}
          </TabsContent>

          <TabsContent value="recommendations" className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
            <h3 className="text-md font-semibold text-blue-900 mb-3">Recommendations</h3>
            <p className="text-sm text-gray-700 mb-4">{currentScan.recommendations}</p>

            {advancedMode ? (
              <div>
                <div className="mb-4">
                  <p className="text-sm font-medium mb-1">Primary Interventions</p>
                  <ul className="text-xs text-gray-600 list-disc pl-4 space-y-1">
                    <li>Prescribe preservative-free artificial tears QID</li>
                    <li>Recommend warm compress therapy for 10 minutes daily</li>
                    <li>Consider omega-3 fatty acid supplementation</li>
                  </ul>
                </div>

                <div className="mb-4">
                  <p className="text-sm font-medium mb-1">Environmental Modifications</p>
                  <ul className="text-xs text-gray-600 list-disc pl-4 space-y-1">
                    <li>Increase ambient humidity in work/home environment</li>
                    <li>Implement 20-20-20 rule during screen use</li>
                    <li>Ensure proper positioning of computer screens</li>
                  </ul>
                </div>

                <div>
                  <p className="text-sm font-medium mb-1">Follow-up</p>
                  <p className="text-xs text-gray-600">
                    Recommend reassessment in 3 months to evaluate response to therapy
                  </p>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="flex items-start">
                  <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mt-1 mr-3">
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
                      <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path>
                      <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">Use artificial tears</p>
                    <p className="text-xs text-gray-600">
                      Apply preservative-free eye drops 3-4 times daily to relieve dryness
                    </p>
                  </div>
                </div>

                <div className="flex items-start">
                  <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mt-1 mr-3">
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
                      <circle cx="12" cy="12" r="10"></circle>
                      <path d="M12 6v6l4 2"></path>
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">Take screen breaks</p>
                    <p className="text-xs text-gray-600">
                      Follow the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds
                    </p>
                  </div>
                </div>

                <div className="flex items-start">
                  <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mt-1 mr-3">
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
                      <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"></path>
                      <circle cx="12" cy="13" r="3"></circle>
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">Schedule a follow-up</p>
                    <p className="text-xs text-gray-600">Consider a professional eye exam in the next 3-6 months</p>
                  </div>
                </div>
              </div>
            )}
          </TabsContent>

          {advancedMode && (
            <TabsContent value="metrics" className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
              <h3 className="text-md font-semibold text-blue-900 mb-3">Clinical Metrics</h3>

              <div className="space-y-4">
                <div>
                  <p className="text-sm font-medium mb-1">Tear Film Analysis</p>
                  <div className="grid grid-cols-2 gap-2">
                    <div className="bg-blue-50 p-2 rounded">
                      <p className="text-xs text-gray-600">TBUT (Left)</p>
                      <p className="text-sm font-medium">8.2 seconds</p>
                    </div>
                    <div className="bg-blue-50 p-2 rounded">
                      <p className="text-xs text-gray-600">TBUT (Right)</p>
                      <p className="text-sm font-medium">10.1 seconds</p>
                    </div>
                    <div className="bg-blue-50 p-2 rounded">
                      <p className="text-xs text-gray-600">Tear Meniscus</p>
                      <p className="text-sm font-medium">0.22 mm</p>
                    </div>
                    <div className="bg-blue-50 p-2 rounded">
                      <p className="text-xs text-gray-600">Osmolarity (Est.)</p>
                      <p className="text-sm font-medium">310 mOsm/L</p>
                    </div>
                  </div>
                </div>

                <div>
                  <p className="text-sm font-medium mb-1">Corneal Assessment</p>
                  <div className="bg-blue-50 p-3 rounded mb-2">
                    <div className="flex justify-between mb-1">
                      <p className="text-xs text-gray-600">Corneal Thickness (Est.)</p>
                      <p className="text-xs font-medium">540 μm</p>
                    </div>
                    <div className="w-full h-1.5 bg-white rounded-full">
                      <div className="h-full bg-green-500 rounded-full" style={{ width: "65%" }}></div>
                    </div>
                    <div className="flex justify-between mt-1">
                      <p className="text-xs">Thin</p>
                      <p className="text-xs">Normal</p>
                      <p className="text-xs">Thick</p>
                    </div>
                  </div>

                  <div className="bg-blue-50 p-3 rounded">
                    <p className="text-xs text-gray-600 mb-2">Corneal Surface Regularity</p>
                    <div className="grid grid-cols-5 gap-1">
                      {[1, 2, 3, 4, 5].map((i) => (
                        <div key={i} className={`h-1.5 rounded-full ${i <= 4 ? "bg-green-500" : "bg-white"}`}></div>
                      ))}
                    </div>
                    <p className="text-xs text-right mt-1">4/5 - Good</p>
                  </div>
                </div>

                <div>
                  <p className="text-sm font-medium mb-1">Predictive Analysis</p>
                  <div className="bg-blue-50 p-3 rounded">
                    <p className="text-xs text-gray-600 mb-1">Dry Eye Progression Risk</p>
                    <div className="flex items-center">
                      <div className="w-full h-1.5 bg-white rounded-full mr-2">
                        <div className="h-full bg-yellow-500 rounded-full" style={{ width: "35%" }}></div>
                      </div>
                      <span className="text-xs font-medium">35%</span>
                    </div>
                    <p className="text-xs text-gray-500 mt-2">
                      Based on environmental factors, screen time, and current symptoms
                    </p>
                  </div>
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
            Scan Again
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

