import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mood", "note"]

  selectEmoji(event) {
    const selectedMood = event.target.dataset.reflectionEmoji
    this.moodTarget.value = selectedMood
    // Optional: highlight selected emoji
    this.element.querySelectorAll("[data-reflection-emoji]").forEach(el => {
      el.classList.remove("selected")
    })
    event.target.classList.add("selected")
  }
}
