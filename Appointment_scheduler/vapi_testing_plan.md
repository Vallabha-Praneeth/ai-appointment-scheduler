# Vapi End-to-End Testing Plan
**Generated:** November 25, 2025
**Purpose:** Comprehensive testing of all Vapi → n8n integration scenarios

---

## Prerequisites

### 1. Update Vapi Assistant Configuration

**Current issue:** System prompt has incorrect date (November 12, 2025)
**Required update:** Change to November 24, 2025

**Missing sections to add:**

```
[CRITICAL TOOL USAGE RULES]

* ALWAYS use function_tool for ANY booking request, even if user specifies a time.
* function_tool handles ALL validation including business hours (10am-6pm) and conflicts.
* NEVER call check_availability_tool when user wants to book - it is ONLY for browsing available slots.
* NEVER call group_booking_tool unless user explicitly mentions group/multiple people/team.

[Tool Priority - MEMORIZE THIS]

1. User says "book at 10am tomorrow" → Use function_tool (NOT check_availability_tool)
2. User says "what times are available?" → Use check_availability_tool
3. User says "book for me and my colleague" → Use group_booking_tool
4. Default: function_tool for all booking requests
```

**Time interpretation rule to add:**
```
* IMPORTANT: When user says "10" without AM/PM, assume 10:00 AM (business hours are 10am-6pm).
```

**Alternatives handling logic to add (in [Dialog Logic]):**
```
When the booking tool returns alternatives:
  1. Check the `sameDayAvailable` field in the response
  2. If `sameDayAvailable: true` - say: "That time isn't available, but I have other options on the same day. Which works best for you?" Then read the actual times from the `alternatives` array.
  3. If `sameDayAvailable: false` - say: "Unfortunately, that day is fully booked. Here are the next available slots." Then read the actual times from the `alternatives` array.
  4. ALWAYS present alternatives as choices - never auto-confirm a single option
  5. Read the ACTUAL times from the `alternatives` array in the tool response. Each alternative has `start`, `end`, and `tz` fields. Convert these to a friendly spoken format.
  6. Wait for the user to pick one before proceeding
  7. If user declines all, ask what other day or time works for them
```

### 2. API Credentials Needed

```bash
VAPI_PRIVATE_KEY="your_vapi_private_key"
ASSISTANT_ID="cda9d127-ac08-45d3-93d7-3d18ad9570fc"
N8N_BASE_URL="https://polarmedia.app.n8n.cloud"
WEBHOOK_SECRET="xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
```

---

## Test Scenarios

### Scenario 1: Simple Booking - User Has Specific Time
**Goal:** Verify function_tool is called directly (NOT check_availability_tool)

**User says:**
- "I want to book an appointment tomorrow at 10"
- "Book me for November 25 at 2pm"
- "Schedule a consultation for tomorrow at 14:00"

**Expected flow:**
1. Assistant collects: name, email, phone, service_type
2. Assistant confirms: "Let me book you for [date] at [time]. May I have your name?"
3. Assistant calls `function_tool` with:
   - `startIso: "2025-11-25T10:00:00-06:00"` (or 14:00)
   - `endIso: "2025-11-25T11:00:00-06:00"` (or 15:00)
   - `timezone: "America/Chicago"`
   - `confirm: "yes"`
4. If slot available → bookingId returned, confirmation given
5. If slot NOT available → alternatives offered

**Validation points:**
- ✅ "10" interpreted as "10:00 AM" (not 10:00 PM)
- ✅ `check_availability_tool` is NOT called
- ✅ Name and email are confirmed/spelled back
- ✅ Response includes bookingId and calendar URL

**Test commands:**
```bash
# Direct webhook test
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "type": "tool-calls",
      "toolCalls": [{
        "id": "test_booking_simple",
        "function": {
          "name": "function_tool",
          "arguments": {
            "name": "John Smith",
            "email": "john.smith@example.com",
            "phone": "+12145551234",
            "title": "Consultation with John Smith",
            "startIso": "2025-11-25T10:00:00-06:00",
            "endIso": "2025-11-25T11:00:00-06:00",
            "timezone": "America/Chicago",
            "service_type": "consultation",
            "confirm": "yes"
          }
        }
      }]
    }
  }'
```

