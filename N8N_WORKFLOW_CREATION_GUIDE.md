# Step-by-Step Guide: Creating a New n8n Workflow

Based on the appointment scheduling system architecture.

## Prerequisites

- Access to n8n instance: `https://polarmedia.app.n8n.cloud`
- Understanding of the webhook-based event-driven architecture
- Required integrations: Vapi (voice AI), Google Calendar, Twilio (SMS)

## Step 1: Design the Workflow Logic

**Define the workflow purpose:**
- What user action triggers this workflow? (book, cancel, reschedule, lookup, recover)
- What business logic is needed? (availability check, validation, state tracking)
- What external services are involved? (Calendar, SMS, etc.)
- What response format does Vapi expect?

## Step 2: Set Up the Webhook Trigger

**Add Webhook node as the entry point:**
```
Webhook Trigger → HTTP POST
Path pattern: /webhook/vapi/{operation}
Example: /webhook/vapi/call, /webhook/vapi/cancel
```

**Expected incoming data from Vapi:**
```json
{
  "title": "string",
  "startIso": "2025-11-10T10:00:00-06:00",
  "endIso": "2025-11-10T11:00:00-06:00",
  "timezone": "America/Chicago",
  "name": "string",
  "phone": "+12145551234",
  "service_type": "consultation|support|maintenance|onsite|emergency",
  "email": "user@example.com",
  "bookingId": "optional-for-cancellations",
  "stage": "new|confirm|reschedule|cancel",
  "carry": {}
}
```

## Step 3: Add Security/Validation (Production)

**First Code node after webhook:**
```javascript
// Validate webhook secret (production requirement)
const receivedSecret = $json.headers['x-webhook-secret'];
const expectedSecret = $env.WEBHOOK_SECRET;

if (receivedSecret !== expectedSecret) {
  return {
    error: 'Unauthorized',
    statusCode: 401
  };
}

// Input validation
const required = ['title', 'startIso', 'endIso', 'timezone', 'phone'];
const missing = required.filter(field => !$json[field]);

if (missing.length > 0) {
  return {
    result: 'error',
    reason: `Missing required fields: ${missing.join(', ')}`
  };
}

return $json;
```

## Step 4: Implement Business Logic

**For appointment booking workflows:**

### A. Check Google Calendar Availability

**Code node - Availability Check:**
```javascript
// Extract request parameters
const startIso = $json.startIso;
const endIso = $json.endIso;
const timezone = $json.timezone || 'America/Chicago';

// Business hours validation
const OPEN_HOUR = 10;  // 10:00 AM
const CLOSE_HOUR = 18; // 6:00 PM

const startTime = new Date(startIso);
const endTime = new Date(endIso);
const startHour = startTime.getHours();
const endHour = endTime.getHours();

// Check business hours
if (startHour < OPEN_HOUR || endHour > CLOSE_HOUR) {
  return {
    available: false,
    reason: `Requested time outside business hours (${OPEN_HOUR}:00-${CLOSE_HOUR}:00)`
  };
}

return {
  available: true,
  startIso,
  endIso,
  timezone
};
```

**Google Calendar node - List Events:**
```
Calendar ID: quantumops9@gmail.com
Time Min: {{ $json.startIso }}
Time Max: {{ $json.endIso }}
Max Results: 50
```

**Code node - Check Conflicts:**
```javascript
// Get calendar events from previous node
const events = $items('Google Calendar').map(item => item.json);

// Filter out placeholder/test appointments
const realEvents = events.filter(event => {
  const summary = event.summary || '';
  return !summary.includes('[TEST]') && !summary.includes('[PLACEHOLDER]');
});

// Check for conflicts
if (realEvents.length > 0) {
  // Find alternative slots (next 3 available slots)
  const alternatives = findNextAvailableSlots(3); // Implement this logic

  return {
    available: false,
    reason: 'Time slot already booked',
    alternatives: alternatives
  };
}

return {
  available: true
};
```

### B. Create Calendar Event (if available)

**Google Calendar node - Create Event:**
```
Calendar ID: quantumops9@gmail.com
Event Name: {{ $json.title }}
Start: {{ $json.startIso }}
End: {{ $json.endIso }}
Description: Service: {{ $json.service_type }}
              Name: {{ $json.name }}
              Phone: {{ $json.phone }}
              Email: {{ $json.email }}
Attendees: {{ $json.email }}
```

### C. Send SMS Confirmation

**Twilio node - Send SMS:**
```
From: +14694365607
To: {{ $json.phone }}
Message: "Appointment confirmed for {{ $json.name }}
         Date/Time: {{ formatDateTime($json.startIso) }}
         Service: {{ $json.service_type }}
         Booking ID: {{ $json.bookingId }}

         To cancel or reschedule, call us or text CANCEL."
```

## Step 5: Format Response for Vapi

