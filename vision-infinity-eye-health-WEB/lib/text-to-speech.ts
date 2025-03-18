export function speak(text: string, lang = "en-US") {
  return new Promise<void>((resolve, reject) => {
    if ("speechSynthesis" in window) {
      const synthesis = window.speechSynthesis
      const utterance = new SpeechSynthesisUtterance(text)

      // Check if the desired language is available
      const voices = synthesis.getVoices()
      const availableVoice = voices.find((voice) => voice.lang.startsWith(lang))

      if (availableVoice) {
        utterance.voice = availableVoice
        utterance.lang = lang
      } else {
        console.warn(`Language ${lang} not available, falling back to default voice.`)
        // Fallback to the default voice (usually English)
      }

      utterance.rate = 0.9 // Slightly slower rate

      utterance.onend = () => resolve()
      utterance.onerror = (error) => reject(error)

      synthesis.speak(utterance)
    } else {
      reject(new Error("Text-to-speech not supported in this browser."))
    }
  })
}

export function stopSpeaking() {
  if ("speechSynthesis" in window) {
    window.speechSynthesis.cancel()
  }
}

export function isSpeechSynthesisSupported(): boolean {
  return "speechSynthesis" in window
}

