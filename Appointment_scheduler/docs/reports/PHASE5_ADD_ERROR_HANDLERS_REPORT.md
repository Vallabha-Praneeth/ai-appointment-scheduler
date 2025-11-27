# Phase 5: Add Error Handlers to All Workflows Report

**Date:** 2025-11-26
**Phase:** 5 of 7
**Estimated Time:** 20-30 minutes
**Status:** Ready for Execution

---

## Objective

Add comprehensive error handling to all 7 production workflows using the Error Handler Template, enabling real-time error detection, classification, and alerting.

---

## Prerequisites

- [ ] Phase 4 completed (Health Monitor active)
- [ ] File: `Error Handler Template.json` available
- [ ] All 7 workflows accessible in n8n
- [ ] Credentials configured (Twilio, Email, Google Sheets)
- [ ] Environment variables set (ALERT_EMAIL, ALERT_PHONE, ERROR_LOG_SHEET_ID)

---

## Workflows to Update

You will add error handlers to these 7 workflows:

1. ✅ Appointment Scheduling AI_v.0.0.3.json (Main Booking)
2. ✅ Appointment Scheduling AI_v.0.0.3_vapi_lookup.json
3. ✅ Appointment Scheduling AI_v.0.0.3_vapi_cancel.json
4. ✅ Appointment Scheduling AI_v.0.0.3_vapi_reschedule.json
5. ✅ Appointment Scheduling AI_v.0.0.3_vapi_recovery.json
6. ✅ Appointment Scheduling AI v.0.0.3 (Check Availability).json
7. ✅ Appointment Scheduling AI v.0.0.3 (Group Booking).json

---

## Overview: Two Methods

### Method A: Copy Nodes from Template (Recommended - Faster)
- Open template
- Copy all error handling nodes
- Paste into each workflow
- Configure credentials once per workflow
- **Time:** ~3-4 min per workflow

### Method B: Manual Addition (More Control)
- Add nodes one by one
- Copy code from template
- Configure each node
- **Time:** ~5-7 min per workflow

**We'll use Method A for efficiency.**

---

## Step-by-Step Instructions (Method A)

### Step 1: Open Error Handler Template (1 minute)

1. **In n8n, import the template** (if not already imported)
   - Workflows → Import from File
   - Select: `Error Handler Template.json`
   - Import (but DON'T activate it)

2. **Open the template workflow**
   - This is your reference for copying

3. **You should see these nodes:**
   ```
   [Error Trigger] → [Process Error Details] → [Route by Severity] →
   ├─ [Send SMS Alert]
   ├─ [Send Email Alert]
   └─ [Log to Error Sheet]
        └─ [Check if Recurring] → [Send Escalation Alert]
   ```

---

### Step 2: Add Error Handler to Workflow #1 - Main Booking (4 minutes)

1. **Open workflow:** "Appointment Scheduling AI_v.0.0.3"

2. **Select all error handling nodes in template:**
   - In the Error Handler Template workflow
   - Click and drag to select ALL nodes (7 nodes total)
   - Or: Ctrl+A / Cmd+A to select all
   - Ctrl+C / Cmd+C to copy

3. **Switch to Main Booking workflow**

4. **Paste nodes:**
   - Click on empty canvas area
   - Ctrl+V / Cmd+V to paste
   - Nodes should appear (may be overlapping - we'll fix that)

5. **Position nodes (important for clarity):**
   - Drag the Error Trigger node to a clear area (e.g., far right or bottom)
   - Other nodes should auto-arrange based on connections
   - Goal: Keep error handling separate from main workflow logic

6. **Configure Credentials:**

   **For each node that needs credentials:**

   **a) Send SMS Alert:**
   - Click node
   - Select your Twilio credential from dropdown
   - Verify To: `{{$env.ALERT_PHONE}}`
   - Verify From: `+14694365607`

   **b) Send Email Alert:**
   - Click node
   - Select your Email credential
   - Verify To: `{{$env.ALERT_EMAIL}}`
   - Update From: (your sending email)

   **c) Log to Error Sheet:**
   - Click node
   - Select your Google Sheets credential
   - Verify Document ID: `{{$env.ERROR_LOG_SHEET_ID}}`
   - Verify Sheet Name: `Error Log`

   **d) Send Escalation Alert:**
   - Click node
   - Select your Email credential
   - Same settings as Send Email Alert

7. **Verify Connections:**
   - Error Trigger should NOT be connected to main workflow
   - It triggers independently when ANY node in the workflow errors
   - All other nodes should be connected as in template

