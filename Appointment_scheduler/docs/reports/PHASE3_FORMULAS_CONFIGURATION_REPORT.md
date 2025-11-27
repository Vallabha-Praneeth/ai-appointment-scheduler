# Phase 3: Google Sheets Formulas Configuration Report

**Date:** 2025-11-26
**Phase:** 3 of 7
**Estimated Time:** 15 minutes
**Status:** Ready for Execution

---

## Objective

Configure advanced formulas, calculations, and dashboard visualizations in Google Sheets for real-time monitoring analytics.

---

## Prerequisites

- [ ] Phase 2 completed (all tabs created with headers)
- [ ] Google Sheet open and accessible
- [ ] Basic understanding of Google Sheets formulas (we'll provide all formulas)

---

## Step-by-Step Instructions

### Part A: Configure Metrics Tab (5 minutes)

1. **Click on "Metrics" tab**

2. **Add Formulas in Column B**

#### B3: Success Rate (Last 24 Hours)

Click on cell B3 and paste this formula:

```
=IFERROR(
  COUNTIFS('Activity Log'!D:D,"booked",'Activity Log'!A:A,">="&NOW()-1) /
  COUNTA(FILTER('Activity Log'!D:D,'Activity Log'!A:A>=NOW()-1)),
  0
)
```

Format B3 as: Percentage with 1 decimal place

**What it does:** Counts successful bookings in last 24 hours divided by total attempts

---

#### B4: System Uptime (Last 7 Days)

Click on cell B4 and paste:

```
=IFERROR(
  COUNTIFS('System Health Log'!B:B,"OK",'System Health Log'!A:A,">="&NOW()-7) /
  COUNTA(FILTER('System Health Log'!B:B,'System Health Log'!A:A>=NOW()-7)),
  1
)
```

Format B4 as: Percentage with 2 decimal places

**What it does:** Calculates percentage of "OK" health checks in last 7 days

---

#### B5: Average Response Time (Last 24 Hours)

Click on cell B5 and paste:

```
=IFERROR(
  AVERAGE(FILTER('Activity Log'!H:H,'Activity Log'!A:A>=NOW()-1,'Activity Log'!H:H<>""))&" ms",
  "No data"
)
```

Format B5 as: Plain text (the formula adds " ms")

**What it does:** Averages all Duration_ms values from last 24 hours

---

#### B6: Error Count (Last 24 Hours)

Click on cell B6 and paste:

```
=COUNTA(FILTER('Error Log'!A:A,'Error Log'!A:A>=NOW()-1,'Error Log'!A:A<>""))
```

Format B6 as: Number (no decimals)

**What it does:** Counts all errors in last 24 hours

---

#### B7: Critical Errors (Last 7 Days)

Click on cell B7 and paste:

```
=COUNTIFS('Error Log'!D:D,"HIGH",'Error Log'!A:A,">="&NOW()-7)
```

Format B7 as: Number (no decimals)

**What it does:** Counts HIGH severity errors in last 7 days

---

### Part B: Configure Dashboard Tab (10 minutes)

1. **Click on "Dashboard" tab**

---

#### Section 1: System Health Status (Rows 5-11)

**Set up structure:**

Row 5 (Headers):
- A5: `Metric`
- B5: `Value`
- C5: `Status`

Make row 5 bold.

Row 6-10 (Metrics):

**A6:** `System Uptime (7d)`
**B6:** `=Metrics!B4`
**C6:** `=IF(Metrics!B4>=0.95,"✅ Healthy","⚠️ Warning")`

**A7:** `Success Rate (24h)`
**B7:** `=Metrics!B3`
**C7:** `=IF(Metrics!B3>=0.90,"✅ Good","❌ Poor")`

**A8:** `Avg Response Time`
**B8:** `=Metrics!B5`
**C8:** `=IF(VALUE(LEFT(Metrics!B5,FIND(" ",Metrics!B5)-1))<2000,"✅ Fast","⚠️ Slow")`

**A9:** `Active Errors (24h)`
**B9:** `=Metrics!B6`
**C9:** `=IF(Metrics!B6=0,"✅ None",Metrics!B6&" errors")`

**A10:** `Critical Errors (7d)`
**B10:** `=Metrics!B7`
**C10:** `=IF(Metrics!B7=0,"✅ None","🔴 "&Metrics!B7)`

**Format columns:**
- Column B: Align right
- Column C: Align center

**Add borders:**
- Select A5:C10
- Menu: Borders → All borders

---

#### Section 2: Recent Activity (Rows 13-21)

**A13:** `Recent Activity (Last 10 Events)`
Make bold.

**A14:** Header row
- A14: `Time`
- B14: `Workflow`
- C14: `Action`
- D14: `Result`
- E14: `BookingID`

Make row 14 bold.

**A15 (Formula for recent activity):**

We'll use a QUERY to show last 10 activities:

Click on A15 and paste:

```
=QUERY('Activity Log'!A:E,"SELECT A, B, C, D, E WHERE A is not null ORDER BY A DESC LIMIT 10",1)
```

**What it does:** Pulls last 10 activity log entries, sorted by time (newest first)

**Note:** This will auto-populate rows 15-24 with data. If no data yet, it will show nothing (that's normal).

---

#### Section 3: Recent Errors (Rows 23-31)

**A23:** `Recent Errors (High/Medium Severity)`
Make bold.

**A24:** Header row
- A24: `Time`
- B24: `Workflow`
- C24: `Severity`
- D24: `Error Message`

Make row 24 bold.

**A25 (Formula for recent errors):**

Click on A25 and paste:

```
=QUERY('Error Log'!A:F,"SELECT A, B, D, F WHERE (D = 'HIGH' or D = 'MEDIUM') AND A is not null ORDER BY A DESC LIMIT 10",1)
```

**What it does:** Shows last 10 HIGH or MEDIUM severity errors

---

#### Section 4: Booking Statistics Today (Rows 33-40)

**A33:** `Booking Statistics (Today)`
Make bold.

**A34:** `Metric`
**B34:** `Count`
Make row 34 bold.

**A35:** `Bookings Today`
**B35:**
```
=COUNTIFS('Activity Log'!C:C,"book",'Activity Log'!D:D,"booked",'Activity Log'!A:A,">="&INT(NOW()))
```

**A36:** `Cancellations Today`
**B36:**
```
=COUNTIFS('Activity Log'!C:C,"cancel",'Activity Log'!D:D,"cancelled",'Activity Log'!A:A,">="&INT(NOW()))
```

**A37:** `Reschedules Today`
**B37:**
```
=COUNTIFS('Activity Log'!C:C,"reschedule",'Activity Log'!D:D,"rescheduled",'Activity Log'!A:A,">="&INT(NOW()))
```

**A38:** `Failed Attempts Today`
**B38:**
```
=COUNTIFS('Activity Log'!D:D,"error",'Activity Log'!A:A,">="&INT(NOW()))
```

**A39:** `No Slots Available`
**B39:**
```
=COUNTIFS('Activity Log'!D:D,"no_free_slot",'Activity Log'!A:A,">="&INT(NOW()))
```

**Add borders:**
- Select A34:B39
- Add all borders

---

### Part C: Create Charts (Optional but Recommended)

#### Chart 1: System Health Over Time

1. **Go to "System Health Log" tab**
2. **Select data range:** A1:C100 (or more if you expect more data)
3. **Menu:** Insert → Chart
4. **Chart type:** Line chart
5. **Customize:**
   - X-axis: Timestamp (Column A)
   - Y-axis: Health_Percentage (Column C)
   - Title: "System Health Over Time"
   - Legend position: Bottom
6. **Move chart to Dashboard tab:**
   - Click chart → Three dots menu → Move to sheet
   - Choose: Dashboard
   - Position: Starting at cell F5

---

#### Chart 2: Error Distribution by Severity

1. **Go to "Error Log" tab**
2. **Create a helper calculation first** (we need to count by severity)

Actually, let's use a simpler approach - create a summary table first:

**On Metrics tab, add:**

Row 10: `Error Distribution`
Row 11: Headers: A11: `Severity` | B11: `Count`

Row 12-14:
- A12: `HIGH` | B12: `=COUNTIF('Error Log'!D:D,"HIGH")`
- A13: `MEDIUM` | B13: `=COUNTIF('Error Log'!D:D,"MEDIUM")`
- A14: `LOW` | B14: `=COUNTIF('Error Log'!D:D,"LOW")`

3. **Now create chart:**
   - Select A11:B14
   - Insert → Chart
   - Chart type: Pie chart
   - Title: "Errors by Severity"
   - Move to Dashboard at position F23

---

#### Chart 3: Daily Booking Activity

This is more advanced. For now, skip this or add later.

---

### Part D: Add Conditional Formatting to Dashboard (2 minutes)

**Format Status column (C6:C10) with colors:**

1. Select C6:C10
2. Format → Conditional formatting

**Rule 1:**
- Format cells if: Text contains: `✅`
- Background: Light green (#D9EAD3)

**Rule 2:**
- Format cells if: Text contains: `⚠️`
- Background: Light yellow (#FFF2CC)

**Rule 3:**
- Format cells if: Text contains: `❌` or `🔴`
- Background: Light red (#F4CCCC)

---

### Part E: Set Up Auto-Refresh (Optional - 2 minutes)

**Method 1: Manual Refresh Button**

1. **Insert a drawing:**
   - Menu: Insert → Drawing
   - Create a rectangle with text "🔄 Refresh Now"
   - Click "Save and Close"
   - Position it at top of Dashboard (near B2)

2. **Assign script:**
   - Right-click the drawing
   - Click "Assign script"
   - Type: `refreshData`

3. **Create the script:**
   - Menu: Extensions → Apps Script
   - Delete existing code
   - Paste:

```javascript
function refreshData() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var dashboard = ss.getSheetByName('Dashboard');

  // Update timestamp
  dashboard.getRange('B2').setValue(new Date());

  // Force recalculation
  SpreadsheetApp.flush();

  // Show confirmation
  SpreadsheetApp.getUi().alert('Dashboard refreshed!');
}
```

4. **Save script:** File → Save (name it "Monitoring Scripts")
5. **Close Apps Script tab**

Now clicking the button will refresh all data!

---

**Method 2: Auto-refresh on Edit (Simpler)**

The NOW() function in B2 already causes auto-refresh every minute. No action needed!

---

## Verification Checklist

After completing this phase:

- [ ] Metrics tab has all 5 formulas working (B3:B7)
- [ ] Dashboard shows System Health Status with ✅/⚠️/❌ indicators
- [ ] Recent Activity section pulls data from Activity Log
- [ ] Recent Errors section filters HIGH/MEDIUM errors
- [ ] Booking Statistics shows today's counts
- [ ] (Optional) Charts created and positioned
- [ ] (Optional) Refresh button working
- [ ] All formulas showing correct results (or "No data" if no data yet)

---

## Testing Formulas

Since you don't have data yet, test formulas by:

### Add Test Data to Activity Log:

Manually add a row in Activity Log (Row 2):

```
Timestamp: =NOW()
Workflow: Test Workflow
Action: book
Result: booked
BookingID: test123
Phone: +12145551234
Email: test@example.com
Duration_ms: 1500
```

Then check:
- Metrics!B3 should show a percentage
- Dashboard should show the test data in Recent Activity
- Booking Statistics should show "1" for Bookings Today

### Add Test Data to Error Log:

Add row in Error Log (Row 2):

```
Timestamp: =NOW()
Workflow: Test Workflow
Node: Test Node
Severity: HIGH
Error_Type: TestError
Error_Message: This is a test error
Execution_ID: test_exec_123
Input_Data: {}
Alert_Sent: EMAIL
```

Then check:
- Metrics!B6 should show "1"
- Metrics!B7 should show "1"
- Dashboard Recent Errors should show the test error

### Add Test Data to System Health Log:

Add row in System Health Log (Row 2):

```
Timestamp: =NOW()
Severity: OK
Health_Percentage: 100%
Healthy_Count: 7
Unhealthy_Count: 0
Critical_Failures: []
Warnings: []
Alert_Sent: NONE
```

Then check:
- Metrics!B4 should show 100%
- Dashboard System Health should show ✅

**After testing, delete the test rows!**

---

## Formula Reference

Quick reference of all formulas used:

| Location | Formula Purpose | Time Range |
|----------|----------------|------------|
| Metrics!B3 | Success rate | Last 24 hours |
| Metrics!B4 | System uptime | Last 7 days |
| Metrics!B5 | Avg response time | Last 24 hours |
| Metrics!B6 | Error count | Last 24 hours |
| Metrics!B7 | Critical errors | Last 7 days |
| Dashboard A15 | Recent activity | Last 10 events |
| Dashboard A25 | Recent errors | Last 10 errors |
| Dashboard B35-B39 | Today's stats | Today only |

---

## Common Formula Errors

### #REF! Error
- **Cause:** Sheet name doesn't match (check spelling)
- **Fix:** Update sheet name in formula

### #VALUE! Error
- **Cause:** No data in columns yet
- **Fix:** Normal - will resolve when data flows in

### #DIV/0! Error
- **Cause:** Dividing by zero (no data)
- **Fix:** IFERROR handles this - check formula

### Formula shows as text
- **Cause:** Started with space or apostrophe
- **Fix:** Delete cell, re-enter without space

---

## Next Steps

After completing this phase:

1. ✅ Phase 3 complete - Formulas configured
2. ➡️ Proceed to Phase 4: Import System Health Monitor to n8n
3. ➡️ Then workflows will start populating data!

---

## Completion Criteria

Phase 3 is complete when:

- [x] All Metrics formulas working (showing 0 or "No data" is fine)
- [x] Dashboard sections structured properly
- [x] Status indicators showing (even if no real data)
- [x] Test data validates formulas work correctly
- [x] Charts created (optional)
- [x] Refresh mechanism in place

---

## Time Spent

- **Estimated:** 15 minutes
- **Actual:** _____ minutes (fill in after completion)

---

## Phase 3 Status: ⏳ READY TO EXECUTE

**Next Phase:** Phase 4 - Import System Health Monitor to n8n

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
**Phase:** 3 of 7
