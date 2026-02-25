import type { Recipe } from '../types'

const GRADIENT_PAIRS = [
  ['#FF9500', '#FFCC02'],
  ['#FF2D55', '#FF6B35'],
  ['#AF52DE', '#FF375F'],
  ['#007AFF', '#34C6E8'],
  ['#34C759', '#30B0C7'],
  ['#5856D6', '#007AFF'],
  ['#FF3B30', '#FF6B6B'],
  ['#FFCC02', '#FF9500'],
  ['#30B0C7', '#34C759'],
  ['#BF5AF2', '#7B68EE'],
]

interface Props {
  recipe: Recipe
  index: number
  onClick: () => void
}

export function RecipeCard({ recipe, index, onClick }: Props) {
  const [from, to] = GRADIENT_PAIRS[index % GRADIENT_PAIRS.length]

  return (
    <button
      onClick={onClick}
      className="w-full text-left bg-white rounded-2xl shadow-sm overflow-hidden
                 active:scale-[0.985] transition-transform hover:shadow-md"
    >
      {/* Gradient header bar */}
      <div
        className="h-24 flex items-end p-4 gap-3"
        style={{ background: `linear-gradient(135deg, ${from}, ${to})` }}
      >
        {/* Index badge */}
        <span className="flex-shrink-0 w-8 h-8 rounded-full bg-white/30 text-white
                         font-bold text-sm flex items-center justify-center backdrop-blur-sm">
          {index + 1}
        </span>
        <h3 className="flex-1 font-bold text-white text-lg leading-tight drop-shadow-sm line-clamp-2">
          {recipe.name}
        </h3>
        <ChevronRightIcon />
      </div>

      {/* Card body */}
      <div className="px-4 py-3 space-y-2">
        <p className="text-sm text-gray-500 line-clamp-2">{recipe.description}</p>

        <div className="flex items-center gap-4 text-xs text-gray-400">
          <MetaItem icon="⏱" value={recipe.prepTime} label="prep" />
          <MetaItem icon="🔥" value={recipe.cookTime} label="cook" />
          <MetaItem icon="👥" value={String(recipe.servings)} label="servings" />
          <span className="ml-auto text-xs text-gray-400">
            {recipe.ingredients.length} ingredients
          </span>
        </div>
      </div>
    </button>
  )
}

function MetaItem({ icon, value, label }: { icon: string; value: string; label: string }) {
  return (
    <span className="flex items-center gap-1">
      <span>{icon}</span>
      <span className="font-medium text-gray-600">{value}</span>
      <span>{label}</span>
    </span>
  )
}

function ChevronRightIcon() {
  return (
    <svg className="w-5 h-5 text-white/80 flex-shrink-0" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
    </svg>
  )
}
