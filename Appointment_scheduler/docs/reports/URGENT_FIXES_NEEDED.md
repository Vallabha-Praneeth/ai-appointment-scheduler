# 🚨 URGENT FIXES FOR BOTH WORKFLOWS

## PROBLEM 1: Error Handler - Google Sheets Getting Wrong Data ❌

**Issue:** Google Sheets is receiving Slack API response instead of error data

**ROOT CAUSE:** Workflow connections are wrong

**MANUAL FIX IN N8N:**

1. Open "Error Handler Template" workflow
2. Delete the connection from "Send Email Alert" (Slack) to "Log to Error Sheet"  
3. Delete the connection from "Send SMS Alert" to "Log to Error Sheet"
4. Connect like this:

```
Route by Severity Output 0 (HIGH) → Send SMS Alert
Route by Severity Output 0 (HIGH) → Log to Error Sheet (PARALLEL)

Route by Severity Output 1 (MEDIUM) → Send Email Alert (Slack)
Route by Severity Output 1 (MEDIUM) → Log to Error Sheet (PARALLEL)

Route by Severity Output 2 (LOW) → Log to Error Sheet
```

**The key is:** Each Switch output should connect to BOTH the alert node AND Google Sheets IN PARALLEL, not in series.

5. Save and test again

---

## PROBLEM 2: System Health Monitor - "undefined" in Alerts ❌

**Issue:** Warnings show "undefined" instead of workflow names

**Output shows:**
```json
"warnings": [
  {"status": 0, "error": "404"}  // Missing "workflow" field!
]
```

**ROOT CAUSE:** HTTP Request node doesn't pass through original input data

**MANUAL FIX IN N8N:**

1. Open "System Health Monitor v1.0" workflow
2. Click on "Check Webhook Endpoint" (HTTP Request node)
3. Scroll down to "Options"
4. Find "Response" section
5. Turn ON: **"Always Output Data"**
6. Turn ON: **"Include Input Data in Output"** (if available)

OR better solution:

**Add a Merge node:**

1. After "Check Webhook Endpoint", add a **Merge** node
2. Set merge type to: **Combine by Position**
3. Connect:
   - Input 1: "Prepare Health Checks" → Merge
   - Input 2: "Check Webhook Endpoint" → Merge
4. Connect Merge → "Analyze Results"

This ensures workflow names are preserved!

---

## ALTERNATIVE: Re-import Updated Files

I've fixed the Error Handler connections in the file.

**For Error Handler:**
- ✅ Re-import `Error Handler Template.json`
- Connections now correct

**For System Health Monitor:**
- ⚠️ Needs manual fix (HTTP Request issue)
- OR I can regenerate the workflow

---

## Quick Test After Fixes:

**Error Handler:**
```bash
curl -X POST https://polarmedia.app.n8n.cloud/webhook/error-handler \
  -H "Content-Type: application/json" \
  -d '{"error": {"message": "test"}}'
```

Check Google Sheets → Should see actual error data, not Slack response

**System Health Monitor:**
- Wait for next 5-min execution
- Check Google Sheets → Should show workflow names, not "undefined"

