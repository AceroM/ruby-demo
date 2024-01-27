import { Controller } from "@hotwired/stimulus"
import IMask from "imask"

export default class extends Controller {
  static values = { pattern: String, overwrite: String }

  connect() {
    let options = {}
    if (this.hasOverwriteValue) {
      options.overwrite = this.overwriteValue
      options.lazy = !!this.overwriteValue
      options.definitions = {
        X: {
          mask: "0",
          displayChar: "X",
        },
      }
    }
    this.mask = IMask(this.element, {
      mask: this.patternValue,
      ...options,
    })
  }

  disconnect() {
    this.mask?.destroy()
  }
}