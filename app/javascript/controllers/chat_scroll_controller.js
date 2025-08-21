// app/javascript/controllers/chat_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"]

  connect() {
    this.scrollToBottom()
    this.observeNewMessages()
  }

  observeNewMessages() {
    // Observe child additions to trigger scroll automatically
    if (!this.hasMessagesTarget) return

    const config = { childList: true }
    const callback = () => this.scrollToBottom()
    this.observer = new MutationObserver(callback)
    this.observer.observe(this.messagesTarget, config)
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