---

### Scenario 2: Booking Triggers Alternatives
**Goal:** Test that alternatives are presented correctly with `sameDayAvailable` logic

**User says:**
- "Book me for tomorrow at 3pm" (slot is already taken)

**Expected flow:**
1. Assistant calls `function_tool` with requested time
2. Webhook returns `result: "no_free_slot"` with:
   - `sameDayAvailable: true` or `false`
   - `alternatives: [...]` array with available slots
3. If `sameDayAvailable: true`:
   - Assistant says: "That time isn't available, but I have other options on the same day. Which works best for you?"
4. If `sameDayAvailable: false`:
   - Assistant says: "Unfortunately, that day is fully booked. Here are the next available slots."
5. Assistant reads actual times from `alternatives` array (NOT generic times)
6. User picks one: "I'll take the 4pm slot"
7. Assistant confirms and re-calls `function_tool` with new time

**Validation points:**
- ✅ Alternatives are read from the actual response, not invented
- ✅ Assistant waits for user choice before proceeding
- ✅ Assistant does NOT auto-book the first alternative
- ✅ If user declines all, assistant asks for other preferences

**Pre-test setup:**
```bash
# First, book a slot to create a conflict
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "function": {
          "name": "function_tool",
          "arguments": {
            "name": "Conflict Blocker",
            "email": "conflict@test.com",
            "phone": "+12145559999",
            "title": "Blocking Appointment",
            "startIso": "2025-11-25T15:00:00-06:00",
            "endIso": "2025-11-25T16:00:00-06:00",
            "timezone": "America/Chicago",
            "service_type": "consultation",
            "confirm": "yes"
          }
        }
      }]
    }
  }'

# Then test booking the same slot
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "function": {
          "name": "function_tool",
          "arguments": {
            "name": "Sarah Johnson",
            "email": "sarah@example.com",
            "phone": "+12145552222",
            "title": "Consultation with Sarah",
            "startIso": "2025-11-25T15:00:00-06:00",
            "endIso": "2025-11-25T16:00:00-06:00",
            "timezone": "America/Chicago",
            "service_type": "consultation",
            "confirm": "yes"
          }
        }
      }]
    }
  }'
```

---

### Scenario 3: Check Availability Request
**Goal:** Verify check_availability_tool is ONLY called when user browses slots

**User says:**
- "What times are available tomorrow?"
- "Show me your availability"
- "When are you free this week?"

**Expected flow:**
1. Assistant calls `check_availability_tool` with:
   - `startFrom: "2025-11-25T10:00:00-06:00"` (tomorrow at business open)
   - `duration: 60` (default)
   - `slotsCount: 5` (default)
   - `timezone: "America/Chicago"`
   - `service_type: "consultation"`
2. Tool returns slots with `formatted` field
3. Assistant presents slots conversationally:
   - "I have availability on Monday, Nov 25 at 10:00 AM, 11:30 AM, 2:00 PM..."
4. User picks: "I'll take the 2pm slot"
5. Assistant transitions to booking by calling `function_tool`

**Validation points:**
- ✅ `check_availability_tool` is called (not `function_tool`)
- ✅ Slots are presented using `formatted` field
- ✅ Same-day slots are grouped together
- ✅ Only 5 slots shown initially (unless user asks for more)
- ✅ After user picks, `function_tool` is called to complete booking

**Test command:**
```bash
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/check-availability" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "id": "test_check_avail",
        "function": {
          "name": "check_availability_tool",
          "arguments": {
            "startFrom": "2025-11-25T10:00:00-06:00",
            "duration": 60,
            "slotsCount": 5,
            "timezone": "America/Chicago",
            "service_type": "consultation"
          }
        }
      }]
    }
  }'
```

---

### Scenario 4: Lookup by Phone
**Goal:** Verify phone normalization and lookup matching

**User says:**
- "I want to check my appointment" → Assistant asks for phone
- User provides: "214-555-1234" or "+1 (214) 555-1234"

**Expected flow:**
1. Assistant calls `lookup_tool` with `phone: "+12145551234"`
2. Tool returns appointments matching that phone
3. Assistant summarizes: "I found your appointment on [date] at [time] for [service]"
4. Assistant does NOT read bookingId aloud

