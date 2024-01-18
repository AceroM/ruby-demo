import { Controller } from "@hotwired/stimulus"
import { computePosition, autoUpdate, flip, shift, offset } from "@floating-ui/dom"

export default class extends Controller {
  static targets = ["reference", "floating"]
  static values = { placement: String }

  initialize() {
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  connect() {
    this.element.setAttribute("aria-expanded", "false")
  }

  clean() {
    this.element.setAttribute("aria-expanded", "false")
    if (this.cleanup) {
      this.cleanup()
      this.cleanup = null
    }
  }

  disconnect() {
    if (this.cleanup) {
      this.cleanup()
    }
  }

  toggle(event) {
    let popover = document.getElementById("popover")
    if (popover && this.floatingTarget.dataset.uuid === popover.dataset.uuid) {
      this.clean()
      const clonedContent = popover.cloneNode(true)
      while (clonedContent.firstChild) {
        this.floatingTarget.appendChild(clonedContent.firstChild)
      }
      popover.remove()
    }
    if (popover && this.floatingTarget.dataset.uuid !== popover.dataset.uuid) {
      // insert the popover contents back into it's pair
      const uuidMatches = document.querySelectorAll(`[data-uuid="${popover.dataset.uuid}"]`)
      const matchedElem = Array.from(uuidMatches).find((elem) => !elem.contains(popover))
      if (matchedElem) {
        this.clean()
        const clonedContent = popover.cloneNode(true)
        while (clonedContent.firstChild) {
          matchedElem.appendChild(clonedContent.firstChild)
        }
        popover.remove()
        popover = null
      }
    }
    if (!popover) {
      const elem = document.createElement("div")
      elem.id = "popover"
      elem.classList.add("floating")
      elem.classList.add("floating--popover")
      Array.from(this.floatingTarget.classList).filter(c => c !== "d-none").forEach((c) => {
        elem.classList.add(c)
      })
      const uuid = crypto.randomUUID()
      elem.dataset.uuid = uuid
      elem.setAttribute("aria-hidden", "false")
      elem.setAttribute("aria-haspopup", "true")
      if (this.hasFloatingTarget) {
        this.floatingTarget.dataset.uuid = uuid
        const clonedContent = this.floatingTarget.cloneNode(true)
        while (clonedContent.firstChild) {
          elem.appendChild(clonedContent.firstChild)
        }
        while (this.floatingTarget.firstChild) {
          this.floatingTarget.removeChild(this.floatingTarget.firstChild)
        }
      }
      document.body.insertAdjacentElement("beforeend", elem)
      elem.addEventListener("keydown", this.handleKeydown)
      this.portaledTarget = elem
      this.firstUpdate = true
      this.cleanup = autoUpdate(this.referenceTarget, elem, () => {
        computePosition(this.referenceTarget, elem, {
          placement: this.placementValue || "bottom",
          middleware: [flip(), shift(), offset(3)]
        }).then((pos) => {
          Object.assign(elem.style, {
            top: `${pos.y}px`,
            left: `${pos.x}px`,
          })
          if (this.firstUpdate) {
            elem.tabIndex = -1
            elem.focus()
          }
          this.firstUpdate = false
        })
      })
    }
  }

  hide(event, force = false) {
    const popover = document.getElementById("popover")
    let canCloseDropdown = !this.element.contains(event.target)
    if (event.type === "hide" || force) {
      canCloseDropdown = true
    } else if (popover && this.portaledTarget && this.portaledTarget.contains(event.target)) {
      canCloseDropdown = false
    }
    if (popover && this.hasFloatingTarget && canCloseDropdown && this.floatingTarget.dataset.uuid === popover.dataset.uuid) {
      this.clean()
      const clonedContent = popover.cloneNode(true)
      while (clonedContent.firstChild) {
        this.floatingTarget.appendChild(clonedContent.firstChild)
      }
      popover.remove()
    }
  }

  handleKeydown(event) {
    const popover = document.getElementById("popover")
    if (popover && event.key === "Escape") {
      event.preventDefault()
      this.hide(event, true)
    }
  }
}
