import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timer = setTimeout(() => this.dismiss(), 5000)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.3s ease-out, max-height 0.3s ease-out"
    this.element.style.opacity = "0"
    this.element.style.overflow = "hidden"
    this.element.style.maxHeight = "0"
    setTimeout(() => this.element.remove(), 350)
  }
}
