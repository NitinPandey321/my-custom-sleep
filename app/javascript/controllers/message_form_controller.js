import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]  // ✅ Add submit here

  preventEmpty(event) {
    if (this.inputTarget.value.trim() === "") {
      event.preventDefault()
    }
  }

  connect() {
    this.toggleButton()
  }

  checkInput() {
    this.toggleButton()
  }

  toggleButton() {
    this.submitTarget.disabled = this.inputTarget.value.trim() === ""
  }
}
