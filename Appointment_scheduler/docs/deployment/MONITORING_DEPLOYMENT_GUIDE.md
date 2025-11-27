# Monitoring System Deployment Guide

## Quick Start: Deploy Monitoring in 30 Minutes

This guide will walk you through deploying the complete monitoring system for your appointment scheduling workflows.

---

## Prerequisites

Before starting, ensure you have:

- [ ] Access to n8n instance at https://polarmedia.app.n8n.cloud
- [ ] Admin access to Google account (quantumops9@gmail.com)
- [ ] Twilio account credentials configured in n8n
- [ ] Email sending configured in n8n (or Gmail account)
- [ ] Phone number for SMS alerts

---

## Phase 1: Environment Setup (5 minutes)

### Step 1: Set Environment Variables in n8n

1. Log into n8n: https://polarmedia.app.n8n.cloud
2. Go to Settings → Environment Variables
3. Add the following variables:

```bash
# Alert Configuration
ALERT_EMAIL=your-email@example.com
ALERT_PHONE=+1234567890

# Google Sheets Configuration
MONITORING_SHEET_ID=<will-set-after-creating-sheet>
ERROR_LOG_SHEET_ID=<same-as-above>

# Monitoring Settings
HEALTH_CHECK_INTERVAL=5  # minutes
ERROR_ALERT_THRESHOLD=3  # consecutive errors before escalation
```

4. Save changes
5. Restart n8n instance (if required)

---

## Phase 2: Create Monitoring Dashboard (10 minutes)

### Step 1: Create Google Sheet

1. Go to https://sheets.google.com
2. Create new spreadsheet: **"Appointment System Monitoring"**
3. Copy Sheet ID from URL:
   - URL format: `https://docs.google.com/spreadsheets/d/[COPY_THIS_ID]/edit`
4. Update `MONITORING_SHEET_ID` environment variable in n8n with this ID

### Step 2: Create Required Sheets

Create these tabs (bottom left, click "+"):

1. **Dashboard** (main overview)
2. **System Health Log**
3. **Error Log**
4. **Activity Log**
5. **Metrics**

### Step 3: Set Up Column Headers

**System Health Log** (Row 1):
```
Timestamp | Severity | Health_Percentage | Healthy_Count | Unhealthy_Count | Critical_Failures | Warnings | Alert_Sent
```

**Error Log** (Row 1):
```
Timestamp | Workflow | Node | Severity | Error_Type | Error_Message | Execution_ID | Input_Data | Alert_Sent
```

**Activity Log** (Row 1):
```
Timestamp | Workflow | Action | Result | BookingID | Phone | Email | Duration_ms
```

### Step 4: Share Sheet with n8n

1. Click "Share" button (top right)
2. Add your n8n service account email (check n8n Google Sheets credentials)
3. Grant "Editor" access
4. Click "Done"

---

## Phase 3: Import Monitoring Workflows (10 minutes)

### Step 1: Import System Health Monitor

1. In n8n, click "+" → "Import from File" or "Import from URL"
2. Select: `System Health Monitor v1.0.json`
3. Click "Import"

### Step 2: Configure Health Monitor

1. Open the imported workflow
2. Update "Prepare Health Checks" node if needed (verify webhook URLs)
3. In "Send SMS (Critical)" node:
   - Verify Twilio credentials are selected
   - Confirm phone number: `+14694365607`
4. In "Send Email (High)" node:
   - Configure email credentials
   - Verify sender email
5. In Google Sheets nodes:
   - Select your Google credentials
   - Verify Sheet ID references `MONITORING_SHEET_ID` env var
6. Save workflow
7. **Activate workflow** (toggle in top right)

### Step 3: Import Error Handler Template

1. Import: `Error Handler Template.json`
2. **DO NOT ACTIVATE** - This is a template to copy into other workflows

### Step 4: Add Error Handling to Existing Workflows

For **EACH** of your main workflows:

