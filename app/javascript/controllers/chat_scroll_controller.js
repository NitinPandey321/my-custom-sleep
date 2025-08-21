// app/javascript/controllers/chat_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"]

  connect() {
    this.scrollToBottom()
    this.observeNewMessages()
  }

  observeNewMessages() {
    if (!this.hasMessagesTarget) return
    const config = { childList: true }
    const callback = () => this.scrollToBottom()
    this.observer = new MutationObserver(callback)
    this.observer.observe(this.messagesTarget, config)
  }

  // Call this when the panel becomes visible or the frame finishes loading
  refreshScroll() {
    // wait a tick for layout after visibility toggle
    requestAnimationFrame(() => this.scrollToBottom())
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
