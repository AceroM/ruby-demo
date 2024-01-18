import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["otpField", "tokenField"]
  static values = { codeLength: String }

  connect() {
    this.otpFieldTargets.forEach(el => {
      el.addEventListener("paste", this.handlePaste.bind(this))
    })
  }

  handlePaste(event) {
    event.preventDefault()
    const pastedData = event.clipboardData.getData("text").split("")
    const idx = this.otpFieldTargets.findIndex(el => el.id === event.target.id)
    for (let i = idx; i < this.otpFieldTargets.length; i++) {
      if (pastedData.length > 0) {
        this.otpFieldTargets[i].value = pastedData.shift()
      }
    }
    this.tokenFieldTarget.value = this.otpFieldTargets.map(el => el.value).join("")
  }

  handleKeyDown(event) {
    if (!this._isValidOtpInput(event.key)) {
      event.preventDefault()
    }
  }

  handleInput(event) {
    const idx = this.otpFieldTargets.findIndex(el => el.id === event.target.id)
    if (idx < this.otpFieldTargets.length - 1) {
      this.otpFieldTargets[idx + 1].focus()
      let value = this.otpFieldTargets.map(el => el.value).join("")
      this.tokenFieldTarget.value = value
    } else if (idx === this.otpFieldTargets.length - 1) {
      let value = this.otpFieldTargets.map(el => el.value).join("")
      this.tokenFieldTarget.value = value
    }
  }

  handleKeyUp(event) {
    const idx = this.otpFieldTargets.findIndex(el => el.id === event.target.id)
    let value = this.otpFieldTargets.map(el => el.value).join("")
    if (event.key === "ArrowLeft" && idx > 0) {
      let inputField = this.otpFieldTargets[idx - 1]
      inputField.focus()
      let len = inputField.value.length
      inputField.setSelectionRange(len, len)
    } else if (event.key === "ArrowRight" && idx < this.otpFieldTargets.length - 1) {
      let inputField = this.otpFieldTargets[idx + 1]
      inputField.focus()
      let len = inputField.value.length
      inputField.setSelectionRange(len, len)
    } else if (event.key === "Backspace" && idx > 0) {
      this.otpFieldTargets[idx - 1].value = ""
      let inputField = this.otpFieldTargets[idx - 1]
      inputField.focus()
      let len = inputField.value.length
      inputField.setSelectionRange(len, len)
    } else if (value.length === parseInt(this.codeLengthValue)) {
      this.element.submit()
    }
  }

  _isValidOtpInput(key) {
    return ["Backspace", "ArrowLeft", "ArrowRight", "Tab", "Shift", "Meta"].includes(key) ||
      ("0" <= key && key <= "9") ||
      ("a" <= key && key <= "z")
  }
}