1. Open workflow (e.g., "Appointment Scheduling AI_v.0.0.3.json")
2. Click "+" to add node
3. Search "Error Trigger"
4. Add Error Trigger node
5. Copy the error handling logic from `Error Handler Template.json`:
   - Process Error Details node
   - Route by Severity switch
   - Alert nodes (SMS/Email)
   - Log to Error Sheet node
6. Connect Error Trigger to Process Error Details
7. Save workflow

**Workflows to update:**
- ✅ Appointment Scheduling AI_v.0.0.3.json (Main)
- ✅ Appointment Scheduling AI_v.0.0.3_vapi_lookup.json
- ✅ Appointment Scheduling AI_v.0.0.3_vapi_cancel.json
- ✅ Appointment Scheduling AI_v.0.0.3_vapi_reschedule.json
- ✅ Appointment Scheduling AI_v.0.0.3_vapi_recovery.json
- ✅ Appointment Scheduling AI v.0.0.3 (Check Availability).json
- ✅ Appointment Scheduling AI v.0.0.3 (Group Booking).json

---

## Phase 4: Set Up External Monitoring (5 minutes)

### Option A: UptimeRobot (Recommended - Free)

1. Sign up: https://uptimerobot.com
2. Add monitors for each webhook:

**Monitor 1: Main Booking**
- Type: HTTP(s)
- URL: `https://polarmedia.app.n8n.cloud/webhook/vapi/call`
- Method: HEAD
- Check interval: 5 minutes
- Alert when: Down

**Monitor 2: Lookup**
- URL: `https://polarmedia.app.n8n.cloud/webhook/vapi/lookup`
- Same settings as above

**Monitor 3: Cancel**
- URL: `https://polarmedia.app.n8n.cloud/webhook/vapi/cancel`

**Monitor 4: Reschedule**
- URL: `https://polarmedia.app.n8n.cloud/webhook/vapi/reschedule`

3. Configure alert contacts:
   - Email: your-email@example.com
   - SMS (optional, paid): your-phone

### Option B: Pingdom (Alternative)

Follow similar steps at https://pingdom.com

---

## Phase 5: Testing (5 minutes)

### Test 1: Health Monitor

```bash
# Manually trigger health monitor in n8n
# OR wait for next 5-minute cycle

# Expected result:
# - Check runs successfully
# - No alerts sent (all healthy)
# - New row added to System Health Log
```

### Test 2: Error Handler

```bash
# Trigger an error by sending invalid data
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{"invalid": "request"}'

# Expected results:
# 1. Error is caught by Error Trigger
# 2. Error details processed
# 3. Alert sent via email (MEDIUM severity)
# 4. New row added to Error Log sheet
# 5. You receive email alert within 1 minute
```

### Test 3: Activity Logging

```bash
# Run a successful booking
./test_single_booking.sh

# Expected results:
# 1. Booking succeeds
# 2. New row added to Activity Log sheet
# 3. No error alerts
```

### Test 4: UptimeRobot

```bash
# Deactivate one workflow in n8n
# Wait 5 minutes
# Check email for UptimeRobot alert

# Reactivate workflow
# Wait 5 minutes
# Check email for recovery notification
```

---

## Phase 6: Configure Dashboard (Optional - 10 minutes)

Follow detailed instructions in `MONITORING_DASHBOARD_SETUP.md` to:

1. Create KPI formulas in Metrics tab
2. Build Dashboard tab with live metrics
3. Add charts and visualizations
4. Set up auto-refresh

---

## Verification Checklist

After deployment, verify:

- [x] Health monitor running every 5 minutes
- [x] All 7+ webhooks being checked
- [x] Error handlers active in all workflows
- [x] Google Sheets receiving data
- [x] Email alerts working
- [x] SMS alerts working (for critical errors)
- [x] UptimeRobot monitoring active
- [x] Dashboard displaying data

---