**Validation points:**
- ✅ Phone is normalized to E.164 format
- ✅ Multiple phone formats are matched (full, last 10 digits, last 7)
- ✅ BookingId is NOT read aloud to user
- ✅ Appointments are described by date/time/service

**Test command:**
```bash
# First, create a booking
BOOKING_ID=$(curl -s -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "function": {
          "name": "function_tool",
          "arguments": {
            "name": "Test Lookup User",
            "email": "lookup@test.com",
            "phone": "+12145551111",
            "title": "Lookup Test Appointment",
            "startIso": "2025-11-26T14:00:00-06:00",
            "endIso": "2025-11-26T15:00:00-06:00",
            "timezone": "America/Chicago",
            "service_type": "consultation",
            "confirm": "yes"
          }
        }
      }]
    }
  }' | jq -r '.results[0].result | fromjson | .bookingId')

# Then lookup
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi-lookup" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "id": "test_lookup",
        "function": {
          "name": "lookup_tool",
          "arguments": {
            "phone": "+12145551111"
          }
        }
      }]
    }
  }'
```

---

### Scenario 5: Cancel with BookingId
**Goal:** Verify cancel workflow with confirmation

**User says:**
- "I need to cancel booking ID abc123xyz"

**Expected flow:**
1. Assistant recognizes bookingId was provided
2. Assistant asks: "Please confirm you want to cancel booking ID abc123xyz by replying yes"
3. User says: "yes"
4. Assistant calls `cancel_tool` with:
   - `bookingId: "abc123xyz"`
   - `confirm: "yes"`
5. Tool returns cancellation confirmation
6. Assistant says: "Your appointment has been successfully canceled"

**Validation points:**
- ✅ Assistant does NOT ask for phone/email when bookingId is provided
- ✅ Confirmation is required before canceling
- ✅ Cancel only proceeds when user says "yes"
- ✅ Success/error messages are accurate

**Test command:**
```bash
# First, create a booking to cancel
CANCEL_BOOKING_ID=$(curl -s -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "function": {
          "name": "function_tool",
          "arguments": {
            "name": "Cancel Test User",
            "email": "cancel@test.com",
            "phone": "+12145553333",
            "title": "Cancel Test Appointment",
            "startIso": "2025-11-27T10:00:00-06:00",
            "endIso": "2025-11-27T11:00:00-06:00",
            "timezone": "America/Chicago",
            "service_type": "consultation",
            "confirm": "yes"
          }
        }
      }]
    }
  }' | jq -r '.results[0].result | fromjson | .bookingId')

echo "Booking ID to cancel: $CANCEL_BOOKING_ID"

# Then cancel it
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/cancel" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d "{
    \"message\": {
      \"toolCalls\": [{
        \"id\": \"test_cancel\",
        \"function\": {
          \"name\": \"cancel_tool\",
          \"arguments\": {
            \"bookingId\": \"$CANCEL_BOOKING_ID\",
            \"phone\": \"+12145553333\",
            \"confirm\": \"yes\"
          }
        }
      }]
    }
  }"
```

---

### Scenario 6: Reschedule Existing Appointment
**Goal:** Test reschedule workflow with validation

**User says:**
- "I need to reschedule my appointment"
- Assistant: "May I have your phone number?"
- User: "214-555-4444"
- Assistant looks up → "I found your appointment on Nov 26 at 2pm. What day and time would work better?"
- User: "Can we do November 28 at 10am?"

**Expected flow:**
1. Lookup → bookingId found
2. New time collected and validated
3. Assistant calls `reschedule_tool` with:
   - `bookingId: "..."`
   - `newStartIso: "2025-11-28T10:00:00-06:00"`
   - `newEndIso: "2025-11-28T11:00:00-06:00"`
   - `timezone: "America/Chicago"`
4. Tool updates calendar event
5. Confirmation given

**Validation points:**
- ✅ Lookup happens first to get bookingId
- ✅ New time is within business hours
- ✅ No conflicts with new time
- ✅ Original appointment is updated (not duplicated)

