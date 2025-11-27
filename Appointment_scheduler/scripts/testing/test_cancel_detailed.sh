#!/bin/bash

WEBHOOK_SECRET="xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
N8N_BASE="https://polarmedia.app.n8n.cloud"

echo "=== Test Cancel Workflow ==="

# Use the booking from Scenario 4
BOOKING_ID="foe0aegkmame6avkq72tvlv9jk"

echo "Cancelling booking: $BOOKING_ID"

curl -s -X POST "$N8N_BASE/webhook/vapi/cancel" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d "{
    \"bookingId\": \"$BOOKING_ID\",
    \"confirm\": \"yes\"
  }" | python3 -m json.tool

