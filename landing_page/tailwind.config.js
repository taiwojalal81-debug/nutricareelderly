/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./lib/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#10b981",
          light: "#34d399",
          dark: "#059669",
          container: "#d1fae5",
        },
        secondary: "#3b82f6",
        accent: "#f59e0b",
        background: "#f8fafc",
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
      },
      boxShadow: {
        glow: "0 0 40px rgba(16, 185, 129, 0.15)",
        "glow-lg": "0 0 60px rgba(16, 185, 129, 0.25)",
        card: "0 4px 24px rgba(0, 0, 0, 0.06)",
        "card-hover": "0 12px 40px rgba(0, 0, 0, 0.12)",
      },
    },
  },
  plugins: [],
};