**Test command:**
```bash
# First, create a booking to reschedule
RESCHEDULE_BOOKING_ID=$(curl -s -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "function": {
          "name": "function_tool",
          "arguments": {
            "name": "Reschedule Test User",
            "email": "reschedule@test.com",
            "phone": "+12145554444",
            "title": "Reschedule Test Appointment",
            "startIso": "2025-11-26T14:00:00-06:00",
            "endIso": "2025-11-26T15:00:00-06:00",
            "timezone": "America/Chicago",
            "service_type": "consultation",
            "confirm": "yes"
          }
        }
      }]
    }
  }' | jq -r '.results[0].result | fromjson | .bookingId')

echo "Booking ID to reschedule: $RESCHEDULE_BOOKING_ID"

# Then reschedule it
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/reschedule" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d "{
    \"message\": {
      \"toolCalls\": [{
        \"id\": \"test_reschedule\",
        \"function\": {
          \"name\": \"reschedule_tool\",
          \"arguments\": {
            \"bookingId\": \"$RESCHEDULE_BOOKING_ID\",
            \"phone\": \"+12145554444\",
            \"newStartIso\": \"2025-11-28T10:00:00-06:00\",
            \"newEndIso\": \"2025-11-28T11:00:00-06:00\",
            \"timezone\": \"America/Chicago\"
          }
        }
      }]
    }
  }"
```

---

### Scenario 7: Group Booking Request
**Goal:** Verify group_booking_tool is ONLY activated when explicitly requested

**User says (SHOULD trigger group booking):**
- "I need to book for me and my colleague"
- "Can you schedule a meeting for our team of 3?"
- "Book for multiple people"

**User says (should NOT trigger group booking):**
- "I want to book an appointment" (even if they later mention bringing someone)

**Expected flow:**
1. Assistant recognizes group/plural language
2. Assistant asks: "Would you like a shared appointment together, or separate individual appointments?"
3. User picks: "Shared"
4. Assistant collects names and phones for all attendees
5. Assistant confirms booking type and details
6. Assistant calls `group_booking_tool` with:
   - `bookingType: "shared"`
   - `sharedBooking: {...}`
   - `confirm: "yes"`

**Validation points:**
- ✅ Tool is NOT suggested unless user mentions group/multiple/team
- ✅ Booking type is confirmed before proceeding
- ✅ All attendee names and phones are collected
- ✅ Single calendar event created with all attendees (if "shared")

**Test command:**
```bash
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/group-booking" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "id": "test_group_booking",
        "function": {
          "name": "group_booking_tool",
          "arguments": {
            "bookingType": "shared",
            "confirm": "yes",
            "sharedBooking": {
              "title": "Team Consultation",
              "startIso": "2025-11-29T10:00:00-06:00",
              "endIso": "2025-11-29T11:00:00-06:00",
              "timezone": "America/Chicago",
              "service_type": "consultation",
              "attendees": [
                {
                  "name": "Alice Johnson",
                  "phone": "+12145555555",
                  "email": "alice@example.com"
                },
                {
                  "name": "Bob Smith",
                  "phone": "+12145556666",
                  "email": "bob@example.com"
                }
              ],
              "notes": "Group consultation for team"
            }
          }
        }
      }]
    }
  }'
```

---

### Scenario 8: Recovery Workflow
**Goal:** Test recover_tool for disconnected calls

**Trigger:**
- Call disconnects mid-conversation
- User has provided phone but booking incomplete

**Expected flow:**
1. Vapi detects silence > 10 seconds or disconnect
2. Assistant calls `recover_tool` with:
   - `stage: "new"` (or "confirm", "reschedule", "cancel")
   - `phone: "+12145557777"`
   - `name: "..."` (if collected)
   - `carry: { title, startIso, endIso, timezone }` (if partially collected)
3. Tool generates JWT-signed links
4. SMS sent via Twilio with:
   - Resume link
   - Cancel link
   - Reschedule link
   - (Confirm link if bookingId exists)

**Validation points:**
- ✅ JWT tokens are valid (not `undefined.undefined.undefined`)
- ✅ SMS is sent from correct Twilio number (+14694365607)
- ✅ Links expire after 15 minutes (TOKEN_TTL_SEC)
- ✅ Response returns `{ result: 'ok', sent: true, links: {...} }`

