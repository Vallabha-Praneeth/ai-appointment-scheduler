#!/bin/bash

WEBHOOK_SECRET="xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
N8N_BASE="https://polarmedia.app.n8n.cloud"

echo "=== Test 1: Create booking ==="
RESPONSE1=$(curl -s -X POST "$N8N_BASE/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "name": "Final Test",
    "phone": "+12145551111",
    "email": "finaltest@example.com",
    "title": "Final Test",
    "service_type": "consultation",
    "startIso": "2025-12-20T10:00:00-06:00",
    "endIso": "2025-12-20T11:00:00-06:00",
    "timezone": "America/Chicago",
    "confirm": "yes"
  }')

echo "$RESPONSE1" | jq -r '.results[0].result' | jq '.result, .bookingId'
BOOKING_ID=$(echo "$RESPONSE1" | jq -r '.results[0].result' | jq -r '.bookingId')

if [ "$BOOKING_ID" != "null" ] && [ -n "$BOOKING_ID" ]; then
  echo "✅ Booking created: $BOOKING_ID"
  
  sleep 2
  echo ""
  echo "=== Test 2: Cancel booking ==="
  RESPONSE2=$(curl -s -X POST "$N8N_BASE/webhook/vapi/cancel" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: $WEBHOOK_SECRET" \
    -d "{
      \"bookingId\": \"$BOOKING_ID\",
      \"confirm\": \"yes\"
    }")
  
  echo "$RESPONSE2" | jq -r '.results[0].result' | jq '.result'
  
  if echo "$RESPONSE2" | grep -q '"result":"cancelled"'; then
    echo "✅ Cancel workflow: PASS"
  else
    echo "⚠️  Cancel result: $(echo "$RESPONSE2" | jq -r '.results[0].result' | jq -r '.result')"
  fi
else
  echo "❌ Failed to create booking"
fi
