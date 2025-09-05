import { Controller } from "@hotwired/stimulus"

// Form data persistence controller
// Handles saving and restoring form data across page refreshes
export default class extends Controller {
  static values = { 
    type: String,     // "login", "signup-client", "signup-coach"
    expiry: Number    // expiry time in minutes (default: 30)
  }
  
  static targets = ["field"]

  connect() {
    this.expiryValue = this.expiryValue || 30 // Default 30 minutes
    this.storagePrefix = `form_${this.typeValue}_`
    this.timestampKey = `${this.storagePrefix}timestamp`
    
    // Clean expired data on connect
    this.cleanExpiredData()
    
    // Restore saved form data
    this.restoreFormData()
    
    // Set up auto-save on input changes
    this.setupAutoSave()
  }

  disconnect() {
    // Cleanup happens automatically when the controller disconnects
    // No manual event listener removal needed since we use arrow functions
  }

  setupAutoSave() {
    // Add event listeners to all field targets
    this.fieldTargets.forEach(field => {
      // Skip password fields for security
      if (this.isPasswordField(field)) {
        return
      }
      
      field.addEventListener('input', () => this.saveFormData())
      field.addEventListener('change', () => this.saveFormData())
    })
  }

  saveFormData() {
    const data = {}
    
    // Collect all non-password field values
    this.fieldTargets.forEach(field => {
      if (this.isPasswordField(field)) {
        return // Skip password fields
      }
      
      if (field.value.trim()) {
        data[field.name] = field.value
      }
    })
    
    const storage = this.getStorage()
    
    // Save the data and timestamp
    storage.setItem(this.storagePrefix + 'data', JSON.stringify(data))
    storage.setItem(this.timestampKey, Date.now().toString())
  }

  restoreFormData() {
    // Check if data has expired first
    if (this.isDataExpired()) {
      this.clearFormData()
      return
    }

    const storage = this.getStorage()
    const savedDataRaw = storage.getItem(this.storagePrefix + 'data')
    
    if (!savedDataRaw) {
      return // No data to restore
    }
    
    try {
      const savedData = JSON.parse(savedDataRaw)
      
      this.fieldTargets.forEach(field => {
        // Skip password fields
        if (this.isPasswordField(field)) {
          return
        }
        
        if (savedData[field.name]) {
          field.value = savedData[field.name]
          // Trigger any validation that might be listening
          field.dispatchEvent(new Event('input', { bubbles: true }))
        }
      })
    } catch (error) {
      console.error('Error parsing saved form data:', error)
      this.clearFormData()
    }
  }

  clearFormData() {
    const storage = this.getStorage()
    
    // Remove both the data and timestamp
    storage.removeItem(this.storagePrefix + 'data')
    storage.removeItem(this.timestampKey)
  }

  cleanExpiredData() {
    if (this.isDataExpired()) {
      this.clearFormData()
    }
  }

  // Check if stored data has expired
  isDataExpired() {
    const storage = this.getStorage()
    const timestamp = storage.getItem(this.timestampKey)
    
    if (!timestamp) {
      return true // No timestamp means no data or expired
    }
    
    const savedTime = parseInt(timestamp, 10)
    const now = Date.now()
    const expiryMs = this.expiryValue * 60 * 1000 // Convert minutes to milliseconds
    
    return (now - savedTime) > expiryMs
  }

  // Helper methods
  isPasswordField(field) {
    const fieldName = field.name || field.id || ''
    const fieldType = field.type || ''
    
    return fieldType === 'password' || 
           fieldName.includes('password') || 
           fieldName.includes('Password')
  }

  getStorage() {
    // Use sessionStorage for login (expires when tab closes)
    // Use localStorage for signup (persists across browser sessions)
    return this.typeValue === 'login' ? sessionStorage : localStorage
  }

  // Action to manually clear form (can be triggered by button)
  clear() {
    this.clearFormData()
    
    // Also clear the form fields in the UI
    this.fieldTargets.forEach(field => {
      field.value = ''
    })
  }
}
