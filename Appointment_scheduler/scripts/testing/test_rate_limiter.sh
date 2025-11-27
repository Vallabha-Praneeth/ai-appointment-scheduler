#!/bin/bash

##############################################################################
# Twilio Rate Limiter Test Script
#
# Purpose: Simulate incoming calls to test rate limiting function
#
# Usage:
#   ./test_rate_limiter.sh <FUNCTION_URL> <TEST_PHONE_NUMBER>
#
# Example:
#   ./test_rate_limiter.sh https://rate-limiter-xxxx-dev.twil.io/rate-limiter +12145551234
#
# What it does:
#   1. Simulates 7 incoming calls from the same number
#   2. First 5 should be allowed (forwarded to Vapi)
#   3. Calls 6-7 should be blocked (rate limit exceeded)
#   4. Displays TwiML responses for verification
#
##############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FUNCTION_URL=$1
TEST_PHONE=$2
MAX_CALLS=7
DELAY_SECONDS=2

# Validate arguments
if [ -z "$FUNCTION_URL" ] || [ -z "$TEST_PHONE" ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo ""
    echo "Usage: $0 <FUNCTION_URL> <TEST_PHONE_NUMBER>"
    echo ""
    echo "Example:"
    echo "  $0 https://rate-limiter-xxxx-dev.twil.io/rate-limiter +12145551234"
    echo ""
    exit 1
fi

# Display test configuration
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Twilio Rate Limiter Test Suite                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Function URL:   $FUNCTION_URL"
echo "  Test Phone:     $TEST_PHONE"
echo "  Total Calls:    $MAX_CALLS"
echo "  Delay:          $DELAY_SECONDS seconds"
echo ""
echo -e "${YELLOW}Expected Results:${NC}"
echo "  Calls 1-5:      ${GREEN}ALLOWED${NC} (forwarded to Vapi)"
echo "  Calls 6-7:      ${RED}BLOCKED${NC} (rate limit exceeded)"
echo ""
read -p "Press Enter to start tests..."
echo ""

# Initialize counters
allowed=0
blocked=0
errors=0

# Run tests
for i in $(seq 1 $MAX_CALLS); do
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}Test Call #$i${NC}"
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────────────${NC}"

    # Simulate Twilio webhook payload
    response=$(curl -s -X POST "$FUNCTION_URL" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "From=$TEST_PHONE" \
        -d "To=+14694365607" \
        -d "CallSid=CA$(openssl rand -hex 16)" \
        -d "CallStatus=ringing" \
        -d "Direction=inbound" \
        -d "Called=+14694365607" \
        -d "Caller=$TEST_PHONE")

    # Check response
    if echo "$response" | grep -q "<Dial>"; then
        echo -e "Status:   ${GREEN}✓ ALLOWED${NC}"
        echo "Action:   Forwarding to Vapi"
        allowed=$((allowed + 1))
    elif echo "$response" | grep -q "exceeded the maximum"; then
        echo -e "Status:   ${RED}✗ BLOCKED${NC}"
        echo "Reason:   Rate limit exceeded"
        blocked=$((blocked + 1))
    elif echo "$response" | grep -q "Error"; then
        echo -e "Status:   ${RED}✗ ERROR${NC}"
        echo "Error:    $response"
        errors=$((errors + 1))
    else
        echo -e "Status:   ${YELLOW}? UNKNOWN${NC}"
        echo "Response: $response"
    fi

    # Show TwiML preview (first 200 chars)
    echo "Response: $(echo "$response" | head -c 200)..."
    echo ""

    # Wait before next call (except for last one)
    if [ $i -lt $MAX_CALLS ]; then
        echo "Waiting $DELAY_SECONDS seconds..."
        sleep $DELAY_SECONDS
        echo ""
    fi
done

# Display summary
echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                            Test Results                                 ${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Total Calls:      $MAX_CALLS"
echo -e "  ${GREEN}Allowed:          $allowed${NC}"
echo -e "  ${RED}Blocked:          $blocked${NC}"
echo -e "  ${YELLOW}Errors:           $errors${NC}"
echo ""

# Verify expected results
if [ $allowed -eq 5 ] && [ $blocked -eq 2 ] && [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ TEST PASSED${NC}"
    echo "  Rate limiting is working correctly!"
    echo ""
    exit 0
else
    echo -e "${RED}✗ TEST FAILED${NC}"
    echo "  Expected: 5 allowed, 2 blocked, 0 errors"
    echo "  Got:      $allowed allowed, $blocked blocked, $errors errors"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check Function logs in Twilio Console"
    echo "  2. Verify environment variables are set correctly"
    echo "  3. Ensure Sync Service SID is correct"
    echo "  4. Check Function URL is accessible"
    echo ""
    exit 1
fi


##############################################################################
# ADVANCED TESTING
##############################################################################

# Uncomment to test with multiple phone numbers (no rate limiting expected)

# echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════${NC}"
# echo -e "${BLUE}           Testing with Multiple Phone Numbers (Negative Test)          ${NC}"
# echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════${NC}"
# echo ""
# echo "Expected: All calls from different numbers should be ALLOWED"
# echo ""

# for i in $(seq 1 5); do
#     random_phone="+1214555$(printf '%04d' $RANDOM)"
#     echo "Call from: $random_phone"
#
#     response=$(curl -s -X POST "$FUNCTION_URL" \
#         -H "Content-Type: application/x-www-form-urlencoded" \
#         -d "From=$random_phone" \
#         -d "To=+14694365607" \
#         -d "CallSid=CA$(openssl rand -hex 16)")
#
#     if echo "$response" | grep -q "<Dial>"; then
#         echo -e "${GREEN}✓ ALLOWED${NC}"
#     else
#         echo -e "${RED}✗ BLOCKED (unexpected!)${NC}"
#     fi
#     echo ""
# done
