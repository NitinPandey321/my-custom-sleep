// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.loadState()
  }

  toggle() {
    this.element.classList.toggle("expanded")
    localStorage.setItem(
      "sidebarExpanded",
      this.element.classList.contains("expanded")
    )
  }

  loadState() {
    if (localStorage.getItem("sidebarExpanded") === "true") {
      this.element.classList.add("expanded")
    }
  }
}
