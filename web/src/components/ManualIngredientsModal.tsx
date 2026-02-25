import { useEffect, useRef, useState } from 'react'
import { useVoiceInput } from '../hooks/useVoiceInput'

interface Props {
  onSubmit: (ingredients: string[]) => void
  onClose: () => void
}

export function ManualIngredientsModal({ onSubmit, onClose }: Props) {
  const [ingredients, setIngredients] = useState<string[]>([])
  const [inputText, setInputText] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)
  const voice = useVoiceInput()

  // When voice stops recording, populate the input with the transcript
  useEffect(() => {
    if (!voice.isRecording && voice.transcript) {
      setInputText(voice.transcript)
    }
  }, [voice.isRecording, voice.transcript])

  const addFromText = () => {
    const parts = inputText.split(',').map(s => s.trim()).filter(Boolean)
    const toAdd = parts.filter(p => !ingredients.some(i => i.toLowerCase() === p.toLowerCase()))
    if (toAdd.length) setIngredients(prev => [...prev, ...toAdd])
    setInputText('')
    voice.reset()
    inputRef.current?.focus()
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') { e.preventDefault(); addFromText() }
  }

  const handleSubmit = () => {
    onClose()
    onSubmit(ingredients)
  }

  const toggleVoice = () => {
    if (voice.isRecording) {
      voice.stop()
    } else {
      setInputText('')
      voice.start()
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm fade-in" onClick={onClose} />

      {/* Sheet */}
      <div className="relative w-full sm:max-w-lg sm:mx-4 bg-white rounded-t-3xl sm:rounded-3xl
                      shadow-2xl slide-up-enter max-h-[90dvh] flex flex-col overflow-hidden">
        {/* Drag indicator */}
        <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mt-3 mb-1 sm:hidden flex-shrink-0" />

        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 flex-shrink-0">
          <h2 className="text-lg font-bold text-gray-900">Your Ingredients</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 p-1">
            <XIcon />
          </button>
        </div>

        {/* Input area */}
        <div className="px-5 pb-4 space-y-3 flex-shrink-0">
          {/* Text input row */}
          <div className="flex gap-2">
            <input
              ref={inputRef}
              value={inputText}
              onChange={e => setInputText(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="e.g., eggs, butter, garlic"
              autoCorrect="off"
              autoCapitalize="none"
              className="flex-1 px-4 py-2.5 text-sm border border-gray-200 rounded-xl
                         focus:outline-none focus:border-brand transition-colors"
            />
            <button
              onClick={addFromText}
              disabled={!inputText.trim()}
              className="text-brand disabled:text-gray-300 transition-colors px-2"
              aria-label="Add ingredient"
            >
              <PlusCircleIcon />
            </button>
          </div>

          {/* Voice row */}
          <div className="flex items-center gap-3">
            <button
              onClick={toggleVoice}
              className={`flex items-center gap-1.5 text-sm font-medium px-4 py-2 rounded-full transition-colors
                          ${voice.isRecording
                            ? 'bg-red-500 text-white'
                            : 'bg-brand/10 text-brand'}`}
            >
              {voice.isRecording
                ? <><PulseDot /><span>Stop</span></>
                : <><MicIcon /><span>Voice Input</span></>}
            </button>

            {voice.isRecording && (
              <span className="text-sm text-gray-500 flex-1 line-clamp-1">
                {voice.transcript || 'Listening…'}
              </span>
            )}
            {!voice.isRecording && !voice.isSupported && (
              <span className="text-xs text-gray-400">Not supported in this browser</span>
            )}
            {!voice.isRecording && voice.isSupported && !voice.transcript && (
              <span className="text-xs text-gray-400">Separate items with commas</span>
            )}
          </div>

          {/* Voice error */}
          {voice.error && (
            <p className="text-xs text-red-500">{voice.error}</p>
          )}
        </div>

        <div className="border-t border-gray-100 flex-shrink-0" />

        {/* Ingredient list */}
        <div className="flex-1 overflow-y-auto">
          {ingredients.length === 0 ? (
            <div className="flex flex-col items-center justify-center gap-3 py-10 text-center px-6">
              <span className="text-4xl">🛒</span>
              <p className="text-sm text-gray-400">
                Add ingredients above — type them or use voice input.
                <br />Separate multiple items with commas.
              </p>
            </div>
          ) : (
            <ul className="px-5 py-3 space-y-1">
              {ingredients.map((ing, i) => (
                <li key={i} className="flex items-center gap-3 py-2">
                  <span className="w-2 h-2 rounded-full bg-brand flex-shrink-0" />
                  <span className="flex-1 text-sm text-gray-800 capitalize">{ing}</span>
                  <button
                    onClick={() => setIngredients(prev => prev.filter((_, j) => j !== i))}
                    className="text-gray-300 hover:text-red-400 transition-colors"
                    aria-label={`Remove ${ing}`}
                  >
                    <XIcon />
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Footer action */}
        <div className="px-5 py-4 flex-shrink-0 border-t border-gray-100">
          <button
            onClick={handleSubmit}
            disabled={ingredients.length === 0}
            className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl font-semibold
                       text-white bg-brand disabled:bg-brand/40 transition-colors active:scale-[0.98]"
          >
            <WandIcon />
            Get Recipes
          </button>
        </div>
      </div>
    </div>
  )
}

function PulseDot() {
  return <span className="w-2.5 h-2.5 rounded-full bg-white pulse-dot inline-block" />
}
function XIcon() {
  return <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>
}
function PlusCircleIcon() {
  return <svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm5 11h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/></svg>
}
function MicIcon() {
  return <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.91-3c-.49 0-.9.36-.98.85C16.52 14.2 14.47 16 12 16s-4.52-1.8-4.93-4.15c-.08-.49-.49-.85-.98-.85-.61 0-1.09.54-1 1.14.49 3 2.89 5.35 5.91 5.78V20c0 .55.45 1 1 1s1-.45 1-1v-2.08c3.02-.43 5.42-2.78 5.91-5.78.1-.6-.39-1.14-1-1.14z"/></svg>
}
function WandIcon() {
  return <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M7.5 5.6L10 7 8.6 4.5 10 2 7.5 3.4 5 2l1.4 2.5L5 7zm12 9.8L17 14l1.4 2.5L17 19l2.5-1.4L22 19l-1.4-2.5L22 14zM22 2l-2.5 1.4L17 2l1.4 2.5L17 7l2.5-1.4L22 7l-1.4-2.5zm-7.63 5.29a1 1 0 0 0-1.41 0L1.29 18.96a1 1 0 0 0 0 1.41l2.34 2.34c.39.39 1.02.39 1.41 0L16.7 11.05a1 1 0 0 0 0-1.41l-2.33-2.35zm-1.03 5.49l-2.12-2.12 2.44-2.44 2.12 2.12-2.44 2.44z"/></svg>
}
