# Phase 4: Import System Health Monitor Workflow Report

**Date:** 2025-11-26
**Phase:** 4 of 7
**Estimated Time:** 10 minutes
**Status:** Ready for Execution

---

## Objective

Import the System Health Monitor workflow into n8n, configure it with your credentials, and activate automated health checking.

---

## Prerequisites

- [ ] Phase 1-3 completed (env vars set, Google Sheets ready)
- [ ] Access to n8n at https://polarmedia.app.n8n.cloud
- [ ] File: `System Health Monitor v1.0.json` available
- [ ] Twilio credentials configured in n8n
- [ ] Google Sheets credentials configured in n8n
- [ ] Email credentials configured in n8n

---

## Step-by-Step Instructions

### Step 1: Import Workflow File (2 minutes)

1. **Open n8n**
   - Navigate to: https://polarmedia.app.n8n.cloud
   - Log in with your credentials

2. **Import Workflow**
   - Click **"+"** button (top right) or "Add Workflow"
   - Click **"Import from File"** or look for import option in menu
   - Alternative: Workflows menu → Import

3. **Select File**
   - Browse to: `/Users/anitavallabha/claude/Appointment_scheduler/`
   - Select: `System Health Monitor v1.0.json`
   - Click **"Open"** or **"Import"**

4. **Wait for Import**
   - n8n will load the workflow
   - You should see the workflow canvas with nodes
   - Name should be: "System Health Monitor v1.0"

---

### Step 2: Verify Workflow Structure (1 minute)

You should see these nodes connected in sequence:

```
[Every 5 Minutes] → [Prepare Health Checks] → [Check Webhook Endpoint] →
[Analyze Results] → [Has Issues?] → [Route by Severity] →
├─ [Send SMS (Critical)]
├─ [Send Email (High)]
├─ [Log to Sheets (Warning)]
└─ [Log Healthy Status]
```

**Node count:** 9 nodes total

If any nodes are missing or disconnected, the import may have failed - try re-importing.

---

### Step 3: Configure Credentials (5 minutes)

Now we need to connect each node to your credentials.

#### 3A: Configure Twilio (SMS) Node

1. **Click on node:** "Send SMS (Critical)"

2. **Credential field:**
   - If you already have Twilio credentials:
     - Click dropdown → Select existing "Twilio Account" or "Twilio API"
   - If not set up yet:
     - Click "Create New"
     - Enter:
       - **Account SID:** (from Twilio console)
       - **Auth Token:** (from Twilio console)
     - Click "Save"

3. **Verify phone numbers:**
   - From: Should be `+14694365607` (your Twilio number)
   - To: Should reference `{{$env.ALERT_PHONE}}` (uses env variable)
   - If you want to test with a different number, you can hardcode it temporarily

---

#### 3B: Configure Email Nodes

1. **Click on node:** "Send Email (High)"

2. **Set up Email credential:**

   **Option A: Gmail**
   - Credential type: "Gmail OAuth2"
   - Click "Connect my account"
   - Authorize with Google
   - Grant permissions

   **Option B: SMTP**
   - Credential type: "SMTP"
   - Host: (your SMTP server, e.g., smtp.gmail.com)
   - Port: 587 (TLS) or 465 (SSL)
   - User: your-email@gmail.com
   - Password: (app password if using Gmail)

   **Option C: SendGrid / Other**
   - Follow n8n's credential setup for your email provider

3. **Configure email fields:**
   - **From:** Your sending email (e.g., alerts@quantumops.com)
   - **To:** `{{$env.ALERT_EMAIL}}` (uses environment variable)
   - **Subject:** Already set in workflow
   - **Body:** Already set in workflow

---

#### 3C: Configure Google Sheets Nodes

There are 2 Google Sheets nodes in the workflow:
- "Log to Sheets (Warning)"
- "Log Healthy Status"

For EACH node:

1. **Click on the node**

2. **Set credentials:**
   - If you have Google Sheets OAuth already:
     - Select from dropdown
   - If not:
     - Click "Create New"
     - Choose "Google Sheets OAuth2"
     - Click "Connect my account"
     - Authorize with Google
     - Grant permissions

3. **Configure Sheet reference:**
   - Document ID field should show: `{{$env.MONITORING_SHEET_ID}}`
   - This pulls from your environment variable
   - If you see an error, make sure MONITORING_SHEET_ID is set in env vars

