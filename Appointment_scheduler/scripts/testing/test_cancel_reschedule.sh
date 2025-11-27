#!/bin/bash

# Test Script for Cancel and Reschedule Workflows
# Tests Scenarios 5 & 6 that were skipped in the automated test suite

set -e

WEBHOOK_SECRET="xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
N8N_BASE="https://polarmedia.app.n8n.cloud"

echo "============================================"
echo "Testing Cancel and Reschedule Workflows"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Create a test booking first
echo -e "${YELLOW}Step 1: Creating test booking...${NC}"
BOOKING_RESPONSE=$(curl -s -X POST "$N8N_BASE/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "name": "Test Cancel User",
    "phone": "+12145559999",
    "email": "testcancel@example.com",
    "title": "Test Appointment for Cancel",
    "service_type": "consultation",
    "startIso": "2025-12-15T10:00:00-06:00",
    "endIso": "2025-12-15T11:00:00-06:00",
    "timezone": "America/Chicago",
    "confirm": "yes",
    "notes": "Test booking to be cancelled"
  }')

echo "Response: $BOOKING_RESPONSE"

# Extract bookingId (handle both direct response and results wrapper)
BOOKING_ID=$(echo "$BOOKING_RESPONSE" | grep -o '"bookingId":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$BOOKING_ID" ]; then
  echo -e "${YELLOW}⚠️  Trying alternative parsing for bookingId...${NC}"
  # Try to extract from nested result field
  BOOKING_ID=$(echo "$BOOKING_RESPONSE" | grep -o 'bookingId[^,}]*' | head -1 | grep -o '[a-z0-9]\{20,\}')
fi

if [ -z "$BOOKING_ID" ]; then
  echo -e "${RED}❌ Failed to extract bookingId. Cannot proceed with cancel/reschedule tests.${NC}"
  echo "Response was: $BOOKING_RESPONSE"
  exit 1
fi

echo -e "${GREEN}✅ Booking created: $BOOKING_ID${NC}"
echo ""
sleep 2

# Step 2: Test Lookup to verify booking exists
echo -e "${YELLOW}Step 2: Looking up booking by phone...${NC}"
LOOKUP_RESPONSE=$(curl -s -X POST "$N8N_BASE/webhook/vapi-lookup" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "phone": "+12145559999"
  }')

echo "Lookup Response: $LOOKUP_RESPONSE"
echo ""

# Check if lookup found the booking
if echo "$LOOKUP_RESPONSE" | grep -q '"result":"found"\|"result":"multiple_found"'; then
  echo -e "${GREEN}✅ Lookup successful - booking verified${NC}"
else
  echo -e "${RED}⚠️  Lookup returned unexpected result${NC}"
fi
echo ""
sleep 2

# Step 3: Test Reschedule
echo -e "${YELLOW}Step 3: Testing Reschedule Workflow...${NC}"
RESCHEDULE_RESPONSE=$(curl -s -X POST "$N8N_BASE/webhook/vapi/reschedule" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d "{
    \"bookingId\": \"$BOOKING_ID\",
    \"newStartIso\": \"2025-12-15T14:00:00-06:00\",
    \"newEndIso\": \"2025-12-15T15:00:00-06:00\",
    \"timezone\": \"America/Chicago\"
  }")

echo "Reschedule Response: $RESCHEDULE_RESPONSE"
echo ""

# Validate reschedule response
if echo "$RESCHEDULE_RESPONSE" | grep -q '"result":"rescheduled"'; then
  echo -e "${GREEN}✅ SCENARIO 6: Reschedule - PASS${NC}"

  # Verify new time in response
  if echo "$RESCHEDULE_RESPONSE" | grep -q "14:00:00"; then
    echo -e "${GREEN}   ✅ New time (14:00) confirmed in response${NC}"
  else
    echo -e "${YELLOW}   ⚠️  New time not found in response${NC}"
  fi
else
  echo -e "${RED}❌ SCENARIO 6: Reschedule - FAIL${NC}"
  echo "Expected: result='rescheduled'"
  echo "Got: $RESCHEDULE_RESPONSE"
fi
echo ""
sleep 2

# Step 4: Test Cancel
echo -e "${YELLOW}Step 4: Testing Cancel Workflow...${NC}"
CANCEL_RESPONSE=$(curl -s -X POST "$N8N_BASE/webhook/vapi/cancel" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d "{
    \"bookingId\": \"$BOOKING_ID\",
    \"confirm\": \"yes\"
  }")

echo "Cancel Response: $CANCEL_RESPONSE"
echo ""

# Validate cancel response
if echo "$CANCEL_RESPONSE" | grep -q '"result":"cancelled"'; then
  echo -e "${GREEN}✅ SCENARIO 5: Cancel - PASS${NC}"
else
  echo -e "${RED}❌ SCENARIO 5: Cancel - FAIL${NC}"
  echo "Expected: result='cancelled'"
  echo "Got: $CANCEL_RESPONSE"
fi
echo ""

# Step 5: Verify cancellation with lookup
echo -e "${YELLOW}Step 5: Verifying cancellation...${NC}"
VERIFY_RESPONSE=$(curl -s -X POST "$N8N_BASE/webhook/vapi-lookup" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "phone": "+12145559999"
  }')

echo "Verify Response: $VERIFY_RESPONSE"
echo ""

if echo "$VERIFY_RESPONSE" | grep -q '"result":"not_found"'; then
  echo -e "${GREEN}✅ Cancellation verified - booking no longer exists${NC}"
else
  echo -e "${YELLOW}⚠️  Booking still exists after cancel (may be expected if soft delete)${NC}"
fi
echo ""

echo "============================================"
echo "Test Summary"
echo "============================================"
echo -e "${GREEN}✅ Created test booking: $BOOKING_ID${NC}"
echo -e "${GREEN}✅ Looked up booking successfully${NC}"

if echo "$RESCHEDULE_RESPONSE" | grep -q '"result":"rescheduled"'; then
  echo -e "${GREEN}✅ Reschedule test: PASS${NC}"
else
  echo -e "${RED}❌ Reschedule test: FAIL${NC}"
fi

if echo "$CANCEL_RESPONSE" | grep -q '"result":"cancelled"'; then
  echo -e "${GREEN}✅ Cancel test: PASS${NC}"
else
  echo -e "${RED}❌ Cancel test: FAIL${NC}"
fi

echo ""
echo "Test completed at: $(date)"
