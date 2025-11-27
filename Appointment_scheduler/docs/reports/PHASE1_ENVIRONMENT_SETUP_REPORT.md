# Phase 1: Environment Variables Setup Report

**Date:** 2025-11-26
**Phase:** 1 of 7
**Estimated Time:** 5 minutes
**Status:** Ready for Execution

---

## Objective

Configure essential environment variables in your n8n instance to support monitoring system.

---

## Prerequisites

- [ ] Access to n8n instance at https://polarmedia.app.n8n.cloud
- [ ] Admin/Owner permissions in n8n
- [ ] Your alert email address
- [ ] Your alert phone number (E.164 format: +1234567890)

---

## Step-by-Step Instructions

### 1. Log into n8n (1 minute)

1. Open browser and navigate to: https://polarmedia.app.n8n.cloud
2. Log in with your credentials
3. Verify you're on the main dashboard

### 2. Access Settings (1 minute)

1. Click on **Settings** (gear icon) in the left sidebar
2. Look for **Environment** or **Variables** section
   - If you don't see this option, you may need to add variables via:
   - **Alternative:** Settings → Credentials → Environment Variables
   - **Or:** Via docker-compose.yml if self-hosted

### 3. Add Required Variables (3 minutes)

Add the following environment variables:

#### Critical Variables (Required)

```bash
# Alert Configuration
ALERT_EMAIL=<your-email@example.com>
# Example: ALERT_EMAIL=admin@quantumops.com

ALERT_PHONE=<your-phone-in-e164-format>
# Example: ALERT_PHONE=+12145551234
# Note: Must start with + and country code
```

#### Monitoring Variables (Required)

```bash
# Google Sheets - Will be filled in Phase 2
MONITORING_SHEET_ID=<will-set-after-creating-sheet>
# Leave blank for now - we'll update this in Phase 2

ERROR_LOG_SHEET_ID=<will-set-after-creating-sheet>
# Leave blank for now - same as MONITORING_SHEET_ID
```

#### Optional Configuration Variables

```bash
# Monitoring Tuning (Optional - has defaults)
HEALTH_CHECK_INTERVAL=5
# How often (in minutes) to check system health

ERROR_ALERT_THRESHOLD=3
# How many errors before escalation

BUSINESS_OPEN_HOUR=10
# Already exists in your system

BUSINESS_CLOSE_HOUR=18
# Already exists in your system
```

### 4. Verify Variables (1 minute)

After adding, verify by:

1. Check that variables appear in the list
2. Ensure no typos (especially in email/phone)
3. Save changes
4. **Important:** Some n8n instances require restart to load new env vars
   - If cloud-hosted: Usually auto-restarts
   - If self-hosted: Restart n8n service

---

## Verification Checklist

After completing this phase:

- [ ] `ALERT_EMAIL` is set to your email address
- [ ] `ALERT_PHONE` is set to your phone in +1234567890 format
- [ ] `MONITORING_SHEET_ID` is created (blank for now - Phase 2)
- [ ] `ERROR_LOG_SHEET_ID` is created (blank for now - Phase 2)
- [ ] Variables are saved
- [ ] n8n instance restarted (if required)

---

## Environment Variables Summary

| Variable | Purpose | Example | Status |
|----------|---------|---------|--------|
| `ALERT_EMAIL` | Email for alerts | admin@quantumops.com | ⏳ To set |
| `ALERT_PHONE` | SMS for critical alerts | +12145551234 | ⏳ To set |
| `MONITORING_SHEET_ID` | Google Sheet for logs | 1abc...xyz | ⏳ Phase 2 |
| `ERROR_LOG_SHEET_ID` | Error log sheet | 1abc...xyz | ⏳ Phase 2 |
| `HEALTH_CHECK_INTERVAL` | Check frequency (min) | 5 | ⏳ Optional |
| `ERROR_ALERT_THRESHOLD` | Escalation threshold | 3 | ⏳ Optional |

---

## Testing

To verify environment variables are loaded:

### Method 1: In n8n Workflow

1. Create a test workflow
2. Add a Code node
3. Use this code:

```javascript
return [{
  json: {
    alertEmail: $env.ALERT_EMAIL,
    alertPhone: $env.ALERT_PHONE,
    sheetId: $env.MONITORING_SHEET_ID || 'Not set yet',
    allEnvVars: Object.keys($env)
  }
}];
```

4. Execute the workflow
5. Check output - should show your email/phone

### Method 2: Check Execution Logs

Environment variables should be accessible in workflow execution context without showing sensitive values in logs.

---

## Alternative: n8n Cloud Environment Variables

If using **n8n Cloud** and don't see Environment Variables in Settings:

### Option A: Use Credentials

1. Go to **Credentials**
2. Create new credential type: **Generic**
3. Store variables as key-value pairs
4. Reference in workflows as: `{{$credentials.myConfig.ALERT_EMAIL}}`

### Option B: Contact n8n Support

n8n Cloud may have different methods for environment variables. Check:
- n8n Documentation: https://docs.n8n.io/hosting/environment-variables/
- Support: support@n8n.io

---

## Common Issues

### Issue 1: "Environment Variables not available"

**Solution:**
- Verify you're on n8n v0.200.0+
- Check if your plan supports environment variables
- Use Credentials as alternative

### Issue 2: "Variables not loading in workflows"

**Solution:**
- Restart n8n instance
- Clear browser cache
- Check variable syntax (no spaces, uppercase)

### Issue 3: "Can't find Settings → Environment"

**Solution:**
- Try: Settings → Execution → Environment Variables
- Or: Workflows → Settings → Variables
- Self-hosted: Edit docker-compose.yml or .env file

---

## n8n Cloud Specific Setup

If you're on **n8n Cloud** (polarmedia.app.n8n.cloud), environment variables might be set via:

### Via Settings UI (Preferred)
1. Settings → Environments (if available)
2. Add variables as shown above

### Via Credentials (Alternative)
1. Credentials → Add Credential
2. Choose "HTTP Header Auth" or create custom
3. Store values there
4. Reference in workflows

### Via Support Request
If neither works:
1. Contact n8n support
2. Request environment variable setup
3. Provide list of variables needed

---

## Security Notes

🔒 **Important Security Practices:**

1. **Never commit env vars to git**
   - Already in .gitignore
   - Keep sensitive values private

2. **Use strong phone number validation**
   - Must be E.164 format
   - Verify it's your number

3. **Email security**
   - Use dedicated monitoring email
   - Enable 2FA on email account

4. **Access control**
   - Limit who can edit environment variables
   - Audit changes regularly

---

## Next Steps

After completing this phase:

1. ✅ Mark Phase 1 as complete
2. ✅ Proceed to Phase 2: Google Sheets Dashboard
3. ✅ Return to update `MONITORING_SHEET_ID` after creating sheet

---

## Completion Criteria

Phase 1 is complete when:

- [x] All required variables are set in n8n
- [x] Variables are accessible in workflow context
- [x] Test workflow confirms values are loaded
- [x] n8n instance is running normally

---

## Time Spent

- **Estimated:** 5 minutes
- **Actual:** _____ minutes (fill in after completion)

---

## Phase 1 Status: ⏳ READY TO EXECUTE

**Next Phase:** Phase 2 - Google Sheets Dashboard Setup

---

## Notes / Issues Encountered

(Fill in any issues or notes during execution)

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

**Prepared by:** Claude Code
**Date:** 2025-11-26
**Document Version:** 1.0