4. **Set Sheet Name:**
   - Sheet Name: `System Health Log`
   - This must match the tab name in your Google Sheet exactly

5. **Verify column mapping:**
   - Should already be configured:
     - Timestamp → `{{$json.timestamp}}`
     - Severity → `{{$json.severity}}`
     - Health_Percentage → `{{$json.healthPercentage}}`
     - Healthy_Count → `{{$json.healthy}}`
     - Unhealthy_Count → `{{$json.unhealthy}}`
     - Critical_Failures → `{{JSON.stringify($json.critical_failures)}}`
     - Warnings → `{{JSON.stringify($json.warnings)}}`
     - Alert_Sent → `{{$json.alertMethod}}`

---

### Step 4: Configure Webhook URLs (2 minutes)

1. **Click on node:** "Prepare Health Checks"

2. **This is a Code node** - you may need to verify webhook URLs match your setup

3. **Open the code editor** (click on node, then "Edit Code" or similar)

4. **Verify URLs in the `workflows` array:**

```javascript
const workflows = [
  {
    name: 'Main Booking',
    webhook: 'https://polarmedia.app.n8n.cloud/webhook/vapi/call',
    critical: true
  },
  {
    name: 'Lookup',
    webhook: 'https://polarmedia.app.n8n.cloud/webhook/vapi/lookup',
    critical: true
  },
  // ... etc
];
```

5. **Update if needed:**
   - If your webhooks use different paths, update them here
   - Verify your n8n instance URL is correct (polarmedia.app.n8n.cloud)
   - Check that webhook paths match your actual workflows

6. **Click "Save"** (if you made changes)

---

### Step 5: Test the Workflow (3 minutes)

**BEFORE activating, test manually:**

1. **Click "Execute Workflow"** button (top right, or "Test Workflow")

2. **Watch execution:**
   - Green checkmarks = success
   - Red X = error
   - You'll see data flow through each node

3. **Expected results:**

   **If all workflows are active and healthy:**
   - "Check Webhook Endpoint" should show 7 successful requests (status 200 or 405)
   - "Analyze Results" should show `allHealthy: true`, `severity: OK`
   - "Has Issues?" should take the FALSE path (no issues)
   - "Log Healthy Status" should execute
   - A new row should appear in your Google Sheet "System Health Log" tab

   **If any workflow is down:**
   - You'll see failed requests in "Check Webhook Endpoint"
   - "Analyze Results" will show unhealthy count > 0
   - "Route by Severity" will execute
   - You'll receive an alert (SMS or Email based on severity)

4. **Check Google Sheet:**
   - Open your monitoring sheet
   - Go to "System Health Log" tab
   - You should see a new row with current timestamp

5. **Check for errors:**
   - If you see red X on any node, click it to see error details
   - Common issues:
     - Credentials not set
     - Google Sheet not shared
     - Environment variables not loaded
     - Webhook URLs incorrect

---

### Step 6: Activate the Workflow (1 minute)

Once test is successful:

1. **Toggle to activate:**
   - Top right: Look for **"Inactive"** toggle switch
   - Click to change to **"Active"**
   - Workflow should now show **"Active"** status

2. **Verify schedule:**
   - The "Every 5 Minutes" trigger should now be running
   - Check workflow executions list to confirm it runs automatically

3. **First automatic execution:**
   - Wait 5 minutes
   - Check "Executions" (left sidebar)
   - You should see an automatic execution
   - Verify it succeeded

---

## Verification Checklist

After completing this phase:

- [ ] Workflow imported successfully with all 9 nodes
- [ ] Twilio credentials configured and connected
- [ ] Email credentials configured and connected
- [ ] Google Sheets credentials configured and connected
- [ ] Google Sheet ID referenced via environment variable
- [ ] Webhook URLs verified and match your system
- [ ] Manual test execution successful
- [ ] Google Sheet received test data
- [ ] Workflow activated (toggle shows "Active")
- [ ] First automatic execution successful (after 5 min wait)

---

## Workflow Configuration Summary

| Node | Credential Type | Configuration |
|------|----------------|---------------|
| Send SMS (Critical) | Twilio API | From: +14694365607, To: $env.ALERT_PHONE |
| Send Email (High) | Gmail/SMTP | From: alerts@, To: $env.ALERT_EMAIL |
| Log to Sheets (Warning) | Google OAuth | Sheet: $env.MONITORING_SHEET_ID, Tab: System Health Log |
| Log Healthy Status | Google OAuth | Sheet: $env.MONITORING_SHEET_ID, Tab: System Health Log |

