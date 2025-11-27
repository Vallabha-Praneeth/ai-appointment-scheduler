# Monitoring Dashboard Setup Guide

## Overview

This guide will help you set up a comprehensive monitoring dashboard using Google Sheets to track your appointment scheduling system's health and performance.

## Step 1: Create Google Sheets Dashboard (10 minutes)

### Create New Sheet

1. Go to Google Sheets: https://sheets.google.com
2. Create new spreadsheet: **"Appointment System Monitoring"**
3. Note the Sheet ID from URL: `https://docs.google.com/spreadsheets/d/[SHEET_ID]/edit`

### Create Required Tabs

Create the following sheets (tabs):

1. **Dashboard** - Main overview
2. **System Health Log** - From health monitor workflow
3. **Error Log** - From error handler
4. **Activity Log** - From workflow executions
5. **Metrics** - Calculated metrics and charts

---

## Step 2: System Health Log Tab

### Column Headers (Row 1):

| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| Timestamp | Severity | Health_Percentage | Healthy_Count | Unhealthy_Count | Critical_Failures | Warnings | Alert_Sent |

### Formatting:

- Row 1: Bold, frozen header
- Column A: Format as "yyyy-MM-dd HH:mm:ss"
- Column C: Format as percentage with 1 decimal
- Conditional formatting for Severity (B):
  - CRITICAL = Red background
  - HIGH = Orange background
  - WARNING = Yellow background
  - OK = Green background

### Sample Data Row:

```
2025-11-26 10:05:23 | OK | 100.0% | 7 | 0 | [] | [] | NONE
```

---

## Step 3: Error Log Tab

### Column Headers (Row 1):

| A | B | C | D | E | F | G | H | I |
|---|---|---|---|---|---|---|---|---|
| Timestamp | Workflow | Node | Severity | Error_Type | Error_Message | Execution_ID | Input_Data | Alert_Sent |

### Formatting:

- Row 1: Bold, frozen header
- Column A: Format as "yyyy-MM-dd HH:mm:ss"
- Conditional formatting for Severity (D):
  - HIGH = Red text
  - MEDIUM = Orange text
  - LOW = Blue text
- Column F: Wrap text enabled
- Column H: Wrap text enabled, font size 9

### Sample Data Row:

```
2025-11-26 10:15:33 | Main Booking | Check Availability | MEDIUM | ValidationError | Missing required field: startIso | exec_abc123 | {"phone": "+1..."} | EMAIL
```

---

## Step 4: Activity Log Tab

### Column Headers (Row 1):

| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| Timestamp | Workflow | Action | Result | BookingID | Phone | Email | Duration_ms |

### Formatting:

- Row 1: Bold, frozen header
- Column A: Format as "yyyy-MM-dd HH:mm:ss"
- Conditional formatting for Result (D):
  - booked = Green
  - cancelled = Red
  - rescheduled = Blue
  - error = Dark Red
  - no_free_slot = Orange

### Sample Data Row:

```
2025-11-26 11:30:45 | Main Booking | book | booked | evt_xyz789 | +12145551234 | john@example.com | 1247
```

---

## Step 5: Metrics Tab

### Key Performance Indicators (KPIs)

Create calculated fields:

#### A. Success Rate (Last 24 Hours)

```
=COUNTIF(FILTER('Activity Log'!D:D, 'Activity Log'!A:A >= NOW()-1), "booked") /
 COUNTA(FILTER('Activity Log'!D:D, 'Activity Log'!A:A >= NOW()-1))
```

Format as percentage with 1 decimal.

#### B. System Uptime (Last 7 Days)

```
=COUNTIF(FILTER('System Health Log'!B:B, 'System Health Log'!A:A >= NOW()-7), "OK") /
 COUNTA(FILTER('System Health Log'!B:B, 'System Health Log'!A:A >= NOW()-7))
```

Format as percentage with 2 decimals.

#### C. Average Response Time

```
=AVERAGE(FILTER('Activity Log'!H:H, 'Activity Log'!A:A >= NOW()-1))
```

Format as number with 0 decimals, append " ms"

#### D. Error Rate (Last 24 Hours)

```
=COUNTA(FILTER('Error Log'!A:A, 'Error Log'!A:A >= NOW()-1))
```

#### E. Critical Errors (Last 7 Days)

```
=COUNTIF(FILTER('Error Log'!D:D, 'Error Log'!A:A >= NOW()-7), "HIGH")
```

---

## Step 6: Dashboard Tab Layout

