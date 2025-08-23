import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  toggleForm() {
    this.formTarget.style.display =
      this.formTarget.style.display === "none" ? "block" : "none"

    if (this.formTarget.style.display === "block") {
      // Optional: focus first field
      const firstInput = this.formTarget.querySelector("input")
      if (firstInput) firstInput.focus()
    }
  }
}
