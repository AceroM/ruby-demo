import { Controller } from "@hotwired/stimulus"
import { autoUpdate, computePosition, offset, shift } from "@floating-ui/dom"

export default class extends Controller {
  static targets = ["item", "submit"]

  #cleanups = []
  #privacyVisited = false
  #esignVisited = false

  disconnect() {
    this.#cleanups.forEach((cleanup) => cleanup())
  }

  toggleChecked() {
    const disclosuresAccepted = this.itemTargets.every((item) => item.querySelector("[type=\"checkbox\"]").checked)
    if (disclosuresAccepted) {
      if (!this.#esignVisited) {
        this.#addErrorToItem(this.itemTargets[0])
      }
      if (!this.#privacyVisited) {
        this.#addErrorToItem(this.itemTargets[3])
      }
    }
    this.#updateSubmit()
  }

  visitLink(event) {
    event.stopPropagation()
    if (event.target.textContent === "E-Sign Consent") {
      this.#esignVisited = true
      if (event.target.classList.contains("link--danger")) {
        this.#removeErrorFromItem(this.itemTargets[0])
      }
    }
    if (event.target.textContent === "Privacy Notice") {
      this.#privacyVisited = true
      if (event.target.classList.contains("link--danger")) {
        this.#removeErrorFromItem(this.itemTargets[3])
      }
    }
    this.#updateSubmit(event)
  }

  #updateSubmit() {
    const disclosuresAccepted = this.itemTargets.every((item) => item.querySelector("[type=\"checkbox\"]").checked)
    this.submitTarget.disabled = !(this.#privacyVisited && this.#esignVisited && disclosuresAccepted)
  }

  #removeErrorFromItem(elem) {
    const link = elem.querySelector("a")
    const floating = elem.querySelector(".floating")
    floating.classList.add("d-none")
    link.classList.remove("link--danger")
  }

  #addErrorToItem(elem) {
    const link = elem.querySelector("a")
    const reference = elem.querySelector("label")
    const floating = elem.querySelector(".floating")
    floating.classList.remove("d-none")
    link.classList.add("link--danger")
    this.#cleanups.push(autoUpdate(reference, floating, () => {
      computePosition(reference, reference.nextElementSibling, {
        placement: "top",
        middleware: [shift(), offset({ mainAxis: 10, crossAxis: -4 })]
      }).then((pos) => {
        Object.assign(floating.style, {
          top: `${pos.y}px`,
          left: `${pos.x}px`,
        })
      })
    }))
  }
}
