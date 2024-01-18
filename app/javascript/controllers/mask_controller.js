import { Controller } from "@hotwired/stimulus"
import IMask from "imask"

export default class extends Controller {
  static values = { pattern: String }

  connect() {
    this.mask = IMask(this.element, { mask: this.patternValue })
  }

  disconnect() {
    this.mask?.destroy()
  }
}