import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "city", "state", "zip"]
  static values = { mapsKey: String }

  connect() {
    const script = document.createElement("script")
    script.async = false
    script.defer = true
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.mapsKeyValue}&libraries=places&callback=initMap`
    document.head.appendChild(script)
  }

  initGoogle() {
    this.autocomplete = new google.maps.places.Autocomplete(this.inputTarget, {
      fields: ["address_components", "geometry"],
      types: ["address"],
    })
    this.autocomplete.addListener("place_changed", this.#placeSelected.bind(this))
  }

  #placeSelected() {
    const place = this.autocomplete.getPlace()

    if (!place.geometry) {
      return
    }

    for (const component of place.address_components) {
      const componentType = component.types[0]
      switch (componentType) {
        case "postal_code":
          this.zipTarget.value = component.long_name
          break
        case "postal_code_suffix":
          this.zipTarget.value = `${this.zipTarget.value}-${component.long_name}`
          break
        case "locality":
          this.cityTarget.value = component.long_name
          break
        case "neighborhood":
          this.cityTarget.value = component.short_name
          break
        case "administrative_area_level_1":
          this.stateTarget.value = component.short_name
          break
      }
    }
  }
}
