import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "icon"]

  toggle() {
    const input = this.inputTarget
    const icon = this.iconTarget
    
    if (input.type === "password") {
      // Show password
      input.type = "text"
      icon.innerHTML = this.getEyeOffIcon()
      input.setAttribute("aria-label", "Password is visible")
    } else {
      // Hide password
      input.type = "password"
      icon.innerHTML = this.getEyeIcon()
      input.setAttribute("aria-label", "Password is hidden")
    }
  }

  getEyeIcon() {
    return `
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="#0e3264" stroke-width="2" fill="none"/>
        <circle cx="12" cy="12" r="3" stroke="#0e3264" stroke-width="2" fill="none"/>
      </svg>
    `
  }

  getEyeOffIcon() {
    return `
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="m1 1 22 22" stroke="#0e3264" stroke-width="2"/>
        <path d="m3 3 18 18" stroke="#0e3264" stroke-width="2"/>
        <path d="M10.584 10.587a2 2 0 0 0 2.828 2.83" stroke="#0e3264" stroke-width="2" fill="none"/>
        <path d="M9.363 5.365A9.466 9.466 0 0 1 12 5c7 0 11 8 11 8a13.229 13.229 0 0 1-1.297 2.025" stroke="#0e3264" stroke-width="2" fill="none"/>
        <path d="M5.255 7.334A13.229 13.229 0 0 0 1 12s4 8 11 8a9.465 9.465 0 0 0 5.49-1.708" stroke="#0e3264" stroke-width="2" fill="none"/>
      </svg>
    `
  }
}
