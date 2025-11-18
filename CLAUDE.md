# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered appointment scheduling system built on **n8n** workflow automation platform. It uses **Vapi** for voice AI interactions, integrates with **Google Calendar** for scheduling, and **Twilio** for SMS reminders. The AI assistant (named "Alex") is powered by **OpenAI's GPT-4o**.

## Architecture

**Webhook-based event-driven system:**

1. **Vapi voice assistant** handles phone interactions with users
2. User actions (book, cancel, reschedule, lookup) trigger **webhook calls** to n8n workflows
3. **n8n workflows** execute business logic:
   - Check Google Calendar availability
   - Create/update/delete calendar events
   - Send SMS confirmations via Twilio
4. **Response flows back** to Vapi, which communicates results to the user

**Key integration points:**
- n8n instance: `https://polarmedia.app.n8n.cloud`
- Google Calendar ID: `quantumops9@gmail.com`
- Twilio phone number: `+14694365607`
- Business hours: 10:00-18:00 in configured timezone (default: America/Chicago)

## Working with n8n Workflows

**Workflow files are JSON exports** stored in `Appointment_scheduler/` directory. There's no traditional build process.

**To import/update workflows:**
1. Log into the n8n instance at `https://polarmedia.app.n8n.cloud`
2. Import the JSON file via n8n UI
3. Activate the workflow

**Main workflow:** `Appointment Scheduling AI_v.0.0.3.json`

**Sub-workflows for specific operations:**
- `Appointment Scheduling AI_v.0.0.3_vapi_lookup.json` - Find existing appointments
- `Appointment Scheduling AI_v.0.0.3_vapi_cancel-2.json` - Cancel appointments
- `Appointment Scheduling AI_v.0.0.3_vapi_reschedule-2.json` - Reschedule appointments
- `Appointment Scheduling AI_v.0.0.3_vapi_recovery.json` - Handle disconnected/incomplete calls

**Additional workflows:**
- `Appointment Scheduling AI v.0.0.3 (Check Availability).json` - Check calendar availability for requested time slots
- `Appointment Scheduling AI v.0.0.3 (Group Booking).json` - Handle group/multi-person bookings
- `Appointment Scheduling AI_v.0.0.3 (If_Confrim_yes).json` - Confirmation flow when user confirms action
- `Appointment Scheduling AI_v.0.0.3(If_Confirm_No).json` - Confirmation flow when user declines action
- `Appointment_scheduler_v0.0.3_RDC – Signed Link Resolver (JWT verify → 302 redirect).json` - JWT token verification and secure redirect handling

**Webhook endpoints pattern:** `https://polarmedia.app.n8n.cloud/webhook/vapi/{operation}`

## Vapi Configuration

**Configuration files** (referenced but not included in repo):
- `vapi-assistant.json` - Defines the AI assistant's persona, voice (Elliot), system prompts, and conversation policies
- `vapi-tools.json` - Defines the function tools (schemas) that the assistant can call

**Key tools available to the assistant:**
- `function_tool` - Book new appointments
- `lookup_tool` - Find appointments by phone/email
- `cancel_tool` - Cancel appointments (requires bookingId + confirmation)
- `reschedule_tool` - Move appointments to new time slots
- `recover_tool` - Handle call disconnects/abandonment
- `send_text_tool` - Send SMS to user

**Dialog policies enforced by the assistant:**
- Lookup → Confirm → Cancel (requires user confirmation)
- Lookup → Confirm → Reschedule (with new time validation)
- Must collect all required fields before calling booking tool
- Never read long booking IDs to users; use human-friendly date/time summaries

## Business Logic & Validation

**Availability checking logic** (in Code nodes):
1. Check if requested slot overlaps with existing calendar events
2. Validate slot is within business hours (10:00-18:00 local time)
3. Filter out placeholder/self-created test appointments
4. Return `available: true/false` with reason codes

**Business hours enforcement:**
- Open: 10:00 local time
- Close: 18:00 local time
- Timezone-aware using IANA identifiers (e.g., "America/Chicago")

**ISO datetime handling:**
- All times passed between Vapi and n8n use ISO 8601 format
- Default timezone: America/Chicago (configurable per request)

**State tracking across conversation turns:**
- `phone` - Caller phone number
- `bookingId` - Google Calendar event ID
- `stage` - Current flow: "new" | "confirm" | "reschedule" | "cancel"
- `carry` - Pending booking details: {title, startIso, endIso, timezone}

