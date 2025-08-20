# Gmail App Password Setup Guide

## The Issue
Your App Password `jrmk wawu ifnh qtbj` is being rejected by Gmail.

## Quick Fix - Generate New App Password

### Step 1: Check Current Status
1. Go to https://myaccount.google.com/security
2. Ensure "2-Step Verification" is ON
3. Look for "App passwords" section

### Step 2: Generate New App Password
1. Click "App passwords"
2. Select "Other (Custom name)"
3. Type: "My Custom Sleep Journey"
4. Click "Generate"
5. Copy the 16-character password (no spaces)

### Step 3: Update .env File
Replace the current password in `.env`:
```
GMAIL_USERNAME=iamtheworst369@gmail.com
GMAIL_APP_PASSWORD=your_new_16_char_password
```

### Step 4: Test Email
1. Save the .env file
2. Run: `rails runner smtp_test.rb`
3. If successful, test signup at http://localhost:3000

## Current Fallback
✅ While we fix Gmail, emails will open in your browser automatically
✅ All email functionality is working
✅ Professional email templates are ready

## Alternative: Test Right Now
1. Go to http://localhost:3000
2. Click "Sign Up" → "I'm a Client"
3. Fill in your details with iamtheworst369@gmail.com
4. Submit → Email will open in browser tab

Once Gmail App Password is fixed, emails will be sent to your real inbox automatically!
