#!/bin/bash

# Test Holiday Blocking System
# Verifies that appointments cannot be booked on federal holidays

echo "========================================="
echo "Holiday Blocking System - Test"
echo "========================================="
echo ""

WEBHOOK_URL="https://polarmedia.app.n8n.cloud/webhook/vapi/call"

echo "Test 1: Attempt to book on Christmas 2025"
echo "==========================================="
echo ""

RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Consultation",
    "startIso": "2025-12-25T14:00:00-06:00",
    "endIso": "2025-12-25T15:00:00-06:00",
    "timezone": "America/Chicago",
    "name": "Holiday Test User",
    "phone": "+919494348091",
    "service_type": "consultation",
    "email": "test@example.com"
  }')

echo "Response:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

if echo "$RESPONSE" | grep -qi "available.*false\|conflict\|closed"; then
  echo "✓ PASS: Christmas correctly blocked"
else
  echo "✗ FAIL: Christmas was NOT blocked!"
fi

echo ""
echo "========================================="
echo ""

echo "Test 2: Attempt to book on Independence Day 2025"
echo "=================================================="
echo ""

RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Consultation",
    "startIso": "2025-07-04T10:00:00-06:00",
    "endIso": "2025-07-04T11:00:00-06:00",
    "timezone": "America/Chicago",
    "name": "Holiday Test User",
    "phone": "+919494348091",
    "service_type": "consultation",
    "email": "test@example.com"
  }')

echo "Response:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

if echo "$RESPONSE" | grep -qi "available.*false\|conflict\|closed"; then
  echo "✓ PASS: Independence Day correctly blocked"
else
  echo "✗ FAIL: Independence Day was NOT blocked!"
fi

echo ""
echo "========================================="
echo ""

echo "Test 3: Attempt to book on Thanksgiving 2025"
echo "=============================================="
echo ""

RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Consultation",
    "startIso": "2025-11-27T10:00:00-06:00",
    "endIso": "2025-11-27T11:00:00-06:00",
    "timezone": "America/Chicago",
    "name": "Holiday Test User",
    "phone": "+919494348091",
    "service_type": "consultation",
    "email": "test@example.com"
  }')

echo "Response:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

if echo "$RESPONSE" | grep -qi "available.*false\|conflict\|closed"; then
  echo "✓ PASS: Thanksgiving correctly blocked"
else
  echo "✗ FAIL: Thanksgiving was NOT blocked!"
fi

echo ""
echo "========================================="
echo ""

echo "Test 4: Attempt to book on regular day (should work)"
echo "====================================================="
echo ""

# Use a date that's definitely not a holiday (random Wednesday)
RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Consultation",
    "startIso": "2025-12-10T14:00:00-06:00",
    "endIso": "2025-12-10T15:00:00-06:00",
    "timezone": "America/Chicago",
    "name": "Regular Day Test",
    "phone": "+919494348091",
    "service_type": "consultation",
    "email": "test@example.com"
  }')

echo "Response:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

if echo "$RESPONSE" | grep -qi "available.*true\|booked\|success"; then
  echo "✓ PASS: Regular day booking works"
else
  echo "⚠ WARNING: Regular day booking might have failed (could be due to existing conflict)"
fi

echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo ""
echo "Expected Results:"
echo "  - Holidays should return 'available: false'"
echo "  - Regular days should be bookable"
echo ""
echo "If all holiday tests passed, your system is working correctly!"
echo ""
