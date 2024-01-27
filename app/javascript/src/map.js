window.initMap = () => {
  const event = new CustomEvent("map")
  window.dispatchEvent(event)
}