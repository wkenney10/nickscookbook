import { useRef, useState } from 'react'
import type { InputMode } from '../types'

interface Props {
  ingredients: string[]
  mode: InputMode
  onAdd: (name: string) => void
  onRemove: (index: number) => void
}

export function IngredientsList({ ingredients, mode, onAdd, onRemove }: Props) {
  const [editing, setEditing] = useState(false)
  const [newItem, setNewItem] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)

  const handleAdd = () => {
    const parts = newItem.split(',').map(s => s.trim()).filter(Boolean)
    parts.forEach(onAdd)
    setNewItem('')
    inputRef.current?.focus()
  }

  return (
    <section className="bg-white rounded-2xl shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-4 pb-2">
        <div className="flex items-center gap-2">
          <span className="text-brand">
            {mode === 'text'
              ? <ListIcon />
              : <CartIcon />}
          </span>
          <h2 className="font-semibold text-gray-900">
            {mode === 'text' ? 'Your Ingredients' : 'Identified Ingredients'}
          </h2>
          <span className="text-xs text-gray-400 bg-gray-100 px-2 py-0.5 rounded-full">
            {ingredients.length}
          </span>
        </div>
        <button
          onClick={() => setEditing(e => !e)}
          className="text-sm font-medium text-brand"
        >
          {editing ? 'Done' : 'Edit'}
        </button>
      </div>

      {/* Tags */}
      <div className={`px-4 pb-3 ${editing ? '' : 'overflow-x-auto'}`}>
        <div className={`flex gap-2 ${editing ? 'flex-wrap' : 'flex-nowrap'} min-w-0`}>
          {ingredients.map((ing, i) => (
            <span
              key={i}
              className="inline-flex items-center gap-1 shrink-0 text-xs font-medium text-brand
                         bg-brand/10 border border-brand/20 px-3 py-1.5 rounded-full"
            >
              {ing.charAt(0).toUpperCase() + ing.slice(1)}
              {editing && (
                <button
                  onClick={() => onRemove(i)}
                  className="text-red-400 hover:text-red-600 transition-colors ml-0.5"
                  aria-label={`Remove ${ing}`}
                >
                  <XMarkIcon />
                </button>
              )}
            </span>
          ))}
        </div>
      </div>

      {/* Add field (edit mode) */}
      {editing && (
        <div className="px-4 pb-4 flex gap-2">
          <input
            ref={inputRef}
            value={newItem}
            onChange={e => setNewItem(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && handleAdd()}
            placeholder="Add ingredient… (comma-separated)"
            className="flex-1 text-sm px-3 py-2 rounded-xl border border-gray-200
                       focus:outline-none focus:border-brand transition-colors"
          />
          <button
            onClick={handleAdd}
            disabled={!newItem.trim()}
            className="px-3 py-2 text-brand disabled:text-gray-300 transition-colors"
            aria-label="Add ingredient"
          >
            <PlusCircleIcon />
          </button>
        </div>
      )}
    </section>
  )
}

function CartIcon() {
  return <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M17 18c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2m-10 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2M5.8 6l.9 2H18c.6 0 1 .4 1 1s-.4 1-1 1L7 10l-.8 1.5L5.6 13H19c.6 0 1 .4 1 1s-.4 1-1 1H5c-.5 0-.9-.3-1-.8L1.6 4H1c-.6 0-1-.4-1-1s.4-1 1-1h1.9c.4 0 .8.3.9.7L4.4 5H5.8z"/></svg>
}
function ListIcon() {
  return <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/></svg>
}
function XMarkIcon() {
  return <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20"><path d="M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22z"/></svg>
}
function PlusCircleIcon() {
  return <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm5 11h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/></svg>
}
