# Smart Reminder System - Deployment Guide

**Status:** ✅ Ready to deploy
**Expected Impact:** 40-60% reduction in no-shows
**Time to Deploy:** 30-40 minutes

---

## Overview

This system sends automated SMS reminders to customers:
- **24-hour reminder:** Sent daily at 9 AM for tomorrow's appointments
- **4-hour reminder:** Sent every 2 hours for upcoming appointments

**Key Features:**
- ✅ Prevents duplicate reminders (tracks sent reminders in Google Sheets)
- ✅ Personalized messages with customer name and appointment details
- ✅ Automatic timezone handling (America/Chicago)
- ✅ Extracts phone numbers from calendar event descriptions
- ✅ Logs all sent reminders for tracking

---

## Prerequisites

Before starting, ensure you have:
- ✅ n8n instance: `https://polarmedia.app.n8n.cloud`
- ✅ Google Calendar: `quantumops9@gmail.com`
- ✅ Google Sheets ID: `1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc`
- ✅ Twilio account with phone number: `+14694365607`
- ✅ Google Calendar and Sheets credentials configured in n8n
- ✅ Twilio credentials configured in n8n

---

## STEP 1: Set Up Google Sheet

### Create Reminder_Log Tab

1. **Open your Google Sheet:**
   ```
   https://docs.google.com/spreadsheets/d/1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc/edit
   ```

2. **Add a new tab:**
   - Click the "+" icon at the bottom
   - Rename the new tab to: `Reminder_Log`

3. **Add column headers in Row 1:**

   | A | B | C | D | E | F | G |
   |---|---|---|---|---|---|---|
   | bookingId | phone | name | appointmentTime | reminderType | sentAt | status |

4. **Format the header row:**
   - Select Row 1
   - Make it bold
   - Optional: Add background color
   - Freeze row: View → Freeze → 1 row

5. **Verify setup:**
   - Tab name is exactly: `Reminder_Log` (case-sensitive)
   - 7 columns with exact names above
   - Row 1 is frozen

---

## STEP 2: Import Workflow 1 (24-Hour Reminders)

### Import the Workflow

1. **Log in to n8n:**
   ```
   https://polarmedia.app.n8n.cloud
   ```

2. **Go to Workflows:**
   - Click "Workflows" in the left sidebar

3. **Import workflow:**
   - Click "+ Add workflow" → "Import from File"
   - Select file: `Smart_Reminder_System_24h.json`
   - Click "Import"

### Configure Credentials

The workflow will show nodes with missing credentials. Configure each:

**A. Google Calendar Credentials:**

1. Find node: "Get Tomorrow's Appointments"
2. Click on the node
3. In "Credential to connect with" → Select your Google Calendar credential
4. If not exists:
   - Click "Create New"
   - Follow OAuth flow to authorize `quantumops9@gmail.com`

**B. Google Sheets Credentials:**

1. Find nodes: "Check If 24h Reminder Already Sent" and "Log Sent Reminder"
2. For each node:
   - Click on the node
   - Select your Google Sheets credential
   - Or create new credential if needed

**C. Twilio Credentials:**

1. Find node: "Send SMS Reminder"
2. Click on the node
3. Select your Twilio credential
4. If not exists:
   - Click "Create New"
   - Enter Account SID and Auth Token from Twilio console

### Verify Configuration

After adding credentials, check:

1. **Calendar ID is correct:**
   - Node: "Get Tomorrow's Appointments"
   - CalendarId should be: `quantumops9@gmail.com`

2. **Sheet ID is correct:**
   - Nodes: "Check If 24h Reminder Already Sent", "Log Sent Reminder"
   - DocumentId should be: `1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc`
   - SheetName should be: `Reminder_Log`

3. **Twilio phone number:**
   - Node: "Send SMS Reminder"
   - From: `+14694365607`

### Activate the Workflow

1. **Save the workflow:**
   - Click "Save" button (top right)

2. **Activate:**
   - Toggle the "Active" switch to ON (top right)
   - Status should change to: "Active"

