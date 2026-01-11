// app/javascript/controllers/activity_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { idleLimit: { type: Number, default: 900000 } } // 15 minutes

  connect() {
    this.active = true
    this.lastActivity = Date.now()
    this.idle = false

    this.setupActivityListeners()
    this.startHeartbeat()
    this.startIdleWatcher()
  }

  setupActivityListeners() {
    const updateActivity = () => {
      this.lastActivity = Date.now()
    }

    document.addEventListener("mousemove", updateActivity)
    document.addEventListener("keydown", updateActivity)
    document.addEventListener("scroll", updateActivity)
    document.addEventListener("click", updateActivity)

    document.addEventListener("visibilitychange", () => {
      this.active = !document.hidden
    })
  }

  startIdleWatcher() {
    this.idleTimer = setInterval(() => {
      const inactiveTime = Date.now() - this.lastActivity
      if (!this.idle && inactiveTime > this.idleLimitValue) {
        this.pauseTracking()
      }
    }, 10000)
  }

  startHeartbeat() {
    this.timer = setInterval(() => {
      if (this.active && document.hasFocus() && !this.idle) {
        this.sendPing()
      }
    }, 60000) // every 60 seconds
  }

  sendPing() {
    fetch("/activity_logs", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name=csrf-token]").content
      },
      body: JSON.stringify({ seconds: 60 })
    }).catch((err) => console.warn("Activity ping failed:", err))
  }

  pauseTracking() {
    this.idle = true
    this.showIdlePopup()
  }

  resumeTracking() {
    this.idle = false
    this.lastActivity = Date.now()
    this.hideIdlePopup()
  }

  stopTracking() {
    this.idle = true
    this.active = false
    this.hideIdlePopup()

    fetch("/logout", {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name=csrf-token]").content
      }
    }).then(() => {
      window.location.href = "/" // Redirect to home or login page
    }).catch(err => console.error("Logout failed:", err))
  }


  showIdlePopup() {
    if (document.getElementById("idle-popup")) return

    const popup = document.createElement("div")
    popup.id = "idle-popup"
    popup.innerHTML = `
      <div class="idle-popup-backdrop"></div>
      <div class="idle-popup-box">
        <p>You’ve been inactive for a while.<br>Are you still working?</p>
        <div class="idle-popup-actions">
          <button id="idle-continue">Yes, I’m here</button>
          <button id="idle-stop">No, I’m done</button>
        </div>
      </div>
    `

    document.body.appendChild(popup)

    document.getElementById("idle-continue").addEventListener("click", () => {
      this.resumeTracking()
    })

    document.getElementById("idle-stop").addEventListener("click", () => {
      this.stopTracking()
    })
  }

  hideIdlePopup() {
    const popup = document.getElementById("idle-popup")
    if (popup) popup.remove()
  }

  disconnect() {
    clearInterval(this.timer)
    clearInterval(this.idleTimer)
  }
}
