# Phase 2: Google Sheets Dashboard Setup Report

**Date:** 2025-11-26
**Phase:** 2 of 7
**Estimated Time:** 10 minutes
**Status:** Ready for Execution

---

## Objective

Create a comprehensive Google Sheets dashboard for real-time monitoring, logging, and analytics.

---

## Prerequisites

- [ ] Google account access (quantumops9@gmail.com or your monitoring account)
- [ ] Phase 1 completed (environment variables ready)
- [ ] Internet access to Google Sheets

---

## Step-by-Step Instructions

### Step 1: Create New Google Sheet (2 minutes)

1. **Open Google Sheets**
   - Navigate to: https://sheets.google.com
   - Sign in with: quantumops9@gmail.com (or your account)

2. **Create New Spreadsheet**
   - Click: "+ Blank" or "Blank spreadsheet"
   - Wait for new sheet to open

3. **Rename Spreadsheet**
   - Click on "Untitled spreadsheet" at top left
   - Rename to: **"Appointment System Monitoring"**
   - Press Enter to save

4. **Copy Sheet ID**
   - Look at URL in browser:
   ```
   https://docs.google.com/spreadsheets/d/[THIS_IS_THE_SHEET_ID]/edit
   ```
   - Copy the ID (long string between `/d/` and `/edit`)
   - Example: `1AbC123XyZ456...`
   - **IMPORTANT:** Save this ID - you'll need it for Phase 1 (update env vars)

---

### Step 2: Create Required Tabs/Sheets (2 minutes)

By default, you have one tab called "Sheet1". We need 5 tabs total.

1. **Rename Sheet1 to "Dashboard"**
   - Right-click on "Sheet1" tab at bottom
   - Click "Rename"
   - Type: **Dashboard**
   - Press Enter

2. **Create "System Health Log" Tab**
   - Click "+" button at bottom left
   - Right-click new sheet → Rename
   - Type: **System Health Log**

3. **Create "Error Log" Tab**
   - Click "+" button again
   - Rename to: **Error Log**

4. **Create "Activity Log" Tab**
   - Click "+" button again
   - Rename to: **Activity Log**

5. **Create "Metrics" Tab**
   - Click "+" button again
   - Rename to: **Metrics**

**Verify:** You should now have 5 tabs:
- Dashboard
- System Health Log
- Error Log
- Activity Log
- Metrics

---

### Step 3: Set Up "System Health Log" Tab (2 minutes)

1. **Click on "System Health Log" tab**

2. **Add Column Headers in Row 1:**

Click on cell A1 and type the following headers across Row 1:

| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| Timestamp | Severity | Health_Percentage | Healthy_Count | Unhealthy_Count | Critical_Failures | Warnings | Alert_Sent |

**Exact values to type:**
- A1: `Timestamp`
- B1: `Severity`
- C1: `Health_Percentage`
- D1: `Healthy_Count`
- E1: `Unhealthy_Count`
- F1: `Critical_Failures`
- G1: `Warnings`
- H1: `Alert_Sent`

3. **Format Header Row:**
   - Select Row 1 (click on row number "1")
   - Click **Bold** button (or Ctrl+B / Cmd+B)
   - Click **Background color** → Choose light gray
   - Menu: View → Freeze → 1 row (keeps headers visible)

4. **Format Timestamp Column:**
   - Click on column A header (to select entire column)
   - Menu: Format → Number → Date time
   - Or choose: Format → Number → Custom date and time
   - Use format: `yyyy-MM-dd HH:mm:ss`

5. **Format Health_Percentage Column:**
   - Click on column C header
   - Menu: Format → Number → Percent
   - Set decimal places: 1

