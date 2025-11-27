# Smart Reminder System - Google Sheet Setup

**Sheet ID:** `1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc`

---

## Create New Tab: "Reminder_Log"

1. Open Google Sheet: https://docs.google.com/spreadsheets/d/1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc/edit
2. Click "+" at bottom to add new tab
3. Rename tab to: **Reminder_Log**
4. Add the following header row (Row 1):

### **Column Headers:**

| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| bookingId | phone | name | appointmentTime | reminderType | sentAt | status |

---

## Column Descriptions:

- **bookingId** - Google Calendar event ID (unique identifier)
- **phone** - Customer phone number (E.164 format: +12145551234)
- **name** - Customer name from appointment
- **appointmentTime** - ISO timestamp of appointment (2025-11-28T14:00:00-06:00)
- **reminderType** - Either "24h" or "4h"
- **sentAt** - ISO timestamp when reminder was sent
- **status** - "sent", "delivered", "failed", or "pending"

---

## Example Data:

| bookingId | phone | name | appointmentTime | reminderType | sentAt | status |
|-----------|-------|------|-----------------|--------------|--------|--------|
| abc123xyz | +12145551234 | John Doe | 2025-11-28T14:00:00-06:00 | 24h | 2025-11-27T09:00:15-06:00 | sent |
| abc123xyz | +12145551234 | John Doe | 2025-11-28T14:00:00-06:00 | 4h | 2025-11-28T10:00:10-06:00 | sent |
| def456uvw | +12145559876 | Jane Smith | 2025-11-28T16:00:00-06:00 | 24h | 2025-11-27T09:00:20-06:00 | sent |

---

## Important Notes:

1. **Each appointment gets 2 rows** (one for 24h reminder, one for 4h reminder)
2. **bookingId is the same** for both reminders of same appointment
3. **Don't delete rows** - workflows check this log to prevent duplicate sends
4. **Status updates** happen automatically when Twilio confirms delivery

---

## Setup Checklist:

- [ ] Opened Google Sheet
- [ ] Created new tab named "Reminder_Log"
- [ ] Added 7 column headers in Row 1
- [ ] Formatted headers (bold, freeze row 1)
- [ ] Sheet is ready for workflow integration

---

**Next:** Import n8n workflows that will populate this sheet automatically
