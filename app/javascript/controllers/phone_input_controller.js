import { Controller } from "@hotwired/stimulus"

// Phone Input Controller for country selection and search functionality
export default class extends Controller {
  static targets = ["countrySelect", "dropdown", "searchInput", "countryList", "mobileInput", "validationMessage", "countryDisplay", "selectedFlag", "selectedCode"]
  static values = { 
    placeholder: String,
    defaultCountry: String 
  }

  connect() {
    this.initializePhoneInput()
    this.setupEventListeners()
    this.setupKeyboardNavigation()
  }

  disconnect() {
    this.removeEventListeners()
  }

  initializePhoneInput() {
    // Set default country if provided
    if (this.defaultCountryValue) {
      this.selectCountry(this.defaultCountryValue)
    }
    
    // Initialize search functionality
    this.allCountries = this.getAllCountries()
    this.currentHighlightIndex = -1
  }

  setupEventListeners() {
    // Country selector click
    this.countryDisplayTarget.addEventListener('click', this.toggleDropdown.bind(this))
    
    // Search input
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.addEventListener('input', this.handleSearch.bind(this))
      this.searchInputTarget.addEventListener('keydown', this.handleSearchKeydown.bind(this))
    }
    
    // Country option clicks
    this.countryListTarget.addEventListener('click', this.handleCountrySelection.bind(this))
    
    // Close dropdown when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this))
    
    // Mobile input formatting and validation
    if (this.hasMobileInputTarget) {
      this.mobileInputTarget.addEventListener('input', this.formatMobileNumber.bind(this))
      this.mobileInputTarget.addEventListener('blur', this.handleValidation.bind(this))
      this.mobileInputTarget.addEventListener('focus', this.clearValidationFeedback.bind(this))
    }
    
