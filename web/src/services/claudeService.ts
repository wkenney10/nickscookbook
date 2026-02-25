import type { Recipe } from '../types'

const API_URL = 'https://api.anthropic.com/v1/messages'

type MsgRole = 'user' | 'assistant'
type RawMessage = { role: MsgRole; content: unknown }

// ---------------------------------------------------------------------------
// Image compression utility
// ---------------------------------------------------------------------------

export async function imageFileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const img = new Image()
    const url = URL.createObjectURL(file)

    img.onload = () => {
      const MAX = 1280
      let w = img.naturalWidth
      let h = img.naturalHeight
      if (w > MAX || h > MAX) {
        if (w >= h) { h = Math.round(h * MAX / w); w = MAX }
        else        { w = Math.round(w * MAX / h); h = MAX }
      }
      const canvas = document.createElement('canvas')
      canvas.width = w
      canvas.height = h
      const ctx = canvas.getContext('2d')!
      ctx.drawImage(img, 0, 0, w, h)
      URL.revokeObjectURL(url)
      // strip the "data:image/jpeg;base64," prefix
      resolve(canvas.toDataURL('image/jpeg', 0.8).split(',')[1])
    }

    img.onerror = () => {
      URL.revokeObjectURL(url)
      reject(new Error('Could not load image'))
    }
    img.src = url
  })
}

// ---------------------------------------------------------------------------
// ClaudeService
// ---------------------------------------------------------------------------

export class ClaudeService {
  private readonly apiKey: string
  private history: RawMessage[] = []

  constructor(apiKey: string) {
    this.apiKey = apiKey
  }

  async analyzeImage(base64: string): Promise<{ ingredients: string[]; recipes: Recipe[] }> {
    this.history = []

    const msg: RawMessage = {
      role: 'user',
      content: [
        {
          type: 'image',
          source: { type: 'base64', media_type: 'image/jpeg', data: base64 },
        },
        { type: 'text', text: INITIAL_PROMPT },
      ],
    }
    this.history.push(msg)

    const response = await this.call(SYSTEM_PROMPT)
    this.history.push({ role: 'assistant', content: response })
    return this.parse(response)
  }

  async analyzeTextIngredients(ingredients: string[]): Promise<{ ingredients: string[]; recipes: Recipe[] }> {
    this.history = []

    const list = ingredients.join(', ')
    const msg: RawMessage = {
      role: 'user',
      content: textIngredientPrompt(list),
    }
    this.history.push(msg)

    const response = await this.call(SYSTEM_PROMPT)
    this.history.push({ role: 'assistant', content: response })
    return this.parse(response)
  }

  async getMoreRecipes(feedback: string | null, currentIngredients: string[]): Promise<Recipe[]> {
    const feedbackClause = feedback?.trim()
      ? ` taking this feedback into account: "${feedback.trim()}"`
      : ''
    const list = currentIngredients.length
      ? currentIngredients.join(', ')
      : 'the same ingredients identified earlier'

    const prompt = `Please suggest 5 more different recipes${feedbackClause}. Use these ingredients: ${list}. Do NOT repeat any recipes already provided. Aim for variety — different cuisines, cooking methods, and meal types.

Respond ONLY with valid JSON in this exact format:
{
  "identified_ingredients": [],
  "recipes": [
    {
      "name": "Recipe Name",
      "description": "Brief appetizing description",
      "ingredients": ["amount ingredient", ...],
      "instructions": ["Step 1: ...", ...],
      "prep_time": "X minutes",
      "cook_time": "X minutes",
      "servings": 4
    }
  ]
}`

    this.history.push({ role: 'user', content: prompt })
    const response = await this.call(null)
    this.history.push({ role: 'assistant', content: response })
    const { recipes } = this.parse(response)
    return recipes
  }

  // ── Private ───────────────────────────────────────────────────────────────

