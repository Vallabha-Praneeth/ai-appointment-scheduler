# Monitoring & Alerts Setup Guide

## Quick Start: Basic Error Notifications (15 minutes)

### Option 1: n8n Error Workflow Node

Add this to your main workflow `Appointment Scheduling AI_v.0.0.3.json`:

1. **Add Error Trigger Node:**
   - In n8n, open the workflow
   - Click "+" → Search "Error Trigger"
   - This catches any workflow errors automatically

2. **Add Twilio SMS Node:**
   - Connect Error Trigger to Twilio SMS node
   - Configure:
     - To: Your phone number (e.g., `+1234567890`)
     - From: `+14694365607` (your Twilio number)
     - Message:
       ```
       🚨 Workflow Error!
       Workflow: {{$workflow.name}}
       Error: {{$json.error.message}}
       Time: {{$now.format('YYYY-MM-DD HH:mm:ss')}}
       ```

3. **Test It:**
   ```bash
   # Trigger an error by sending invalid data
   curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
     -H "Content-Type: application/json" \
     -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
     -d '{"bad": "request"}'

   # You should receive an SMS within 10 seconds
   ```

---

## Option 2: UptimeRobot External Monitoring (10 minutes)

### Setup Steps:

1. **Sign up:** https://uptimerobot.com (free tier)

2. **Add Monitors:**

   Monitor 1: Main Booking Workflow
   - Type: HTTP(s)
   - URL: `https://polarmedia.app.n8n.cloud/webhook/vapi/call`
   - Method: HEAD
   - Interval: 5 minutes

   Monitor 2: Cancel Workflow
   - URL: `https://polarmedia.app.n8n.cloud/webhook/vapi/cancel`

   Monitor 3: Reschedule Workflow
   - URL: `https://polarmedia.app.n8n.cloud/webhook/vapi/reschedule`

3. **Configure Alerts:**
   - Go to "Alert Contacts"
   - Add your email
   - Add SMS number (if on paid plan)
   - Set "Alert When: Down"

4. **Test:**
   - Deactivate one workflow in n8n
   - Wait 5 minutes
   - You should get an alert
   - Reactivate the workflow

---

## Option 3: Google Sheets Activity Log (45 minutes)

### Create Log Sheet:

1. **New Google Sheet:** "Appointment System Activity Log"

2. **Columns:**
   - A: Timestamp
   - B: Workflow
   - C: Action (book/cancel/reschedule)
   - D: Result (success/fail)
   - E: BookingID
   - F: Phone
   - G: Error Message

### Add to Each Workflow:

At the END of each workflow (after success/error paths):

1. **Add Google Sheets Node:**
   - Operation: Append
   - Sheet: "Appointment System Activity Log"
   - Columns:
     ```
     Timestamp: {{$now.format('YYYY-MM-DD HH:mm:ss')}}
     Workflow: {{$workflow.name}}
     Action: {{$json.action}}
     Result: {{$json.result}}
     BookingID: {{$json.bookingId}}
     Phone: {{$json.phone}}
     Error: {{$json.error}}
     ```

2. **Enable "Always Output Data"** on the Sheets node

### Test:
```bash
# Run test suite
./run_all_tests.sh

# Check Google Sheet - should have 8 new rows
```

---

## Option 4: Advanced Monitoring Workflow (1 hour)

Create a dedicated monitoring workflow that checks all other workflows.

### Workflow: "System Health Monitor"

**Nodes:**

1. **Schedule Trigger** (every 5 minutes)
   ↓
2. **HTTP Request to n8n API**
   - URL: `https://polarmedia.app.n8n.cloud/api/v1/executions`
   - Method: GET
   - Authentication: API Key (get from n8n settings)
   - Query: `status=error&limit=10`
   ↓
3. **IF Node** (check if errors > 0)
   ↓
4. **Switch Node** (based on error count)
   - 1-3 errors: Send Email
   - 4-9 errors: Send SMS
   - 10+ errors: Send SMS + Email + Slack
   ↓
5. **Aggregate Stats**
   - Count by workflow
   - Last error time
   - Error rate
   ↓
6. **Send Notification**

### Test:
- Manually execute the monitor workflow in n8n
- Check execution log shows recent errors
- Verify notifications are sent

---

## Recommended Setup for Your System

### Phase 1: Basic (Do Now - 25 minutes)
- ✅ Add Error Trigger + SMS to main workflow
- ✅ Set up UptimeRobot for webhook availability

### Phase 2: Enhanced (First Week - 1 hour)
- ⏳ Add Google Sheets logging
- ⏳ Create simple dashboard in Sheets

### Phase 3: Advanced (Optional)
- ⏳ Set up dedicated monitoring workflow
- ⏳ Add Slack integration
- ⏳ Create metrics dashboard

---

## What to Monitor

### Critical Metrics:
1. **Workflow Execution Status** (success/fail rate)
2. **Webhook Availability** (are endpoints responding?)
3. **Response Times** (is it slow?)
4. **Booking Success Rate** (are appointments being created?)

### Nice-to-Have Metrics:
1. Daily booking count
2. Peak usage hours
3. Average appointment duration
4. Most common service types
5. Cancellation rate

---

## Testing Your Monitoring

### Test 1: Trigger an Error
```bash
# Send invalid request
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{}'

# Expected: Error notification within 1 minute
```

### Test 2: Simulate Downtime
```bash
# Deactivate workflow in n8n UI
# Wait 5 minutes
# Expected: UptimeRobot alert

# Reactivate workflow
# Expected: Recovery notification
```

### Test 3: Check Logs
```bash
# Run full test suite
./run_all_tests.sh

# Check:
# - Google Sheets has 8 new entries
# - n8n execution history shows all runs
# - No error alerts triggered (all tests passed)
```

---

## When You Should Get Alerted

### Immediate Alerts (SMS/Call):
- Workflow completely down (404/500 errors)
- 5+ consecutive failures
- Google Calendar API errors
- Twilio SMS failures

### Email Alerts (within 15 min):
- Single workflow execution failure
- Validation errors
- Business hours violations
- Duplicate booking attempts

### Daily Summary (Email):
- Total bookings/cancellations/reschedules
- Success rates
- Any warnings or issues
- System health report

---

## Cost Breakdown

### Free Options:
- n8n built-in error handling: FREE
- UptimeRobot (50 monitors): FREE
- Google Sheets logging: FREE
- Email notifications: FREE

### Paid Options (Optional):
- UptimeRobot SMS alerts: $7/month
- Better Uptime: $10/month
- PagerDuty: $19/month
- Datadog: $15/month

**Recommendation:** Start with 100% free options. Upgrade only if you need SMS alerts.

---

## Next Steps

1. **Today:** Add Error Trigger + SMS to main workflow (15 min)
2. **Today:** Set up UptimeRobot (10 min)
3. **This Week:** Add Google Sheets logging (45 min)
4. **Test Everything:** Run monitoring tests
5. **Monitor:** Watch for alerts over first week
6. **Adjust:** Tune alert thresholds based on actual traffic

---

## Support

If you need help setting up monitoring:
1. Check n8n documentation: https://docs.n8n.io/error-handling
2. UptimeRobot guides: https://uptimerobot.com/help
3. Test your setup thoroughly before going live
