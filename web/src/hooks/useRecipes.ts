import { useCallback, useRef, useState } from 'react'
import type { InputMode, Recipe } from '../types'
import { ClaudeService, imageFileToBase64 } from '../services/claudeService'

const API_KEY_STORAGE = 'NCB_anthropic_api_key'

function buildService(key: string): ClaudeService | null {
  const k = key.trim()
  return k ? new ClaudeService(k) : null
}

export function useRecipes() {
  const [apiKey, setApiKeyState] = useState<string>(
    () => localStorage.getItem(API_KEY_STORAGE) ?? ''
  )
  const [recipes, setRecipes] = useState<Recipe[]>([])
  const [identifiedIngredients, setIdentifiedIngredients] = useState<string[]>([])
  const [selectedImageUrl, setSelectedImageUrl] = useState<string | null>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [isLoadingMore, setIsLoadingMore] = useState(false)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [hasAnalyzed, setHasAnalyzed] = useState(false)
  const [inputMode, setInputMode] = useState<InputMode>('photo')

  const serviceRef = useRef<ClaudeService | null>(buildService(apiKey))

  const saveApiKey = useCallback((key: string) => {
    const trimmed = key.trim()
    localStorage.setItem(API_KEY_STORAGE, trimmed)
    setApiKeyState(trimmed)
    serviceRef.current = buildService(trimmed)
  }, [])

  const analyzeImage = useCallback(async (file: File) => {
    const service = serviceRef.current
    if (!service) {
      setErrorMessage('Please add your Anthropic API key in Settings (gear icon).')
      return
    }

    const imageUrl = URL.createObjectURL(file)
    setSelectedImageUrl(imageUrl)
    setIsAnalyzing(true)
    setInputMode('photo')
    setErrorMessage(null)
    setRecipes([])
    setIdentifiedIngredients([])
    setHasAnalyzed(false)

    try {
      const base64 = await imageFileToBase64(file)
      const { ingredients, recipes: newRecipes } = await service.analyzeImage(base64)
      setIdentifiedIngredients(ingredients)
      setRecipes(newRecipes)
      setHasAnalyzed(true)
    } catch (e) {
      setErrorMessage(e instanceof Error ? e.message : String(e))
    } finally {
      setIsAnalyzing(false)
    }
  }, [])

  const analyzeTextIngredients = useCallback(async (ingredients: string[]) => {
    const service = serviceRef.current
    if (!service) {
      setErrorMessage('Please add your Anthropic API key in Settings (gear icon).')
      return
    }
    if (!ingredients.length) {
      setErrorMessage('Please add at least one ingredient.')
      return
    }

    setIsAnalyzing(true)
    setInputMode('text')
    setErrorMessage(null)
    setRecipes([])
    setIdentifiedIngredients([])
    setSelectedImageUrl(null)
    setHasAnalyzed(false)

    try {
      const { ingredients: returned, recipes: newRecipes } = await service.analyzeTextIngredients(ingredients)
      setIdentifiedIngredients(returned.length ? returned : ingredients)
      setRecipes(newRecipes)
      setHasAnalyzed(true)
    } catch (e) {
      setErrorMessage(e instanceof Error ? e.message : String(e))
    } finally {
      setIsAnalyzing(false)
    }
  }, [])

  const getMoreRecipes = useCallback(async (feedback: string | null) => {
    const service = serviceRef.current
    if (!service || !hasAnalyzed) return

    setIsLoadingMore(true)
    setErrorMessage(null)

    try {
      const more = await service.getMoreRecipes(feedback, identifiedIngredients)
      setRecipes(prev => [...prev, ...more])
    } catch (e) {
      setErrorMessage(e instanceof Error ? e.message : String(e))
    } finally {
      setIsLoadingMore(false)
    }
  }, [hasAnalyzed, identifiedIngredients])

  const addIngredient = useCallback((name: string) => {
    const trimmed = name.trim()
    if (!trimmed) return
    setIdentifiedIngredients(prev => {
      if (prev.some(i => i.toLowerCase() === trimmed.toLowerCase())) return prev
      return [...prev, trimmed]
    })
  }, [])

  const removeIngredient = useCallback((index: number) => {
    setIdentifiedIngredients(prev => prev.filter((_, i) => i !== index))
  }, [])

  const reset = useCallback(() => {
    setRecipes([])
    setIdentifiedIngredients([])
    setSelectedImageUrl(null)
    setIsAnalyzing(false)
    setIsLoadingMore(false)
    setErrorMessage(null)
    setHasAnalyzed(false)
    setInputMode('photo')
  }, [])

  return {
    apiKey,
    saveApiKey,
    recipes,
    identifiedIngredients,
    selectedImageUrl,
    isAnalyzing,
    isLoadingMore,
    errorMessage,
    hasAnalyzed,
    inputMode,
    analyzeImage,
    analyzeTextIngredients,
    getMoreRecipes,
    addIngredient,
    removeIngredient,
    reset,
  }
}