## Monitoring Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Appointment System                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ Main       │  │ Lookup     │  │ Cancel     │  + 4 more  │
│  │ Booking    │  │ Workflow   │  │ Workflow   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│         │               │                │                   │
│         └───────────────┴────────────────┘                   │
│                         │                                     │
│                    Error Trigger                              │
│                         │                                     │
│                    Error Handler                              │
│                         │                                     │
│         ┌───────────────┼───────────────┐                    │
│         ▼               ▼               ▼                     │
│   ┌─────────┐    ┌──────────┐   ┌─────────────┐            │
│   │ SMS     │    │ Email    │   │ Google      │            │
│   │ Alert   │    │ Alert    │   │ Sheets Log  │            │
│   └─────────┘    └──────────┘   └─────────────┘            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              System Health Monitor (Separate)                │
│                                                               │
│  Every 5 minutes:                                            │
│    1. Check all webhook endpoints (HEAD request)            │
│    2. Analyze response codes                                 │
│    3. Calculate health percentage                            │
│    4. Route alerts by severity:                              │
│       - CRITICAL → SMS                                       │
│       - HIGH → Email                                         │
│       - WARNING → Log only                                   │
│    5. Log to Google Sheets                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              External Monitoring (UptimeRobot)               │
│                                                               │
│  Every 5 minutes:                                            │
│    - Check webhook availability from external location       │
│    - Alert if any endpoint is down                           │
│    - Provides redundancy if n8n itself has issues           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Monitoring Dashboard                       │
│                    (Google Sheets)                           │
│                                                               │
│  Real-time metrics:                                          │
│    - System uptime %                                         │
│    - Error rate                                              │
│    - Response times                                          │
│    - Booking success rate                                    │
│    - Recent errors list                                      │
│    - Activity timeline                                       │
│    - Charts and visualizations                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Alert Severity Routing

| Severity | Trigger Conditions | Alert Method | Response Time |
|----------|-------------------|--------------|---------------|
| **CRITICAL** | - Critical workflow down<br>- 5+ consecutive failures<br>- Calendar/Twilio API errors | SMS + Email | Immediate |
| **HIGH** | - 2-4 workflow failures<br>- Multiple errors in 1 hour<br>- System health < 80% | Email | 5 minutes |
| **MEDIUM** | - Single workflow error<br>- Validation failures | Email | 15 minutes |
| **LOW** | - Input validation warnings<br>- Non-critical issues | Log only | Daily review |

---

## Incident Response Workflow

When you receive an alert:

### 1. Critical Alert (SMS)
1. **Acknowledge** within 5 minutes
2. **Check** System Health Dashboard
3. **Identify** which workflow(s) are down
4. **Check** n8n execution logs for details
5. **Fix** the immediate issue
6. **Verify** system returns to healthy state
7. **Document** incident in Error Log

### 2. High/Medium Alert (Email)
1. **Review** within 30 minutes
2. **Check** Error Log for details
3. **Determine** if action needed immediately
4. **Schedule** fix if not urgent
5. **Monitor** for recurring patterns

### 3. Daily Review
1. Open Dashboard in morning
2. Check overnight errors
3. Review success rates
4. Look for trends or patterns
5. Plan preventive actions

---

## Maintenance Schedule

### Daily (5 minutes)
- Check Dashboard for overnight issues
- Review critical error count
- Verify system health > 95%

### Weekly (15 minutes)
- Review Error Log for patterns
- Check Success Rate trends
- Verify all monitors are active
- Test alert delivery (send test alert)

### Monthly (30 minutes)
- Export historical data (backup)
- Review and adjust alert thresholds
- Update monitoring workflows if needed
- Clean up old logs (keep last 90 days)
- Review incident response times

---

## Troubleshooting Common Issues

### Issue: Not Receiving Alerts

