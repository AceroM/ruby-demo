import { Controller } from "@hotwired/stimulus"
import { useTransition } from "src/use_transition"

export default class extends Controller {
  static targets = ["content", "focus", "overlay", "submit"]

  initialize() {
    this.close = this.close.bind(this)
  }

  connect() {
    useTransition(this, {
      element: this.contentTarget,
      enterActive: "fade-enter-active",
      enterFrom: "fade-enter-from",
      enterTo: "fade-enter-to",
      hiddenClass: "d-none",
      preserveOriginalClasses: true,
    })
    this.element.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    debugger
    if (event.target.tagName === "INPUT") {
      return
    }
    if (event.key === "Escape") {
      this.close()
    } if (!["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight", "Tab", "Space", "Enter"].includes(event.key)) {
      event.preventDefault()
    }
  }

  open() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle("d-none")
    }
    this.toggleTransition()
    if (this.hasFocusTarget) {
      this.focusTarget.focus()
    }
  }

  close() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("d-none")
    }
    this.leave()
  }
}
