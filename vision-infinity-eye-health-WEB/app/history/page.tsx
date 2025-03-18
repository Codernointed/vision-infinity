"use client"

import { useState, useEffect } from "react"
import { ArrowLeft, Calendar, Eye, History, User, Volume2, VolumeX, ChevronRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { speak, stopSpeaking, isSpeechSynthesisSupported } from "@/lib/text-to-speech"
import { toast } from "@/components/ui/use-toast"

export default function HistoryPage() {
  const [speakingId, setSpeakingId] = useState<number | null>(null)
  const [isSpeechSupported, setIsSpeechSupported] = useState(true)

  useEffect(() => {
    setIsSpeechSupported(isSpeechSynthesisSupported())
    return () => {
      stopSpeaking()
    }
  }, [])

  const handleSpeak = async (id: number, text: string) => {
    if (!isSpeechSupported) {
      toast({
        title: "Speech Synthesis Unavailable",
        description: "Your browser does not support text-to-speech functionality.",
        variant: "destructive",
      })
      return
    }

    if (speakingId === id) {
      stopSpeaking()
      setSpeakingId(null)
    } else {
      stopSpeaking()
      setSpeakingId(id)
      try {
        await speak(text, "en-US")
        setSpeakingId(null)
      } catch (error) {
        console.error("Speech synthesis error:", error)
        toast({
          title: "Speech Synthesis Error",
          description: "An error occurred while trying to speak the text. Please try again.",
          variant: "destructive",
        })
        setSpeakingId(null)
      }
    }
  }

  const scanHistory = [
    {
      id: 1,
      date: "May 4, 2025",
      time: "6:24 PM",
      status: "Healthy",
      statusColor: "green",
      description: "Your eyes are in excellent condition. No issues detected.",
    },
    {
      id: 2,
      date: "April 28, 2025",
      time: "9:15 AM",
      status: "Mild Dryness",
      statusColor: "yellow",
      description: "Slight dryness detected. Consider using eye drops.",
    },
    {
      id: 3,
      date: "April 15, 2025",
      time: "2:30 PM",
      status: "Healthy",
      statusColor: "green",
      description: "Your eye health is good. Keep up the good habits.",
    },
    {
      id: 4,
      date: "March 30, 2025",
      time: "11:45 AM",
      status: "Moderate Redness",
      statusColor: "orange",
      description: "Moderate redness detected. Rest your eyes and avoid screens for a while.",
    },
  ]

  return (
    <main className="flex min-h-screen flex-col bg-white">
      {/* Header */}
      <div className="sticky top-0 bg-white border-b border-gray-200 z-10">
        <div className="max-w-md mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center">
            <Link href="/">
              <Button variant="ghost" size="icon" className="mr-2">
                <ArrowLeft className="h-5 w-5 text-blue-900" />
              </Button>
            </Link>
            <h1 className="text-xl font-bold text-blue-900">Scan History</h1>
          </div>
          <Button variant="outline" size="sm" className="text-blue-900 border-blue-200">
            <Calendar className="h-4 w-4 mr-1" />
            Filter
          </Button>
        </div>
      </div>

      <div className="max-w-md mx-auto w-full px-4 py-6">
        <div className="space-y-3">
          {scanHistory.map((scan) => (
            <div
              key={scan.id}
              className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 hover:shadow-md transition-shadow"
            >
              <div className="flex items-center">
                <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                  <Eye className="h-5 w-5 text-blue-900" />
                </div>
                <div className="ml-3 flex-1">
                  <div className="flex justify-between items-center">
                    <p className="text-sm font-medium text-blue-900">Eye Scan</p>
                    <span
                      className={`text-xs font-medium px-2 py-0.5 rounded-full ${
                        scan.statusColor === "green"
                          ? "bg-green-100 text-green-800"
                          : scan.statusColor === "yellow"
                            ? "bg-yellow-100 text-yellow-800"
                            : "bg-orange-100 text-orange-800"
                      }`}
                    >
                      {scan.status}
                    </span>
                  </div>
                  <p className="text-xs text-gray-500">
                    {scan.date} • {scan.time}
                  </p>
                </div>
                {isSpeechSupported && (
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() =>
                      handleSpeak(scan.id, `${scan.date}, ${scan.time}. Status: ${scan.status}. ${scan.description}`)
                    }
                    className="text-blue-600 ml-2"
                  >
                    {speakingId === scan.id ? <VolumeX className="h-5 w-5" /> : <Volume2 className="h-5 w-5" />}
                  </Button>
                )}
              </div>
              <p className="text-sm text-gray-700 mt-2">{scan.description}</p>
              <div className="mt-3 flex justify-end">
                <Link href={`/results/${scan.id}`}>
                  <Button variant="ghost" size="sm" className="text-blue-600">
                    View Details
                    <ChevronRight className="h-4 w-4 ml-1" />
                  </Button>
                </Link>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Navigation Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200">
        <div className="max-w-md mx-auto flex justify-around py-4">
          <Link href="/" className="flex flex-col items-center text-gray-400">
            <Eye className="h-6 w-6" />
            <span className="text-xs mt-1">Home</span>
          </Link>
          <Link href="/history" className="flex flex-col items-center text-blue-900">
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

