import { useState } from 'react'
import type { Recipe } from '../types'

interface Props {
  recipe: Recipe
  onClose: () => void
}

export function RecipeDetail({ recipe, onClose }: Props) {
  const [servings, setServings] = useState(recipe.servings)
  const [completedSteps, setCompletedSteps] = useState<Set<number>>(new Set())

  const scale = servings / recipe.servings

  const scaledIngredient = (text: string) => {
    if (scale === 1) return text
    return text.replace(/(\d+(?:\.\d+)?)/g, (match) => {
      const n = parseFloat(match) * scale
      return Number.isInteger(n) ? String(n) : n.toFixed(1)
    })
  }

  const toggleStep = (i: number) => {
    setCompletedSteps(prev => {
      const next = new Set(prev)
      next.has(i) ? next.delete(i) : next.add(i)
      return next
    })
  }

  const shareText = [
    `🍽 ${recipe.name}`,
    '',
    recipe.description,
    '',
    `⏱ Prep: ${recipe.prepTime} | 🔥 Cook: ${recipe.cookTime} | 👥 Serves ${recipe.servings}`,
    '',
    '📋 Ingredients:',
    ...recipe.ingredients.map(i => `• ${i}`),
    '',
    '👨‍🍳 Instructions:',
    ...recipe.instructions.map((s, i) => `${i + 1}. ${s}`),
    '',
    '— From Nick\'s Cookbook',
  ].join('\n')

  const handleShare = async () => {
    if (navigator.share) {
      await navigator.share({ title: recipe.name, text: shareText })
    } else {
      await navigator.clipboard.writeText(shareText)
      alert('Recipe copied to clipboard!')
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/40 backdrop-blur-sm fade-in"
        onClick={onClose}
      />

      {/* Sheet */}
      <div className="relative w-full sm:max-w-2xl sm:mx-4 bg-white rounded-t-3xl sm:rounded-3xl
                      overflow-hidden shadow-2xl slide-up-enter max-h-[92dvh] flex flex-col">
        {/* Hero header */}
        <div className="bg-gradient-to-br from-brand to-yellow-400 px-5 pt-5 pb-6 flex-shrink-0">
          {/* Drag indicator (mobile) */}
          <div className="w-10 h-1 bg-white/40 rounded-full mx-auto mb-4 sm:hidden" />

          <div className="flex items-start justify-between gap-3">
            <div className="flex-1 min-w-0">
              <h2 className="text-2xl font-bold text-white leading-tight">{recipe.name}</h2>
              <p className="text-white/85 text-sm mt-1 leading-relaxed">{recipe.description}</p>
            </div>
            <button onClick={onClose} className="flex-shrink-0 text-white/80 hover:text-white p-1">
              <XMarkLargeIcon />
            </button>
          </div>

          {/* Stats row */}
          <div className="mt-4 bg-white/20 rounded-2xl grid grid-cols-3 divide-x divide-white/20">
            <StatBox icon="⏱" value={recipe.prepTime} label="Prep" />
            <StatBox icon="🔥" value={recipe.cookTime} label="Cook" />
            <div className="flex flex-col items-center py-3 px-2 gap-1">
              <span className="text-base">👥</span>
              <div className="flex items-center gap-1.5">
                <button
                  onClick={() => setServings(s => Math.max(1, s - 1))}
                  className="w-6 h-6 rounded-full bg-white/30 text-white font-bold text-sm
                             flex items-center justify-center active:scale-90 transition-transform"
                  disabled={servings <= 1}
                >
                  −
                </button>
                <span className="text-white font-semibold text-sm min-w-[1.5ch] text-center">
                  {servings}
                </span>
                <button
                  onClick={() => setServings(s => s + 1)}
                  className="w-6 h-6 rounded-full bg-white/30 text-white font-bold text-sm
                             flex items-center justify-center active:scale-90 transition-transform"
                >
                  +
                </button>
              </div>
              <span className="text-white/75 text-[11px]">Servings</span>
            </div>
          </div>
        </div>

        {/* Scrollable content */}
        <div className="overflow-y-auto flex-1 pb-6">
          {/* Ingredients */}
          <section className="px-5 pt-5">
            <h3 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-brand/10 text-brand flex items-center justify-center text-xs">
                {recipe.ingredients.length}
              </span>
              Ingredients
              {scale !== 1 && (
                <span className="text-xs text-brand font-normal ml-1">
                  (scaled ×{scale.toFixed(1)})
                </span>
              )}
            </h3>
            <ul className="space-y-2">
              {recipe.ingredients.map((ing, i) => (
                <li key={i} className="flex gap-2.5 text-sm text-gray-700">
                  <span className="w-2 h-2 rounded-full bg-brand mt-1.5 flex-shrink-0" />
                  {scaledIngredient(ing)}
                </li>
              ))}
            </ul>
          </section>

          {/* Instructions */}
          <section className="px-5 pt-6">
            <h3 className="font-semibold text-gray-900 mb-3">Instructions</h3>
            <ol className="space-y-3">
              {recipe.instructions.map((step, i) => {
                const done = completedSteps.has(i)
                return (
                  <li
                    key={i}
                    onClick={() => toggleStep(i)}
                    className={`flex gap-3 text-sm cursor-pointer rounded-xl p-3 transition-colors
                                ${done ? 'bg-green-50' : 'hover:bg-gray-50'}`}
                  >
                    <span
                      className={`flex-shrink-0 w-7 h-7 rounded-full flex items-center justify-center
                                  text-xs font-bold transition-colors
                                  ${done
                                    ? 'bg-green-500 text-white'
                                    : 'bg-brand text-white'}`}
                    >
                      {done ? '✓' : i + 1}
                    </span>
                    <span className={`leading-relaxed text-gray-700 ${done ? 'line-through opacity-50' : ''}`}>
                      {step}
                    </span>
                  </li>
                )
              })}
            </ol>
          </section>
        </div>

        {/* Share bar */}
        <div className="flex-shrink-0 px-5 py-3 bg-white border-t border-gray-100">
          <button
            onClick={handleShare}
            className="w-full flex items-center justify-center gap-2 py-3 rounded-2xl
                       bg-brand/10 text-brand font-semibold text-sm active:scale-[0.98] transition-transform"
          >
            <ShareIcon />
            Share Recipe
          </button>
        </div>
      </div>
    </div>
  )
}

function StatBox({ icon, value, label }: { icon: string; value: string; label: string }) {
  return (
    <div className="flex flex-col items-center py-3 px-2 gap-0.5">
      <span className="text-base">{icon}</span>
      <span className="text-white font-semibold text-xs leading-tight">{value}</span>
      <span className="text-white/70 text-[11px]">{label}</span>
    </div>
  )
}

function XMarkLargeIcon() {
  return (
    <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
    </svg>
  )
}
function ShareIcon() {
  return (
    <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M7.217 10.907a2.25 2.25 0 100 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186l9.566-5.314m-9.566 7.5l9.566 5.314m0 0a2.25 2.25 0 103.935 2.186 2.25 2.25 0 00-3.935-2.186zm0-12.814a2.25 2.25 0 103.933-2.185 2.25 2.25 0 00-3.933 2.185z" />
    </svg>
  )
}
