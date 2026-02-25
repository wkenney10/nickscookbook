import type { InputMode } from '../types'

export function AnalyzingView({ mode }: { mode: InputMode }) {
  return (
    <div className="flex flex-col items-center justify-center gap-5 py-20 px-6 text-center">
      {/* Spinner */}
      <div className="w-14 h-14 border-4 border-brand/20 border-t-brand rounded-full animate-spin" />

      <div className="space-y-1.5">
        <p className="text-lg font-semibold text-gray-900">
          {mode === 'text' ? 'Finding your recipes…' : 'Analyzing your fridge…'}
        </p>
        <p className="text-sm text-gray-500">
          {mode === 'text'
            ? 'Crafting recipes from your ingredient list'
            : 'Identifying ingredients and crafting recipes'}
        </p>
      </div>
    </div>
  )
}
