import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inner", "revealBtn", "judgmentBtns", "writtenArea", "writtenInput"]
  static values  = { written: Boolean }

  connect() {
    // Auto-focus written input if in written mode
    if (this.writtenValue && this.hasWrittenInputTarget) {
      this.writtenInputTarget.focus()
    }
  }

  reveal(event) {
    event.preventDefault()

    // Flip the card
    this.innerTarget.classList.add("flipped")

    // Hide reveal button, show judgment buttons
    this.revealBtnTarget.classList.add("hidden")
    this.judgmentBtnsTarget.classList.remove("hidden")
    this.judgmentBtnsTarget.classList.add("grid")

    // Disable written input if present
    if (this.hasWrittenInputTarget) {
      this.writtenInputTarget.disabled = true
      this.writtenInputTarget.classList.add("opacity-60")
    }

    // Scroll into view smoothly on mobile
    this.judgmentBtnsTarget.scrollIntoView({ behavior: "smooth", block: "nearest" })
  }
}
