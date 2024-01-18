import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arrow", "content"]

  toggle() {
    if (this.arrowTarget.classList.contains("accordion__arrow--open")) {
      this.arrowTarget.classList.remove("accordion__arrow--open")
      this.contentTarget.classList.remove("accordion__content--open")
    } else {
      this.arrowTarget.classList.add("accordion__arrow--open")
      this.contentTarget.classList.add("accordion__content--open")
    }
  }
}
