#!/bin/bash

# Direct test - use the actual time suggested by the workflow

WEBHOOK_SECRET="xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
N8N_BASE="https://polarmedia.app.n8n.cloud"

# Use one of the suggested slots: 2025-11-26T10:30:00
curl -X POST "$N8N_BASE/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "name": "Test Cancel User",
    "phone": "+12145559999",
    "email": "testcancel@example.com",
    "title": "Test Appointment for Cancel",
    "service_type": "consultation",
    "startIso": "2025-11-26T10:30:00-06:00",
    "endIso": "2025-11-26T11:00:00-06:00",
    "timezone": "America/Chicago",
    "confirm": "yes",
    "notes": "Test booking to be cancelled"
  }' | python3 -m json.tool

