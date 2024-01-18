// Example usage:
//
//   <%= button_to "Delete", my_path, method: :delete, form: {
//     data: {
//       turbo_confirm: "Are you sure?",
//       turbo_confirm_description: "This will delete your record.",
//       turbo_confirm_text: "Confirm"
//       turbo_confirm_type: "danger" // or "primary" or "warning". Default is "danger"
//     }
//   } %>
//

function insertConfirmModal(message, element, button) {
  const dropdown = document.getElementById("dropdown")
  if (dropdown) {
    window.dispatchEvent(new CustomEvent("hide"))
  }
  const type = button?.dataset?.turboConfirmType || element.dataset.turboConfirmType || "danger"
  let confirmClass = null
  if (type === "danger") {
    confirmClass = "button--danger"
  } else if (type === "primary") {
    confirmClass = "button--primary"
  }
  const confirmText =
    button?.dataset?.turboConfirmText || element.dataset.turboConfirmText || "Confirm"
  const description =
    button?.dataset?.turboConfirmDescription ||
    element.dataset.turboConfirmDescription ||
    ""
  const id = `confirm-modal-${new Date().getTime()}`
  const closeButton = document.createElement("button")
  closeButton.classList.add("dialog__close")
  const closeIcon = document.createElement("i")
  closeIcon.classList.add("fa-sm", "fa-light", "fa-times")
  closeButton.appendChild(closeIcon)
  const dialogHeader = document.createElement("div")
  dialogHeader.classList.add("dialog__header")
  const dialogTitle = document.createElement("h3")
  dialogTitle.classList.add("heading-2")
  dialogTitle.textContent = message
  const dialogDescription = document.createElement("p")
  dialogDescription.classList.add("dialog__description")
  dialogDescription.textContent = description
  dialogHeader.appendChild(dialogTitle)
  dialogHeader.appendChild(dialogDescription)
  const dialogFooter = document.createElement("div")
  dialogFooter.classList.add("dialog__footer")
  const cancelButton = document.createElement("button")
  cancelButton.dataset.behavior = "cancel"
  cancelButton.classList.add("button", "button--outline")
  cancelButton.textContent = "Cancel"
  const confirmButton = document.createElement("button")
  confirmButton.dataset.behavior = "commit"
  confirmButton.classList.add("button")
  if (confirmClass) {
    confirmButton.classList.add(confirmClass)
  }
  confirmButton.textContent = confirmText
  dialogFooter.appendChild(cancelButton)
  dialogFooter.appendChild(confirmButton)
  const dialogContent = document.createElement("div")
  dialogContent.classList.add("dialog", "dialog--no-content")
  dialogContent.appendChild(closeButton)
  dialogContent.appendChild(dialogHeader)
  dialogContent.appendChild(dialogFooter)
  const dialogOverlay = document.createElement("div")
  dialogOverlay.classList.add("dialog-overlay")
  const dialog = document.createElement("div")
  dialog.id = id
  dialog.appendChild(dialogContent)
  dialog.appendChild(dialogOverlay)
  document.body.insertAdjacentElement("beforeend", dialog)
  let modal = document.getElementById(id)
  // Focus on the first button in the modal after rendering
  modal.querySelector("[data-behavior='cancel']").focus()

  return modal
}

Turbo.setConfirmMethod(async (message, element, button) => {
  const dialog = insertConfirmModal(message, element, button)

  return new Promise((resolve) => {
    ["[data-behavior='cancel']", ".dialog__close", ".dialog-overlay"].forEach((selector) =>
      dialog.querySelector(selector).addEventListener(
        "click",
        () => {
          dialog.remove()
          resolve(false)
        },
        { once: true },
      )
    )
    dialog.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        dialog.remove()
        resolve(false)
      }
    })
    dialog.querySelector("[data-behavior='commit']").addEventListener(
      "click",
      () => {
        dialog.remove()
        resolve(true)
      },
      { once: true },
    )
  })
})