6. **Add Conditional Formatting for Severity (Column B):**
   - Select column B (click column header)
   - Menu: Format → Conditional formatting

   **Rule 1: CRITICAL**
   - Format cells if: Text is exactly: `CRITICAL`
   - Formatting: Background color = Red (#FF0000), Text color = White
   - Click "Done"

   **Add another rule (+):**
   - Format cells if: Text is exactly: `HIGH`
   - Formatting: Background color = Orange (#FF9900), Text color = Black
   - Click "Done"

   **Add another rule (+):**
   - Format cells if: Text is exactly: `WARNING`
   - Formatting: Background color = Yellow (#FFFF00), Text color = Black
   - Click "Done"

   **Add another rule (+):**
   - Format cells if: Text is exactly: `OK`
   - Formatting: Background color = Green (#00FF00), Text color = Black
   - Click "Done"

---

### Step 4: Set Up "Error Log" Tab (2 minutes)

1. **Click on "Error Log" tab**

2. **Add Column Headers in Row 1:**

| A | B | C | D | E | F | G | H | I |
|---|---|---|---|---|---|---|---|---|
| Timestamp | Workflow | Node | Severity | Error_Type | Error_Message | Execution_ID | Input_Data | Alert_Sent |

**Type in Row 1:**
- A1: `Timestamp`
- B1: `Workflow`
- C1: `Node`
- D1: `Severity`
- E1: `Error_Type`
- F1: `Error_Message`
- G1: `Execution_ID`
- H1: `Input_Data`
- I1: `Alert_Sent`

3. **Format Header Row:**
   - Select Row 1
   - Make it **Bold**
   - Background color: Light gray
   - View → Freeze → 1 row

4. **Format Timestamp (Column A):**
   - Select column A
   - Format → Number → Date time
   - Or custom: `yyyy-MM-dd HH:mm:ss`

5. **Format Text Columns:**
   - Select column F (Error_Message)
   - Menu: Format → Text wrapping → Wrap
   - Select column H (Input_Data)
   - Menu: Format → Text wrapping → Wrap
   - Menu: Format → Text → Font size → 9

6. **Add Conditional Formatting for Severity (Column D):**
   - Select column D
   - Format → Conditional formatting

   **Rule 1: HIGH**
   - Text is exactly: `HIGH`
   - Text color: Red, Bold

   **Rule 2: MEDIUM**
   - Text is exactly: `MEDIUM`
   - Text color: Orange, Bold

   **Rule 3: LOW**
   - Text is exactly: `LOW`
   - Text color: Blue

---

### Step 5: Set Up "Activity Log" Tab (2 minutes)

1. **Click on "Activity Log" tab**

2. **Add Column Headers in Row 1:**

| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| Timestamp | Workflow | Action | Result | BookingID | Phone | Email | Duration_ms |

**Type in Row 1:**
- A1: `Timestamp`
- B1: `Workflow`
- C1: `Action`
- D1: `Result`
- E1: `BookingID`
- F1: `Phone`
- G1: `Email`
- H1: `Duration_ms`

3. **Format Header Row:**
   - Select Row 1
   - Make **Bold**
   - Background: Light gray
   - Freeze row 1

4. **Format Timestamp:**
   - Column A → Date time format

5. **Add Conditional Formatting for Result (Column D):**
   - Select column D
   - Format → Conditional formatting

   **Rule 1: booked**
   - Text is exactly: `booked`
   - Background: Light green

   **Rule 2: cancelled**
   - Text is exactly: `cancelled`
   - Background: Light red

   **Rule 3: rescheduled**
   - Text is exactly: `rescheduled`
   - Background: Light blue

   **Rule 4: error**
   - Text is exactly: `error`
   - Background: Dark red, Text: White

   **Rule 5: no_free_slot**
   - Text is exactly: `no_free_slot`
   - Background: Orange

---

### Step 6: Set Up "Metrics" Tab (2 minutes)

This tab will contain calculated metrics.

1. **Click on "Metrics" tab**

2. **Set Up Structure:**

In column A (labels) and column B (values):

```
A1: Metric Name               B1: Value
A2: (blank)                   B2: (blank)
A3: Success Rate (24h)        B3: [formula - we'll add later]
A4: System Uptime (7d)        B4: [formula - we'll add later]
A5: Avg Response Time         B5: [formula - we'll add later]
A6: Error Count (24h)         B6: [formula - we'll add later]
A7: Critical Errors (7d)      B7: [formula - we'll add later]
```

**Type now:**
- A1: `Metric Name`
- B1: `Value`
- A3: `Success Rate (24h)`
- A4: `System Uptime (7d)`
- A5: `Avg Response Time`
- A6: `Error Count (24h)`
- A7: `Critical Errors (7d)`

3. **Format:**
   - Row 1: Bold, background gray
   - Column A: Bold
   - Column B: Right-align

**Note:** We'll add formulas in Phase 3 (next phase)

---

### Step 7: Set Up "Dashboard" Tab (1 minute)

This will be our main view. For now, we'll just add a title.

1. **Click on "Dashboard" tab**

2. **Add Title:**
   - A1: `Appointment System Monitoring Dashboard`
   - Select A1, make it **Bold**, Font size **18**
   - Merge cells A1:H1

3. **Add Last Updated:**
   - A2: `Last Updated:`
   - B2: `=NOW()`
   - Format B2: Format → Number → Date time

4. **Add placeholder sections:**
   - A4: `System Health Status`
   - Make bold, font size 14

   - A12: `Recent Activity`
   - Make bold, font size 14

   - A22: `Recent Errors`
   - Make bold, font size 14

   - A32: `Booking Statistics`
   - Make bold, font size 14

**Note:** We'll populate these sections in Phase 3

---

### Step 8: Share Sheet with n8n (1 minute)

n8n needs access to write to this sheet.

1. **Click "Share" button** (top right)

2. **Find your n8n Google Service Account Email:**
   - In n8n: Go to Credentials
   - Find your "Google Sheets" credential
   - Look for "Service Account Email"
   - It looks like: `n8n-xxxxx@project-name.iam.gserviceaccount.com`
   - Or: Your own Google email if using OAuth

3. **Add to sheet:**
   - In Share dialog, paste the service account email
   - Set role: **Editor**
   - Uncheck "Notify people"
   - Click "Share" or "Send"

4. **Alternative (if you don't have service account yet):**
   - For now, just share with your own email
   - We'll configure service account when setting up workflows

---

### Step 9: Update Environment Variables (1 minute)

Now that we have the Sheet ID, go back to n8n and update:

1. Go back to n8n: https://polarmedia.app.n8n.cloud
2. Settings → Environment Variables
3. Update these values:

```bash
MONITORING_SHEET_ID=<paste-your-sheet-id-here>
ERROR_LOG_SHEET_ID=<same-sheet-id-as-above>
```

4. Save and restart n8n if needed

---

## Verification Checklist

After completing this phase:

- [ ] Google Sheet created with name "Appointment System Monitoring"
- [ ] Sheet ID copied and saved
- [ ] All 5 tabs created (Dashboard, System Health Log, Error Log, Activity Log, Metrics)
- [ ] System Health Log has 8 columns with headers and formatting
- [ ] Error Log has 9 columns with headers and formatting
- [ ] Activity Log has 8 columns with headers and formatting
- [ ] Metrics tab has structure set up
- [ ] Dashboard tab has title and sections
- [ ] Sheet shared with n8n service account (Editor access)
- [ ] Environment variables updated in n8n with Sheet ID

---

## Sheet Structure Summary

| Tab Name | Purpose | Columns | Data Source |
|----------|---------|---------|-------------|
| **Dashboard** | Main overview | Variable | Aggregates from other tabs |
| **System Health Log** | Health check results | 8 | Health Monitor workflow |
| **Error Log** | Error details | 9 | Error Handler in workflows |
| **Activity Log** | Booking activity | 8 | All workflows |
| **Metrics** | Calculated KPIs | 2 | Formulas from other tabs |

---

## Sample Data for Testing

Once workflows are active, here's what sample data looks like:

**System Health Log:**
```
2025-11-26 10:05:23 | OK | 100.0% | 7 | 0 | [] | [] | NONE
```

**Error Log:**
```
2025-11-26 10:15:33 | Main Booking | Check Availability | MEDIUM | ValidationError | Missing field: startIso | exec_abc123 | {...} | EMAIL
```

**Activity Log:**
```
2025-11-26 11:30:45 | Main Booking | book | booked | evt_xyz789 | +12145551234 | user@example.com | 1247
```

---

## Google Sheets Dashboard URL

After creation, your dashboard URL will be:

```
https://docs.google.com/spreadsheets/d/[YOUR_SHEET_ID]/edit
```

**Bookmark this URL for quick access!**

---

## Security Settings

Recommended share settings:

1. **For n8n service account:**
   - Role: Editor (needs write access)
   - Notify: OFF

2. **For team members (viewing only):**
   - Role: Viewer
   - Can comment: Optional

3. **For admins:**
   - Role: Editor
   - Can share: Optional

4. **General access:**
   - Keep as "Restricted" (not public)

---

## Next Steps

After completing this phase:

1. ✅ Phase 2 complete - Google Sheets dashboard created
2. ➡️ Proceed to Phase 3: Configure formulas and advanced formatting
3. ➡️ Then Phase 4: Import monitoring workflows to n8n

---

## Troubleshooting

### Issue: "Can't find service account email"

**Solution:**
- In n8n: Credentials → + Add Credential
- Search "Google Sheets"
- Create new credential following n8n's instructions
- Use OAuth method if service account not available

### Issue: "Sheet won't accept data from n8n"

**Solution:**
- Verify share permissions (Editor, not Viewer)
- Check that email matches exactly
- Try sharing with your own email for testing

### Issue: "Conditional formatting not working"

**Solution:**
- Ensure you're selecting the entire column (click column letter)
- Check exact text matching (case-sensitive)
- Apply format rules in order (most specific first)

---

## Completion Criteria

Phase 2 is complete when:

- [x] All 5 tabs created with correct names
- [x] All column headers set up
- [x] Basic formatting applied (bold headers, freeze rows)
- [x] Conditional formatting working on Severity and Result columns
- [x] Sheet shared with n8n
- [x] Sheet ID saved and environment variables updated

---

## Time Spent

- **Estimated:** 10 minutes
- **Actual:** _____ minutes (fill in after completion)

---

## Phase 2 Status: ⏳ READY TO EXECUTE

**Next Phase:** Phase 3 - Configure Formulas and Advanced Formatting

---

## Sheet ID to Save

**IMPORTANT:** Write your Sheet ID here after creation:

```
MONITORING_SHEET_ID = _____________________________________________
```

This will be needed for:
- Updating n8n environment variables
- Configuring workflows
- API access (if needed)

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
**Phase:** 2 of 7
