import { Controller } from "@hotwired/stimulus"
import { computePosition, autoUpdate, flip, shift, offset } from "@floating-ui/dom"

export default class extends Controller {
  static targets = ["reference", "floating"]
  static values = { placement: String }

  initialize() {
    this.handleItemHover = this.handleItemHover.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  connect() {
    this.element.setAttribute("aria-haspopup", "menu")
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
    this.clean()
  }

  toggle(event) {
    let dropdown = document.getElementById("dropdown")
    if (dropdown && this.floatingTarget.dataset.uuid === dropdown.dataset.uuid) {
      this.clean()
      const clonedContent = dropdown.cloneNode(true)
      while (clonedContent.firstChild) {
        this.floatingTarget.appendChild(clonedContent.firstChild)
      }
      dropdown.remove()
    }
    if (dropdown && this.floatingTarget.dataset.uuid !== dropdown.dataset.uuid) {
      // insert the dropdown contents back into it's pair
      const uuidMatches = document.querySelectorAll(`[data-uuid="${dropdown.dataset.uuid}"]`)
      const matchedElem = Array.from(uuidMatches).find((elem) => !elem.contains(dropdown))
      if (matchedElem) {
        this.clean()
        const clonedContent = dropdown.cloneNode(true)
        while (clonedContent.firstChild) {
          matchedElem.appendChild(clonedContent.firstChild)
        }
        dropdown.remove()
        dropdown = null
      }
    }
    if (!dropdown) {
      const elem = document.createElement("div")
      elem.id = "dropdown"
      elem.classList.add("floating")
      elem.classList.add("floating--dropdown")
      const uuid = crypto.randomUUID()
      elem.dataset.uuid = uuid
      elem.setAttribute("role", "menu")
      elem.setAttribute("aria-hidden", "false")
      if (this.element.dataset?.turboPermanent !== undefined) {
        elem.dataset.turboPermanent = ""
      }
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
      const items = elem.querySelectorAll("[data-dropdown-target='item']")
      if (items && items.length > 0) {
        for (let item of items) {
          item.addEventListener("mouseenter", this.handleItemHover.bind(this))
        }
      }
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
      this.element.setAttribute("aria-expanded", "true")
    }
  }

  hide(event, force = false) {
    const dropdown = document.getElementById("dropdown")
    let canCloseDropdown = false
    if (event.type === "hide" || force) {
      canCloseDropdown = true
    } else {
      canCloseDropdown = !!dropdown && !this.element.contains(event.target)
      if (dropdown && this.portaledTarget && this.portaledTarget.contains(event.target)) {
        const items = this.portaledTarget.querySelectorAll("[data-dropdown-target='item']")
        const currentItem = Array.from(items).find((item) => item.contains(event.target))
        canCloseDropdown = !(currentItem && currentItem.dataset?.close === "false")
      }
    }
    if (dropdown && this.hasFloatingTarget && canCloseDropdown && this.floatingTarget.dataset.uuid === dropdown.dataset.uuid) {
      this.clean()
      const clonedContent = dropdown.cloneNode(true)
      while (clonedContent.firstChild) {
        this.floatingTarget.appendChild(clonedContent.firstChild)
      }
      dropdown.remove()
    }
  }

  handleKeydown(event) {
    event.preventDefault()
    const dropdown = document.getElementById("dropdown")
    if (dropdown) {
      const items = dropdown.querySelectorAll("[data-dropdown-target='item']")
      const list = Array.from(items)
      const idx = list.findIndex((item) => item.contains(event.target))
      if (idx === -1 && ["ArrowDown", "j"].includes(event.key)) {
        list[0].focus()
      }
      if (idx === -1 && ["ArrowUp", "k"].includes(event.key)) {
        list[list.length - 1].focus()
      }
      if ((event.key === "ArrowDown" || event.key === "j") && idx > -1 && list[idx + 1]) {
        list[idx + 1].focus()
      } else if ((event.key === "ArrowUp" || event.key === "k") && idx > 0 && list[idx - 1]) {
        list[idx - 1].focus()
      } else if (event.key === "Escape") {
        this.hide(event, true)
        this.referenceTarget.focus()
      } else if (["Enter", " "].includes(event.key) && idx > -1 && list[idx]) {
        list[idx].click()
      }
    }
  }

  handleItemHover() {
    if (this.portaledTarget) {
      this.portaledTarget.focus()
    }
  }
}