**Final Code node - Response Formatter:**
```javascript
// Success response
if ($json.result === 'booked') {
  return {
    result: 'booked',
    slot: {
      start: $json.startIso,
      end: $json.endIso,
      timezone: $json.timezone
    },
    title: $json.title,
    bookingId: $json.calendarEventId,
    calendarUrl: $json.htmlLink,
    message: `Your appointment is confirmed for ${formatDateTime($json.startIso)}`
  };
}

// No availability response
if ($json.result === 'no_free_slot') {
  return {
    result: 'no_free_slot',
    reason: $json.reason,
    alternatives: $json.alternatives || []
  };
}

// Need more info
if ($json.result === 'need_more_info') {
  return {
    result: 'need_more_info',
    reason: 'Please provide all required information',
    missing: $json.missingFields
  };
}

// Error response
return {
  result: 'error',
  reason: $json.error || 'An unexpected error occurred'
};
```

## Step 6: Add Error Handling

**For each critical node:**
1. Enable "Continue on Fail" setting
2. Add error handling branch
3. Log errors for monitoring

**Error handler Code node:**
```javascript
console.log('Error in workflow:', $json.error);

return {
  result: 'error',
  reason: 'System temporarily unavailable. Please try again.',
  technicalDetails: $json.error // Don't expose to end user
};
```

## Step 7: Create Sub-Workflows (Optional)

**For complex operations, create separate workflows:**

**Example: Cancel Appointment Sub-Workflow**
```
File: vapi_cancel.json

Flow:
1. Webhook Trigger (/webhook/vapi/cancel)
2. Validate bookingId
3. Lookup appointment in Calendar
4. Confirm with user (via Vapi dialog)
5. Delete Calendar event
6. Send SMS confirmation
7. Return success response
```

**Call sub-workflow using "Execute Workflow" node:**
```
Workflow: vapi_cancel
Data to pass: {{ $json }}
```

## Step 8: Export and Version Control

**Export workflow:**
1. Open workflow in n8n UI
2. Click "..." menu → Download
3. Save as: `[Workflow Name]_v.X.X.X (Prod).json`

**Naming convention:**
- Version numbers: `v.0.0.3`
- Environment: `(Prod)` or `(Test)` or `(If_Confirm_yes)`
- Operation: `vapi_{operation}.json`

**Example filenames:**
- `Appointment Scheduling AI_v.0.0.3 (Prod).json`
- `vapi_lookup.json`
- `vapi_cancel.json`

## Step 9: Import and Activate

**Import to n8n:**
1. Log into `https://polarmedia.app.n8n.cloud`
2. Click "Import from File"
3. Upload JSON file
4. Configure credentials (Google, Twilio)
5. Test with sample data
6. Activate workflow

## Step 10: Test the Workflow

**Manual webhook testing:**
```bash
curl -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/call \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: YOUR_SECRET" \
  -d '{
    "title": "Test Appointment",
    "startIso": "2025-11-10T10:00:00-06:00",
    "endIso": "2025-11-10T11:00:00-06:00",
    "timezone": "America/Chicago",
    "name": "Test User",
    "phone": "+12145551234",
    "service_type": "consultation",
    "email": "test@example.com"
  }'
```

**Check execution logs:**
1. Go to n8n UI → Executions
2. Find your test execution
3. Verify each node output
4. Check for errors

## Configuration Reference

**Environment variables to externalize:**
```javascript
// In Code nodes, use:
const calendarId = $env.GOOGLE_CALENDAR_ID || 'quantumops9@gmail.com';
const twilioPhone = $env.TWILIO_PHONE_NUMBER || '+14694365607';
const webhookSecret = $env.WEBHOOK_SECRET;
const openHour = parseInt($env.BUSINESS_OPEN_HOUR || '10');
const closeHour = parseInt($env.BUSINESS_CLOSE_HOUR || '18');
```

**Service durations reference:**
```javascript
const SERVICE_DURATIONS = {
  'support': { min: 30, max: 60 },
  'maintenance': { min: 45, max: 90 },
  'consultation': { min: 60, max: 90 },
  'onsite': { min: 60, max: 120 },
  'emergency': { min: 0, max: 999 } // Variable
};
```

## Production Readiness Checklist

Before deploying to production:

- [ ] Webhook authentication implemented
- [ ] Input validation on all webhook data
- [ ] Error handling with "Continue on Fail" enabled
- [ ] Environment variables for all configuration
- [ ] Logging for debugging and monitoring
- [ ] Test coverage for happy path and error cases
- [ ] SMS notifications working
- [ ] Calendar integration tested
- [ ] Proper versioning and backup of workflow JSON
- [ ] Documentation updated

## Common Workflow Patterns

**Pattern 1: Conditional branching**
```
IF node → Check condition
  True branch → Action A
  False branch → Action B
Merge → Continue
```

**Pattern 2: State tracking**
```javascript
// Carry state across conversation turns
return {
  ....$json,
  stage: 'confirm',
  carry: {
    pendingAction: 'cancel',
    bookingId: $json.bookingId,
    confirmationRequired: true
  }
};
```

**Pattern 3: Pagination handling**
```javascript
// For large calendar result sets
let allEvents = [];
let pageToken = null;

do {
  const response = await fetchCalendarEvents(pageToken);
  allEvents = allEvents.concat(response.events);
  pageToken = response.nextPageToken;
} while (pageToken);

return { events: allEvents };
```
