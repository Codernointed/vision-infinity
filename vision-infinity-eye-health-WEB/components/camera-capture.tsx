"use client"

import { useState, useRef, useEffect } from "react"
import { Camera, X, Loader, RefreshCw, CheckCircle } from "lucide-react"
import { Button } from "@/components/ui/button"
import { analyzeEyeImage } from "@/lib/gemini-api"
import { toast } from "@/components/ui/use-toast"

interface CameraCaptureProps {
  onAnalysisComplete: (result: string) => void
  onAnalysisStart: () => void
}

export default function CameraCapture({ onAnalysisComplete, onAnalysisStart }: CameraCaptureProps) {
  const [cameraActive, setCameraActive] = useState(false)
  const [capturedImage, setCapturedImage] = useState<string | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [cameraError, setCameraError] = useState<string | null>(null)
  const [countdown, setCountdown] = useState<number | null>(null)
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const streamRef = useRef<MediaStream | null>(null)

  // Start camera when component mounts
  const startCamera = async () => {
    try {
      setCameraError(null)

      // First check if user media is supported
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        setCameraError("Camera access is not supported in your browser. Please try a different browser.")
        return
      }

      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: "user", // Use front camera for eye scanning
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
      })

      streamRef.current = stream

      if (videoRef.current) {
        videoRef.current.srcObject = stream
        setCameraActive(true)

        // Add a small delay to ensure video is ready
        setTimeout(() => {
          if (videoRef.current) {
            videoRef.current.play().catch((err) => {
              console.error("Error playing video:", err)
              setCameraError("Unable to start camera stream. Please check permissions and try again.")
            })
          }
        }, 500)
      }
    } catch (error) {
      console.error("Error accessing camera:", error)

      // Provide more specific error messages
      if (error instanceof DOMException) {
        if (error.name === "NotAllowedError") {
          setCameraError("Camera access denied. Please allow camera access in your browser settings.")
        } else if (error.name === "NotFoundError") {
          setCameraError("No camera found. Please ensure your device has a working camera.")
        } else {
          setCameraError(`Camera error: ${error.message}. Please try again.`)
        }
      } else {
        setCameraError("Unable to access camera. Please check permissions and try again.")
      }

      setCameraActive(false)
    }
  }

  // Stop camera when component unmounts
  const stopCamera = () => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop())
      streamRef.current = null
      setCameraActive(false)
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

          // Stop camera after capturing
          stopCamera()
        } catch (error) {
          console.error("Error capturing image:", error)
          toast({
            title: "Capture Failed",
            description: "Unable to capture image. Please try again.",
            variant: "destructive",
          })
        }
      }
    }
  }

  // Retake photo
  const retakePhoto = () => {
    setCapturedImage(null)
    startCamera()
  }

  // Analyze captured image
  const analyzeImage = async () => {
    if (!capturedImage) {
      toast({
        title: "No Image Captured",
        description: "Please capture an eye image first.",
        variant: "destructive",
      })
      return
    }

    try {
      setIsAnalyzing(true)
      onAnalysisStart()

      // Extract base64 data from data URL
      const base64Data = capturedImage.split(",")[1]

      // Save the captured image for reference
      if (typeof window !== "undefined") {
        localStorage.setItem("capturedEyeImage", capturedImage)
      }

      // Call the Gemini API
      const analysisResult = await analyzeEyeImage(base64Data)

      // Pass the result to the parent component
      onAnalysisComplete(analysisResult)
    } catch (error) {
      console.error("Error during analysis:", error)
      toast({
        title: "Analysis Failed",
        description: "Unable to analyze image. Please try again.",
        variant: "destructive",
      })
      onAnalysisComplete("")
    } finally {
      setIsAnalyzing(false)
    }
  }

  return (
    <div className="w-full">
      <div className="mb-4">
        <div className="flex items-center justify-between mb-2">
          <p className="text-sm font-medium text-gray-700">Eye Camera</p>
          {capturedImage && (
            <Button variant="ghost" size="sm" onClick={retakePhoto} className="text-blue-500 h-8 px-2">
              <RefreshCw className="h-4 w-4 mr-1" />
              Retake
            </Button>
          )}
        </div>

        <div className="relative rounded-lg overflow-hidden bg-gray-100 aspect-[4/3]">
          {!cameraActive && !capturedImage && !cameraError && (
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <Camera className="h-12 w-12 text-gray-400 mb-2" />
              <p className="text-sm text-gray-500 mb-4">Start camera to capture eye image</p>
              <Button onClick={startCamera} className="bg-blue-600 hover:bg-blue-700">
                Start Camera
              </Button>
            </div>
          )}

          {cameraError && (
            <div className="absolute inset-0 flex flex-col items-center justify-center p-4">
              <X className="h-12 w-12 text-red-500 mb-2" />
              <p className="text-sm text-red-500 text-center mb-4">{cameraError}</p>
              <Button onClick={startCamera} className="bg-blue-600 hover:bg-blue-700">
                Try Again
              </Button>
            </div>
          )}

          {cameraActive && (
            <div className="relative">
              <video ref={videoRef} autoPlay playsInline muted className="w-full h-full object-cover" />

              {/* Countdown overlay */}
              {countdown !== null && (
                <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                  <div className="text-white text-6xl font-bold animate-pulse">{countdown}</div>
                </div>
              )}

              {/* Guide overlay */}
              <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
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
            </div>
          )}

          {capturedImage && (
            <div className="relative">
              <img
                src={capturedImage || "/placeholder.svg"}
                alt="Captured eye"
                className="w-full h-full object-cover"
              />
              <div className="absolute top-2 right-2">
                <div className="bg-green-500 text-white p-1 rounded-full">
                  <CheckCircle className="h-5 w-5" />
                </div>
              </div>
            </div>
          )}

          {/* Hidden canvas for image capture */}
          <canvas ref={canvasRef} className="hidden" />
        </div>
      </div>

      {capturedImage && (
        <Button className="w-full bg-blue-600 hover:bg-blue-700" onClick={analyzeImage} disabled={isAnalyzing}>
          {isAnalyzing ? (
            <>
              <Loader className="h-4 w-4 mr-2 animate-spin" />
              Analyzing...
            </>
          ) : (
            "Analyze Eye Image"
          )}
        </Button>
      )}
    </div>
  )
}

