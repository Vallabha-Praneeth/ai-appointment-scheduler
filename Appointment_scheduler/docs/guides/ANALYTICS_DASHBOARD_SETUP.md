# Analytics Dashboard - Google Sheets Setup Guide

**Purpose:** Create a comprehensive analytics dashboard for appointment data

**Time:** 30-40 minutes

**What you'll build:**
- Automated data collection from Google Calendar
- Real-time metrics dashboard
- Trend analysis charts
- Service breakdown
- Revenue tracking

---

## Step 1: Create Google Sheets Tabs

**Open your Google Sheet:**
```
https://docs.google.com/spreadsheets/d/1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc/edit
```

**Create 2 new tabs:**

### Tab 1: "Analytics_Raw_Data"

**Column Headers (Row 1):**

| A | B | C | D | E | F | G | H | I | J | K | L | M | N |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| bookingId | date | time | dayOfWeek | hour | month | customerName | phone | email | serviceType | durationMinutes | status | revenue | summary |

**Format:**
- Bold header row
- Freeze row 1
- This tab will be auto-populated by n8n workflow

---

### Tab 2: "Dashboard"

This will contain formulas and charts. Set up in sections:

---

## Step 2: Dashboard Layout (Tab: "Dashboard")

### Section A: Key Metrics (Top of sheet)

**Cell A1:** "📊 APPOINTMENT ANALYTICS DASHBOARD"
- Make it large, bold, centered across A1:F1

**Row 3 - Metric Cards:**

| Cell | Label | Formula |
|------|-------|---------|
| A3 | "Total Appointments (30 days)" | |
| A4 | Value | `=COUNTA(Analytics_Raw_Data!A2:A)` |
| | | |
| C3 | "Completed Appointments" | |
| C4 | Value | `=COUNTIF(Analytics_Raw_Data!L2:L,"Completed")` |
| | | |
| E3 | "No-Show Rate" | |
| E4 | Value | `=IF(C4=0,"N/A",TEXT((COUNTIF(Analytics_Raw_Data!L2:L,"No-Show")/C4),"0.0%"))` |

**Note:** For no-shows, you'll need to manually update status in Analytics_Raw_Data when someone doesn't show up.

**Row 6 - Revenue Metrics:**

| Cell | Label | Formula |
|------|-------|---------|
| A6 | "Total Revenue (30 days)" | |
| A7 | Value | `=TEXT(SUM(Analytics_Raw_Data!M2:M),"$#,##0")` |
| | | |
| C6 | "Average Revenue per Appointment" | |
| C7 | Value | `=TEXT(AVERAGE(Analytics_Raw_Data!M2:M),"$#,##0")` |
| | | |
| E6 | "This Month Revenue" | |
| E7 | Value | `=TEXT(SUMIF(Analytics_Raw_Data!F2:F,TEXT(TODAY(),"MMMM YYYY"),Analytics_Raw_Data!M2:M),"$#,##0")` |

---

### Section B: Service Breakdown (Row 10+)

**Cell A10:** "SERVICE TYPE BREAKDOWN"

**Table starting at A11:**

| A | B | C |
|---|---|---|
| Service Type | Count | Revenue |
| Consultation | `=COUNTIF(Analytics_Raw_Data!J2:J,"Consultation")` | `=SUMIF(Analytics_Raw_Data!J2:J,"Consultation",Analytics_Raw_Data!M2:M)` |
| Maintenance | `=COUNTIF(Analytics_Raw_Data!J2:J,"Maintenance")` | `=SUMIF(Analytics_Raw_Data!J2:J,"Maintenance",Analytics_Raw_Data!M2:M)` |
| Support | `=COUNTIF(Analytics_Raw_Data!J2:J,"Support")` | `=SUMIF(Analytics_Raw_Data!J2:J,"Support",Analytics_Raw_Data!M2:M)` |
| Onsite | `=COUNTIF(Analytics_Raw_Data!J2:J,"Onsite")` | `=SUMIF(Analytics_Raw_Data!J2:J,"Onsite",Analytics_Raw_Data!M2:M)` |
| Emergency | `=COUNTIF(Analytics_Raw_Data!J2:J,"Emergency")` | `=SUMIF(Analytics_Raw_Data!J2:J,"Emergency",Analytics_Raw_Data!M2:M)` |
| Group Booking | `=COUNTIF(Analytics_Raw_Data!J2:J,"Group Booking")` | `=SUMIF(Analytics_Raw_Data!J2:J,"Group Booking",Analytics_Raw_Data!M2:M)` |
| Standard | `=COUNTIF(Analytics_Raw_Data!J2:J,"Standard")` | `=SUMIF(Analytics_Raw_Data!J2:J,"Standard",Analytics_Raw_Data!M2:M)` |

