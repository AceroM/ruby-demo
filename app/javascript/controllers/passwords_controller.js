import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["currentPassword", "password", "passwordConfirmation", "toggle"]

  toggle() {
    if (this.hasCurrentPasswordTarget) {
      this.currentPasswordTarget.type = this.currentPasswordTarget.type === "password" ? "text" : "password"
    }
    if (this.hasPasswordTarget) {
      this.passwordTarget.type = this.passwordTarget.type === "password" ? "text" : "password"
    }
    if (this.hasPasswordConfirmationTarget) {
      this.passwordConfirmationTarget.type = this.passwordConfirmationTarget.type === "password" ? "text" : "password"
    }
    if (this.hasToggleTarget) {
      this.toggleTargets.forEach((el) => {
        if (el.classList.contains("fa-eye")) {
          el.classList.replace("fa-eye", "fa-eye-slash")
        } else {
          el.classList.replace("fa-eye-slash", "fa-eye")
        }
      })
    }
  }
}
