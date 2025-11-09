# AI Appointment Scheduler

An AI-powered appointment scheduling system built on the **n8n** workflow automation platform. The system uses **Vapi** for voice AI interactions, integrates with **Google Calendar** for scheduling, and **Twilio** for SMS reminders. The AI assistant (named "Alex") is powered by **OpenAI's GPT-4o**.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Configuration](#configuration)
- [Workflow Files](#workflow-files)
- [Vapi Configuration](#vapi-configuration)
- [Testing](#testing)
- [Production Deployment](#production-deployment)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project provides a complete voice-based appointment scheduling solution that handles:

- Booking new appointments
- Confirming existing appointments
- Canceling appointments
- Rescheduling appointments
- Automated SMS reminders
- Business hours validation
- Conflict detection

Users interact with the system via phone, speaking naturally with the AI assistant "Alex" who manages all appointment operations.

## Architecture

The system follows a webhook-based, event-driven architecture:

```
┌─────────────┐         ┌──────────────┐         ┌───────────────┐
│   User      │ Phone   │    Vapi      │Webhooks │     n8n       │
│  (Caller)   │◄───────►│Voice Assistant│────────►│  Workflows    │
└─────────────┘         └──────────────┘         └───────┬───────┘
                                                          │
                        ┌─────────────────────────────────┼────────┐
                        │                                 │        │
                        ▼                                 ▼        ▼
                ┌──────────────┐                 ┌──────────┐ ┌─────────┐
                │Google Calendar│                │  Twilio  │ │ OpenAI  │
                │  (Scheduling) │                │  (SMS)   │ │ GPT-4o  │
                └──────────────┘                 └──────────┘ └─────────┘
```

### Flow:

1. User calls the Vapi voice assistant
2. User requests an action (book, cancel, reschedule, lookup)
3. Vapi calls the appropriate n8n webhook
4. n8n workflow executes business logic:
   - Checks Google Calendar availability
   - Creates/updates/deletes calendar events
   - Sends SMS confirmations via Twilio
5. Response flows back to Vapi
6. Vapi communicates results to the user

## Features

- **Voice-First Interface**: Natural conversation flow powered by OpenAI GPT-4o
- **Smart Scheduling**: Automatic availability checking and conflict detection
- **Business Hours Enforcement**: Configurable operating hours (default: 10:00-18:00)
- **Timezone Support**: Full IANA timezone support with ISO 8601 datetime handling
- **SMS Notifications**: Automatic confirmations and reminders via Twilio
- **Multiple Service Types**: Support, Maintenance, Consultation, Onsite, Emergency
- **Conversation Recovery**: Handles disconnected/incomplete calls
- **Phone & Email Lookup**: Find appointments using phone number or email

## Prerequisites

Before setting up this project, you'll need:

- **n8n instance**: Cloud or self-hosted (v1.0+)
- **Vapi account**: For voice AI assistant
- **Google Calendar API**: Enabled with OAuth credentials
- **Twilio account**: For SMS functionality
- **OpenAI API key**: For GPT-4o model access

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/ai-appointment-scheduler.git
cd ai-appointment-scheduler
```

### 2. Configure Environment Variables

Copy the example environment file and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual values (see [Configuration](#configuration) section).

### 3. Import n8n Workflows

1. Log into your n8n instance
2. Go to **Workflows** → **Import from File**
3. Import the main workflow first:
   - `Appointment Scheduling AI_v.0.0.3 (Prod).json`
4. Import the sub-workflows:
   - `Appointment Scheduling AI_v.0.0.3_vapi_lookup.json`
   - `Appointment Scheduling AI_v.0.0.3_vapi_cancel.json`
   - `Appointment Scheduling AI_v.0.0.3_vapi_reschedule.json`
   - `Appointment Scheduling AI_v.0.0.3_vapi_recovery.json`
5. Import conditional workflows:
   - `Appointment Scheduling AI_v.0.0.3 (If_Confrim_yes).json`
   - `Appointment Scheduling AI_v.0.0.3(If_Confirm_No).json`
6. Import the signed link resolver (optional):
   - `Appointment_scheduler_v0.0.3_RDC - Signed Link Resolver (JWT verify → 302 redirect).json`

### 4. Configure n8n Workflows

For each imported workflow:

1. Update the webhook URLs to match your n8n instance
2. Configure Google Calendar credentials
3. Configure Twilio credentials
4. Set environment variables in n8n settings
5. Activate the workflows

### 5. Set Up Vapi Assistant

1. Log into your Vapi dashboard
2. Create a new assistant or import the configuration:
   - Upload `vapi/vapi-assistant.json`
   - Upload `vapi/vapi-tools.json`
3. Update the webhook URLs in the tools configuration to point to your n8n instance
4. Configure the phone number for incoming calls

## Configuration

### Environment Variables

Create a `.env` file in the project root with the following variables:

```bash
# n8n Configuration
N8N_INSTANCE_URL=https://your-instance.app.n8n.cloud

# Google Calendar
GOOGLE_CALENDAR_ID=your-calendar@gmail.com

# Twilio
TWILIO_PHONE_NUMBER=+1234567890
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token

# Security
JWT_SECRET=your-strong-secret-key
WEBHOOK_SECRET=your-webhook-secret

# Business Hours (24-hour format)
BUSINESS_HOURS_START=10:00
BUSINESS_HOURS_END=18:00
DEFAULT_TIMEZONE=America/Chicago

# OpenAI
OPENAI_API_KEY=your_openai_api_key
```

### n8n Environment Variables

In your n8n instance settings, configure the following environment variables:

- `GOOGLE_CALENDAR_ID`
- `TWILIO_PHONE_NUMBER`
- `JWT_SECRET`
- `N8N_INSTANCE_URL`
- `WEBHOOK_SECRET` (for webhook security)

### Vapi Configuration

Update the webhook URLs in `vapi/vapi-tools.json`:

```json
{
  "server": {
    "url": "https://YOUR_N8N_INSTANCE/webhook/vapi/call"
  }
}
```

## Workflow Files

### Main Workflows

- **`Appointment Scheduling AI_v.0.0.3 (Prod).json`**
  - Main production workflow
  - Handles new appointment bookings
  - Includes availability checking and calendar integration

### Sub-Workflows

- **`vapi_lookup.json`**
  - Finds existing appointments by phone or email
  - Returns appointment details

- **`vapi_cancel.json`**
  - Cancels appointments
  - Requires booking ID and confirmation

- **`vapi_reschedule.json`**
  - Reschedules appointments to new time slots
  - Validates new slot availability

- **`vapi_recovery.json`**
  - Handles disconnected or incomplete calls
  - Sends follow-up messages with continuation links

### Conditional Workflows

- **`If_Confrim_yes.json`** - Executes when user confirms an appointment
- **`If_Confirm_No.json`** - Executes when user declines an appointment

## Vapi Configuration

### Files

- **`vapi/vapi-assistant.json`**
  - Defines the AI assistant's persona
  - Voice settings (Elliot voice)
  - System prompts and conversation policies

- **`vapi/vapi-tools.json`**
  - Function definitions (tools) the assistant can call
  - Webhook endpoints for each operation

### Available Tools

1. **function_tool** - Book new appointments
2. **lookup_tool** - Find appointments by phone/email
3. **cancel_tool** - Cancel appointments (requires confirmation)
4. **reschedule_tool** - Move appointments to new time slots
5. **recover_tool** - Handle call disconnects/abandonment
6. **send_text_tool** - Send SMS to user

## Testing

### Manual Testing

Use curl to test webhook endpoints:

```bash
# Test booking endpoint
curl -X POST https://your-instance.app.n8n.cloud/webhook/vapi/call \
  -H "Content-Type: application/json" \
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

### Testing Checklist

- [ ] Appointment creation in Google Calendar
- [ ] SMS confirmations sent via Twilio
- [ ] Conflict detection (overlapping appointments)
- [ ] Business hours validation
- [ ] Cancellation flow
- [ ] Rescheduling flow
- [ ] Lookup by phone/email
- [ ] Recovery workflow for disconnected calls

### End-to-End Testing

1. Call the Vapi phone number
2. Request to book an appointment
3. Verify appointment appears in Google Calendar
4. Check SMS confirmation was sent
5. Test cancellation and rescheduling flows

## Production Deployment

Before deploying to production, complete these tasks:

### 1. Configuration Management
- ✅ Move all hardcoded values to environment variables
- ✅ Create separate configurations for dev/staging/production

### 2. Security
- [ ] Add webhook authentication (see `Project_Workflow.md`)
- [ ] Rotate JWT secrets regularly
- [ ] Enable HTTPS for all endpoints
- [ ] Review and restrict API permissions

### 3. Error Handling
- [ ] Enable "Continue on Fail" on critical nodes
- [ ] Add error handling branches
- [ ] Implement retry logic for API calls
- [ ] Set up error notifications

### 4. Input Validation
- [ ] Validate all webhook inputs
- [ ] Sanitize user-provided data
- [ ] Add rate limiting

### 5. Monitoring
- [ ] Set up logging in all workflows
- [ ] Configure external monitoring (Prometheus/Grafana)
- [ ] Set up uptime monitoring
- [ ] Create alerts for failures

### 6. Testing
- [ ] Create automated test workflows
- [ ] Set up CI/CD pipeline
- [ ] Perform load testing

See `Project_Workflow.md` for detailed implementation instructions.

## API Reference

### Webhook Endpoints

All endpoints expect JSON payloads and return JSON responses.

#### Book Appointment

```
POST /webhook/vapi/call
```

**Request:**
```json
{
  "title": "Consultation",
  "startIso": "2025-11-10T10:00:00-06:00",
  "endIso": "2025-11-10T11:00:00-06:00",
  "timezone": "America/Chicago",
  "name": "John Doe",
  "phone": "+12145551234",
  "service_type": "consultation",
  "email": "john@example.com"
}
```

**Response:**
```json
{
  "result": "booked",
  "slot": {
    "start": "2025-11-10T10:00:00-06:00",
    "end": "2025-11-10T11:00:00-06:00",
    "timezone": "America/Chicago"
  },
  "title": "Consultation",
  "bookingId": "abc123xyz",
  "calendarUrl": "https://calendar.google.com/..."
}
```

#### Lookup Appointment

```
POST /webhook/vapi-lookup
```

**Request:**
```json
{
  "phone": "+12145551234"
}
```

**Response:**
```json
{
  "result": "found",
  "appointments": [{
    "bookingId": "abc123xyz",
    "title": "Consultation",
    "start": "2025-11-10T10:00:00-06:00",
    "end": "2025-11-10T11:00:00-06:00"
  }]
}
```

#### Cancel Appointment

```
POST /webhook/vapi/cancel
```

**Request:**
```json
{
  "bookingId": "abc123xyz",
  "confirm": "yes"
}
```

#### Reschedule Appointment

```
POST /webhook/vapi/reschedule
```

**Request:**
```json
{
  "bookingId": "abc123xyz",
  "newStartIso": "2025-11-11T14:00:00-06:00",
  "newEndIso": "2025-11-11T15:00:00-06:00",
  "timezone": "America/Chicago"
}
```

### Service Types & Durations

- **Support**: 30-60 minutes
- **Maintenance**: 45-90 minutes
- **Consultation**: 60-90 minutes
- **Onsite**: 60-120 minutes
- **Emergency**: Variable (can be scheduled outside business hours)

## Troubleshooting

### Common Issues

**Issue: Appointments not showing in Google Calendar**
- Check Google Calendar API credentials in n8n
- Verify `GOOGLE_CALENDAR_ID` is correct
- Check workflow execution logs in n8n

**Issue: SMS not being sent**
- Verify Twilio credentials
- Check Twilio phone number is configured correctly
- Ensure Twilio account has sufficient credits

**Issue: "No free slot" despite available time**
- Check business hours configuration
- Verify timezone is correct
- Look for overlapping calendar events

**Issue: Webhook timeouts**
- Check n8n instance is running
- Verify webhook URLs are accessible
- Review n8n execution logs

### Debug Mode

Enable detailed logging in n8n Code nodes:

```javascript
console.log('Debug:', {
  input: $json,
  timestamp: new Date().toISOString()
});
```

Check logs in n8n Workflow Executions.

## Contributing

Contributions are welcome! Please see `CONTRIBUTING.md` for guidelines.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Support

For issues and questions:
- Create an issue in this repository
- Check existing documentation in `CLAUDE.md` and `Project_Workflow.md`
- Review n8n workflow execution logs

## Acknowledgments

- **n8n** - Workflow automation platform
- **Vapi** - Voice AI platform
- **OpenAI** - GPT-4o language model
- **Google Calendar API** - Scheduling integration
- **Twilio** - SMS functionality
