"use client"

import type React from "react"

import { useState } from "react"
import { Upload, X, Loader } from "lucide-react"
import { Button } from "@/components/ui/button"
import { analyzeEyeImage } from "@/lib/gemini-api"
import { toast } from "@/components/ui/use-toast"

interface EyeImageUploadProps {
  onAnalysisComplete: (result: string) => void
  onAnalysisStart: () => void
}

export default function EyeImageUpload({ onAnalysisComplete, onAnalysisStart }: EyeImageUploadProps) {
  const [selectedImage, setSelectedImage] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0]
      setSelectedImage(file)

      // Create a preview
      const reader = new FileReader()
      reader.onload = (event) => {
        setImagePreview(event.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const handleAnalyze = async () => {
    if (!selectedImage) {
      toast({
        title: "No Image Selected",
        description: "Please select an eye image to analyze.",
        variant: "destructive",
      })
      return
    }

    try {
      setIsAnalyzing(true)
      onAnalysisStart()

      // Convert image to base64
      const reader = new FileReader()
      reader.readAsDataURL(selectedImage)
      reader.onload = async () => {
        try {
          // Extract the base64 data (remove the data:image/jpeg;base64, part)
          const base64Data = (reader.result as string).split(",")[1]

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
    } catch (error) {
      console.error("Error reading file:", error)
      setIsAnalyzing(false)
      toast({
        title: "Error",
        description: "Failed to process the image. Please try again.",
        variant: "destructive",
      })
    }
  }

  const handleClearImage = () => {
    setSelectedImage(null)
    setImagePreview(null)
  }

  return (
    <div className="w-full">
      <div className="mb-4">
        <div className="flex justify-end mb-2">
          {imagePreview && (
            <Button variant="ghost" size="sm" onClick={handleClearImage} className="text-red-500 h-8 px-2">
              <X className="h-4 w-4 mr-1" />
              Clear
            </Button>
          )}
        </div>

        {imagePreview ? (
          <div className="relative rounded-lg overflow-hidden">
            <img src={imagePreview || "/placeholder.svg"} alt="Eye preview" className="w-full h-48 object-cover" />
          </div>
        ) : (
          <label className="flex flex-col items-center justify-center w-full h-48 border-2 border-dashed border-gray-300 rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100">
            <div className="flex flex-col items-center justify-center pt-5 pb-6">
              <Upload className="w-8 h-8 mb-3 text-gray-400" />
              <p className="mb-2 text-sm text-gray-500">
                <span className="font-semibold">Click to upload</span> or drag and drop
              </p>
              <p className="text-xs text-gray-500">PNG, JPG or JPEG (max. 5MB)</p>
            </div>
            <input
              type="file"
              className="hidden"
              accept="image/png, image/jpeg, image/jpg"
              onChange={handleImageChange}
            />
          </label>
        )}
      </div>

      <Button
        className="w-full bg-blue-600 hover:bg-blue-700"
        onClick={handleAnalyze}
        disabled={!selectedImage || isAnalyzing}
      >
        {isAnalyzing ? (
          <>
            <Loader className="h-4 w-4 mr-2 animate-spin" />
            Analyzing...
          </>
        ) : (
          "Analyze Eye Image"
        )}
      </Button>
    </div>
  )
}

