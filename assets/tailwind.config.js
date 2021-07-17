const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  purge: [
      '../lib/**/*.ex',
      '../lib/**/*.leex',
      '../lib/**/*.eex',
      './js/**/*.js'
  ],
  darkMode: 'class', // or 'media' or 'class'
  theme: {
    extend: {
              fontFamily: {
        sans: ['Inter', defaultTheme.fontFamily.sans],
      }
      },
  },
  variants: {
    extend: {
      tableLayout: ['hover', 'focus'],
    },
  },
  plugins: [require('@tailwindcss/forms')],
}
