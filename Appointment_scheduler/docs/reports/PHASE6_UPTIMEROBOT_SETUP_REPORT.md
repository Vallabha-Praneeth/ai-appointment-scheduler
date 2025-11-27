# Phase 6: UptimeRobot External Monitoring Setup Report

**Date:** 2025-11-26
**Phase:** 6 of 7
**Estimated Time:** 10 minutes
**Status:** Ready for Execution

---

## Objective

Set up external monitoring using UptimeRobot (free service) to provide redundant health checking from outside your n8n instance.

---

## Why External Monitoring?

- **Redundancy:** If n8n itself has issues, UptimeRobot still monitors
- **External perspective:** Checks from internet, not just internal
- **Independent alerts:** Separate from n8n-based monitoring
- **Uptime tracking:** Historical uptime data and statistics

---

## Prerequisites

- [ ] Email address for alerts
- [ ] (Optional) Phone number for SMS alerts (paid feature)
- [ ] List of webhook URLs to monitor
- [ ] Internet access to UptimeRobot

---

## Step-by-Step Instructions

### Step 1: Create UptimeRobot Account (3 minutes)

1. **Visit UptimeRobot**
   - Navigate to: https://uptimerobot.com

2. **Sign Up**
   - Click "Sign Up" or "Get Started Free"
   - Enter your email (use the same as ALERT_EMAIL for consistency)
   - Create strong password
   - Verify email (check inbox for verification link)

3. **Log In**
   - After email verification, log into dashboard

4. **You should see:**
   - Dashboard with "Add New Monitor" button
   - Free plan: 50 monitors, 5-minute check interval

---

### Step 2: Add Monitor #1 - Main Booking (2 minutes)

1. **Click "+ Add New Monitor"**

2. **Configure Monitor:**

   **Monitor Type:** HTTP(s)

   **Friendly Name:** `Appointment System - Main Booking`

   **URL (or IP):** `https://polarmedia.app.n8n.cloud/webhook/vapi/call`

   **Monitoring Interval:** 5 minutes (free tier default)

3. **Advanced Settings (expand):**

   **HTTP Method:** GET
   - Note: Some webhooks may not support HEAD method
   - GET is more reliable but might trigger webhook (usually OK for health checks)

   **Custom HTTP Headers (optional):**
   - If your webhook requires authentication:
     - Header name: `x-webhook-secret`
     - Value: `xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=`

   **Expected Status Codes:** Leave default or set to `200,405,302`
   - Some webhooks return 405 for GET/HEAD on POST-only endpoints
   - 302 might be redirect (acceptable)