**Test command:**
```bash
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/recover" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "message": {
      "toolCalls": [{
        "id": "test_recovery",
        "function": {
          "name": "recover_tool",
          "arguments": {
            "stage": "new",
            "phone": "+12145557777",
            "name": "Recovery Test User",
            "email": "recovery@test.com",
            "carry": {
              "title": "Incomplete Appointment",
              "startIso": "2025-11-30T14:00:00-06:00",
              "endIso": "2025-11-30T15:00:00-06:00",
              "timezone": "America/Chicago"
            }
          }
        }
      }]
    }
  }'
```

---

## Testing Checklist

### Before Testing
- [ ] Update Vapi assistant system prompt with latest version (November 24, 2025)
- [ ] Add CRITICAL TOOL USAGE RULES section
- [ ] Add time interpretation rule ("10" → "10:00 AM")
- [ ] Add alternatives handling logic with `sameDayAvailable`
- [ ] Verify webhook secret is configured in Vapi Org Settings
- [ ] Verify all n8n workflows are active and deployed

### During Testing
- [ ] Monitor n8n execution logs for each test
- [ ] Check Vapi call logs for tool selection
- [ ] Verify Google Calendar events are created/updated/deleted correctly
- [ ] Confirm SMS messages are sent (if applicable)
- [ ] Test both curl (direct webhook) and Vapi voice calls

### After Testing
- [ ] Document any failures or unexpected behavior
- [ ] Update workflows if issues found
- [ ] Re-test failed scenarios
- [ ] Archive test data (bookingIds, phone numbers used)

---

## Common Issues & Troubleshooting

### Issue: Vapi calls wrong tool
**Symptom:** User says "book tomorrow at 10" but `check_availability_tool` is called
**Fix:** Verify CRITICAL TOOL USAGE RULES section is in system prompt

### Issue: `confirm` field is null
**Symptom:** Booking takes FALSE path on IF Confirm node
**Fix:** Check Validate Input node handles both real-time and end-of-call-report formats (Issue 9 from 24nov2_47.md)

### Issue: JWT tokens show `undefined.undefined.undefined`
**Symptom:** Recovery SMS links are broken
**Fix:** Verify `require('crypto')` is working in n8n Cloud environment (Issue 4e from 24nov2_47.md)

### Issue: Webhook returns 403 Forbidden
**Symptom:** All requests fail with 403
**Fix:** Verify webhook secret header is configured in Vapi Org Settings → Server URL (Issue 2 from 24nov2_47.md)

### Issue: Alternatives not presented correctly
**Symptom:** Assistant says generic times instead of reading from response
**Fix:** Add alternatives handling logic to system prompt with `sameDayAvailable` checks

---

## API Reference

### Vapi API Base URL
```
https://api.vapi.ai
```

### Update Assistant Prompt
```bash
curl -X PATCH "https://api.vapi.ai/assistant/cda9d127-ac08-45d3-93d7-3d18ad9570fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": {
      "messages": [{
        "role": "system",
        "content": "<NEW_SYSTEM_PROMPT>"
      }]
    }
  }'
```

### Get Assistant Details
```bash
curl "https://api.vapi.ai/assistant/cda9d127-ac08-45d3-93d7-3d18ad9570fc" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY"
```

---

## Test Execution Log Template

```markdown
### Test Run: [Date/Time]

**Scenario:** [Scenario Name]

**Steps:**
1. [Step 1]
2. [Step 2]
...

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Status:** ✅ PASS / ❌ FAIL

**Notes:**
[Any observations, issues, or recommendations]
```

---

## Next Steps After Testing

1. **If all tests pass:**
   - Mark system as production-ready
   - Enable monitoring/logging (Phase 3 from production_deployment.md)
   - Set up error alerts

2. **If tests fail:**
   - Document failures in session log
   - Update workflows as needed
   - Re-run affected tests
   - Update CLAUDE.md with any new learnings

3. **Ongoing maintenance:**
   - Review Vapi call logs weekly
   - Monitor n8n execution success rates
   - Update business hours/holidays as needed
   - Rotate JWT secrets quarterly
