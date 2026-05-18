/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.html.erb",
    "./app/**/*.html",
    "./app/**/*.js",
    "./app/**/*.jsx",
    "./app/**/*.ts",
    "./app/**/*.tsx",
    "./app/**/*.vue",
    // Also include any custom paths if you have components elsewhere
  ],
  theme: {
    extend: {
      fontFamily: {
        // Nice system font stack with a preference for modern sans-serif
        sans: [
          'system-ui',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          '"Noto Sans"',
          'sans-serif',
          '"Apple Color Emoji"',
          '"Segoe UI Emoji"',
          '"Segoe UI Symbol"',
          '"Noto Color Emoji"'
        ],
      },
    },
  },
  plugins: [
    function({ addBase }) {
      // Set fluid base font size using clamp() on the root element
      addBase({
        ':root': {
          '--font-sans': '"system-ui", "-apple-system", "BlinkMacSystemFont", "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"',
          '--text-base': 'clamp(1.125rem, 0.9rem + 0.6vw, 1.5rem)', // Base font size: 18px-24px fluid
          '--text-lg': 'clamp(1.25rem, 1rem + 0.6vw, 1.75rem)',   // Large text: 20px-28px fluid
          '--text-sm': 'clamp(0.875rem, 0.75rem + 0.3vw, 1.125rem)', // Small text: 14px-18px fluid
        },
      });
    },
  ],
};