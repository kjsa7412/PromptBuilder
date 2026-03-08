/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#6366f1',
        secondary: '#8b5cf6',
      },
      screens: {
        // 3xl: 4-col full-size reference
        '3xl': '1729px',
      },
      maxWidth: {
        'screen-3xl': '1729px',
      },
    },
  },
  plugins: [],
};
