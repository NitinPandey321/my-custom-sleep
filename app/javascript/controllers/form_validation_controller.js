import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "firstNameInput", "firstNameError",
    "lastNameInput", "lastNameError", 
    "emailInput", "emailError",
    "passwordInput", "passwordError", "passwordStrength",
    "passwordConfirmationInput", "passwordConfirmationError",
    "phoneInput", "phoneError",
    "submitButton", "form"
  ]

  connect() {
    this.setupValidation()
    this.debounceTimers = {}
  }

  disconnect() {
    // Clear any pending timers
    Object.values(this.debounceTimers).forEach(timer => clearTimeout(timer))
  }

  setupValidation() {
    // Add event listeners for real-time validation
    if (this.hasFirstNameInputTarget) {
      this.firstNameInputTarget.addEventListener('blur', () => this.validateFirstName())
      this.firstNameInputTarget.addEventListener('input', () => this.debounceValidation('firstName', () => this.validateFirstName()))
    }

    if (this.hasLastNameInputTarget) {
      this.lastNameInputTarget.addEventListener('blur', () => this.validateLastName())
      this.lastNameInputTarget.addEventListener('input', () => this.debounceValidation('lastName', () => this.validateLastName()))
    }

    if (this.hasEmailInputTarget) {
      this.emailInputTarget.addEventListener('blur', () => this.validateEmail())
      this.emailInputTarget.addEventListener('input', () => this.debounceValidation('email', () => this.validateEmail()))
    }

    if (this.hasPasswordInputTarget) {
      this.passwordInputTarget.addEventListener('blur', () => this.validatePassword())
      this.passwordInputTarget.addEventListener('input', () => {
        this.debounceValidation('password', () => this.validatePassword())
        this.updatePasswordStrength()
        if (this.hasPasswordConfirmationInputTarget && this.passwordConfirmationInputTarget.value) {
          this.validatePasswordConfirmation()
        }
      })
    }

    if (this.hasPasswordConfirmationInputTarget) {
      this.passwordConfirmationInputTarget.addEventListener('blur', () => this.validatePasswordConfirmation())
      this.passwordConfirmationInputTarget.addEventListener('input', () => this.debounceValidation('passwordConfirmation', () => this.validatePasswordConfirmation()))
    }
  }

  debounceValidation(field, validationFn) {
    if (this.debounceTimers[field]) {
      clearTimeout(this.debounceTimers[field])
    }
    this.debounceTimers[field] = setTimeout(validationFn, 300)
  }

  validateFirstName() {
    const value = this.firstNameInputTarget.value.trim()
    const namePattern = /^[a-zA-Z\-'\s]+$/

    if (!value) {
      this.showError('firstName', 'First name is required.')
      return false
    } else if (!namePattern.test(value)) {
      this.showError('firstName', 'First name can only contain letters, hyphens, and apostrophes.')
      return false
    } else if (value.length > 50) {
      this.showError('firstName', 'First name cannot exceed 50 characters.')
      return false
    } else {
      this.clearError('firstName')
      return true
    }
  }

  validateLastName() {
    const value = this.lastNameInputTarget.value.trim()
    const namePattern = /^[a-zA-Z\-'\s]+$/

    if (!value) {
      this.showError('lastName', 'Last name is required.')
      return false
    } else if (!namePattern.test(value)) {
      this.showError('lastName', 'Last name can only contain letters, hyphens, and apostrophes.')
      return false
    } else if (value.length > 50) {
      this.showError('lastName', 'Last name cannot exceed 50 characters.')
      return false
    } else {
      this.clearError('lastName')
      return true
    }
  }

  validateEmail() {
    const value = this.emailInputTarget.value.trim()
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    if (!value) {
      this.showError('email', 'Email is required.')
      return false
    } else if (!emailPattern.test(value)) {
      this.showError('email', 'Enter a valid email address.')
      return false
    } else if (value.length > 255) {
      this.showError('email', 'Email cannot exceed 255 characters.')
      return false
    } else {
      this.clearError('email')
      return true
    }
  }

  validatePassword() {
    const value = this.passwordInputTarget.value

    if (!value) {
      this.showError('password', 'Password is required.')
      return false
    } else if (value.length < 8) {
      this.showError('password', 'Password must be at least 8 characters long.')
      return false
    } else if (!this.checkPasswordComplexity(value)) {
      this.showError('password', 'Password must include uppercase, lowercase, number, and special character (@$!%*?&).')
      return false
    } else {
      this.clearError('password')
      return true
    }
  }

  validatePasswordConfirmation() {
    const password = this.passwordInputTarget.value
    const confirmation = this.passwordConfirmationInputTarget.value

    if (!confirmation) {
      this.showError('passwordConfirmation', 'Confirm your password.')
      return false
    } else if (password !== confirmation) {
      this.showError('passwordConfirmation', 'Passwords do not match.')
      return false
    } else {
      this.clearError('passwordConfirmation')
      return true
    }
  }

  checkPasswordComplexity(password) {
    const hasUpper = /[A-Z]/.test(password)
    const hasLower = /[a-z]/.test(password)
    const hasNumber = /\d/.test(password)
    const hasSpecial = /[@$!%*?&]/.test(password)
    
    return hasUpper && hasLower && hasNumber && hasSpecial
  }

  updatePasswordStrength() {
    if (!this.hasPasswordStrengthTarget) return

    const password = this.passwordInputTarget.value
    const strength = this.calculatePasswordStrength(password)
    
    this.passwordStrengthTarget.className = `password-strength ${strength.level}`
    this.passwordStrengthTarget.textContent = strength.text
    this.passwordStrengthTarget.style.display = password ? 'block' : 'none'
  }

  calculatePasswordStrength(password) {
    if (!password) return { level: '', text: '' }
    
    let score = 0
    const checks = {
      length: password.length >= 8,
      upper: /[A-Z]/.test(password),
      lower: /[a-z]/.test(password),
      number: /\d/.test(password),
      special: /[@$!%*?&]/.test(password)
    }
    
    score = Object.values(checks).filter(Boolean).length
    
    if (score < 3) return { level: 'weak', text: 'Weak password' }
    if (score < 4) return { level: 'medium', text: 'Medium strength' }
    if (score === 5) return { level: 'strong', text: 'Strong password' }
    
    return { level: 'weak', text: 'Weak password' }
  }

  showError(field, message) {
    const errorTarget = this[`${field}ErrorTarget`]
    const inputTarget = this[`${field}InputTarget`]
    
    if (errorTarget) {
      errorTarget.textContent = message
      errorTarget.style.display = 'block'
      errorTarget.setAttribute('aria-live', 'polite')
    }
    
    if (inputTarget) {
      inputTarget.classList.add('error')
      inputTarget.setAttribute('aria-invalid', 'true')
      inputTarget.setAttribute('aria-describedby', errorTarget?.id || `${field}-error`)
    }
  }

  clearError(field) {
    const errorTarget = this[`${field}ErrorTarget`]
    const inputTarget = this[`${field}InputTarget`]
    
    if (errorTarget) {
      errorTarget.textContent = ''
      errorTarget.style.display = 'none'
      errorTarget.removeAttribute('aria-live')
    }
    
    if (inputTarget) {
      inputTarget.classList.remove('error')
      inputTarget.setAttribute('aria-invalid', 'false')
      inputTarget.removeAttribute('aria-describedby')
    }
  }

  validateForm(event) {
    const isValid = this.validateAllFields()
    
    if (!isValid) {
      event.preventDefault()
      this.focusFirstError()
    }
    
    return isValid
  }

  validateAllFields() {
    let isValid = true
    
    if (this.hasFirstNameInputTarget) {
      isValid = this.validateFirstName() && isValid
    }
    
    if (this.hasLastNameInputTarget) {
      isValid = this.validateLastName() && isValid
    }
    
    if (this.hasEmailInputTarget) {
      isValid = this.validateEmail() && isValid
    }
    
    if (this.hasPasswordInputTarget) {
      isValid = this.validatePassword() && isValid
    }
    
    if (this.hasPasswordConfirmationInputTarget) {
      isValid = this.validatePasswordConfirmation() && isValid
    }
    
    return isValid
  }

  focusFirstError() {
    const errorFields = ['firstName', 'lastName', 'email', 'phone', 'password', 'passwordConfirmation']
    
    for (const field of errorFields) {
      const errorTarget = this[`${field}ErrorTarget`]
      const inputTarget = this[`${field}InputTarget`]
      
      if (errorTarget && errorTarget.textContent && inputTarget) {
        inputTarget.focus()
        break
      }
    }
  }

  handleServerErrors(errors) {
    // Clear all existing errors first
    const allFields = ['firstName', 'lastName', 'email', 'phone', 'password', 'passwordConfirmation']
    allFields.forEach(field => {
      if (this[`${field}ErrorTarget`]) {
        this.clearError(field)
      }
    })
    
    // Show server-side errors
    Object.entries(errors).forEach(([field, message]) => {
      if (this[`${field}ErrorTarget`]) {
        this.showError(field, message)
      }
    })
    
    this.focusFirstError()
  }
}
