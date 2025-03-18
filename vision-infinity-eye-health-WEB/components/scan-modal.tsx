"use client"

import { useState, useEffect, useRef } from "react"
import { X, Camera, Loader, Check, RefreshCw, AlertCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useRouter } from "next/navigation"
import { analyzeEyeImage } from "@/lib/gemini-api"
import { toast } from "@/components/ui/use-toast"

interface ScanModalProps {
  onClose: () => void
}

export default function ScanModal({ onClose }: ScanModalProps) {
  const router = useRouter()
  const [scanState, setScanState] = useState<"ready" | "camera" | "preview" | "processing" | "complete" | "error">(
    "ready",
  )
  const [progress, setProgress] = useState(0)
  const [cameraError, setCameraError] = useState<string | null>(null)
  const [countdown, setCountdown] = useState<number | null>(null)
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const streamRef = useRef<MediaStream | null>(null)
  const [capturedImage, setCapturedImage] = useState<string | null>(null)

  // Start camera when component mounts
  const startCamera = async () => {
    try {
      setCameraError(null)

      // First check if user media is supported
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        setCameraError("Camera access is not supported in your browser. Please try a different browser.")
        setScanState("error")
        return
      }

      const constraints = {
        video: {
          facingMode: "user", // Use front camera for eye scanning
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
      }

      try {
        const stream = await navigator.mediaDevices.getUserMedia(constraints)
        streamRef.current = stream

        if (videoRef.current) {
          videoRef.current.srcObject = stream

          // Wait for video to be ready
          videoRef.current.onloadedmetadata = () => {
            videoRef.current?.play().catch((err) => {
              console.error("Error playing video:", err)
              setCameraError("Unable to start camera stream. Please check permissions and try again.")
              setScanState("error")
            })
          }

          setScanState("camera")
        }
      } catch (err) {
        console.error("Error accessing camera:", err)
        if (err instanceof DOMException) {
          if (err.name === "NotAllowedError") {
            setCameraError("Camera access denied. Please allow camera access in your browser settings.")
          } else if (err.name === "NotFoundError") {
            setCameraError("No camera found. Please ensure your device has a working camera.")
          } else {
            setCameraError(`Camera error: ${err.message}. Please try again.`)
          }
        } else {
          setCameraError("Unable to access camera. Please check permissions and try again.")
        }
        setScanState("error")
      }
    } catch (error) {
      console.error("Unexpected error:", error)
      setCameraError("An unexpected error occurred. Please try again.")
      setScanState("error")
    }
  }

  // Stop camera when component unmounts
  const stopCamera = () => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop())
      streamRef.current = null
    }
  }

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stopCamera()
    }
  }, [])

  // Start countdown for capture
  const startCountdown = () => {
    setCountdown(3)

    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev === null || prev <= 1) {
          clearInterval(timer)
          captureImage()
          return null
        }
        return prev - 1
      })
    }, 1000)
  }

  // Capture image from camera
  const captureImage = () => {
    if (videoRef.current && canvasRef.current) {
      const video = videoRef.current
      const canvas = canvasRef.current
      const context = canvas.getContext("2d")

      if (context) {
        try {
          // Set canvas dimensions to match video
          canvas.width = video.videoWidth
          canvas.height = video.videoHeight

          // Draw video frame to canvas
          context.drawImage(video, 0, 0, canvas.width, canvas.height)

          // Convert canvas to data URL with high quality
          const imageDataUrl = canvas.toDataURL("image/jpeg", 0.95)

          if (imageDataUrl === "data:,") {
            throw new Error("Failed to capture image from camera")
          }

          setCapturedImage(imageDataUrl)

          // Move to preview state
          setScanState("preview")
        } catch (error) {
          console.error("Error capturing image:", error)
          toast({
            title: "Capture Failed",
            description: "Unable to capture image. Please try again.",
            variant: "destructive",
          })
          setScanState("error")
        }
      }
    }
  }

  // Retake photo
  const retakePhoto = () => {
    setCapturedImage(null)
    startCamera()
  }

  // Process the captured image with AI
  const processImage = async () => {
    if (!capturedImage) {
      toast({
        title: "No Image Captured",
        description: "Please capture an eye image first.",
        variant: "destructive",
      })
      return
    }

    try {
      // Stop camera after confirming
      stopCamera()

      // Move to processing state
      setScanState("processing")
      setProgress(0)

      // Extract base64 data from data URL
      const base64Data = capturedImage.split(",")[1]

      // Simulate progress
      const interval = setInterval(() => {
        setProgress((prevProgress) => {
          if (prevProgress >= 95) {
            clearInterval(interval)
            return 95
          }
          return prevProgress + Math.floor(Math.random() * 5) + 1
        })
      }, 300)

      // Call the Gemini API
      const analysisResult = await analyzeEyeImage(base64Data)

      // Set progress to 100% when analysis is complete
      setProgress(100)

      // Save the analysis result to localStorage
      if (typeof window !== "undefined") {
        localStorage.setItem("aiAnalysisResult", analysisResult)
        localStorage.setItem("aiAnalysisDate", new Date().toISOString())
        localStorage.setItem("capturedEyeImage", capturedImage) // Store the image for reference
      }

      // Complete the scan
      setScanState("complete")

      // Wait a moment before redirecting
      setTimeout(() => {
        router.push("/results/analysis")
        onClose()
      }, 1500)
    } catch (error) {
      console.error("Error analyzing image:", error)
      toast({
        title: "Analysis Failed",
        description: "Unable to analyze image. Please try again.",
        variant: "destructive",
      })
      setScanState("error")
    }
  }

  // Start scan process
  const startScan = async () => {
    await startCamera()
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl w-full max-w-md overflow-hidden">
        <div className="flex justify-between items-center p-4 border-b">
          <h3 className="text-lg font-semibold text-blue-900">Eye Scan</h3>
          <Button variant="ghost" size="icon" onClick={onClose} className="rounded-full">
            <X className="h-5 w-5" />
          </Button>
        </div>

        <div className="p-4">
          <div className="relative aspect-[3/4] bg-gradient-to-br from-blue-900 to-blue-700 rounded-lg overflow-hidden mb-4">
            {/* Ready State */}
            {scanState === "ready" && (
              <div className="absolute inset-0 flex flex-col items-center justify-center text-white">
                <Camera className="h-16 w-16 mb-4" />
                <p className="text-center px-8 text-lg">Position your face within the frame and keep your eyes open</p>
              </div>
            )}

            {/* Camera State */}
            {scanState === "camera" && (
              <>
                <video
                  ref={videoRef}
                  autoPlay
                  playsInline
                  muted
                  className="absolute inset-0 w-full h-full object-cover"
                />

                {/* Countdown overlay */}
                {countdown !== null && (
                  <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                    <div className="text-white text-6xl font-bold animate-pulse">{countdown}</div>
                  </div>
                )}

                {/* Guide overlay */}
                <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                  <div className="w-48 h-48 border-4 border-blue-400 rounded-full opacity-70"></div>
                </div>

                {/* Instructions */}
                <div className="absolute top-4 left-0 right-0 text-center">
                  <p className="text-sm bg-black bg-opacity-50 text-white py-1 px-2 rounded-full inline-block">
                    Position your eye within the circle
                  </p>
                </div>

                {/* Capture button */}
                <div className="absolute bottom-4 left-0 right-0 flex justify-center">
                  <Button
                    onClick={startCountdown}
                    disabled={countdown !== null}
                    className="bg-blue-600 hover:bg-blue-700 rounded-full h-14 w-14 flex items-center justify-center"
                  >
                    <Camera className="h-6 w-6" />
                  </Button>
                </div>
              </>
            )}

            {/* Preview State */}
            {scanState === "preview" && capturedImage && (
              <div className="relative">
                <img
                  src={capturedImage || "/placeholder.svg"}
                  alt="Captured eye"
                  className="absolute inset-0 w-full h-full object-contain bg-black"
                />
                <div className="absolute inset-0 bg-gradient-to-b from-black/50 to-transparent p-4">
                  <p className="text-white font-medium">Image Preview</p>
                </div>
                <div className="absolute bottom-4 right-4">
                  <div className="bg-green-500 text-white p-1 rounded-full">
                    <Check className="h-5 w-5" />
                  </div>
                </div>
              </div>
            )}

            {/* Processing State */}
            {scanState === "processing" && (
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <Loader className="h-16 w-16 text-blue-400 animate-spin mb-4" />
                <p className="text-blue-100 font-medium text-lg">Processing scan...</p>
                <div className="w-48 h-2 bg-blue-800 rounded-full mt-4">
                  <div
                    className="h-full bg-blue-400 rounded-full transition-all duration-300 ease-in-out"
                    style={{ width: `${progress}%` }}
                  ></div>
                </div>
                <p className="text-blue-100 text-sm mt-2">{progress}%</p>
              </div>
            )}

            {/* Complete State */}
            {scanState === "complete" && (
              <div className="absolute inset-0 flex flex-col items-center justify-center bg-green-500">
                <Check className="h-16 w-16 text-white mb-4" />
                <p className="text-white font-medium text-lg">Scan Complete!</p>
              </div>
            )}

            {/* Error State */}
            {scanState === "error" && (
              <div className="absolute inset-0 flex flex-col items-center justify-center bg-red-500 bg-opacity-80">
                <AlertCircle className="h-16 w-16 text-white mb-4" />
                <p className="text-white font-medium text-lg text-center px-6">
                  {cameraError || "An error occurred during the scan"}
                </p>
              </div>
            )}

            {/* Show captured image in processing and complete states */}
            {(scanState === "processing" || scanState === "complete") && capturedImage && (
              <img
                src={capturedImage || "/placeholder.svg"}
                alt="Captured eye"
                className="absolute inset-0 w-full h-full object-cover opacity-50"
              />
            )}

            {/* Hidden canvas for image capture */}
            <canvas ref={canvasRef} className="hidden" />
          </div>

          {/* Action buttons based on state */}
          {scanState === "ready" && (
            <Button className="w-full bg-blue-600 hover:bg-blue-700 text-white py-6 text-lg" onClick={startScan}>
              Start Scan
            </Button>
          )}

          {scanState === "preview" && (
            <div className="flex gap-3">
              <Button variant="outline" className="flex-1 border-blue-200 text-blue-600 py-3" onClick={retakePhoto}>
                <RefreshCw className="h-4 w-4 mr-2" />
                Retake Photo
              </Button>
              <Button className="flex-1 bg-blue-600 hover:bg-blue-700 py-3" onClick={processImage}>
                <Check className="h-4 w-4 mr-2" />
                Confirm & Analyze
              </Button>
            </div>
          )}

          {scanState === "error" && (
            <Button className="w-full bg-blue-600 hover:bg-blue-700 text-white" onClick={startScan}>
              Try Again
            </Button>
          )}

          {/* Status message */}
          {scanState !== "ready" && scanState !== "preview" && scanState !== "error" && (
            <p className="text-sm text-gray-500 text-center mt-2">
              {scanState === "camera"
                ? "Please position your eye and tap the camera button"
                : scanState === "processing"
                  ? "Our AI is analyzing your eye health..."
                  : "Redirecting to results..."}
            </p>
          )}
        </div>
      </div>
    </div>
  )
}

