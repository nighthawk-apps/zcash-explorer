const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  darkMode: 'class',
  content: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.heex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        green: colors.emerald,
        yellow: colors.amber,
        purple: colors.violet,
      },
      fontFamily: {
        sans: ['Inter', defaultTheme.fontFamily.sans],
      }
    },
  },
  plugins: [require('@tailwindcss/forms')],
}
