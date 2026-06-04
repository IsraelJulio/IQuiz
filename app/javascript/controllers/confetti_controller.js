import { Controller } from "@hotwired/stimulus"

const COLORS = [
  "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
  "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F",
  "#BB8FCE", "#82E0AA", "#F1948A", "#85C1E9"
]

export default class extends Controller {
  connect() {
    this.burst()
  }

  burst() {
    const count = 120
    for (let i = 0; i < count; i++) {
      setTimeout(() => this.createPiece(), Math.random() * 600)
    }
  }

  createPiece() {
    const piece = document.createElement("div")
    const size  = Math.random() * 8 + 6
    piece.style.cssText = `
      position: fixed;
      top: -20px;
      left: ${Math.random() * 100}vw;
      width: ${size}px;
      height: ${size}px;
      background: ${COLORS[Math.floor(Math.random() * COLORS.length)]};
      border-radius: ${Math.random() > 0.5 ? "50%" : "2px"};
      animation: confetti ${1.5 + Math.random() * 2}s ease-in forwards;
      transform: rotateZ(${Math.random() * 360}deg);
      z-index: 9999;
      pointer-events: none;
    `
    document.body.appendChild(piece)
    piece.addEventListener("animationend", () => piece.remove())
  }
}