---

### Section C: Peak Hours Analysis (Row 20+)

**Cell A20:** "PEAK HOURS ANALYSIS"

**Table starting at A21:**

| A | B |
|---|---|
| Hour | Appointments |
| 9 AM | `=COUNTIF(Analytics_Raw_Data!E2:E,9)` |
| 10 AM | `=COUNTIF(Analytics_Raw_Data!E2:E,10)` |
| 11 AM | `=COUNTIF(Analytics_Raw_Data!E2:E,11)` |
| 12 PM | `=COUNTIF(Analytics_Raw_Data!E2:E,12)` |
| 1 PM | `=COUNTIF(Analytics_Raw_Data!E2:E,13)` |
| 2 PM | `=COUNTIF(Analytics_Raw_Data!E2:E,14)` |
| 3 PM | `=COUNTIF(Analytics_Raw_Data!E2:E,15)` |
| 4 PM | `=COUNTIF(Analytics_Raw_Data!E2:E,16)` |
| 5 PM | `=COUNTIF(Analytics_Raw_Data!E2:E,17)` |
| 6 PM | `=COUNTIF(Analytics_Raw_Data!E2:E,18)` |

---

### Section D: Day of Week Analysis (Row 33+)

**Cell A33:** "BUSIEST DAYS OF WEEK"

**Table starting at A34:**

| A | B |
|---|---|
| Day | Appointments |
| Monday | `=COUNTIF(Analytics_Raw_Data!D2:D,"Monday")` |
| Tuesday | `=COUNTIF(Analytics_Raw_Data!D2:D,"Tuesday")` |
| Wednesday | `=COUNTIF(Analytics_Raw_Data!D2:D,"Wednesday")` |
| Thursday | `=COUNTIF(Analytics_Raw_Data!D2:D,"Thursday")` |
| Friday | `=COUNTIF(Analytics_Raw_Data!D2:D,"Friday")` |
| Saturday | `=COUNTIF(Analytics_Raw_Data!D2:D,"Saturday")` |
| Sunday | `=COUNTIF(Analytics_Raw_Data!D2:D,"Sunday")` |

---

## Step 3: Create Charts

### Chart 1: Service Type Pie Chart

1. **Select data:** A11:B18 (Service Type Breakdown table)
2. **Insert → Chart**
3. **Chart type:** Pie chart
4. **Title:** "Appointments by Service Type"
5. **Position:** Next to Service Breakdown table (Column D)

### Chart 2: Peak Hours Bar Chart

1. **Select data:** A21:B31 (Peak Hours table)
2. **Insert → Chart**
3. **Chart type:** Column chart
4. **Title:** "Appointments by Hour"
5. **Position:** Next to Peak Hours table

### Chart 3: Day of Week Bar Chart

1. **Select data:** A34:B40 (Day of Week table)
2. **Insert → Chart**
3. **Chart type:** Bar chart (horizontal)
4. **Title:** "Appointments by Day of Week"
5. **Position:** Next to Day of Week table

### Chart 4: Daily Trend Line Chart (Advanced)

**Create helper tab first:** "Daily_Aggregation"

**In Daily_Aggregation tab:**

| A | B |
|---|---|
| Date | Count |
| Formula in A2 | `=UNIQUE(Analytics_Raw_Data!B2:B)` |
| Formula in B2 | `=COUNTIF(Analytics_Raw_Data!$B$2:$B,A2)` |