    // Country code validation
    this.countrySelectTarget.addEventListener('change', this.handleValidation.bind(this))
  }

  removeEventListeners() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  setupKeyboardNavigation() {
    this.countrySelectTarget.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault()
        this.toggleDropdown()
      } else if (e.key === 'ArrowDown') {
        e.preventDefault()
        this.openDropdown()
        this.highlightNext()
      } else if (e.key === 'ArrowUp') {
        e.preventDefault()
        this.openDropdown()
        this.highlightPrevious()
      }
    })

    if (this.hasDropdownTarget) {
      this.dropdownTarget.addEventListener('keydown', (e) => {
        switch (e.key) {
          case 'ArrowDown':
            e.preventDefault()
            this.highlightNext()
            break
          case 'ArrowUp':
            e.preventDefault()
            this.highlightPrevious()
            break
          case 'Enter':
            e.preventDefault()
            this.selectHighlightedCountry()
            break
          case 'Escape':
            e.preventDefault()
            this.closeDropdown()
            this.countrySelectTarget.focus()
            break
        }
      })
    }
  }

  toggleDropdown() {
    if (this.isDropdownOpen()) {
      this.closeDropdown()
    } else {
      this.openDropdown()
    }
  }

  openDropdown() {
    if (!this.hasDropdownTarget) return
    
    this.dropdownTarget.classList.add('show')
    this.element.querySelector('.country-selector').classList.add('active')
    
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
      this.searchInputTarget.value = ''
      this.showAllCountries()
    }
    
    this.currentHighlightIndex = -1
  }

  closeDropdown() {
    if (!this.hasDropdownTarget) return
    
    this.dropdownTarget.classList.remove('show')
    this.element.querySelector('.country-selector').classList.remove('active')
    this.currentHighlightIndex = -1
    this.clearHighlights()
  }

  isDropdownOpen() {
    return this.hasDropdownTarget && this.dropdownTarget.classList.contains('show')
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.closeDropdown()
    }
  }

  handleSearch(event) {
    const searchTerm = event.target.value.toLowerCase().trim()
    this.filterCountries(searchTerm)
    this.currentHighlightIndex = -1
    this.clearHighlights()
  }

  handleSearchKeydown(event) {
    if (event.key === 'Escape') {
      this.closeDropdown()
      this.countrySelectTarget.focus()
    }
  }

  filterCountries(searchTerm) {
    const countryOptions = this.countryListTarget.querySelectorAll('.country-option')
    
    countryOptions.forEach(option => {
      const countryName = option.dataset.name.toLowerCase()
      const countryCode = option.dataset.code.toLowerCase()
      
      if (countryName.includes(searchTerm) || countryCode.includes(searchTerm)) {
        option.classList.remove('hidden')
      } else {
        option.classList.add('hidden')
      }
    })
  }

  showAllCountries() {
    const countryOptions = this.countryListTarget.querySelectorAll('.country-option')
    countryOptions.forEach(option => {
      option.classList.remove('hidden')
    })
  }

  handleCountrySelection(event) {
    const countryOption = event.target.closest('.country-option')
    if (!countryOption) return
    
    const countryCode = countryOption.dataset.code
    const countryFlag = countryOption.dataset.flag
    
    this.selectCountry(countryCode, countryFlag)
    this.closeDropdown()
    
    if (this.hasMobileInputTarget) {
      this.mobileInputTarget.focus()
    }
  }

  selectCountry(countryCode, countryFlag = '') {
    // Update the select element
    this.countrySelectTarget.value = countryCode
    
    // Update the display elements
    if (this.hasSelectedFlagTarget && this.hasSelectedCodeTarget) {
      if (countryFlag) {
        this.selectedFlagTarget.textContent = countryFlag
      }
      this.selectedCodeTarget.textContent = countryCode
    }
    
    // Find the option and update it
    const option = Array.from(this.countrySelectTarget.options)
      .find(opt => opt.value === countryCode)
    
    if (option) {
      option.selected = true
      // Update display from option data if flag wasn't provided
      if (!countryFlag && option.dataset.countryFlag) {
        this.selectedFlagTarget.textContent = option.dataset.countryFlag
      }
    }
    
    // Trigger change event for form validation
    this.countrySelectTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  highlightNext() {
    const visibleOptions = this.getVisibleCountryOptions()
    if (visibleOptions.length === 0) return
    
    this.clearHighlights()
    this.currentHighlightIndex = Math.min(this.currentHighlightIndex + 1, visibleOptions.length - 1)
    this.highlightOption(visibleOptions[this.currentHighlightIndex])
  }

  highlightPrevious() {
    const visibleOptions = this.getVisibleCountryOptions()
    if (visibleOptions.length === 0) return
    
    this.clearHighlights()
    this.currentHighlightIndex = Math.max(this.currentHighlightIndex - 1, 0)
    this.highlightOption(visibleOptions[this.currentHighlightIndex])
  }

  selectHighlightedCountry() {
    const visibleOptions = this.getVisibleCountryOptions()
    if (this.currentHighlightIndex >= 0 && this.currentHighlightIndex < visibleOptions.length) {
      const selectedOption = visibleOptions[this.currentHighlightIndex]
      const countryCode = selectedOption.dataset.code
      const countryFlag = selectedOption.dataset.flag
      
      this.selectCountry(countryCode, countryFlag)
      this.closeDropdown()
      
      if (this.hasMobileInputTarget) {
        this.mobileInputTarget.focus()
      }
    }
  }

  getVisibleCountryOptions() {
    return Array.from(this.countryListTarget.querySelectorAll('.country-option:not(.hidden)'))
  }

  clearHighlights() {
    this.countryListTarget.querySelectorAll('.country-option.highlighted')
      .forEach(option => option.classList.remove('highlighted'))
  }

  highlightOption(option) {
    if (option) {
      option.classList.add('highlighted')
      option.scrollIntoView({ block: 'nearest' })
    }
  }

  getAllCountries() {
    return Array.from(this.countryListTarget.querySelectorAll('.country-option'))
      .map(option => ({
        name: option.dataset.name,
        code: option.dataset.code,
        iso: option.dataset.iso,
        flag: option.dataset.flag
      }))
  }

  formatMobileNumber(event) {
    let value = event.target.value
    
    // Remove any non-numeric characters except + - ( ) and spaces
    value = value.replace(/[^\d\+\-\(\)\s]/g, '')
    
    // Update the input value
    event.target.value = value
  }

  handleValidation() {
    // Delay validation slightly to allow for input completion
    setTimeout(() => {
      this.showValidationFeedback()
    }, 100)
  }

  clearValidationFeedback() {
    const container = this.element
    
    // Clear validation message
    if (this.hasValidationMessageTarget) {
      this.validationMessageTarget.textContent = ''
      this.validationMessageTarget.className = 'validation-message'
    }
    
    // Remove error/success styling from container
    container.classList.remove('has-error', 'has-success')
  }

  // Public method to get the selected country
  getSelectedCountry() {
    const selectedOption = this.countrySelectTarget.selectedOptions[0]
    if (selectedOption) {
      return {
        name: selectedOption.dataset.countryName,
        code: selectedOption.value,
        iso: selectedOption.dataset.countryIso,
        flag: selectedOption.dataset.countryFlag
      }
    }
    return null
  }

  // Public method to get the formatted phone number
  getFormattedPhoneNumber() {
    const country = this.getSelectedCountry()
    const mobileNumber = this.hasMobileInputTarget ? this.mobileInputTarget.value : ''
    
    if (country && mobileNumber) {
      return `${country.code} ${mobileNumber}`.trim()
    }
    
    return mobileNumber
  }

  // Public method to validate the phone number
  validatePhoneNumber() {
    const mobileNumber = this.hasMobileInputTarget ? this.mobileInputTarget.value : ''
    const country = this.getSelectedCountry()
    
    if (!country || !country.code) {
      return { valid: false, message: 'Please select a country code' }
    }
    
    if (!mobileNumber || mobileNumber.trim().length === 0) {
      return { valid: false, message: 'Mobile number is required' }
    }
    
    // Basic validation - at least 7 digits
    const digitCount = mobileNumber.replace(/\D/g, '').length
    if (digitCount < 7) {
      return { valid: false, message: 'Mobile number must have at least 7 digits' }
    }
    
    if (digitCount > 15) {
      return { valid: false, message: 'Mobile number cannot exceed 15 digits' }
    }
    
    return { valid: true, message: 'Valid mobile number' }
  }

  // Public method to show validation feedback
  showValidationFeedback() {
    const validation = this.validatePhoneNumber()
    const container = this.element
    
    // Clear existing validation state
    this.clearValidationFeedback()
    
    // Show validation message and styling
    if (this.hasValidationMessageTarget) {
      if (!validation.valid) {
        this.validationMessageTarget.textContent = validation.message
        this.validationMessageTarget.className = 'validation-message error'
        container.classList.add('has-error')
      } else if (this.mobileInputTarget.value.trim()) {
        // Show success for valid numbers
        container.classList.add('has-success')
      }
    }
    
    return validation
  }
}