4. **Alert Contacts:**
   - Should already have your email from signup
   - Leave as default for now (we'll configure in Step 8)

5. **Click "Create Monitor"**

---

### Step 3: Add Monitor #2 - Lookup (1 minute)

Click "+ Add New Monitor" again:

- **Type:** HTTP(s)
- **Name:** `Appointment System - Lookup`
- **URL:** `https://polarmedia.app.n8n.cloud/webhook/vapi/lookup`
- **Interval:** 5 minutes
- **Method:** GET
- **Headers:** Same as above (if using auth)
- **Create**

---

### Step 4: Add Monitor #3 - Cancel (1 minute)

- **Type:** HTTP(s)
- **Name:** `Appointment System - Cancel`
- **URL:** `https://polarmedia.app.n8n.cloud/webhook/vapi/cancel`
- **Interval:** 5 minutes
- **Method:** GET
- **Create**

---

### Step 5: Add Monitor #4 - Reschedule (1 minute)

- **Type:** HTTP(s)
- **Name:** `Appointment System - Reschedule`
- **URL:** `https://polarmedia.app.n8n.cloud/webhook/vapi/reschedule`
- **Interval:** 5 minutes
- **Method:** GET
- **Create**

---

### Step 6: Add Monitor #5 - Recovery (1 minute)

- **Type:** HTTP(s)
- **Name:** `Appointment System - Recovery`
- **URL:** `https://polarmedia.app.n8n.cloud/webhook/vapi/recovery`
- **Interval:** 5 minutes
- **Method:** GET
- **Create**

---

### Step 7: Add Monitors #6 & #7 - Availability & Group (2 minutes)

**Monitor #6:**
- **Name:** `Appointment System - Check Availability`
- **URL:** `https://polarmedia.app.n8n.cloud/webhook/vapi/check-availability`
- **Settings:** Same as above

**Monitor #7:**
- **Name:** `Appointment System - Group Booking`
- **URL:** `https://polarmedia.app.n8n.cloud/webhook/vapi/group-booking`
- **Settings:** Same as above

---

### Step 8: Configure Alert Contacts (3 minutes)

1. **Go to "My Settings"** (top right, profile icon)

2. **Click "Alert Contacts"** (left sidebar)

3. **Your email should already be listed** (from signup)

4. **Add Additional Contact (Optional - SMS):**
   - Click "+ Add Alert Contact"
   - Type: SMS
   - **Note:** SMS alerts require paid plan ($7/mo)
   - If on free plan, stick with email only

5. **Configure Alert Preferences:**

   For each contact:

   **Send alerts when:**
   - ✅ Down
   - ✅ Up (recovery notification)
   - ❌ Limit exceeded (not needed)

   **Repeat alerts every:** 0 (only alert once)
   - Or set to repeat every 30 minutes if monitor still down

   **Down Alert Threshold:** 1 time
   - Alert immediately when first check fails
   - Alternative: Set to 2-3 for less false positives

6. **Save Changes**

---

### Step 9: Create Monitor Group (Optional - 2 minutes)

**Organize monitors into a group:**

1. **Click "Monitors"** in left sidebar

2. **See all 7 monitors listed**

3. **Create Group:**
   - Look for "Add Monitor Group" or similar option
   - Group name: `Appointment Scheduling System`
   - Add all 7 monitors to group

4. **Benefits:**
   - View all monitors together
   - Get group-level statistics
   - Easier management

---

### Step 10: Set Up Status Page (Optional - 5 minutes)

**Create public or private status page:**

1. **Click "Status Pages"** in left sidebar

2. **Click "Add Status Page"**

3. **Configure:**
   - **Name:** Appointment System Status
   - **Type:** Public or Private
     - Public: Anyone with link can view
     - Private: Password-protected
   - **Monitors:** Select all 7 monitors
   - **Customize:**
     - Logo (optional)
     - Custom domain (paid feature)
     - Branding

4. **Save and Get URL**
   - Example: `https://stats.uptimerobot.com/abc123`
   - Bookmark this for quick status checks

---

## Verification Checklist

After completing this phase:

- [ ] UptimeRobot account created and verified
- [ ] 7 monitors created (one for each webhook)
- [ ] All monitors showing "Up" status (green)
- [ ] Email alert contact configured
- [ ] Alert preferences set (down alerts enabled)
- [ ] (Optional) Monitor group created
- [ ] (Optional) Status page created

---

## Monitor Configuration Summary

| Monitor Name | URL | Interval | Status |
|--------------|-----|----------|--------|
| Main Booking | /webhook/vapi/call | 5 min | ⏳ |
| Lookup | /webhook/vapi/lookup | 5 min | ⏳ |
| Cancel | /webhook/vapi/cancel | 5 min | ⏳ |
| Reschedule | /webhook/vapi/reschedule | 5 min | ⏳ |
| Recovery | /webhook/vapi/recovery | 5 min | ⏳ |
| Check Availability | /webhook/vapi/check-availability | 5 min | ⏳ |
| Group Booking | /webhook/vapi/group-booking | 5 min | ⏳ |

---

## Understanding UptimeRobot Alerts

### When You'll Receive Alerts:

**Down Alert:**
- Sent when monitor check fails
- Subject: "[Down] Appointment System - Main Booking"
- Includes:
  - Time of failure
  - Reason (timeout, 404, 500, etc.)
  - Duration since last up

**Up Alert (Recovery):**
- Sent when monitor recovers
- Subject: "[Up] Appointment System - Main Booking"
- Includes:
  - Downtime duration
  - Recovery time

---

## Testing UptimeRobot

### Test 1: Verify Monitors Are Up

1. Check dashboard - all monitors should show green "Up" status
2. Click on each monitor to see details
3. Should show:
   - Current status: Up
   - Response time: Usually < 1000ms
   - Uptime percentage: Will show 100% initially

### Test 2: Trigger a Down Alert

1. **In n8n:** Deactivate one workflow (e.g., Main Booking)
2. **Wait 5 minutes** (next check interval)
3. **Check email** - should receive "[Down]" alert from UptimeRobot
4. **Reactivate workflow** in n8n
5. **Wait 5 minutes** - should receive "[Up]" recovery alert

### Test 3: Check Status Page

1. Open your status page URL
2. Should show all 7 monitors
3. Color-coded status (green = up, red = down)
4. Historical uptime data

---

## Interpreting UptimeRobot Data

### Response Times:
- **< 500ms:** Excellent
- **500-1500ms:** Good
- **1500-3000ms:** Acceptable
- **> 3000ms:** Slow - investigate

### Uptime Percentage:
- **99.9%+:** Excellent (allows ~43 min downtime/month)
- **99.0-99.9%:** Good (43 min - 7 hours downtime/month)
- **< 99.0%:** Needs improvement

### Alert Frequency:
- **0-1 alerts/week:** Healthy system
- **2-5 alerts/week:** Some issues - monitor trends
- **5+ alerts/week:** Serious problems - investigate root cause

---

## UptimeRobot vs n8n Health Monitor

### UptimeRobot (External):
- ✅ Works even if n8n is down
- ✅ Checks from external internet
- ✅ Historical uptime tracking
- ✅ Public status pages
- ❌ 5-minute interval (free tier)
- ❌ Limited to HTTP checks

### n8n Health Monitor (Internal):
- ✅ Can check internal services
- ✅ More detailed error information
- ✅ Integration with other workflows
- ✅ Custom logic and routing
- ❌ Doesn't work if n8n is down
- ❌ Requires n8n to be running

**Best Practice:** Use BOTH for complete coverage!

---

## Advanced UptimeRobot Features (Paid)

If you upgrade to Pro ($7/mo):

1. **SMS Alerts** - Get text messages for critical issues
2. **1-Minute Intervals** - Faster detection
3. **More Monitors** - Up to 50 on Pro, 10,000 on Enterprise
4. **Custom Ports** - Monitor non-HTTP services
5. **SSL Monitoring** - Get alerts before certificates expire
6. **Keyword Monitoring** - Alert if page content changes

---

## Troubleshooting

### Issue: All monitors showing "Down"

**Possible causes:**
- Webhooks require POST method (not GET)
- Authentication required
- n8n instance actually down

**Solution:**
1. Test webhook manually:
   ```bash
   curl -I https://polarmedia.app.n8n.cloud/webhook/vapi/call
   ```
2. If returns 405 Method Not Allowed, that's normal
3. In UptimeRobot, set "Expected Status Codes" to include 405

### Issue: Getting false positive alerts

**Solution:**
- Increase "Down Alert Threshold" to 2 or 3 checks
- Webhooks may occasionally timeout - this filters transient issues

### Issue: Not receiving email alerts

**Solution:**
- Check spam folder
- Verify email in Alert Contacts
- Test with "Test Alert" button in UptimeRobot

---

## Customization Tips

### Monitor Naming Convention:
Use consistent naming:
- `[AppName] - [Feature]`
- Example: `Appointment System - Main Booking`

### Tagging:
Add tags to monitors:
- `production`
- `critical`
- `appointment-system`

### Maintenance Windows:
When doing planned maintenance:
1. Pause monitors temporarily
2. Or: Use Maintenance feature (paid plans)

---

## Integration with Other Tools

UptimeRobot can integrate with:

- **Slack:** Post status to channel
- **Telegram:** Telegram bot alerts
- **Webhook:** Send alerts to custom endpoint
- **Zapier:** Connect to 1000+ apps

To set up:
1. Alert Contacts → Add Alert Contact
2. Choose integration type
3. Follow setup instructions

---

## Next Steps

After completing this phase:

1. ✅ Phase 6 complete - External monitoring active
2. ➡️ Proceed to Phase 7: End-to-end testing
3. ➡️ Then create final deployment report

---

## Completion Criteria

Phase 6 is complete when:

- [x] UptimeRobot account active
- [x] 7 monitors configured and running
- [x] All monitors showing "Up" status
- [x] Email alerts configured
- [x] Test alert successfully received
- [x] Status page accessible (if created)

---

## Time Spent

- **Estimated:** 10 minutes
- **Actual:** _____ minutes (fill in after completion)

---

## UptimeRobot Dashboard Screenshot

(Take a screenshot of your dashboard showing all monitors "Up")

---

## Phase 6 Status: ⏳ READY TO EXECUTE

**Next Phase:** Phase 7 - End-to-End Testing

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
**Phase:** 6 of 7
**Cost:** FREE (or $7/mo for Pro features)
