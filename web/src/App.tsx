import { useRef, useState } from 'react'
import { useRecipes } from './hooks/useRecipes'
import type { Recipe } from './types'

import { NickLogo }                from './components/NickLogo'
import { EmptyState }              from './components/EmptyState'
import { AnalyzingView }           from './components/AnalyzingView'
import { IngredientsList }         from './components/IngredientsList'
import { RecipeCard }              from './components/RecipeCard'
import { RecipeDetail }            from './components/RecipeDetail'
import { ManualIngredientsModal }  from './components/ManualIngredientsModal'
import { MoreRecipesModal }        from './components/MoreRecipesModal'
import { SettingsModal }           from './components/SettingsModal'

export default function App() {
  const recipes = useRecipes()

  // Modal visibility
  const [showSettings,    setShowSettings]    = useState(false)
  const [showManualInput, setShowManualInput] = useState(false)
  const [showMoreRecipes, setShowMoreRecipes] = useState(false)
  const [selectedRecipe,  setSelectedRecipe]  = useState<Recipe | null>(null)

  // File input refs (for photo retake from results view)
  const cameraRef  = useRef<HTMLInputElement>(null)
  const galleryRef = useRef<HTMLInputElement>(null)

  const handleFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) recipes.analyzeImage(file)
    e.target.value = ''
  }

  return (
    <div className="min-h-dvh bg-gray-50 flex flex-col">
      {/* ── Header ────────────────────────────────────────────────────── */}
      <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b border-gray-100
                         flex items-center justify-between px-4 h-14 flex-shrink-0">
        {/* Left: Start Over (when results visible) */}
        <div className="w-20 flex justify-start">
          {recipes.hasAnalyzed && !recipes.isAnalyzing && (
            <button
              onClick={() => { recipes.reset(); setSelectedRecipe(null) }}
              className="text-sm font-medium text-brand"
            >
              Start Over
            </button>
          )}
        </div>

        {/* Centre: Logo + title */}
        <div className="flex items-center gap-2.5">
          <NickLogo size={32} />
          <span className="font-bold text-gray-900 text-[17px] tracking-tight">
            Nick's Cookbook
          </span>
        </div>

        {/* Right: Settings gear */}
        <div className="w-20 flex justify-end">
          <button
            onClick={() => setShowSettings(true)}
            className="text-gray-500 hover:text-gray-700 p-1.5 rounded-full
                       hover:bg-gray-100 transition-colors"
            aria-label="Settings"
          >
            <GearIcon />
          </button>
        </div>
      </header>

      {/* ── Main content ──────────────────────────────────────────────── */}
      <main className="flex-1 w-full max-w-2xl mx-auto px-4 py-4 pb-12 space-y-4">

        {/* Empty state */}
        {!recipes.hasAnalyzed && !recipes.isAnalyzing && (
          <EmptyState
            onImageFile={file => recipes.analyzeImage(file)}
            onTypeIngredients={() => setShowManualInput(true)}
          />
        )}

        {/* Analyzing */}
        {recipes.isAnalyzing && (
          <AnalyzingView mode={recipes.inputMode} />
        )}

        {/* Results */}
        {recipes.hasAnalyzed && !recipes.isAnalyzing && (
          <>
            {/* Photo preview (photo mode only) */}
            {recipes.selectedImageUrl && (
              <div className="relative rounded-2xl overflow-hidden bg-black shadow-sm">
                <img
                  src={recipes.selectedImageUrl}
                  alt="Your fridge"
                  className="w-full object-cover max-h-72"
                />
                <button
                  onClick={() => cameraRef.current?.click()}
                  className="absolute bottom-3 right-3 flex items-center gap-1.5 text-xs font-semibold
                             text-white bg-black/60 backdrop-blur-sm px-3 py-1.5 rounded-full"
                >
                  <CameraSmallIcon />
                  Retake
                </button>
              </div>
            )}

            {/* Ingredients */}
            {recipes.identifiedIngredients.length > 0 && (
              <IngredientsList
                ingredients={recipes.identifiedIngredients}
                mode={recipes.inputMode}
                onAdd={recipes.addIngredient}
                onRemove={recipes.removeIngredient}
              />
            )}

            {/* Error banner */}
            {recipes.errorMessage && (
              <ErrorBanner message={recipes.errorMessage} />
            )}

            {/* Recipe count header */}
            <div className="flex items-center gap-2 px-1">
              <ForkKnifeIcon />
              <h2 className="font-semibold text-gray-900">
                {recipes.recipes.length} Recipe{recipes.recipes.length !== 1 ? 's' : ''}
              </h2>
            </div>

            {/* Recipe grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {recipes.recipes.map((recipe, i) => (
                <RecipeCard
                  key={recipe.id}
                  recipe={recipe}
                  index={i}
                  onClick={() => setSelectedRecipe(recipe)}
                />
              ))}
            </div>

            {/* More recipes button */}
            <button
              onClick={() => setShowMoreRecipes(true)}
              disabled={recipes.isLoadingMore}
              className="w-full flex items-center justify-center gap-2.5 py-4 rounded-2xl
                         bg-brand text-white font-semibold shadow-sm
                         disabled:bg-brand/60 active:scale-[0.98] transition-transform"
            >
              {recipes.isLoadingMore
                ? <><Spinner />Getting more recipes…</>
                : <><PlusCircleIcon />Get More Recipes</>}
            </button>
          </>
        )}

        {/* Error in empty/analyzing state */}
        {!recipes.hasAnalyzed && recipes.errorMessage && (
          <ErrorBanner message={recipes.errorMessage} />
        )}
      </main>

      {/* Hidden file inputs for retake */}
      <input ref={cameraRef}  type="file" accept="image/*" capture="environment" className="hidden" onChange={handleFile} />
      <input ref={galleryRef} type="file" accept="image/*"                       className="hidden" onChange={handleFile} />

      {/* ── Modals / Sheets ───────────────────────────────────────────── */}
      {selectedRecipe && (
        <RecipeDetail
          recipe={selectedRecipe}
          onClose={() => setSelectedRecipe(null)}
        />
      )}

      {showManualInput && (
        <ManualIngredientsModal
          onSubmit={ings => recipes.analyzeTextIngredients(ings)}
          onClose={() => setShowManualInput(false)}
        />
      )}

      {showMoreRecipes && (
        <MoreRecipesModal
          onSubmit={feedback => recipes.getMoreRecipes(feedback)}
          onClose={() => setShowMoreRecipes(false)}
          isLoading={recipes.isLoadingMore}
        />
      )}

      {showSettings && (
        <SettingsModal
          currentKey={recipes.apiKey}
          onSave={key => recipes.saveApiKey(key)}
          onClose={() => setShowSettings(false)}
        />
      )}
    </div>
  )
}

// ── Small utility components ──────────────────────────────────────────────

function ErrorBanner({ message }: { message: string }) {
  return (
    <div className="flex gap-2.5 p-3.5 bg-red-50 border border-red-200 rounded-2xl text-sm text-red-700">
      <span className="flex-shrink-0">⚠️</span>
      <span>{message}</span>
    </div>
  )
}

function Spinner() {
  return <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
}

function GearIcon() {
  return <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={1.75} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z" /><path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" /></svg>
}
function ForkKnifeIcon() {
  return <svg className="w-4 h-4 text-brand" fill="currentColor" viewBox="0 0 24 24"><path d="M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z"/></svg>
}
function PlusCircleIcon() {
  return <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm5 11h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/></svg>
}
function CameraSmallIcon() {
  return <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 15.5A3.5 3.5 0 0 1 8.5 12 3.5 3.5 0 0 1 12 8.5a3.5 3.5 0 0 1 3.5 3.5 3.5 3.5 0 0 1-3.5 3.5m7-10l-2-2H7L5 5.5H3A2 2 0 0 0 1 7.5v12a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2v-12a2 2 0 0 0-2-2h-2Z"/></svg>
}
