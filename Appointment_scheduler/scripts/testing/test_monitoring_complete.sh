#!/bin/bash

# Comprehensive Monitoring Test Script
# Tests all scenarios and verifies actual responses

echo "=========================================="
echo "🧪 COMPREHENSIVE MONITORING TESTS"
echo "=========================================="
echo ""

WEBHOOK_BASE="https://polarmedia.app.n8n.cloud/webhook"
ERROR_HANDLER="$WEBHOOK_BASE/error-handler"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

# Test function
run_test() {
    local test_name="$1"
    local url="$2"
    local payload="$3"
    local expected_behavior="$4"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Test: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Make request and capture response
    response=$(curl -s -w "\n---HTTP_CODE:%{http_code}---" -X POST "$url" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>&1)
    
    # Extract HTTP code
    http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    response_body=$(echo "$response" | sed 's/---HTTP_CODE:[0-9]*---//')
    
    echo "Expected: $expected_behavior"
    echo "HTTP Code: $http_code"
    echo "Response: $response_body"
    
    # Note: We're just documenting the behavior, not failing tests
    echo -e "${YELLOW}⏳ Check Google Sheets and Slack for verification${NC}"
    echo ""
    
    sleep 2
}

echo "================================================"
echo "TEST SUITE 1: ERROR HANDLER - SEVERITY LEVELS"
echo "================================================"
echo ""

# Test 1: LOW severity error
run_test "1. LOW Severity - Validation Error" \
    "$ERROR_HANDLER" \
    '{
        "error": {
            "message": "validation failed: missing required field phone",
            "name": "ValidationError"
        },
        "node": {
            "name": "Validate Input",
            "type": "n8n-nodes-base.code"
        }
    }' \
    "Should log to Google Sheets only (LOW severity)"

# Test 2: MEDIUM severity error
run_test "2. MEDIUM Severity - General Error" \
    "$ERROR_HANDLER" \
    '{
        "error": {
            "message": "Failed to process booking data",
            "name": "ProcessingError"
        },
        "node": {
            "name": "Process Booking",
            "type": "n8n-nodes-base.code"
        }
    }' \
    "Should log to Google Sheets + send Slack alert (MEDIUM severity)"

# Test 3: HIGH severity error (calendar keyword)
run_test "3. HIGH Severity - Calendar Error" \
    "$ERROR_HANDLER" \
    '{
        "error": {
            "message": "Google Calendar API timeout after 30 seconds",
            "name": "TimeoutError"
        },
        "node": {
            "name": "Create Calendar Event",
            "type": "n8n-nodes-base.googleCalendar"
        }
    }' \
    "Should log to Google Sheets + send SMS + Slack alert (HIGH severity)"

# Test 4: HIGH severity error (twilio keyword)
run_test "4. HIGH Severity - Twilio Error" \
    "$ERROR_HANDLER" \
    '{
        "error": {
            "message": "Twilio authentication failed",
            "name": "AuthError"
        },
        "node": {
            "name": "Send SMS Confirmation",
            "type": "n8n-nodes-base.twilio"
        }
    }' \
    "Should log to Google Sheets + send SMS + Slack alert (HIGH severity)"

echo "================================================"
echo "TEST SUITE 2: RECURRING ERROR DETECTION"
echo "================================================"
echo ""

# Send same error 3 times to trigger recurring detection
echo "Sending same error 3 times (2 second intervals)..."
for i in {1..3}; do
    echo "  → Attempt $i/3"
    curl -s -X POST "$ERROR_HANDLER" \
        -H "Content-Type: application/json" \
        -d '{
            "error": {
                "message": "Recurring test error - database connection timeout",
                "name": "DatabaseError"
            },
            "node": {
                "name": "Query Database",
                "type": "n8n-nodes-base.postgres"
            }
        }' > /dev/null
    
    if [ $i -lt 3 ]; then
        sleep 2
    fi
done

echo -e "${YELLOW}⏳ Check Slack for ESCALATION alert (should trigger after 3rd occurrence)${NC}"
echo ""
sleep 3

echo "================================================"
echo "TEST SUITE 3: SYSTEM HEALTH MONITOR"
echo "================================================"
echo ""

echo "System Health Monitor runs automatically every 5 minutes."
echo "Checking if it's currently running..."
echo ""

# We can't directly trigger the cron workflow, but we can check the endpoints it monitors
echo "Testing webhook endpoints that System Health Monitor checks:"
echo ""

ENDPOINTS=(
    "/webhook/vapi/call:Main Booking"
    "/webhook/vapi/lookup:Lookup"
    "/webhook/vapi/cancel:Cancel"
    "/webhook/vapi/reschedule:Reschedule"
    "/webhook/vapi/recovery:Recovery"
    "/webhook/vapi/check-availability:Check Availability"
    "/webhook/vapi/group-booking:Group Booking"
)

for endpoint_info in "${ENDPOINTS[@]}"; do
    IFS=':' read -r endpoint name <<< "$endpoint_info"
    echo "Testing: $name ($endpoint)"
    
    # Try POST (what the actual workflows expect)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$WEBHOOK_BASE$endpoint" \
        -H "Content-Type: application/json" \
        -d '{}' --max-time 5)
    
    echo "  POST response: $http_code"
    
    # Try HEAD (what System Health Monitor uses)
    http_code_head=$(curl -s -o /dev/null -w "%{http_code}" -X HEAD "$WEBHOOK_BASE$endpoint" --max-time 5)
    
    echo "  HEAD response: $http_code_head"
    echo ""
done

echo "================================================"
echo "VERIFICATION INSTRUCTIONS"
echo "================================================"
echo ""
echo "1. Google Sheets Verification:"
echo "   → Open: https://docs.google.com/spreadsheets/d/1ewZhow8YltZJy9cNynnZ6-ei5v32XuRHKV8rPJ9l6JI"
echo "   → Tab 'Error Log': Should have 7 new entries (4 individual + 3 recurring)"
echo "   → Tab 'System Health Log': Should have entries every 5 minutes"
echo ""
echo "2. Slack Verification:"
echo "   → Channel: #system-alerts-appointment_ai"
echo "   → Should have:"
echo "     - MEDIUM severity alert (Test 2)"
echo "     - HIGH severity alerts (Tests 3 & 4)"
echo "     - ESCALATION alert for recurring error (after 3rd occurrence)"
echo ""
echo "3. n8n Execution Logs:"
echo "   → Open: https://polarmedia.app.n8n.cloud"
echo "   → Workflows → Error Handler Template → Executions"
echo "   → Verify: All executions successful (green checkmarks)"
echo ""
echo "4. System Health Monitor:"
echo "   → Workflows → System Health Monitor v1.0 → Executions"
echo "   → Should show executions every 5 minutes"
echo "   → Check latest execution shows all workflow names (not 'undefined')"
echo ""

echo "================================================"
echo "TEST EXECUTION COMPLETE"
echo "================================================"
echo ""
echo "All tests have been executed."
echo "Please verify results in:"
echo "  ✓ Google Sheets"
echo "  ✓ Slack"
echo "  ✓ n8n Execution Logs"
echo ""
echo "Report any errors you find in the actual logs/sheets."
echo ""
