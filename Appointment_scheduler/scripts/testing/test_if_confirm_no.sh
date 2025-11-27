#!/bin/bash

# Test Script for If_Confirm_No Workflow
# Tests the scenario when user declines initial booking and alternatives flow

set -e

WEBHOOK_SECRET="xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
N8N_BASE="https://polarmedia.app.n8n.cloud"

echo "============================================"
echo "Testing If_Confirm_No Workflow"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test Case 1: User declines initial booking (confirm="no")
echo -e "${YELLOW}Test Case 1: User says NO to initial booking request${NC}"
echo "This should trigger If_Confirm_No workflow and offer alternatives"
echo ""

DECLINE_RESPONSE=$(curl -s -X POST "$N8N_BASE/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "name": "Test Decline User",
    "phone": "+12145558888",
    "email": "testdecline@example.com",
    "title": "Declined Appointment",
    "service_type": "consultation",
    "startIso": "2025-12-02T10:00:00-06:00",
    "endIso": "2025-12-02T11:00:00-06:00",
    "timezone": "America/Chicago",
    "confirm": "no",
    "notes": "Testing decline flow"
  }')

echo "Response: $DECLINE_RESPONSE"
echo ""

# Validate response
if echo "$DECLINE_RESPONSE" | grep -q '"result":"no_free_slot"\|"result":"need_more_info"'; then
  echo -e "${GREEN}✅ Correct response type received${NC}"

  # Check if alternatives are offered
  if echo "$DECLINE_RESPONSE" | grep -q '"alternatives":\['; then
    echo -e "${GREEN}✅ Alternatives offered in response${NC}"

    # Check for sameDayAvailable flag
    if echo "$DECLINE_RESPONSE" | grep -q '"sameDayAvailable"'; then
      echo -e "${GREEN}✅ sameDayAvailable flag present${NC}"
    else
      echo -e "${YELLOW}⚠️  sameDayAvailable flag not found${NC}"
    fi

    # Check for reason field
    if echo "$DECLINE_RESPONSE" | grep -q '"reason":"user_declined"'; then
      echo -e "${GREEN}✅ Reason correctly set to 'user_declined'${NC}"
    else
      echo -e "${YELLOW}⚠️  Reason field not 'user_declined'${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  No alternatives array in response${NC}"
  fi
else
  echo -e "${RED}❌ Unexpected response structure${NC}"
fi
echo ""

# Test Case 2: Create a blocking appointment first, then request that slot with confirm="no"
echo -e "${YELLOW}Test Case 2: Slot conflict with user decline${NC}"
echo "Step 1: Creating blocking appointment..."

BLOCK_RESPONSE=$(curl -s -X POST "$N8N_BASE/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "name": "Blocker",
    "phone": "+12145557777",
    "email": "blocker@example.com",
    "title": "Blocking Appointment",
    "service_type": "consultation",
    "startIso": "2025-12-03T15:00:00-06:00",
    "endIso": "2025-12-03T16:00:00-06:00",
    "timezone": "America/Chicago",
    "confirm": "yes",
    "notes": "Blocker appointment"
  }')

echo "Blocker created: $BLOCK_RESPONSE"
sleep 2
echo ""

echo "Step 2: Requesting same slot with confirm='no'..."
CONFLICT_DECLINE=$(curl -s -X POST "$N8N_BASE/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "name": "Test User",
    "phone": "+12145556666",
    "email": "testuser@example.com",
    "title": "Test Appointment",
    "service_type": "consultation",
    "startIso": "2025-12-03T15:00:00-06:00",
    "endIso": "2025-12-03T16:00:00-06:00",
    "timezone": "America/Chicago",
    "confirm": "no",
    "notes": "Testing conflict + decline"
  }')

echo "Response: $CONFLICT_DECLINE"
echo ""

if echo "$CONFLICT_DECLINE" | grep -q '"result":"no_free_slot"'; then
  echo -e "${GREEN}✅ Conflict detected correctly${NC}"

  if echo "$CONFLICT_DECLINE" | grep -q '"reason":"user_declined"\|"reason":"calendar_conflict"'; then
    echo -e "${GREEN}✅ Reason field present${NC}"
  fi

  if echo "$CONFLICT_DECLINE" | grep -q '"alternatives":\['; then
    echo -e "${GREEN}✅ Alternatives provided despite decline${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Expected no_free_slot response${NC}"
fi
echo ""

# Test Case 3: Test missing time scenario (should also route through If_Confirm_No via Mark NeedTime)
echo -e "${YELLOW}Test Case 3: Missing time information${NC}"
echo "This should trigger Mark NeedTime -> If_Confirm_No flow"
echo ""

MISSING_TIME=$(curl -s -X POST "$N8N_BASE/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "name": "Test User",
    "phone": "+12145555555",
    "email": "testmissing@example.com",
    "title": "Appointment",
    "service_type": "consultation",
    "timezone": "America/Chicago",
    "confirm": "no",
    "notes": "Missing startIso/endIso"
  }')

echo "Response: $MISSING_TIME"
echo ""

if echo "$MISSING_TIME" | grep -q '"result":"need_more_info"'; then
  echo -e "${GREEN}✅ Correctly identified missing time${NC}"

  if echo "$MISSING_TIME" | grep -q '"missing":\['; then
    echo -e "${GREEN}✅ Missing fields listed${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Expected need_more_info response${NC}"
fi
echo ""

echo "============================================"
echo "If_Confirm_No Workflow Test Summary"
echo "============================================"

# Summary
TESTS_PASSED=0
TESTS_TOTAL=3

if echo "$DECLINE_RESPONSE" | grep -q '"result":"no_free_slot"\|"result":"need_more_info"'; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo -e "${GREEN}✅ Test Case 1: Basic decline - PASS${NC}"
else
  echo -e "${RED}❌ Test Case 1: Basic decline - FAIL${NC}"
fi

if echo "$CONFLICT_DECLINE" | grep -q '"result":"no_free_slot"'; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo -e "${GREEN}✅ Test Case 2: Conflict + decline - PASS${NC}"
else
  echo -e "${RED}❌ Test Case 2: Conflict + decline - FAIL${NC}"
fi

if echo "$MISSING_TIME" | grep -q '"result":"need_more_info"'; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo -e "${GREEN}✅ Test Case 3: Missing time - PASS${NC}"
else
  echo -e "${RED}❌ Test Case 3: Missing time - FAIL${NC}"
fi

echo ""
echo "Tests Passed: $TESTS_PASSED / $TESTS_TOTAL"
echo ""
echo "Test completed at: $(date)"
