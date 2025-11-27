# Monitoring System - Quick Reference Card

## 📊 System Overview

```
┌────────────────────────────────────────────────────────┐
│              MONITORING ARCHITECTURE                   │
├────────────────────────────────────────────────────────┤
│                                                        │
│  🔍 HEALTH MONITOR (Every 5 min)                      │
│     ├─ Checks 7 webhook endpoints                     │
│     ├─ Calculates health %                            │
│     └─ Alerts: SMS (critical) / Email (high)          │
│                                                        │
│  🚨 ERROR HANDLERS (Real-time)                        │
│     ├─ Catches all workflow errors                    │
│     ├─ Classifies by severity                         │
│     ├─ Detects recurring patterns                     │
│     └─ Alerts: SMS / Email / Log                      │
│                                                        │
│  🌐 EXTERNAL MONITOR (UptimeRobot)                    │
│     ├─ Independent availability checks                │
│     └─ Redundant alerting                             │
│                                                        │
│  📈 DASHBOARD (Google Sheets)                         │
│     ├─ Real-time metrics                              │
│     ├─ Error logs                                     │
│     ├─ Activity logs                                  │
│     └─ Charts & analytics                             │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 🚦 Alert Severity Matrix

| Severity | Conditions | Alert Method | Response Time |
|----------|-----------|--------------|---------------|
| 🔴 **CRITICAL** | • Critical workflow down<br>• 5+ consecutive failures<br>• Calendar/Twilio API errors | **SMS + Email** | **Immediate** |
| 🟠 **HIGH** | • 2-4 failures<br>• Multiple errors/hour<br>• Health < 80% | **Email** | **5 minutes** |
| 🟡 **MEDIUM** | • Single workflow error<br>• Validation failures | **Email** | **15 minutes** |
| 🔵 **LOW** | • Warnings<br>• Non-critical issues | **Log only** | **Daily review** |

---

## 📁 Files Reference

| File | Purpose | Location |
|------|---------|----------|
| `System Health Monitor v1.0.json` | Import to n8n | Workflow file |
| `Error Handler Template.json` | Copy into workflows | Template file |
| `MONITORING_DEPLOYMENT_GUIDE.md` | Step-by-step setup | Read first |
| `MONITORING_DASHBOARD_SETUP.md` | Dashboard creation | Reference |
| `MONITORING_SUMMARY.md` | Complete overview | Overview |
| `MONITORING_QUICK_REFERENCE.md` | This cheat sheet | Quick help |

---

## ⚡ Quick Commands

### Test Error Handler
```bash
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{}'
```

### Run All Tests
```bash
./run_all_tests.sh
```

### Test Single Booking
```bash
./test_single_booking.sh
```

---

## 🔧 Environment Variables

```bash
# Required in n8n Settings → Environment Variables
ALERT_EMAIL=your-email@example.com
ALERT_PHONE=+12145551234
MONITORING_SHEET_ID=<google-sheet-id>

# Optional
ERROR_LOG_SHEET_ID=<google-sheet-id>
HEALTH_CHECK_INTERVAL=5
ERROR_ALERT_THRESHOLD=3
```

---

## 📊 Google Sheets Structure

### System Health Log
```
Timestamp | Severity | Health_% | Healthy | Unhealthy | Failures | Warnings | Alert
```

### Error Log
```
Timestamp | Workflow | Node | Severity | Type | Message | Exec_ID | Input | Alert
```

### Activity Log
```
Timestamp | Workflow | Action | Result | BookingID | Phone | Email | Duration
```

---

## 🎯 Monitored Endpoints

1. ✅ **Main Booking** - `/webhook/vapi/call`
2. ✅ **Lookup** - `/webhook/vapi/lookup`
3. ✅ **Cancel** - `/webhook/vapi/cancel`
4. ✅ **Reschedule** - `/webhook/vapi/reschedule`
5. ✅ **Recovery** - `/webhook/vapi/recovery`
6. ✅ **Check Availability** - `/webhook/vapi/check-availability`
7. ✅ **Group Booking** - `/webhook/vapi/group-booking`

---

## 🔄 Deployment Checklist

### Phase 1: Environment (5 min)
- [ ] Set environment variables in n8n
- [ ] Restart n8n instance

### Phase 2: Dashboard (10 min)
- [ ] Create Google Sheet
- [ ] Add 5 tabs (Dashboard, Health, Error, Activity, Metrics)
- [ ] Set up column headers
- [ ] Share with n8n service account

### Phase 3: Workflows (10 min)
- [ ] Import "System Health Monitor v1.0"
- [ ] Configure credentials (Twilio, Email, Sheets)
- [ ] Activate health monitor
- [ ] Add error handlers to 7 workflows

### Phase 4: External (5 min)
- [ ] Sign up UptimeRobot
- [ ] Add 7 monitors
- [ ] Configure alert contacts

### Phase 5: Test (5 min)
- [ ] Trigger test error
- [ ] Verify alert received
- [ ] Check Google Sheets updated
- [ ] Run full test suite

---

## 🆘 Common Issues

| Symptom | Solution |
|---------|----------|
| No alerts received | Check Twilio/Email credentials in n8n |
| Sheets not updating | Re-auth Google Sheets, verify Sheet ID |
| False positives | Change HEAD to GET in health check |
| Too many alerts | Increase threshold to 5, add cooldown |
| Health check fails | Add webhook secret header |

---

## 📞 Alert Examples

### Critical SMS:
```
🚨 CRITICAL: Main Booking
Health: 71.4% (5/7)
CRITICAL FAILURES:
• Main Booking: No response
• Cancel: No response
Time: 2025-11-26 10:15:23
```

### High Email:
```
⚠️ Workflow Error: Main Booking - HIGH

