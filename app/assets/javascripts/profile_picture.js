// Profile Picture Upload Functionality

document.addEventListener('DOMContentLoaded', function() {
  const profileUploadInput = document.getElementById('profile-upload-input');
  const profilePic = document.getElementById('profile-pic');
  const editIcon = document.querySelector('.edit-icon');

  if (!profileUploadInput || !profilePic) {
    return; // Exit if elements don't exist
  }

  // Handle file selection
  profileUploadInput.addEventListener('change', function(event) {
    const file = event.target.files[0];
    
    if (!file) {
      return;
    }

    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      alert('Please select a valid image file (JPEG, PNG, or WebP).');
      return;
    }

    // Validate file size (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    if (file.size > maxSize) {
      alert('File size must be less than 5MB.');
      return;
    }

    // Show loading state
    const originalSrc = profilePic.src;
    profilePic.style.opacity = '0.5';
    editIcon.innerHTML = '⟳';
    editIcon.style.animation = 'spin 1s linear infinite';

    // Preview the image immediately
    const reader = new FileReader();
    reader.onload = function(e) {
      profilePic.src = e.target.result;
    };
    reader.readAsDataURL(file);

    // Upload to server
    const formData = new FormData();
    formData.append('profile_picture', file);

    fetch('/profile-picture', {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    .then(response => response.json())
    .then(data => {
      // Reset loading state
      profilePic.style.opacity = '1';
      editIcon.innerHTML = '✎';
      editIcon.style.animation = '';

      if (data.success) {
        // Update the image source with the server URL
        profilePic.src = data.image_url;
        showNotification(data.message, 'success');
      } else {
        // Revert to original image on error
        profilePic.src = originalSrc;
        showNotification(data.message || 'Failed to upload profile picture.', 'error');
      }
    })
    .catch(error => {
      console.error('Upload error:', error);
      
      // Reset loading state
      profilePic.style.opacity = '1';
      editIcon.innerHTML = '✎';
      editIcon.style.animation = '';
      
      // Revert to original image
      profilePic.src = originalSrc;
      showNotification('An error occurred while uploading. Please try again.', 'error');
    });

    // Clear the input so the same file can be selected again
    profileUploadInput.value = '';
  });

  // Add keyboard accessibility
  editIcon.addEventListener('keydown', function(event) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      profileUploadInput.click();
    }
  });

  // Make edit icon focusable
  editIcon.setAttribute('tabindex', '0');
  editIcon.setAttribute('role', 'button');
  editIcon.setAttribute('aria-label', 'Change profile picture');
});

// Notification function
function showNotification(message, type = 'info') {
  // Remove existing notifications
  const existingNotifications = document.querySelectorAll('.profile-notification');
  existingNotifications.forEach(notification => notification.remove());

  // Create notification element
  const notification = document.createElement('div');
  notification.className = `profile-notification profile-notification-${type}`;
  notification.textContent = message;
  
  // Style the notification
  Object.assign(notification.style, {
    position: 'fixed',
    top: '20px',
    right: '20px',
    backgroundColor: type === 'success' ? '#10b981' : '#ef4444',
    color: 'white',
    padding: '12px 20px',
    borderRadius: '8px',
    fontSize: '14px',
    fontWeight: '500',
    boxShadow: '0 4px 12px rgba(0, 0, 0, 0.2)',
    zIndex: '9999',
    opacity: '0',
    transform: 'translateY(-20px)',
    transition: 'all 0.3s ease'
  });

  // Add to DOM
  document.body.appendChild(notification);

  // Animate in
  setTimeout(() => {
    notification.style.opacity = '1';
    notification.style.transform = 'translateY(0)';
  }, 10);

  // Remove after 3 seconds
  setTimeout(() => {
    notification.style.opacity = '0';
    notification.style.transform = 'translateY(-20px)';
    setTimeout(() => notification.remove(), 300);
  }, 3000);
}

// Add CSS animation for loading spinner
const style = document.createElement('style');
style.textContent = `
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
`;
document.head.appendChild(style);
