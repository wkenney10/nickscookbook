import { useCallback, useEffect, useRef, useState } from 'react'

// Minimal Web Speech API type declarations (not in standard TS DOM lib)
interface SpeechRecognitionEvent extends Event {
  results: SpeechRecognitionResultList
}
interface SpeechRecognitionResultList {
  readonly length: number
  item(index: number): SpeechRecognitionResult
  [index: number]: SpeechRecognitionResult
}
interface SpeechRecognitionResult {
  readonly length: number
  readonly isFinal: boolean
  item(index: number): SpeechRecognitionAlternative
  [index: number]: SpeechRecognitionAlternative
}
interface SpeechRecognitionAlternative {
  readonly transcript: string
  readonly confidence: number
}
interface SpeechRecognitionLike extends EventTarget {
  continuous: boolean
  interimResults: boolean
  lang: string
  onresult: ((e: SpeechRecognitionEvent) => void) | null
  onerror: ((e: Event & { error?: string }) => void) | null
  onend: (() => void) | null
  start(): void
  stop(): void
}

declare global {
  interface Window {
    SpeechRecognition?: new () => SpeechRecognitionLike
    webkitSpeechRecognition?: new () => SpeechRecognitionLike
  }
}

export function useVoiceInput() {
  const [isRecording, setIsRecording] = useState(false)
  const [transcript, setTranscript] = useState('')
  const [error, setError] = useState<string | null>(null)
  const recognitionRef = useRef<SpeechRecognitionLike | null>(null)

  const isSupported = !!(window.SpeechRecognition || window.webkitSpeechRecognition)

  const start = useCallback(() => {
    const SpeechRecognition = window.SpeechRecognition ?? window.webkitSpeechRecognition
    if (!SpeechRecognition) {
      setError('Speech recognition is not supported in this browser. Try Chrome or Safari.')
      return
    }

    const rec = new SpeechRecognition()
    rec.continuous = false
    rec.interimResults = true
    rec.lang = 'en-US'

    rec.onresult = (e: SpeechRecognitionEvent) => {
      const full = Array.from({ length: e.results.length }, (_, i) => e.results[i][0].transcript).join('')
      setTranscript(full)
    }

    rec.onerror = (e: Event & { error?: string }) => {
      setError(e.error ? `Recognition error: ${e.error}` : 'An unknown error occurred.')
      setIsRecording(false)
    }

    rec.onend = () => setIsRecording(false)

    rec.start()
    recognitionRef.current = rec
    setIsRecording(true)
    setTranscript('')
    setError(null)
  }, [])

  const stop = useCallback(() => {
    recognitionRef.current?.stop()
    setIsRecording(false)
  }, [])

  const reset = useCallback(() => {
    stop()
    setTranscript('')
    setError(null)
  }, [stop])

  // Cleanup on unmount
  useEffect(() => {
    return () => recognitionRef.current?.stop()
  }, [])

  return { isRecording, transcript, error, isSupported, start, stop, reset }
}
