import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submission"
export default class extends Controller {
  static targets = ["tab", "group", "toggle", "form"]

  connect() {
    this.initTabs()
  }

  // Tabs handling
  initTabs() {
    const savedTab = localStorage.getItem("activeTab") || "pending"
    this.setActiveTab(savedTab)
  }

  selectTab(event) {
    const status = event.currentTarget.dataset.status
    localStorage.setItem("activeTab", status)
    this.setActiveTab(status)
  }

  setActiveTab(status) {
    this.tabTargets.forEach(t => t.classList.remove("active"))
    this.groupTargets.forEach(g => {
      g.style.display = g.dataset.status === status ? "" : "none"
    })
    const activeTab = this.tabTargets.find(t => t.dataset.status === status)
    if (activeTab) activeTab.classList.add("active")
  }

  // Toggle resubmission forms
  toggleResubmit(event) {
    const planId = event.currentTarget.dataset.planId
    const form = this.formTargets.find(f => f.dataset.planId === planId)
    if (form) {
      form.style.display = (form.style.display === "none" ? "block" : "none")
    }
  }
}