### Row 1-3: Title Section

```
A1: "Appointment System Monitoring Dashboard"
A2: "Last Updated:"
B2: =NOW()
```

### Row 5-10: System Health Status

| Metric | Value | Status |
|--------|-------|--------|
| System Uptime (7d) | =Metrics!B2 | =IF(Metrics!B2>=0.95,"✅","⚠️") |
| Success Rate (24h) | =Metrics!B3 | =IF(Metrics!B3>=0.90,"✅","❌") |
| Avg Response Time | =Metrics!B4 | =IF(Metrics!B4<2000,"✅","⚠️") |
| Active Errors | =Metrics!B5 | =IF(Metrics!B5=0,"✅","❌") |
| Critical Errors (7d) | =Metrics!B6 | =IF(Metrics!B6=0,"✅","🔴") |

### Row 12-20: Recent Activity Summary

Create a pivot table or query:

```
=QUERY('Activity Log'!A:H,
  "SELECT A, B, C, D WHERE A >= datetime '"&TEXT(NOW()-1,"yyyy-MM-dd HH:mm:ss")&"' ORDER BY A DESC LIMIT 10", 1)
```

### Row 22-30: Recent Errors

```
=QUERY('Error Log'!A:I,
  "SELECT A, B, D, F WHERE D = 'HIGH' OR D = 'MEDIUM' ORDER BY A DESC LIMIT 10", 1)
```

### Row 32-40: Booking Statistics

| Metric | Count |
|--------|-------|
| Bookings Today | =COUNTIFS('Activity Log'!C:C,"book",'Activity Log'!D:D,"booked",'Activity Log'!A:A,">="&INT(NOW())) |
| Cancellations Today | =COUNTIFS('Activity Log'!C:C,"cancel",'Activity Log'!D:D,"cancelled",'Activity Log'!A:A,">="&INT(NOW())) |
| Reschedules Today | =COUNTIFS('Activity Log'!C:C,"reschedule",'Activity Log'!D:D,"rescheduled",'Activity Log'!A:A,">="&INT(NOW())) |

---

## Step 7: Create Charts

### Chart 1: System Health Over Time (Line Chart)

- Data Range: System Health Log!A:C (last 100 rows)
- X-axis: Timestamp
- Y-axis: Health_Percentage
- Chart type: Line chart
- Place on Dashboard tab

### Chart 2: Error Distribution (Pie Chart)

- Data Range: Error Log!D:D (last 100 rows)
- Group by: Severity
- Chart type: Pie chart
- Place on Dashboard tab

### Chart 3: Booking Activity (Column Chart)

- Data Range: Activity Log!A:D (last 50 rows)
- X-axis: Date (use DATEVALUE to group)
- Y-axis: COUNT of actions
- Stack by: Result
- Chart type: Stacked column chart
- Place on Dashboard tab

---

## Step 8: Set Up Data Refresh

Google Sheets auto-updates formulas, but for optimal performance:

### Option A: Manual Refresh Button

1. Insert Drawing: "Refresh Data"
2. Assign Script:

```javascript
function refreshDashboard() {
  SpreadsheetApp.flush();
  SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Dashboard').getRange('B2').setValue(new Date());
}
```

### Option B: Auto-refresh Every 5 Minutes

1. Extensions → Apps Script
2. Add trigger:

```javascript
function onEdit() {
  // Auto-recalculates on any edit
}

// Set up time-based trigger: every 5 minutes
```

---

## Step 9: Configure Alerts in Google Sheets

### Set up Notification Rules:

1. Tools → Notification rules
2. Create rule:
   - **Condition:** User submits a form (errors added)
   - **Notify:** Email immediately
   - **Apply to:** Error Log sheet

---

## Step 10: Integrate with n8n Workflows

### Add to Each Workflow (After Success/Error)

**For Activity Logging:**

```json
{
  "node": "Google Sheets",
  "operation": "append",
  "sheet": "Activity Log",
  "values": {
    "Timestamp": "={{$now.format('YYYY-MM-DD HH:mm:ss')}}",
    "Workflow": "={{$workflow.name}}",
    "Action": "={{$json.action}}",
    "Result": "={{$json.result}}",
    "BookingID": "={{$json.bookingId}}",
    "Phone": "={{$json.phone}}",
    "Email": "={{$json.email}}",
    "Duration_ms": "={{$execution.duration}}"
  }
}
```

---

## Environment Variables for n8n

Add these to your n8n instance:

```bash
MONITORING_SHEET_ID=<your-sheet-id>
ERROR_LOG_SHEET_ID=<your-sheet-id>  # Can be same as above
ALERT_EMAIL=<your-email>
ALERT_PHONE=<your-phone-number>
```

---

## Testing the Dashboard

### Test 1: Generate Activity Logs

```bash
# Run test suite
./run_all_tests.sh

# Check Activity Log sheet - should have 8+ new entries
```

### Test 2: Trigger an Error

```bash
# Send invalid request
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -d '{}'

# Check Error Log sheet - should have 1 new entry
```

### Test 3: Check Health Monitor

```bash
# Wait for next 5-minute cycle (or manually trigger)
# Check System Health Log - should show current status
```

### Test 4: Verify Dashboard Updates

1. Open Dashboard tab
2. Refresh (Ctrl+R / Cmd+R)
3. Verify all metrics are calculating correctly
4. Check that charts are displaying data

---

## Maintenance

### Daily Tasks:

- Review Dashboard for anomalies
- Check Critical Errors count
- Verify System Uptime percentage

### Weekly Tasks:

- Review Error Log for patterns
- Check Success Rate trends
- Archive old logs (keep last 90 days)

### Monthly Tasks:

- Export historical data for backup
- Review and adjust alert thresholds
- Update monitoring workflows if needed

---

## Advanced Features (Optional)

### 1. SMS Alerts from Google Sheets

Use Google Apps Script with Twilio:

```javascript
function sendSMSAlert(message) {
  var accountSid = 'your_twilio_sid';
  var authToken = 'your_twilio_token';
  var from = '+14694365607';
  var to = '+1234567890';

  var payload = {
    'To': to,
    'From': from,
    'Body': message
  };

  var options = {
    'method': 'post',
    'payload': payload,
    'headers': {
      'Authorization': 'Basic ' + Utilities.base64Encode(accountSid + ':' + authToken)
    }
  };

  UrlFetchApp.fetch('https://api.twilio.com/2010-04-01/Accounts/' + accountSid + '/Messages.json', options);
}

// Trigger on high severity errors
function onEdit(e) {
  var sheet = e.source.getActiveSheet();
  if (sheet.getName() === 'Error Log') {
    var severity = e.range.offset(0, 3).getValue(); // Column D
    if (severity === 'HIGH') {
      sendSMSAlert('🚨 High severity error detected!');
    }
  }
}
```

### 2. Slack Integration

Post to Slack channel when critical errors occur:

```javascript
function postToSlack(message) {
  var webhookUrl = 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL';

  var payload = JSON.stringify({
    'text': message,
    'username': 'Monitoring Bot',
    'icon_emoji': ':chart_with_upwards_trend:'
  });

  var options = {
    'method': 'post',
    'contentType': 'application/json',
    'payload': payload
  };

  UrlFetchApp.fetch(webhookUrl, options);
}
```

### 3. Custom Dashboard URL

Create a shareable dashboard link:

1. File → Share → Publish to web
2. Select "Dashboard" sheet only
3. Copy link
4. Bookmark for quick access

---

## Troubleshooting

### Issue: Formulas not updating

**Solution:**
- Check that auto-calculation is enabled
- File → Settings → Calculation → On change

### Issue: Charts not showing data

**Solution:**
- Verify data range includes headers
- Check that there's actual data in the range
- Refresh the sheet (Ctrl+R)

### Issue: Google Sheets API rate limit

**Solution:**
- Reduce logging frequency
- Batch multiple operations
- Use exponential backoff in n8n nodes

---

## Security Considerations

1. **Restrict Sheet Access:**
   - Share with specific users only
   - Use "View only" for non-admins

2. **Protect Sensitive Data:**
   - Don't log full credit card numbers
   - Mask phone numbers (last 4 digits)
   - Encrypt API keys in scripts

3. **Backup Strategy:**
   - Weekly exports to Google Drive
   - Monthly archives downloaded locally

---

## Next Steps

After setup:

1. ✅ Import monitoring workflows to n8n
2. ✅ Configure environment variables
3. ✅ Test all integrations
4. ✅ Set up mobile notifications
5. ✅ Train team on dashboard usage
6. ✅ Document incident response procedures

---

## Support Resources

- **Google Sheets Help:** https://support.google.com/docs
- **n8n Monitoring Docs:** https://docs.n8n.io/hosting/monitoring/
- **Apps Script Reference:** https://developers.google.com/apps-script/reference