**Phone normalization** (in lookup/cancel/recovery workflows):
- Extracts digits and generates multiple variants (full E.164, last 10 digits, last 7 digits)
- Supports US/CA (+1) and IN (+91) country codes
- Validates: minimum 7 digits, maximum 15 (E.164 spec)

**Lookup matching priority:**
1. Booking ID (calendar event ID or iCalUID)
2. Phone (full digits, then last 10 fallback)
3. Name (substring match in summary/description)

## Environment Variables & Secrets

**Critical configuration should be externalized** (currently hardcoded in workflows):

- `GOOGLE_CALENDAR_ID` - Currently: `quantumops9@gmail.com`
- `TWILIO_PHONE_NUMBER` - Currently: `+14694365607`
- `JWT_SECRET` - Used in JWT token verification in recovery workflow (HS256 algorithm, 15-min token TTL)
- `N8N_INSTANCE_URL` - Currently: `https://polarmedia.app.n8n.cloud`
- `WEBHOOK_SECRET` - For securing webhook endpoints (not yet implemented)
- `BUSINESS_OPEN_HOUR` - Currently: 10
- `BUSINESS_CLOSE_HOUR` - Currently: 18
- `TOKEN_TTL_SEC` - Currently: 900 (15 minutes)

**Security note:** Webhook endpoints currently have no authentication. Production deployment should add webhook secret verification in the first Code node after webhook trigger.

## Testing

**No automated test suite exists.** To test:

1. **Manual webhook testing:** Use curl/Postman to send requests to webhook endpoints
   ```bash
   curl -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/call \
     -H "Content-Type: application/json" \
     -d '{"title":"Test","startIso":"2025-11-10T10:00:00-06:00","endIso":"2025-11-10T11:00:00-06:00","timezone":"America/Chicago","name":"Test User","phone":"+12145551234","service_type":"consultation","email":"test@example.com"}'
   ```

2. **End-to-end testing:** Simulate phone calls through Vapi interface and verify:
   - Appointments created in Google Calendar
   - SMS confirmations sent via Twilio
   - Correct handling of conflicts and business hours

3. **Check workflow execution logs** in n8n UI to debug issues

## Code Conventions

**JavaScript in Code nodes:**
- Uses modern ES6+ syntax
- Accesses workflow data via `$json`, `$items()`, `$env`
- Business logic for availability, validation, and data transformation
- Uses `console.log()` for debugging (visible in n8n execution logs)

**Workflow naming:**
- Version numbers in filename: `v.0.0.3`
- Environment suffix: `(Prod)` or `(If_Confirm_yes)` for conditional flows
- Operation-specific workflows: `vapi_{operation}.json`

**Response format from workflows:**
```json
{
  "result": "booked|need_more_info|no_free_slot|error",
  "slot": {"start": "<ISO>", "end": "<ISO>", "timezone": "America/Chicago"},
  "title": "<str>",
  "bookingId": "<id>",
  "calendarUrl": "<url>",
  "alternatives": [{"start": "<ISO>", "end": "<ISO>"}],
  "reason": "<str>"
}
```

## Production Readiness Checklist

See `Project_Workflow.md` for detailed implementation instructions on:

1. **Configuration Management** - Move hardcoded values to environment variables
2. **Security** - Add webhook authentication, secure JWT secrets
3. **Error Handling** - Enable "Continue on Fail" and add error handling branches
4. **Input Validation** - Validate all webhook inputs in Code nodes
5. **Monitoring** - Add logging and external monitoring (Prometheus/Grafana)
6. **Testing** - Create automated test workflows using "Execute Workflow" nodes

## Service Types & Durations

- **Support:** 30-60 min
- **Maintenance:** 45-90 min
- **Consultation:** 60-90 min
- **Onsite:** 60-120 min
- **Emergency:** Variable (can be scheduled outside business hours)

## Sample Python Script

`appointment_manager.py` - A basic Python example demonstrating appointment cancellation logic. Not part of the production system; used for reference/prototyping.

## Vapi Message Format

**Incoming webhook payload from Vapi:**
```json
{
  "body": {
    "message": {
      "toolCalls": [{
        "id": "call_abc123",
        "function": {
          "name": "function_tool",
          "arguments": "{...}"
        }
      }]
    }
  }
}
```

**Note:** Arguments can be JSON string or object depending on Vapi version.