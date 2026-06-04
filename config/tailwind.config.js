const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  darkMode: "class",
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        brand: {
          50:  "#f5f3ff",
          100: "#ede9fe",
          200: "#ddd6fe",
          300: "#c4b5fd",
          400: "#a78bfa",
          500: "#8b5cf6",
          600: "#7c3aed",
          700: "#6d28d9",
          800: "#5b21b6",
          900: "#4c1d95",
        },
      },
      animation: {
        "bounce-in": "bounceIn 0.5s ease-out",
        "fade-in": "fadeIn 0.3s ease-out",
        "slide-up": "slideUp 0.3s ease-out",
        "confetti": "confetti 3s ease-in forwards",
      },
      keyframes: {
        bounceIn: {
          "0%":   { transform: "scale(0.3)", opacity: "0" },
          "60%":  { transform: "scale(1.1)" },
          "80%":  { transform: "scale(0.9)" },
          "100%": { transform: "scale(1)",   opacity: "1" },
        },
        fadeIn: {
          "0%":   { opacity: "0" },
          "100%": { opacity: "1" },
        },
        slideUp: {
          "0%":   { transform: "translateY(20px)", opacity: "0" },
          "100%": { transform: "translateY(0)",    opacity: "1" },
        },
        confetti: {
          "0%":   { transform: "translateY(-10vh) rotateZ(0deg)", opacity: "1" },
          "100%": { transform: "translateY(110vh) rotateZ(720deg)", opacity: "0" },
        },
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