3. **Verify schedule:**
   - Node: "Schedule Trigger - Daily 9 AM"
   - Cron expression: `0 9 * * *` (runs at 9:00 AM every day)

---

## STEP 3: Import Workflow 2 (4-Hour Reminders)

### Import the Workflow

1. **Still in n8n, import second workflow:**
   - Click "+ Add workflow" → "Import from File"
   - Select file: `Smart_Reminder_System_4h.json`
   - Click "Import"

### Configure Credentials

Same as Workflow 1 - configure:
- Google Calendar credential
- Google Sheets credential
- Twilio credential

### Verify Configuration

Check all the same settings as Workflow 1:
- Calendar ID: `quantumops9@gmail.com`
- Sheet ID: `1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc`
- Sheet name: `Reminder_Log`
- Twilio from: `+14694365607`

### Activate the Workflow

1. **Save the workflow**
2. **Activate** (toggle to ON)
3. **Verify schedule:**
   - Node: "Schedule Trigger - Every 2 Hours"
   - Cron expression: `0 */2 * * *` (runs every 2 hours)

---

## STEP 4: Test the System

### Create Test Appointment

1. **Create a Google Calendar event for tomorrow:**
   - Title: `Test Consultation - John Doe`
   - Time: Any time tomorrow
   - Description:
     ```
     Name: John Doe
     Phone: +12145551234
     Service: Consultation
     ```

2. **Save the event**

### Test 24-Hour Workflow Manually

1. **Open workflow:** "Smart Reminder System - 24h"
2. **Click "Execute Workflow"** button (play icon)
3. **Check execution:**
   - Should fetch tomorrow's events
   - Should find your test appointment
   - Should send SMS (if not already sent)
   - Should log to Google Sheets

4. **Verify:**
   - Check Google Sheets "Reminder_Log" tab
   - Should have new row with bookingId, phone, name, etc.
   - Check your phone for SMS (if you used your real number)

### Test 4-Hour Workflow

1. **Create another test event for 4 hours from now:**
   - Title: `Test Support - Jane Smith`
   - Time: Exactly 4 hours from current time
   - Description:
     ```
     Name: Jane Smith
     Phone: +12145559876
     Service: Support
     ```

2. **Run workflow:** "Smart Reminder System - 4h"
3. **Click "Execute Workflow"**
4. **Verify:**
   - Check Google Sheets for new log entry
   - Check phone for SMS

---

## STEP 5: Integrate with Booking Workflow

### Update Main Booking Workflow

Your main booking workflow (`Appointment Scheduling AI_v.0.0.3.json`) needs to ensure calendar events include phone numbers in the description.

**Current format should be:**
```
Name: [Customer Name]
Phone: [Customer Phone]
Email: [Customer Email]
Service: [Service Type]
```

**If your events don't have this format:**

1. **Open booking workflow** in n8n
2. **Find the "Create Google Calendar Event" node**
3. **Update the description field to include:**
   ```javascript
   Name: {{ $json.name }}
   Phone: {{ $json.phone }}
   Email: {{ $json.email }}
   Service: {{ $json.service_type }}
   ```

4. **Save and activate**

**The reminder workflows extract phone numbers from this description format.**

---

## Understanding the Workflows

### Workflow 1: 24-Hour Reminders

**When it runs:** Every day at 9:00 AM

**What it does:**
1. Calculates tomorrow's date (00:00 to 23:59)
2. Fetches all calendar events for tomorrow
3. For each event:
   - Extracts phone number and name from description
   - Checks Google Sheets if 24h reminder already sent for this booking
   - If not sent → Sends SMS and logs to sheet
   - If already sent → Skips

**SMS Format:**
```
Hi John Doe!

Reminder: You have a consultation appointment tomorrow (November 28) at 2:00 PM.

Need to reschedule or cancel? Call us at +14694365607.

- Alex (Your appointment assistant)
```

### Workflow 2: 4-Hour Reminders

**When it runs:** Every 2 hours (00:00, 02:00, 04:00, ... 22:00)

