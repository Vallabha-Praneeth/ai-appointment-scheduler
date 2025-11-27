# 🚀 DEPLOY NOW - Interactive Guide

**Let's deploy together! Follow these steps while I verify each one.**

---

## STEP 1: Set Environment Variables (5 minutes)

### Your Task:
1. Open: https://polarmedia.app.n8n.cloud
2. Log in
3. Go to: Settings → Environment Variables
4. Add these:

```bash
ALERT_EMAIL=<YOUR_EMAIL_HERE>
ALERT_PHONE=<YOUR_PHONE_+1234567890>
MONITORING_SHEET_ID=
ERROR_LOG_SHEET_ID=
```

### ✅ Verification:
When done, tell me: "Step 1 complete"

---

## STEP 2: Import Health Monitor (3 minutes)

### Your Task:
1. In n8n, click "+" (Add Workflow)
2. Click three dots menu → "Import from File"
3. Select: `System Health Monitor v1.0.json`
4. Click "Import"

### What you should see:
- Workflow with 9 nodes
- Name: "System Health Monitor v1.0"

### ✅ Verification:
When done, tell me: "Step 2 complete" and I'll help configure it

---

## STEP 3: Configure Credentials (5 minutes)

### Your Task:
For each node that needs credentials:

**Node: Send SMS (Critical)**
- Credential: Select your Twilio account
- If not created yet:
  1. Create new Twilio credential
  2. Enter Account SID and Auth Token from Twilio

**Node: Send Email (High)**
- Credential: Gmail OAuth or SMTP
- Follow n8n's credential setup

**Nodes: Log to Sheets (2 nodes)**
- Credential: Google Sheets OAuth
- Authorize with Google account

### ✅ Verification:
When done, tell me: "Step 3 complete"

---

## STEP 4: Test the Workflow (2 minutes)

### Your Task:
1. Click "Execute Workflow" button (top right)
2. Watch it run
3. Check for green checkmarks on all nodes

### What should happen:
- All 7 webhooks checked
- Results analyzed
- Data logged (if Google Sheets connected)

### ✅ Verification:
Tell me the result:
- "All green" = Success!
- "Red errors" = Tell me which node failed

---

## STEP 5: Activate It! (1 minute)

### Your Task:
1. Toggle "Inactive" → "Active" (top right)
2. Confirm it says "Active"

### ✅ Verification:
When done, tell me: "Step 5 complete - Health Monitor is LIVE!"

---

## What Happens Next?

Once activated:
- Health Monitor checks every 5 minutes automatically
- You can watch executions in "Executions" sidebar
- Alerts will be sent if any workflow goes down

---

## Then We'll Do:
- Phase 2: Create Google Sheets dashboard
- Phase 3: Add error handlers
- Phase 4: Set up UptimeRobot

---

**Ready to start? Just tell me when you're at Step 1!** 🚀