**Diagnosis:**
```bash
# Test error trigger manually
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Solutions:**
1. Check n8n workflow execution logs
2. Verify Twilio credentials are valid
3. Confirm email credentials are configured
4. Check environment variables are set
5. Verify Error Trigger nodes are active

### Issue: Health Monitor Shows False Positives

**Diagnosis:**
- Check if HEAD method is supported by webhooks
- Verify webhook URLs are correct

**Solutions:**
1. Change HTTP method from HEAD to GET in health check
2. Add webhook secret header if required
3. Adjust timeout values (increase to 10000ms)

### Issue: Google Sheets Not Updating

**Diagnosis:**
- Check n8n Google Sheets credentials
- Verify Sheet ID is correct
- Check share permissions

**Solutions:**
1. Re-authenticate Google Sheets in n8n
2. Verify service account has Editor access
3. Check API quota hasn't been exceeded

### Issue: Too Many Alerts

**Diagnosis:**
- Review alert threshold settings
- Check if there's a real underlying issue

**Solutions:**
1. Increase error threshold (e.g., 5 instead of 3)
2. Add cooldown period between alerts
3. Filter out low-severity validation errors
4. Fix underlying issues causing errors

---

## Performance Optimization

### Reduce API Calls

```javascript
// In health check, batch requests
// Instead of individual checks, use Promise.all()
const checks = await Promise.all([
  checkEndpoint(url1),
  checkEndpoint(url2),
  // ...
]);
```

### Optimize Sheet Operations

```javascript
// Batch writes instead of individual appends
// Accumulate logs and write every 5 minutes
```

### Implement Caching

```javascript
// Cache health status for 1 minute
// Only send alerts on status change, not on every check
```

---

## Security Best Practices

1. **Protect Sheet Access:**
   - Only share with necessary users
   - Use "View only" for non-admins
   - Enable 2FA on Google account

2. **Secure Alert Channels:**
   - Use encrypted email (TLS)
   - Rotate Twilio auth tokens regularly
   - Don't include sensitive data in alerts

3. **Webhook Security:**
   - Always validate webhook secret
   - Use HTTPS only
   - Implement rate limiting

4. **Data Retention:**
   - Keep logs for 90 days max
   - Archive before deletion
   - Remove PII from old logs

---

## Cost Analysis

### Current Setup (Free Tier):

| Component | Cost | Notes |
|-----------|------|-------|
| n8n Cloud Starter | $0-20/mo | Based on plan |
| Google Sheets | $0 | Free with Google account |
| UptimeRobot | $0 | Up to 50 monitors free |
| Twilio SMS | ~$0.01/SMS | Only for critical alerts |
| Email | $0 | Using Gmail |
| **Total** | **~$20/mo** | Minimal operational cost |

### Scalability Costs:

| Users | Executions/mo | Cost Estimate |
|-------|---------------|---------------|
| 10/day | 300 | $20/mo |
| 50/day | 1,500 | $20-35/mo |
| 100/day | 3,000 | $35-50/mo |

---

## Next Steps After Deployment

1. **Week 1: Tune & Observe**
   - Monitor alert frequency
   - Adjust thresholds as needed
   - Verify all components working

2. **Week 2-4: Optimize**
   - Build custom dashboard views
   - Add business-specific metrics
   - Create weekly reports

3. **Month 2+: Enhance**
   - Add predictive alerting
   - Implement auto-remediation
   - Create runbooks for common issues

---

## Support & Resources

- **n8n Docs:** https://docs.n8n.io
- **UptimeRobot Help:** https://uptimerobot.com/help
- **Google Sheets API:** https://developers.google.com/sheets
- **Twilio Docs:** https://www.twilio.com/docs

---

## Rollback Plan

If monitoring causes issues:

1. **Disable Health Monitor:**
   - Deactivate "System Health Monitor v1.0" workflow

2. **Remove Error Handlers:**
   - Delete Error Trigger nodes from workflows
   - Or disconnect them (don't delete)

3. **Keep Logging:**
   - Activity logging can remain active
   - Only disable alerting components

4. **Restore Original:**
   - Use version control in n8n
   - Restore from backup if needed

---

## Success Metrics

After 1 week of monitoring, you should see:

- ✅ Zero monitoring-related failures
- ✅ All webhooks showing 99%+ uptime
- ✅ Error alerts firing correctly (if any errors)
- ✅ Dashboard updating in real-time
- ✅ Team comfortable using monitoring tools

After 1 month:

- ✅ Identified and fixed recurring issues
- ✅ Reduced error rate by 50%+
- ✅ Improved mean time to resolution (MTTR)
- ✅ Prevented at least 1 major incident

---

**You're now ready to deploy! Start with Phase 1 and work through each phase systematically.**

Good luck! 🚀
