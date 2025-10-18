import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "modalImage", "sortLabel"]

  connect() {
  this.sortDescending = true
  this.images = Array.from(this.element.querySelectorAll(".proof-card"))
  this.currentIndex = 0
  this.modalTarget.style.display = "none"  // ensure hidden
}


  toggleSort() {
    const sections = Array.from(this.element.querySelectorAll(".week-section"))
    this.sortDescending = !this.sortDescending

    sections.sort((a, b) => {
      const aDate = new Date(a.querySelector(".proof-date").textContent)
      const bDate = new Date(b.querySelector(".proof-date").textContent)
      return this.sortDescending ? bDate - aDate : aDate - bDate
    })

    sections.forEach(section => this.element.appendChild(section))
    this.sortLabelTarget.textContent = this.sortDescending ? "Newest First" : "Oldest First"
  }

  openModal(event) {
    const card = event.currentTarget
    this.images = Array.from(this.element.querySelectorAll(".proof-card"))
    this.currentIndex = this.images.indexOf(card)

    this.showImage()
    this.modalTarget.style.display = "block"
  }

  closeModal() {
    this.modalTarget.style.display = "none"
  }

  nextImage() {
    this.currentIndex = (this.currentIndex + 1) % this.images.length
    this.showImage()
  }

  prevImage() {
    this.currentIndex = (this.currentIndex - 1 + this.images.length) % this.images.length
    this.showImage()
  }

  showImage() {
    const card = this.images[this.currentIndex]
    this.modalImageTarget.src = card.dataset.url
  }
}