8. **Save Workflow**
   - Click "Save" (top right)
   - Workflow remains Active (don't deactivate)

9. **Test Error Handler (Optional but Recommended):**
   - Add a temporary "Error" node:
     - Click "+" to add node
     - Search "Stop and Error"
     - Add "Stop and Error" node
     - Connect it somewhere in your workflow (temporarily)
     - Set message: "Test error for monitoring"
   - Execute workflow (will trigger the error)
   - Check that:
     - Error was caught by Error Trigger
     - Error details processed
     - Alert sent (check email)
     - Row added to Error Log in Google Sheets
   - **Remove the test error node after testing!**

---

### Step 3: Add Error Handler to Remaining 6 Workflows (18 minutes)

**Repeat Step 2 for each of these workflows:**

#### Workflow #2: Lookup
- Open: "Appointment Scheduling AI_v.0.0.3_vapi_lookup"
- Copy/paste error handler nodes from template
- Configure credentials (same as #1)
- Save
- (Optional) Test

#### Workflow #3: Cancel
- Open: "Appointment Scheduling AI_v.0.0.3_vapi_cancel"
- Copy/paste error handler nodes
- Configure credentials
- Save

#### Workflow #4: Reschedule
- Open: "Appointment Scheduling AI_v.0.0.3_vapi_reschedule"
- Copy/paste error handler nodes
- Configure credentials
- Save

#### Workflow #5: Recovery
- Open: "Appointment Scheduling AI_v.0.0.3_vapi_recovery"
- Copy/paste error handler nodes
- Configure credentials
- Save

#### Workflow #6: Check Availability
- Open: "Appointment Scheduling AI v.0.0.3 (Check Availability)"
- Copy/paste error handler nodes
- Configure credentials
- Save

#### Workflow #7: Group Booking
- Open: "Appointment Scheduling AI v.0.0.3 (Group Booking)"
- Copy/paste error handler nodes
- Configure credentials
- Save

---

## Alternative: Method B - Manual Addition (If Copy/Paste Doesn't Work)

If n8n doesn't support copy/paste between workflows, use this method:

### For EACH workflow:

1. **Add Error Trigger Node**
   - Click "+" in workflow canvas
   - Search: "Error Trigger"
   - Add it to workflow
   - Position it away from main flow

2. **Add Code Node: "Process Error Details"**
   - Click "+" and connect to Error Trigger
   - Search: "Code"
   - Open Error Handler Template
   - Copy ALL code from "Process Error Details" node
   - Paste into new Code node
   - Rename node to: "Process Error Details"

3. **Add Switch Node: "Route by Severity"**
   - Add Switch node after Code node
   - Configure 3 outputs:
     - Output 1: `{{$json.severity}}` equals `HIGH`
     - Output 2: `{{$json.severity}}` equals `MEDIUM`
     - Output 3: `{{$json.severity}}` equals `LOW`

4. **Add Twilio Node: "Send SMS Alert"**
   - Connect to HIGH output
   - Configure as in Step 2

5. **Add Email Node: "Send Email Alert"**
   - Connect to MEDIUM output
   - Configure as in Step 2

6. **Add Google Sheets Node: "Log to Error Sheet"**
   - Connect ALL three outputs to this node
   - Configure as in Step 2

7. **Add Code Node: "Check if Recurring"**
   - Connect after Google Sheets node
   - Copy code from template
   - Paste

8. **Add Email Node: "Send Escalation Alert"**
   - Connect to Check if Recurring output
   - Configure similar to Send Email Alert

9. **Save**

---

## Verification Checklist

After completing this phase:

### For EACH of the 7 workflows:

- [ ] Error Trigger node added
- [ ] Process Error Details code node added with full code
- [ ] Route by Severity switch configured
- [ ] Send SMS Alert connected and credentialed
- [ ] Send Email Alert connected and credentialed
- [ ] Log to Error Sheet connected and credentialed
- [ ] Check if Recurring code node added
- [ ] Send Escalation Alert connected
- [ ] All nodes properly connected
- [ ] Workflow saved and remains Active

### Overall System:

- [ ] All 7 workflows updated
- [ ] Error handlers tested in at least 1 workflow
- [ ] Google Sheet "Error Log" tab ready to receive data
- [ ] Alert email/phone configured correctly

---

## Error Handler Features

### What the Error Handler Does:

1. **Catches Errors:**
   - Any error in ANY node of the workflow
   - Automatically triggers Error Trigger node

2. **Extracts Context:**
   - Workflow name and ID
   - Node where error occurred
   - Error message and type
   - Input data that caused error
   - Timestamp and execution ID

3. **Classifies Severity:**
   - **HIGH:** Calendar/Twilio/auth errors → SMS alert
   - **MEDIUM:** General errors → Email alert
   - **LOW:** Validation errors → Log only

4. **Routes Alerts:**
   - HIGH severity → SMS to ALERT_PHONE
   - MEDIUM severity → Email to ALERT_EMAIL
   - LOW severity → Log to Google Sheets only

5. **Detects Patterns:**
   - Checks if same error occurred 3+ times in last hour
   - Escalates recurring errors with special alert

6. **Logs Everything:**
   - All errors logged to "Error Log" sheet
   - Includes full context for debugging

---

## Understanding Error Severity Classification

The error handler uses keywords to classify severity:

### HIGH Severity (SMS Alert):
- Error message contains: `calendar`, `twilio`, `authentication`, `timeout`, `network`
- Examples:
  - "Google Calendar API authentication failed"
  - "Twilio service unavailable"
  - "Network timeout"

### MEDIUM Severity (Email Alert):
- Default for most errors
- Examples:
  - "Failed to process booking"
  - "Unexpected response from webhook"

### LOW Severity (Log Only):
- Error message contains: `validation`, `missing`
- Examples:
  - "Validation error: missing required field"
  - "Missing startIso parameter"

### Customizing Severity:

Edit the "Process Error Details" code node:

```javascript
// Classify error severity
const criticalKeywords = ['calendar', 'twilio', 'authentication', 'timeout', 'network'];
const errorLower = errorDetails.errorMessage.toLowerCase();

if (criticalKeywords.some(kw => errorLower.includes(kw))) {
  errorDetails.severity = 'HIGH';
  errorDetails.alertMethod = 'SMS';
}

// Add your custom keywords:
if (errorLower.includes('your_keyword')) {
  errorDetails.severity = 'HIGH';
}
```

---

## Testing Error Handlers

### Test 1: Trigger Validation Error (LOW)

Use a workflow test endpoint:

```bash
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{"missing": "required_fields"}'
```

**Expected:**
- Error caught
- Severity: LOW or MEDIUM
- Email alert sent (or log only)
- Row in Error Log sheet

### Test 2: Trigger High Severity Error

Temporarily modify a Code node in one workflow:

```javascript
// Add this at start of a Code node
throw new Error('Calendar API authentication failed - TEST');
```

Execute workflow.

**Expected:**
- Error caught
- Severity: HIGH
- SMS alert sent
- Email alert sent
- Row in Error Log sheet

**Don't forget to remove the test error!**

### Test 3: Check Error Log Sheet

1. Open Google Sheet
2. Go to "Error Log" tab
3. Should see test errors logged with:
   - Timestamp
   - Workflow name
   - Severity
   - Error message
   - All context

---

## Troubleshooting

### Issue: "Error Trigger not firing"

**Cause:** Error Trigger only catches errors in the SAME workflow

**Solution:**
- Ensure Error Trigger node is in the same workflow as the error
- Verify workflow is Active
- Check if error is actually occurring (check execution logs)

### Issue: "No SMS received"

**Solution:**
- Check Twilio credentials are valid
- Verify phone number format (+1234567890)
- Check Twilio account balance
- Verify ALERT_PHONE env variable is set

### Issue: "Google Sheets not logging errors"

**Solution:**
- Verify sheet is shared with n8n service account
- Check ERROR_LOG_SHEET_ID env variable
- Confirm "Error Log" tab exists and name matches exactly
- Re-authenticate Google Sheets credential

### Issue: "All errors showing as HIGH severity"

**Solution:**
- Check the severity classification logic in "Process Error Details"
- Keywords may be too broad
- Customize keywords as needed

### Issue: "Escalation alerts sending too frequently"

**Solution:**
- Increase threshold in "Check if Recurring" code:
  ```javascript
  if (similarCount >= 5) {  // Changed from 3
  ```

---

## Best Practices

1. **Don't Over-Alert:**
   - Use LOW severity for validation errors
   - Reserve SMS for truly critical issues

2. **Monitor the Monitors:**
   - Check Error Log sheet daily
   - Look for patterns
   - Fix root causes, don't just handle errors

3. **Keep Error Handlers Simple:**
   - Don't add complex logic to error handlers
   - They should be reliable and fast

4. **Test Regularly:**
   - Test error handlers monthly
   - Verify alerts still reach you

5. **Document Custom Changes:**
   - If you modify severity keywords
   - Document in workflow notes

---

## Next Steps

After completing this phase:

1. ✅ Phase 5 complete - All workflows have error handlers
2. ➡️ Proceed to Phase 6: Set up UptimeRobot external monitoring
3. ➡️ Then Phase 7: End-to-end testing

---

## Completion Criteria

Phase 5 is complete when:

- [x] All 7 workflows have error handlers installed
- [x] All credentials configured correctly
- [x] At least one test error successfully caught and logged
- [x] Error Log sheet receiving data
- [x] Alerts being sent (verified via test)
- [x] All workflows remain Active

---

## Time Spent

- **Estimated:** 20-30 minutes
- **Actual:** _____ minutes (fill in after completion)

---

## Workflow Update Log

| Workflow | Status | Test Result | Notes |
|----------|--------|-------------|-------|
| Main Booking | ⏳ | Pass / Fail | |
| Lookup | ⏳ | Pass / Fail | |
| Cancel | ⏳ | Pass / Fail | |
| Reschedule | ⏳ | Pass / Fail | |
| Recovery | ⏳ | Pass / Fail | |
| Check Availability | ⏳ | Pass / Fail | |
| Group Booking | ⏳ | Pass / Fail | |

---

## Phase 5 Status: ⏳ READY TO EXECUTE

**Next Phase:** Phase 6 - Set Up UptimeRobot External Monitoring

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
**Phase:** 5 of 7
