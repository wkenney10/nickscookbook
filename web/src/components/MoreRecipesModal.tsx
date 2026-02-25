import { useState } from 'react'

const SUGGESTIONS = [
  'Vegetarian', 'Quick & easy', 'Healthy', 'Comfort food',
  'Asian cuisine', 'Italian', 'High protein', 'Kid-friendly',
]

interface Props {
  onSubmit: (feedback: string | null) => void
  onClose: () => void
  isLoading: boolean
}

export function MoreRecipesModal({ onSubmit, onClose, isLoading }: Props) {
  const [feedback, setFeedback] = useState('')

  const handleGet = (withFeedback: boolean) => {
    onClose()
    onSubmit(withFeedback && feedback.trim() ? feedback.trim() : null)
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm fade-in" onClick={onClose} />

      {/* Sheet */}
      <div className="relative w-full sm:max-w-lg sm:mx-4 bg-white rounded-t-3xl sm:rounded-3xl
                      shadow-2xl slide-up-enter overflow-hidden">
        {/* Drag indicator */}
        <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mt-3 sm:hidden" />

        {/* Content */}
        <div className="px-5 py-5 space-y-5">
          {/* Header */}
          <div className="text-center space-y-2">
            <div className="w-16 h-16 mx-auto rounded-full bg-brand/10 flex items-center justify-center">
              <SparklesIcon />
            </div>
            <h2 className="text-xl font-bold text-gray-900">Get More Recipe Ideas</h2>
            <p className="text-sm text-gray-500 leading-relaxed">
              Claude will suggest 5 more recipes using the same ingredients — completely different from what you've already seen.
            </p>
          </div>

          {/* Info pills */}
          <div className="grid grid-cols-3 gap-2">
            <InfoPill color="green"  icon="↺" text="No repeated recipes" />
            <InfoPill color="blue"   icon="🌍" text="Varied cuisines"    />
            <InfoPill color="orange" icon="+"  text="Added to list"      />
          </div>

          {/* Feedback */}
          <div className="space-y-2.5">
            <div className="flex items-center gap-2">
              <BubbleIcon />
              <span className="font-semibold text-gray-900 text-sm">Feedback (optional)</span>
              {feedback && (
                <button
                  onClick={() => setFeedback('')}
                  className="ml-auto text-xs text-brand font-medium"
                >
                  Clear
                </button>
              )}
            </div>

            {/* Quick chips */}
            <div className="flex flex-wrap gap-1.5">
              {SUGGESTIONS.map(s => (
                <button
                  key={s}
                  onClick={() => setFeedback(prev => prev === s ? '' : s)}
                  className={`text-xs font-medium px-3 py-1.5 rounded-full transition-colors
                              ${feedback === s
                                ? 'bg-brand text-white'
                                : 'bg-brand/10 text-brand'}`}
                >
                  {s}
                </button>
              ))}
            </div>

            <textarea
              value={feedback}
              onChange={e => setFeedback(e.target.value)}
              placeholder='e.g., "Something vegetarian" or "Quick weeknight dinner"'
              rows={3}
              className="w-full resize-none text-sm px-4 py-3 border border-gray-200 rounded-xl
                         focus:outline-none focus:border-brand transition-colors"
            />
          </div>

          {/* Buttons */}
          <div className="space-y-2 pb-1">
            <button
              onClick={() => handleGet(true)}
              disabled={isLoading}
              className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl
                         font-semibold text-white bg-brand disabled:bg-brand/50 transition-colors
                         active:scale-[0.98]"
            >
              <SparklesIcon />
              {feedback.trim() ? 'Get Recipes with Feedback' : 'Get 5 More Recipes'}
            </button>

            {feedback.trim() && (
              <button
                onClick={() => handleGet(false)}
                className="w-full py-3 rounded-2xl text-brand font-medium text-sm
                           bg-brand/10 active:scale-[0.98] transition-transform"
              >
                Get Recipes Without Feedback
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function InfoPill({ color, icon, text }: { color: 'green' | 'blue' | 'orange'; icon: string; text: string }) {
  const colors = {
    green:  'bg-green-50  text-green-700',
    blue:   'bg-blue-50   text-blue-700',
    orange: 'bg-brand/10  text-brand',
  }
  return (
    <div className={`${colors[color]} rounded-xl py-3 px-2 text-center space-y-1`}>
      <span className="text-base">{icon}</span>
      <p className="text-[11px] font-medium leading-tight">{text}</p>
    </div>
  )
}

function SparklesIcon() {
  return <svg className="w-5 h-5 text-brand" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.3 2.4-7.4L2 9.4h7.6z"/></svg>
}
function BubbleIcon() {
  return <svg className="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 24 24"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/></svg>
}
