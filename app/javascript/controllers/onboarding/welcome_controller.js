import { Controller } from "@hotwired/stimulus"
import { computePosition, autoUpdate, flip, shift, offset } from "@floating-ui/dom"

export default class extends Controller {
  static targets = ["reference", "floating"]

  #submitDisabled = true

  connect() {
    console.log(this.referenceTargets)
    console.log(this.floatingTargets)
  }

  toggleVisited(event) {
    const labelContainer = this.referenceTargets.find((elem) => elem.contains(event.target))
    if (labelContainer && event.target.tagName === "A") {
      labelContainer.dataset.visited = "true"
    }
  }
}
