/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '#FF9500',
          50:  '#FFF5E6',
          100: '#FFE6B3',
          200: '#FFD480',
          300: '#FFC14D',
          400: '#FFAD1A',
          500: '#FF9500',
          600: '#E68500',
          700: '#CC7600',
          800: '#B36600',
          900: '#995700',
        },
      },
      fontFamily: {
        sans: [
          '-apple-system', 'BlinkMacSystemFont', '"Segoe UI"', 'Roboto',
          '"Helvetica Neue"', 'Arial', 'sans-serif',
        ],
      },
    },
  },
  plugins: [],
}
