document.addEventListener("turbo:before-frame-render", (event) => {
  console.log("turbo:before-frame-render", event)
})

document.addEventListener("turbo:submit-end", (event) => {
  const dropdown = document.getElementById("dropdown")
  if (dropdown) {
    window.dispatchEvent(new CustomEvent("hide"))
  }
})