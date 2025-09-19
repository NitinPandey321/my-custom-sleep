import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "file", "message", "submit", "clearButton"]

  open(event) {
    const planId = event.params.planId
    const pillar = event.params.pillar

    // Show modal
    this.modalTarget.classList.add("show")

    // Update form action
    this.formTarget.action = `/plans/${planId}/upload_proof`

    // Reset state
    this.fileTarget.value = ""
    this.clearButtonTarget.style.display = "none"

    // Handle required/optional proof
    if (pillar === "excercise" || pillar === "nutrition") {
      this.fileTarget.required = true
      this.messageTarget.textContent =
        "Proof is mandatory for this plan. Please upload a selfie or a short video to confirm you followed the plan."
      this.submitTarget.value = "Submit"
    } else {
      this.fileTarget.required = false
      this.messageTarget.textContent =
        "Optional but recommended! Uploading a quick selfie or a short video will help your coach in understanding whether you are following the plan correctly or not."
      this.submitTarget.value = "Continue"
    }
  }

  close() {
    this.modalTarget.classList.remove("show")
  }

  fileChanged() {
    if (this.fileTarget.files.length > 0) {
      this.clearButtonTarget.style.display = "inline-block"
    } else {
      this.clearButtonTarget.style.display = "none"
    }
  }

  clearFile() {
    this.fileTarget.value = ""
    this.clearButtonTarget.style.display = "none"
  }
}