**What it does:**
1. Calculates 4-hour window (3.5 to 4.5 hours from now)
2. Fetches calendar events in that window
3. For each event:
   - Extracts phone and name
   - Checks if 4h reminder already sent
   - If not sent → Sends SMS and logs
   - If sent → Skips

**SMS Format:**
```
Hi John Doe!

Your consultation appointment is in 4 hours at 2:00 PM.

See you soon! Call +14694365607 if you need to reschedule.

- Alex
```

---

## Monitoring & Maintenance

### Check Reminder Logs

**Google Sheets:**
- View: `Reminder_Log` tab
- Monitor: sentAt timestamps, status
- Track: How many reminders sent per day

**n8n Execution History:**
- Go to: Workflows → [Workflow Name] → Executions
- Filter: Success, Error, Running
- Debug: Click on execution to see detailed logs

### Common Issues

**Issue 1: No reminders sent**

**Symptoms:** Workflows run but no SMS sent

**Solutions:**
1. Check Google Sheets - any rows added?
   - If YES → Twilio issue
   - If NO → Calendar/extraction issue

2. Check calendar event descriptions
   - Must include: `Phone: +12145551234` format
   - Phone must have country code (+1)

3. Check n8n execution logs
   - Look for errors in "Extract Appointment Data" node
   - Check console.log messages

**Issue 2: Duplicate reminders**

**Symptoms:** Same customer gets multiple reminders

**Solutions:**
1. Check Google Sheets Reminder_Log
   - Are there multiple rows for same bookingId + reminderType?
   - If YES → Sheet lookup not working

2. Verify Sheet name is exactly: `Reminder_Log`
   - Case-sensitive!

3. Check "Check If Reminder Already Sent" node
   - Ensure it's searching on both bookingId AND reminderType

**Issue 3: Wrong time or timezone**

**Symptoms:** Reminders sent at wrong time or with wrong appointment time

**Solutions:**
1. Check timezone in Code nodes
   - Should be: `America/Chicago` (or your timezone)
   - Update in both workflows if different

2. Verify schedule cron expressions:
   - 24h workflow: `0 9 * * *` (9 AM)
   - 4h workflow: `0 */2 * * *` (every 2 hours)

**Issue 4: Can't find phone number**

**Symptoms:** Execution logs show "Skipping event - no phone number found"

**Solutions:**
1. Calendar event description must include:
   ```
   Phone: +12145551234
   ```
   Or:
   ```
   phone: +12145551234
   ```
   Or:
   ```
   tel: +12145551234
   ```

2. Phone must have country code (+1 for US)

3. Update booking workflow to ensure phone is in description

---

## Cost Analysis

### SMS Costs (Twilio)

**Per message:** ~$0.0079 (US domestic)

**Monthly estimate (100 appointments/month):**
- 100 appointments × 2 reminders each = 200 SMS
- 200 × $0.0079 = **$1.58/month**

**Annual:** ~$19/month

### n8n Execution Costs

**Free tier:** Usually sufficient
- 24h workflow: 30 executions/month
- 4h workflow: 360 executions/month (12/day × 30)
- **Total:** 390 executions/month

Most n8n plans include thousands of executions.

### ROI Calculation

**No-show reduction:** 40-60% (industry average)

**Scenario:**
- Current appointments: 100/month
- No-show rate before: 20% (20 appointments)
- No-show rate after: 8% (8 appointments)
- **Reduction:** 12 appointments saved

**If average appointment value = $100:**
- Revenue saved: 12 × $100 = $1,200/month
- Cost: $1.58/month
- **ROI:** 75,000%+

---

## Customization Options

### Change Reminder Timing

**24-Hour Workflow:**

To change from 9 AM to different time:
1. Open workflow
2. Edit "Schedule Trigger - Daily 9 AM" node
3. Change cron expression:
   - 8 AM: `0 8 * * *`
   - 10 AM: `0 10 * * *`
   - Noon: `0 12 * * *`

**4-Hour Workflow:**

To change from "every 2 hours" to different frequency:
1. Open workflow
2. Edit "Schedule Trigger - Every 2 Hours" node
3. Change cron expression:
   - Every hour: `0 * * * *`
   - Every 3 hours: `0 */3 * * *`
   - Every 4 hours: `0 */4 * * *`

