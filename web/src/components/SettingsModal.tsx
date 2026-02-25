import { useState } from 'react'

interface Props {
  currentKey: string
  onSave: (key: string) => void
  onClose: () => void
}

export function SettingsModal({ currentKey, onSave, onClose }: Props) {
  const [draft, setDraft] = useState(currentKey)
  const [visible, setVisible] = useState(false)
  const [saved, setSaved] = useState(false)

  const maskedKey = currentKey.length > 11
    ? `${currentKey.slice(0, 7)}...${currentKey.slice(-4)}`
    : currentKey

  const handleSave = () => {
    const k = draft.trim()
    if (!k) return
    onSave(k)
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  const handleClear = () => {
    onSave('')
    setDraft('')
    setSaved(false)
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm fade-in" onClick={onClose} />

      {/* Sheet */}
      <div className="relative w-full sm:max-w-md sm:mx-4 bg-white rounded-t-3xl sm:rounded-3xl
                      shadow-2xl slide-up-enter overflow-hidden">
        {/* Drag indicator */}
        <div className="w-10 h-1 bg-gray-200 rounded-full mx-auto mt-3 sm:hidden" />

        <div className="px-5 py-5 space-y-5">
          {/* Header */}
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-bold text-gray-900">Settings</h2>
            <button onClick={onClose} className="text-gray-400 hover:text-gray-600 p-1">
              <XIcon />
            </button>
          </div>

          {/* API key section */}
          <div className="space-y-3">
            <h3 className="font-semibold text-gray-800 text-sm">Anthropic API Key</h3>

            {/* Status */}
            {currentKey ? (
              <div className="flex items-center gap-2 text-sm text-green-700 bg-green-50 px-3 py-2 rounded-xl">
                <CheckIcon />
                <span>Configured: <code className="font-mono">{maskedKey}</code></span>
              </div>
            ) : (
              <div className="flex items-center gap-2 text-sm text-amber-700 bg-amber-50 px-3 py-2 rounded-xl">
                <WarningIcon />
                No API key configured
              </div>
            )}

            {/* Input */}
            <div className="flex gap-2">
              <div className="flex-1 relative">
                <input
                  type={visible ? 'text' : 'password'}
                  value={draft}
                  onChange={e => setDraft(e.target.value)}
                  onKeyDown={e => e.key === 'Enter' && handleSave()}
                  placeholder="sk-ant-..."
                  autoCorrect="off"
                  autoCapitalize="none"
                  spellCheck={false}
                  className="w-full px-4 py-2.5 text-sm font-mono border border-gray-200 rounded-xl
                             focus:outline-none focus:border-brand pr-10 transition-colors"
                />
                <button
                  onClick={() => setVisible(v => !v)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {visible ? <EyeOffIcon /> : <EyeIcon />}
                </button>
              </div>
            </div>

            {/* Save / Clear */}
            <div className="flex gap-2">
              <button
                onClick={handleSave}
                disabled={!draft.trim()}
                className={`flex-1 py-2.5 rounded-xl font-semibold text-sm transition-colors
                            ${saved
                              ? 'bg-green-500 text-white'
                              : 'bg-brand text-white disabled:bg-brand/40'}`}
              >
                {saved ? '✓ Saved!' : 'Save Key'}
              </button>
              {currentKey && (
                <button
                  onClick={handleClear}
                  className="px-4 py-2.5 rounded-xl font-semibold text-sm text-red-600 bg-red-50"
                >
                  Clear
                </button>
              )}
            </div>
          </div>

          {/* Instructions */}
          <div className="space-y-2">
            <h3 className="font-semibold text-gray-800 text-sm">How to get an API key</h3>
            <ol className="text-sm text-gray-500 space-y-1 list-decimal list-inside">
              <li>Visit <span className="text-brand font-medium">console.anthropic.com</span></li>
              <li>Create or sign in to your account</li>
              <li>Go to <strong>API Keys</strong> → <strong>Create Key</strong></li>
              <li>Copy and paste the key above</li>
            </ol>
            <p className="text-xs text-gray-400 mt-2">
              Your key is stored locally in your browser and never sent to any server other than Anthropic's API.
            </p>
          </div>

          {/* About */}
          <div className="pt-2 border-t border-gray-100 text-xs text-gray-400 flex justify-between">
            <span>Nick's Cookbook · Web</span>
            <span>Powered by claude-opus-4-6</span>
          </div>
        </div>
      </div>
    </div>
  )
}

function XIcon() {
  return <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>
}
function CheckIcon() {
  return <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
}
function WarningIcon() {
  return <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" /></svg>
}
function EyeIcon() {
  return <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z" /><path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
}
function EyeOffIcon() {
  return <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" /></svg>
}