Then create line chart from this data.

---

## Step 4: Formatting

### Make it look professional:

**Metric cards (Rows 3-7):**
- Background color: Light blue
- Border: All borders
- Center align numbers
- Large font for values (18pt)

**Section headers (A10, A20, A33):**
- Background: Dark blue
- Text color: White
- Bold, 12pt

**Tables:**
- Header row: Bold, background color
- Alternate row colors for readability
- Right-align numbers

**Charts:**
- Consistent color scheme
- Clear titles
- Data labels on

---

## Step 5: Import n8n Workflow

1. **Log in to n8n:**
   ```
   https://polarmedia.app.n8n.cloud
   ```

2. **Import workflow:**
   - Workflows → Add Workflow → Import from File
   - Select: `Analytics_Data_Collector.json`

3. **Configure credentials:**
   - Google Calendar OAuth2
   - Google Sheets OAuth2

4. **Verify sheet ID and names:**
   - Document ID: `1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc`
   - Sheet name: `Analytics_Raw_Data`

5. **Test the workflow:**
   - Click "Execute Workflow"
   - Check Analytics_Raw_Data tab fills with data
   - Check Dashboard formulas calculate correctly

6. **Activate:**
   - Toggle "Active" to ON
   - Runs daily at midnight automatically

---

## Step 6: Manual No-Show Tracking (Optional Enhancement)

Since we can't automatically detect no-shows, you can:

**Option 1: Manual update**
- After each day, review completed appointments
- Change status from "Completed" to "No-Show" in Analytics_Raw_Data tab
- Dashboard no-show rate will update automatically

**Option 2: Add status column to booking workflow**
- Modify booking workflow to track attendance
- Add a webhook endpoint to mark no-shows
- Auto-update status

---

## Maintenance

### Daily
- Workflow runs automatically at midnight
- No action needed

### Weekly
- Review no-show appointments
- Update statuses if needed
- Check for any data anomalies

### Monthly
- Analyze trends
- Adjust business hours based on peak times
- Review service mix
- Calculate actual ROI

---

## Expected Results

**After first run:**
- Analytics_Raw_Data: Filled with last 30 days of appointments
- Dashboard: All metrics calculated
- Charts: Visualizations displayed

**Daily updates:**
- Fresh data every midnight
- Rolling 30-day window
- Automatic calculations

**Key insights you'll see:**
- Which services are most popular
- Peak booking hours
- Busiest days
- Revenue trends
- No-show patterns (if tracked)

---

## Troubleshooting

**Issue: No data in Analytics_Raw_Data**
- Check n8n workflow executed successfully
- Verify Google Calendar has appointments in last 30 days
- Check credentials configured

**Issue: Formulas showing #REF!**
- Verify sheet names are exact: "Analytics_Raw_Data"
- Check column headers match exactly

**Issue: Charts not updating**
- Right-click chart → Advanced Edit → Update data range
- Ensure data range includes new rows

---

## Advanced Features (Optional)

### 1. Month-over-Month Comparison

Add a pivot table to compare months:
- Data → Pivot table
- Rows: Month
- Values: Count of bookingId, Sum of revenue

### 2. Customer Retention

Track repeat customers:
```
=COUNTIF(Analytics_Raw_Data!G:G,G2)>1
```

### 3. Average Duration by Service

```
=AVERAGEIF(Analytics_Raw_Data!J:J,"Consultation",Analytics_Raw_Data!K:K)
```

### 4. Conditional Formatting

Apply color scales to:
- Revenue column (green = high, red = low)
- No-show rates (red = high, green = low)

---

## Summary

**You've built:**
- ✅ Automated data collection
- ✅ Real-time analytics dashboard
- ✅ Visual charts
- ✅ Key business metrics
- ✅ Trend analysis

**Benefits:**
- 📊 Data-driven decisions
- 📈 Track growth over time
- 🎯 Optimize scheduling
- 💰 Revenue insights
- ⏰ Identify peak hours

**Maintenance:** Minimal (runs automatically)

---

**Created:** November 27, 2025
**Version:** 1.0
**Status:** Ready to deploy