  private async call(systemPrompt: string | null): Promise<string> {
    const body: Record<string, unknown> = {
      model: 'claude-opus-4-6',
      max_tokens: 4096,
      thinking: { type: 'adaptive' },
      messages: this.history,
    }
    if (systemPrompt) body.system = systemPrompt

    const res = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': this.apiKey,
        'anthropic-version': '2023-06-01',
        // Required for direct browser access
        'anthropic-dangerous-direct-browser-access': 'true',
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(180_000),
    })

    if (!res.ok) {
      const body = await res.text()
      throw new Error(`API Error ${res.status}: ${body}`)
    }

    const data = await res.json() as { content: Array<{ type: string; text?: string }> }
    const textBlock = data.content.find(b => b.type === 'text')
    if (!textBlock?.text) throw new Error('No text response from Claude')
    return textBlock.text
  }

  private parse(response: string): { ingredients: string[]; recipes: Recipe[] } {
    const jsonStr = extractJSON(response)
    const data = JSON.parse(jsonStr) as {
      identified_ingredients?: string[]
      recipes: Array<{
        name: string
        description: string
        ingredients: string[]
        instructions: string[]
        prep_time: string
        cook_time: string
        servings: number
      }>
    }

    const recipes: Recipe[] = data.recipes.map(r => ({
      id: crypto.randomUUID(),
      name: r.name,
      description: r.description,
      ingredients: r.ingredients,
      instructions: r.instructions,
      prepTime: r.prep_time,
      cookTime: r.cook_time,
      servings: r.servings,
    }))

    return { ingredients: data.identified_ingredients ?? [], recipes }
  }
}

// ---------------------------------------------------------------------------
// Helpers / prompts
// ---------------------------------------------------------------------------

function extractJSON(text: string): string {
  let depth = 0, start = -1
  for (let i = 0; i < text.length; i++) {
    if (text[i] === '{') {
      if (depth === 0) start = i
      depth++
    } else if (text[i] === '}') {
      depth--
      if (depth === 0 && start !== -1) return text.slice(start, i + 1)
    }
  }
  return text
}

function textIngredientPrompt(list: string): string {
  const quoted = list.split(',').map(s => `"${s.trim()}"`).join(', ')
  return `I have these ingredients available: ${list}

Please suggest exactly 5 delicious, practical recipes using these ingredients (supplemented by common pantry staples like oil, salt, pepper, pasta, rice, etc.).

Respond ONLY with a valid JSON object in this exact format — no other text:
{
  "identified_ingredients": [${quoted}],
  "recipes": [
    {
      "name": "Recipe Name",
      "description": "Brief, appetizing description (2-3 sentences)",
      "ingredients": ["2 cups ingredient1", "1 tbsp ingredient2", ...],
      "instructions": ["Step 1: ...", "Step 2: ...", ...],
      "prep_time": "15 minutes",
      "cook_time": "25 minutes",
      "servings": 4
    }
  ]
}

Make sure variety across the 5 recipes — different meals, cuisines, complexity levels.`
}

const SYSTEM_PROMPT = `You are Nick's Cookbook — a friendly, expert culinary assistant. Your specialty is identifying ingredients and crafting creative, delicious recipes from whatever is available.

Guidelines:
- Be practical: use visible ingredients as the foundation, supplemented by common pantry staples
- Be creative: suggest varied cuisines and cooking styles
- Be encouraging: write appetizing descriptions that make recipes sound irresistible
- Always respond with valid JSON only — no extra text before or after the JSON object`

const INITIAL_PROMPT = `Please analyze this fridge photo carefully and:
1. Identify all visible ingredients (be specific — note quantities where visible)
2. Suggest exactly 5 delicious, practical recipes using these ingredients

Respond ONLY with a valid JSON object in this exact format — no other text:
{
  "identified_ingredients": ["ingredient1", "ingredient2", ...],
  "recipes": [
    {
      "name": "Recipe Name",
      "description": "Brief, appetizing description (2-3 sentences)",
      "ingredients": ["2 cups ingredient1", "1 tbsp ingredient2", ...],
      "instructions": ["Step 1: ...", "Step 2: ...", ...],
      "prep_time": "15 minutes",
      "cook_time": "25 minutes",
      "servings": 4
    }
  ]
}

Make sure variety across the 5 recipes — different meals, cuisines, complexity levels.`