### Customize SMS Messages

**24-Hour Message:**

1. Open workflow "Smart Reminder System - 24h"
2. Find node: "Format SMS Message"
3. Edit the `message` variable in the code
4. Current template:
   ```javascript
   const message = `Hi ${$json.name}!\n\nReminder: You have a ${$json.serviceType} appointment tomorrow (${dateFormatted}) at ${timeFormatted.split(', ')[1]}.\n\nNeed to reschedule or cancel? Call us at +14694365607.\n\n- Alex (Your appointment assistant)`;
   ```
5. Modify text as desired
6. Save workflow

**4-Hour Message:**

Same process, but in "Smart Reminder System - 4h" workflow.

### Add Third Reminder (2 hours before)

1. Duplicate "Smart Reminder System - 4h.json"
2. Rename to: "Smart Reminder System - 2h"
3. Change schedule trigger to every hour: `0 * * * *`
4. Update Code node time window:
   ```javascript
   windowStart.setHours(windowStart.getHours() + 1, windowStart.getMinutes() + 30);
   windowEnd.setHours(windowEnd.getHours() + 2, windowEnd.getMinutes() + 30);
   ```
5. Change reminderType from "4h" to "2h"
6. Update SMS message
7. Save and activate

---

## Best Practices

### Do's ✅

- ✅ Test with real phone numbers before going live
- ✅ Monitor Reminder_Log sheet daily for first week
- ✅ Check n8n execution history if reminders stop
- ✅ Update SMS templates with your business details
- ✅ Keep phone numbers in E.164 format (+1...)

### Don'ts ❌

- ❌ Don't delete rows from Reminder_Log (causes duplicates)
- ❌ Don't change sheet/column names without updating workflows
- ❌ Don't send reminders more than 2-3 times per appointment
- ❌ Don't forget to update timezone if you're not in Chicago
- ❌ Don't test with customer phone numbers

---

## Troubleshooting Checklist

Before asking for help, verify:

- [ ] Google Sheet has "Reminder_Log" tab (exact name)
- [ ] 7 columns with exact header names
- [ ] Both workflows are Active (green toggle)
- [ ] All credentials configured (Google Calendar, Sheets, Twilio)
- [ ] Calendar events have phone numbers in description
- [ ] Phone numbers include country code (+1...)
- [ ] Cron expressions are correct
- [ ] Timezone is correct (America/Chicago or yours)
- [ ] Twilio phone number is correct (+14694365607)
- [ ] Google Calendar ID is correct (quantumops9@gmail.com)
- [ ] Sheet ID is correct (1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc)

---

## Next Steps

After deployment:

**Week 1:**
- Monitor daily reminder sends
- Check for any errors in n8n
- Verify customers receive SMS
- Track no-show rate

**Week 2:**
- Analyze Reminder_Log data
- Calculate ROI (appointments saved)
- Adjust timing if needed
- Customize SMS templates

**Month 1:**
- Review overall impact on no-shows
- Consider adding 2-hour reminder
- Optimize send times based on data
- Document lessons learned

---

## Summary

**What you deployed:**
- ✅ Two automated reminder workflows
- ✅ Google Sheets tracking system
- ✅ Personalized SMS messaging
- ✅ Duplicate prevention logic

**Expected results:**
- 📉 40-60% reduction in no-shows
- 📱 Automatic SMS reminders
- 📊 Complete tracking of all reminders
- 💰 Significant ROI ($1,200+ saved per month)

**Maintenance required:**
- Low (check weekly)
- Review logs if issues arise
- Update SMS templates as needed

---

**Status:** ✅ Ready for production use!

**Files created:**
- `Smart_Reminder_System_24h.json` - Daily 9 AM workflow
- `Smart_Reminder_System_4h.json` - Every 2 hours workflow
- `REMINDER_SHEET_SETUP.md` - Google Sheets setup guide
- `SMART_REMINDER_DEPLOYMENT.md` - This deployment guide

**Created:** November 27, 2025
**Version:** 1.0
