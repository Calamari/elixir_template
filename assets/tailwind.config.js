module.exports = {
  mode: "jit",
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography")],
  purge: [
    "../../lib/**/*.ex",
    "../../lib/**/*.leex",
    "../../lib/**/*.heex",
    "../../lib/**/*.lexs",
    "../../lib/**/*.exs",
    "../../lib/**/*.eex",
    "../../lib/**/*.ex",
    "../js/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        primary: "#4F46E5",
        "primary-dark": "#3730A3"
      }
    }
  },
  variants: {
    extend: {}
  }
};
