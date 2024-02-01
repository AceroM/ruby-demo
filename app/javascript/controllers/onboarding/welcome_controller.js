import { Controller } from "@hotwired/stimulus"
import { computePosition, autoUpdate, flip, shift, offset } from "@floating-ui/dom"

export default class extends Controller {
  static targets = ["container", "checkbox", "reference", "floating", "submit"]

  connect() {
  }

  toggleVisited(event) {
    const labelContainer = this.referenceTargets.find((elem) => elem.contains(event.target))
    if (labelContainer && event.target.tagName === "A") {
      labelContainer.dataset.visited = "true"
    }
  }

  toggleChecked() {
    const unvisitedElems = this.element.querySelectorAll("[data-visited='false']")
    const checkedElems = this.checkboxTargets.filter((elem) => elem.checked)
    const disclosuresAccepted = checkedElems.length === this.containerTargets.length
    const visitedLinks = unvisitedElems.length === 0

    if (visitedLinks && disclosuresAccepted) {
      this.submitTarget.disabled = false
    } else if (!visitedLinks || !disclosuresAccepted) {
      this.submitTarget.disabled = true
    }

    if (disclosuresAccepted) {
      unvisitedElems.forEach((elem) => {
        elem.classList.add("error-text")
      })
    }
  }
}