Workflow: Appointment Scheduling AI_v.0.0.3
Node: Check Availability (Code)
Time: 2025-11-26 10:15:33
Severity: HIGH

Error: Calendar API timeout

Execution ID: exec_abc123
Link: https://polarmedia.app.n8n.cloud/...
```

---

## 📈 Key Metrics

### System Health
- **Target:** > 99% uptime
- **Warning:** < 95% uptime
- **Critical:** < 80% uptime

### Success Rate
- **Target:** > 95% successful bookings
- **Warning:** < 90% success
- **Critical:** < 80% success

### Response Time
- **Target:** < 2000ms average
- **Warning:** > 3000ms
- **Critical:** > 5000ms

### Errors
- **Target:** 0 critical errors/day
- **Warning:** 1-3 critical errors/day
- **Critical:** 5+ critical errors/day

---

## 🕐 Maintenance Schedule

### Daily (2 min)
```
□ Open Dashboard
□ Check health is green (>95%)
□ Verify 0 critical errors
```

### Weekly (10 min)
```
□ Review error patterns
□ Check success rate trends
□ Verify monitors active
□ Test alert delivery
```

### Monthly (30 min)
```
□ Export historical data
□ Clean up logs (>90 days)
□ Review alert thresholds
□ Update workflows if needed
```

---

## 🎯 Success Metrics

After 1 week:
- ✅ 99%+ uptime
- ✅ Error alerts working
- ✅ Dashboard updating
- ✅ Team using tools

After 1 month:
- ✅ 50% error reduction
- ✅ Faster issue resolution
- ✅ Prevented 1+ incidents
- ✅ Clear trend visibility

---

## 🔗 Quick Links

| Resource | URL |
|----------|-----|
| n8n Instance | https://polarmedia.app.n8n.cloud |
| Google Sheets | https://sheets.google.com |
| UptimeRobot | https://uptimerobot.com |
| Twilio Console | https://console.twilio.com |

---

## 💰 Cost Summary

```
n8n Cloud:          ~$20/mo  (existing)
Google Sheets:      FREE
UptimeRobot:        FREE     (up to 50 monitors)
Twilio SMS:         $0.01    (per critical alert)
Email:              FREE
─────────────────────────────
Total Added Cost:   ~$0-5/mo
```

---

## 🚀 Start Here

**First time deploying?**
→ Read: `MONITORING_DEPLOYMENT_GUIDE.md`

**Need quick setup?**
→ Read: `MONITORING_SETUP.md` (Phase 1 only)

**Building dashboard?**
→ Read: `MONITORING_DASHBOARD_SETUP.md`

**Want overview?**
→ Read: `MONITORING_SUMMARY.md`

**Need quick help?**
→ Read: This file!

---

## 📋 Incident Response

### When Alert Arrives:

**1. CRITICAL (SMS):**
```
□ Acknowledge within 5 minutes
□ Check System Health Dashboard
□ Identify failed workflow(s)
□ Review n8n execution logs
□ Fix immediate issue
□ Verify system healthy
□ Document in Error Log
```

**2. HIGH (Email):**
```
□ Review within 30 minutes
□ Check Error Log details
□ Determine urgency
□ Schedule fix if needed
□ Monitor for patterns
```

**3. Daily Review:**
```
□ Open Dashboard each morning
□ Check overnight errors
□ Review success rates
□ Look for trends
□ Plan preventive actions
```

---

## 🎨 Dashboard At-a-Glance

```
┌─────────────────────────────────────────────────┐
│  Appointment System Monitoring Dashboard       │
│  Last Updated: 2025-11-26 10:30:00             │
├─────────────────────────────────────────────────┤
│                                                 │
│  System Uptime (7d):    99.8% ✅                │
│  Success Rate (24h):    95.3% ✅                │
│  Avg Response Time:     1,247 ms ✅             │
│  Active Errors:         0 ✅                    │
│  Critical Errors (7d):  0 ✅                    │
│                                                 │
├─────────────────────────────────────────────────┤
│  Recent Activity                                │
│  • 10:25 - Booking successful (evt_xyz)        │
│  • 10:20 - Lookup successful                   │
│  • 10:15 - Cancellation successful             │
├─────────────────────────────────────────────────┤
│  Booking Statistics Today                      │
│  • Bookings: 12                                │
│  • Cancellations: 2                            │
│  • Reschedules: 3                              │
└─────────────────────────────────────────────────┘
```

---

**Print this page for quick reference! 📄**

Last Updated: 2025-11-26
