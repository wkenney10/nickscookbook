import { useRef } from 'react'
import { NickLogo } from './NickLogo'

interface Props {
  onImageFile: (file: File) => void
  onTypeIngredients: () => void
}

export function EmptyState({ onImageFile, onTypeIngredients }: Props) {
  const cameraRef = useRef<HTMLInputElement>(null)
  const galleryRef = useRef<HTMLInputElement>(null)

  const handleFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) onImageFile(file)
    // reset so the same file can be re-selected
    e.target.value = ''
  }

  return (
    <div className="flex flex-col items-center justify-center gap-6 px-6 py-12 text-center min-h-[460px]">
      {/* Logo */}
      <div className="drop-shadow-lg">
        <NickLogo size={112} />
      </div>

      {/* Title */}
      <div className="space-y-2">
        <h1 className="text-3xl font-bold tracking-tight text-gray-900">
          Nick's Cookbook
        </h1>
        <p className="text-gray-500 text-[15px] leading-relaxed max-w-xs mx-auto">
          Snap a photo of your fridge, type what you have, or speak your ingredients —
          Claude will craft personalized recipes on the spot.
        </p>
      </div>

      {/* Action buttons */}
      <div className="w-full max-w-xs space-y-3">
        {/* Camera */}
        <button
          onClick={() => cameraRef.current?.click()}
          className="w-full flex items-center justify-center gap-2.5 bg-brand text-white font-semibold py-4 rounded-2xl shadow-sm active:scale-[0.98] transition-transform"
        >
          <CameraIcon />
          Take a Photo
        </button>

        {/* Gallery */}
        <button
          onClick={() => galleryRef.current?.click()}
          className="w-full flex items-center justify-center gap-2.5 bg-blue-500 text-white font-semibold py-4 rounded-2xl shadow-sm active:scale-[0.98] transition-transform"
        >
          <PhotoIcon />
          Choose from Library
        </button>

        {/* Type / Voice */}
        <button
          onClick={onTypeIngredients}
          className="w-full flex items-center justify-center gap-2.5 bg-green-600 text-white font-semibold py-4 rounded-2xl shadow-sm active:scale-[0.98] transition-transform"
        >
          <KeyboardIcon />
          Type or Speak Ingredients
        </button>
      </div>

      {/* Hidden file inputs */}
      <input
        ref={cameraRef}
        type="file"
        accept="image/*"
        capture="environment"
        className="hidden"
        onChange={handleFile}
      />
      <input
        ref={galleryRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={handleFile}
      />
    </div>
  )
}

function CameraIcon() {
  return (
    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
      <path d="M12 15.5A3.5 3.5 0 0 1 8.5 12 3.5 3.5 0 0 1 12 8.5a3.5 3.5 0 0 1 3.5 3.5 3.5 3.5 0 0 1-3.5 3.5m7-10l-2-2H7L5 5.5H3A2 2 0 0 0 1 7.5v12a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2v-12a2 2 0 0 0-2-2h-2Z" />
    </svg>
  )
}
function PhotoIcon() {
  return (
    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
      <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z" />
    </svg>
  )
}
function KeyboardIcon() {
  return (
    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
      <path d="M20 5H4c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm-9 3h2v2h-2V8zm0 3h2v2h-2v-2zM8 8h2v2H8V8zm0 3h2v2H8v-2zm-1 5H5v-2h2v2zm9 0H8v-2h8v2zm2 0h-2v-2h2v2zm0-3h-2v-2h2v2zm0-3h-2V8h2v2zm-4-3h2v2h-2V8zm0 3h2v2h-2v-2z"/>
    </svg>
  )
}
