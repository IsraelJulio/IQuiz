import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const stored = localStorage.getItem("iquiz-theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches

    if (stored === "dark" || (!stored && prefersDark)) {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }

  toggle() {
    const isDark = document.documentElement.classList.toggle("dark")
    localStorage.setItem("iquiz-theme", isDark ? "dark" : "light")
  }
}
