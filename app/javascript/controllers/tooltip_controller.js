import { Controller } from "@hotwired/stimulus"
import { computePosition, autoUpdate, flip, shift, offset } from "@floating-ui/dom"

export default class extends Controller {
  static targets = ["reference", "floating"]
  static values = { width: Number }

  disconnect() {
    if (this.cleanup) {
      this.cleanup()
    }
  }

  show() {
    if (document.getElementById("tooltip")) {
      // only 1 tooltip at a time
      return
    }
    const elem = document.createElement("div")
    elem.id = "tooltip"
    elem.classList.add("floating")
    elem.classList.add("floating--tooltip")
    if (this.widthValue) {
      elem.style.width = `${this.widthValue}px`
    }
    if (this.floatingTarget) {
      const clonedContent = this.floatingTarget.cloneNode(true)
      while (clonedContent.firstChild) {
        elem.appendChild(clonedContent.firstChild)
      }
      while (this.floatingTarget.firstChild) {
        this.floatingTarget.removeChild(this.floatingTarget.firstChild)
      }
    }
    document.body.insertAdjacentElement("beforeend", elem)
    this.cleanup = autoUpdate(this.referenceTarget, elem, () => {
      computePosition(this.referenceTarget, elem, {
        middleware: [flip(), shift(), offset(3)]
      }).then((pos) => {
        Object.assign(elem.style, {
          top: `${pos.y}px`,
          left: `${pos.x}px`,
        })
      })
    })
  }

  hide(event) {
    const tooltip = document.getElementById("tooltip")
    if (this.cleanup) {
      this.cleanup()
      this.cleanup = null
    }
    if (tooltip && !tooltip.contains(event.target)) {
      const clonedContent = tooltip.cloneNode(true)
      while (clonedContent.firstChild) {
        this.floatingTarget.appendChild(clonedContent.firstChild)
      }
      tooltip.remove()
    }
  }
}
