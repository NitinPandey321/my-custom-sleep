# Email Setup Instructions

## To send real emails to iamtheworst369@gmail.com:

### Step 1: Configure Gmail App Password
1. Go to your Google Account: https://myaccount.google.com/
2. Click on "Security" in the left sidebar
3. Enable "2-Step Verification" if not already enabled
4. Under "2-Step Verification", click on "App passwords"
5. Select "Mail" from the dropdown
6. Click "Generate" 
7. Copy the 16-character password that appears

### Step 2: Update .env file
Open the `.env` file in your project and replace:

```
GMAIL_USERNAME=iamtheworst369@gmail.com
GMAIL_APP_PASSWORD=your_16_character_app_password_here
```

### Step 3: Restart Rails Server
```bash
# Stop current server (Ctrl+C)
# Then restart:
bundle exec rails server
```

### Step 4: Test the Email
1. Go to http://localhost:3000
2. Click "Sign Up" 
3. Choose "I'm a Client"
4. Fill out the form with your details
5. Submit - you should receive a welcome email at iamtheworst369@gmail.com

## Troubleshooting:
- If emails don't arrive, check spam folder
- If SMTP fails, emails will open in browser as fallback
- Check Rails logs for detailed error messages

## Current Status:
✓ Email templates created with company branding
✓ SMTP configuration ready 
✓ Fallback to browser preview if SMTP fails
✓ Email logging for tracking
⚠ Needs your Gmail App Password to send real emails