---

## Understanding the Health Monitor

### What It Does:

**Every 5 minutes:**
1. ✅ Sends HEAD requests to all 7 webhook endpoints
2. ✅ Analyzes responses (200/405 = healthy, others = unhealthy)
3. ✅ Calculates health percentage (healthy/total)
4. ✅ Determines severity:
   - CRITICAL: Critical workflows down
   - HIGH: 3+ workflows unhealthy
   - WARNING: 1-2 workflows unhealthy
   - OK: All healthy
5. ✅ Routes alerts:
   - CRITICAL → SMS
   - HIGH → Email
   - WARNING → Log only
   - OK → Log healthy status
6. ✅ Logs all results to Google Sheets

### Monitored Endpoints:

1. Main Booking: `/webhook/vapi/call`
2. Lookup: `/webhook/vapi/lookup`
3. Cancel: `/webhook/vapi/cancel`
4. Reschedule: `/webhook/vapi/reschedule`
5. Recovery: `/webhook/vapi/recovery`
6. Check Availability: `/webhook/vapi/check-availability`
7. Group Booking: `/webhook/vapi/group-booking`

---

## Customization Options

### Change Check Interval:

1. Click on "Every 5 Minutes" trigger node
2. Change "Minutes Interval" to desired value (e.g., 10, 15)
3. Save

### Add More Endpoints:

1. Click "Prepare Health Checks" code node
2. Add to `workflows` array:
```javascript
{
  name: 'Your Workflow Name',
  webhook: 'https://polarmedia.app.n8n.cloud/webhook/your/path',
  critical: true  // or false
}
```
3. Save

### Change Alert Phone/Email:

Update environment variables in n8n Settings:
- `ALERT_PHONE=+1234567890`
- `ALERT_EMAIL=your-email@example.com`

---

## Troubleshooting

### Issue: "Environment variable not found"

**Solution:**
- Verify env vars are set: Settings → Environment Variables
- Check spelling: `MONITORING_SHEET_ID` (case-sensitive)
- Restart workflow or n8n instance

### Issue: "Authentication failed" (Google Sheets)

**Solution:**
- Re-authenticate: Credentials → Google Sheets → Reconnect
- Verify sheet is shared with service account
- Check sheet ID is correct

### Issue: "Twilio error" or "Email error"

**Solution:**
- Verify credentials are correct
- Check phone number format: +1234567890
- Test credentials manually in n8n

### Issue: "All endpoints show unhealthy"

**Solution:**
- Change HTTP method from HEAD to GET in "Check Webhook Endpoint" node
- Add authentication headers if webhooks require them
- Verify webhook URLs are accessible

### Issue: "Workflow not executing automatically"

**Solution:**
- Check workflow is Active (toggle)
- Verify schedule trigger is enabled
- Check n8n execution quota (plan limits)

---

## Monitoring the Monitor

Once active, monitor the health monitor itself:

- Check Executions list every few hours
- Verify it's running every 5 minutes
- Confirm data is flowing to Google Sheets
- Test alerts by temporarily deactivating a workflow

---

## Next Steps

After completing this phase:

1. ✅ Phase 4 complete - Health monitor active
2. ➡️ Proceed to Phase 5: Add error handlers to all workflows
3. ➡️ Then you'll have complete error coverage!

---

## Completion Criteria

Phase 4 is complete when:

- [x] Workflow imported and all nodes visible
- [x] All credentials configured and tested
- [x] Manual execution successful
- [x] Data appears in Google Sheets
- [x] Workflow activated and running automatically
- [x] No errors in execution logs

---

## Time Spent

- **Estimated:** 10 minutes
- **Actual:** _____ minutes (fill in after completion)

---

## Execution Log

**First Manual Test:**
- Time: ____________
- Result: Success / Failed
- Errors (if any): ____________

**First Automatic Execution:**
- Time: ____________
- Result: Success / Failed
- Data in Sheet: Yes / No

---

## Phase 4 Status: ⏳ READY TO EXECUTE

**Next Phase:** Phase 5 - Add Error Handlers to All Workflows

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
**Phase:** 4 of 7
