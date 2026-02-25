export interface Recipe {
  id: string
  name: string
  description: string
  ingredients: string[]
  instructions: string[]
  prepTime: string
  cookTime: string
  servings: number
}

export type InputMode = 'photo' | 'text'
