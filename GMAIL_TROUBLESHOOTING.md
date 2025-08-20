# 🔧 Gmail App Password Troubleshooting Guide

## Current Status
✅ Password format is correct (16 characters, no spaces)
✅ Environment variables are properly set
❌ Gmail is still rejecting authentication

## Most Likely Issues & Solutions

### 1. 2-Factor Authentication Not Fully Enabled
**Check this first:**
1. Go to: https://myaccount.google.com/security
2. Look for "2-Step Verification" 
3. Must show "On" (not "Getting started" or "Off")
4. If it shows anything other than "On", complete the 2FA setup first

### 2. App Password Generated Incorrectly
**Steps to regenerate:**
1. Go to: https://myaccount.google.com/security
2. Click "2-Step Verification" 
3. Scroll down to "App passwords"
4. Click "App passwords"
5. Select "Other (Custom name)"
6. Type: "Rails Email App"
7. Click "Generate"
8. **IMPORTANT**: Copy the password immediately (it's only shown once)

### 3. Google Workspace Account (Not Personal Gmail)
**If your email is managed by an organization:**
- App Passwords might be disabled by admin
- Contact your IT administrator
- Alternative: Use a personal Gmail account for testing

### 4. Account Security Restrictions
**Recently created accounts may have restrictions:**
- Account less than 24 hours old
- Recent suspicious activity detected
- Multiple failed login attempts

### 5. Alternative SMTP Settings
**Try different Gmail SMTP configuration:**
```
Port: 465 (instead of 587)
SSL: true (instead of STARTTLS)
```

## Quick Test Commands

### Test 1: Verify 2FA Status
1. Visit: https://myaccount.google.com/security
2. Confirm "2-Step Verification" shows "On"

### Test 2: Generate Fresh App Password
1. Delete current App Password (if any exists)
2. Generate new one for "Mail" application
3. Update .env file immediately

### Test 3: Try Alternative Email
If issues persist, test with a different Gmail account to isolate the problem.

## Next Steps
1. ✅ Complete 2FA verification (most common issue)
2. ✅ Generate fresh App Password
3. ✅ Update .env file
4. ✅ Test: `rails runner smtp_test.rb`

## If Still Failing
We'll implement a working email solution using:
- SendGrid (free tier: 100 emails/day)
- Mailgun (free tier: 100 emails/day)
- Continue using browser preview (current fallback)
