#!/bin/bash

################################################################################
# COMPREHENSIVE MONITORING SYSTEM TEST SUITE
# Tests all scenarios: LOW, MEDIUM, HIGH severity + Recurring errors
# Verifies Google Sheets logging and Slack alerting
################################################################################

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
ERROR_HANDLER_URL="https://polarmedia.app.n8n.cloud/webhook/error-handler"
GOOGLE_SHEETS_URL="https://docs.google.com/spreadsheets/d/1ewZhow8YltZJy9cNynnZ6-ei5v32XuRHKV8rPJ9l6JI"
SLACK_CHANNEL="system-alerts-appointment_ai"

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
MANUAL_CHECKS=0

# Helper function to print test header
print_header() {
    echo ""
    echo "=========================================="
    echo -e "${CYAN}$1${NC}"
    echo "=========================================="
    echo ""
}

# Helper function to wait with countdown
wait_with_countdown() {
    local seconds=$1
    local message=$2
    echo -e "${YELLOW}⏳ $message${NC}"
    for ((i=seconds; i>0; i--)); do
        echo -ne "${YELLOW}   Waiting ${i}s...${NC}\r"
        sleep 1
    done
    echo -e "${GREEN}   Ready!              ${NC}"
}

# Helper function to track test results
record_test() {
    local result=$1
    local test_name=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif [ "$result" = "FAIL" ]; then
        echo -e "${RED}✗ FAIL${NC} - $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    else
        echo -e "${YELLOW}⚠ MANUAL CHECK${NC} - $test_name"
        MANUAL_CHECKS=$((MANUAL_CHECKS + 1))
    fi
}

# Start of tests
clear
print_header "🧪 COMPREHENSIVE MONITORING TEST SUITE"

echo "Date: $(date)"
echo "Error Handler URL: $ERROR_HANDLER_URL"
echo "Google Sheets: $GOOGLE_SHEETS_URL"
echo "Slack Channel: #$SLACK_CHANNEL"
echo ""
echo -e "${YELLOW}⚠️  Note: CRITICAL/SMS tests are SKIPPED to avoid Twilio charges${NC}"
echo ""

################################################################################
# TEST 1: PRE-FLIGHT CHECKS
################################################################################

print_header "TEST 1: PRE-FLIGHT CHECKS"

# Check if workflow files exist
if [ -f "System Health Monitor v1.0.json" ]; then
    record_test "PASS" "System Health Monitor file exists"
else
    record_test "FAIL" "System Health Monitor file NOT found"
fi

if [ -f "Error Handler Template.json" ]; then
    record_test "PASS" "Error Handler Template file exists"
else
    record_test "FAIL" "Error Handler Template file NOT found"
fi

# Check Error Handler webhook accessibility
echo -n "Testing Error Handler webhook accessibility..."
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d '{"test":"connectivity"}' \
    --max-time 10)

if [ "$response" -ge 200 ] && [ "$response" -lt 500 ]; then
    record_test "PASS" "Error Handler webhook accessible (HTTP $response)"
else
    record_test "FAIL" "Error Handler webhook not accessible (HTTP $response)"
fi

################################################################################
# TEST 2: SYSTEM HEALTH MONITOR VERIFICATION
################################################################################

print_header "TEST 2: SYSTEM HEALTH MONITOR VERIFICATION"

echo -e "${BLUE}ℹ️  System Health Monitor runs every 5 minutes automatically${NC}"
echo ""
echo "To verify it's working:"
echo "1. Go to: https://polarmedia.app.n8n.cloud"
echo "2. Click 'Executions' → Filter by 'System Health Monitor v1.0'"
echo "3. Check latest execution timestamp (should be within last 5 minutes)"
echo "4. Click execution → Verify all nodes executed successfully"
echo ""
record_test "MANUAL" "System Health Monitor running (check n8n Executions)"

echo ""
echo "Expected in Google Sheets (System Health Log tab):"
echo "- Timestamp: Within last 5 minutes"
echo "- Severity: OK, WARNING, or HIGH"
echo "- Health_Percentage: 0-100%"
echo "- Workflow names in Warnings (not 'undefined')"
echo ""
record_test "MANUAL" "System Health Log has recent entries (check Google Sheets)"

################################################################################
# TEST 3: ERROR HANDLER - LOW SEVERITY
################################################################################

print_header "TEST 3: ERROR HANDLER - LOW SEVERITY (Validation Error)"

echo "Sending LOW severity error (validation failure)..."
TEST3_TIME=$(date '+%Y-%m-%d %H:%M:%S')

payload3='{
  "error": {
    "message": "validation failed: missing required field phone",
    "name": "ValidationError"
  },
  "node": {
    "name": "Validate Input",
    "type": "n8n-nodes-base.code"
  }
}'

response3=$(curl -s -w "\n%{http_code}" -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d "$payload3")

status3=$(echo "$response3" | tail -n1)
body3=$(echo "$response3" | sed '$d')

if [ "$status3" -ge 200 ] && [ "$status3" -lt 300 ]; then
    record_test "PASS" "LOW severity error sent successfully (HTTP $status3)"
    echo "   Test time: $TEST3_TIME"
else
    record_test "FAIL" "LOW severity error failed (HTTP $status3)"
fi

echo ""
echo -e "${YELLOW}⚠️  MANUAL VERIFICATION REQUIRED:${NC}"
echo "1. Go to Google Sheets → Error Log tab"
echo "2. Find entry with timestamp around: $TEST3_TIME"
echo "3. Verify:"
echo "   ✓ Severity: LOW"
echo "   ✓ Error_Message: contains 'validation failed'"
echo "   ✓ Alert_Sent: LOG"
echo "4. Check Slack #$SLACK_CHANNEL:"
echo "   ✓ Should have NO message (LOW = log only)"
echo ""

wait_with_countdown 3 "Waiting before next test..."

################################################################################
# TEST 4: ERROR HANDLER - MEDIUM SEVERITY
################################################################################

print_header "TEST 4: ERROR HANDLER - MEDIUM SEVERITY (Generic Error)"

echo "Sending MEDIUM severity error (normal processing error)..."
TEST4_TIME=$(date '+%Y-%m-%d %H:%M:%S')

payload4='{
  "error": {
    "message": "Failed to process booking request - unexpected data format",
    "name": "ProcessingError"
  },
  "node": {
    "name": "Process Booking",
    "type": "n8n-nodes-base.code"
  }
}'

response4=$(curl -s -w "\n%{http_code}" -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d "$payload4")

status4=$(echo "$response4" | tail -n1)

if [ "$status4" -ge 200 ] && [ "$status4" -lt 300 ]; then
    record_test "PASS" "MEDIUM severity error sent successfully (HTTP $status4)"
    echo "   Test time: $TEST4_TIME"
else
    record_test "FAIL" "MEDIUM severity error failed (HTTP $status4)"
fi

echo ""
echo -e "${YELLOW}⚠️  MANUAL VERIFICATION REQUIRED:${NC}"
echo "1. Go to Google Sheets → Error Log tab"
echo "2. Find entry with timestamp around: $TEST4_TIME"
echo "3. Verify:"
echo "   ✓ Severity: MEDIUM"
echo "   ✓ Error_Message: contains 'Failed to process booking'"
echo "   ✓ Alert_Sent: SLACK"
echo "4. Check Slack #$SLACK_CHANNEL:"
echo "   ✓ Should have NEW message with error details"
echo "   ✓ Message shows workflow, node, and error"
echo ""

wait_with_countdown 3 "Waiting before next test..."

################################################################################
# TEST 5: ERROR HANDLER - HIGH SEVERITY (Critical Keywords)
################################################################################

print_header "TEST 5: ERROR HANDLER - HIGH SEVERITY (Critical Error)"

echo "Sending HIGH severity error (contains critical keyword: 'calendar')..."
TEST5_TIME=$(date '+%Y-%m-%d %H:%M:%S')

payload5='{
  "error": {
    "message": "Google Calendar API timeout after 5000ms - connection failed",
    "name": "CalendarTimeoutError"
  },
  "node": {
    "name": "Create Calendar Event",
    "type": "n8n-nodes-base.googleCalendar"
  }
}'

response5=$(curl -s -w "\n%{http_code}" -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d "$payload5")

status5=$(echo "$response5" | tail -n1)

if [ "$status5" -ge 200 ] && [ "$status5" -lt 300 ]; then
    record_test "PASS" "HIGH severity error sent successfully (HTTP $status5)"
    echo "   Test time: $TEST5_TIME"
else
    record_test "FAIL" "HIGH severity error failed (HTTP $status5)"
fi

echo ""
echo -e "${YELLOW}⚠️  MANUAL VERIFICATION REQUIRED:${NC}"
echo "1. Go to Google Sheets → Error Log tab"
echo "2. Find entry with timestamp around: $TEST5_TIME"
echo "3. Verify:"
echo "   ✓ Severity: HIGH"
echo "   ✓ Error_Message: contains 'Calendar API timeout'"
echo "   ✓ Alert_Sent: SMS"
echo "4. Check Slack #$SLACK_CHANNEL:"
echo "   ✓ Should have NEW message with HIGH severity"
echo "5. SMS: NOT sent (we skipped Twilio to avoid charges)"
echo ""

wait_with_countdown 3 "Waiting before next test..."

################################################################################
# TEST 6: RECURRING ERROR DETECTION
################################################################################

print_header "TEST 6: RECURRING ERROR DETECTION (3x Same Error)"

echo "Sending same error 3 times to trigger recurring error detection..."
TEST6_TIME=$(date '+%Y-%m-%d %H:%M:%S')

recurring_payload='{
  "error": {
    "message": "Database connection timeout - retry failed",
    "name": "DatabaseError"
  },
  "node": {
    "name": "Query Appointments",
    "type": "n8n-nodes-base.postgres"
  }
}'

echo "Sending error 1/3..."
curl -s -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d "$recurring_payload" > /dev/null

wait_with_countdown 10 "Waiting 10 seconds before error 2/3..."

echo "Sending error 2/3..."
curl -s -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d "$recurring_payload" > /dev/null

wait_with_countdown 10 "Waiting 10 seconds before error 3/3..."

echo "Sending error 3/3..."
response6=$(curl -s -w "\n%{http_code}" -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d "$recurring_payload")

status6=$(echo "$response6" | tail -n1)

if [ "$status6" -ge 200 ] && [ "$status6" -lt 300 ]; then
    record_test "PASS" "Recurring errors sent successfully"
    echo "   Test time: $TEST6_TIME"
else
    record_test "FAIL" "Recurring error test failed"
fi

echo ""
echo -e "${YELLOW}⚠️  MANUAL VERIFICATION REQUIRED:${NC}"
echo "1. Go to Google Sheets → Error Log tab"
echo "2. Find 3 entries with timestamp around: $TEST6_TIME"
echo "3. All should have same Error_Message: 'Database connection timeout'"
echo "4. Check Slack #$SLACK_CHANNEL:"
echo "   ✓ Should have ESCALATION message"
echo "   ✓ Message should say 'RECURRING ERROR ALERT'"
echo "   ✓ Should show occurrence count (3+)"
echo ""

################################################################################
# TEST 7: GOOGLE SHEETS COMPREHENSIVE VERIFICATION
################################################################################

print_header "TEST 7: GOOGLE SHEETS COMPREHENSIVE VERIFICATION"

echo -e "${BLUE}📊 Google Sheets URL:${NC}"
echo "$GOOGLE_SHEETS_URL"
echo ""

echo -e "${CYAN}System Health Log Tab:${NC}"
echo "Expected columns:"
echo "  Timestamp | Severity | Health_Percentage | Healthy_Count | Unhealthy_Count"
echo "  Critical_Failures | Warnings | Alert_Sent"
echo ""
echo "What to check:"
echo "  ✓ New entries every 5 minutes"
echo "  ✓ Severity: OK (when all healthy) or WARNING/HIGH (when issues)"
echo "  ✓ Workflow names in Warnings (NOT 'undefined')"
echo "  ✓ Timestamps are current (America/Chicago timezone)"
echo ""

echo -e "${CYAN}Error Log Tab:${NC}"
echo "Expected columns:"
echo "  Timestamp | Workflow | Node | Severity | Error_Type | Error_Message"
echo "  Execution_ID | Input_Data | Alert_Sent"
echo ""
echo "What to check:"
echo "  ✓ Entries from Tests 3, 4, 5, 6 (timestamps match)"
echo "  ✓ Severity matches (LOW, MEDIUM, HIGH)"
echo "  ✓ Alert_Sent matches (LOG, SLACK, SMS)"
echo "  ✓ Execution_ID is populated"
echo "  ✓ Workflow name is 'Error Handler Template'"
echo ""

record_test "MANUAL" "Google Sheets has all expected entries"

################################################################################
# TEST 8: SLACK COMPREHENSIVE VERIFICATION
################################################################################

print_header "TEST 8: SLACK COMPREHENSIVE VERIFICATION"

echo -e "${BLUE}💬 Slack Channel: #$SLACK_CHANNEL${NC}"
echo ""

echo "Expected messages from this test run:"
echo "  1. MEDIUM severity (Test 4) - Generic processing error"
echo "  2. HIGH severity (Test 5) - Calendar timeout error"
echo "  3. Recurring error escalation (Test 6) - Database error 3x"
echo ""

echo "What to check in each message:"
echo "  ✓ Timestamp matches test execution time"
echo "  ✓ Workflow name shown (Error Handler Template)"
echo "  ✓ Node name shown"
echo "  ✓ Error message shown"
echo "  ✓ Severity level shown"
echo "  ✓ Execution link provided (clickable to n8n)"
echo ""

echo "Expected format:"
echo "  🚨 Workflow Error Report"
echo "  Workflow: [name]"
echo "  Node: [name]"
echo "  Severity: [MEDIUM/HIGH]"
echo "  Error: [message]"
echo "  Execution ID: [id]"
echo "  Direct Link: [url]"
echo ""

record_test "MANUAL" "Slack has expected alert messages"

################################################################################
# TEST 9: N8N EXECUTION VERIFICATION
################################################################################

print_header "TEST 9: N8N EXECUTION VERIFICATION"

echo -e "${BLUE}🔧 n8n Instance: https://polarmedia.app.n8n.cloud${NC}"
echo ""

echo "Steps to verify:"
echo "1. Go to n8n → Click 'Executions' (left sidebar)"
echo "2. Filter by 'Error Handler Template'"
echo "3. You should see executions from Tests 3, 4, 5, 6"
echo ""

echo "For each execution, verify:"
echo "  ✓ Execution status: Success (green checkmark)"
echo "  ✓ 'Process Error Details' node executed"
echo "  ✓ 'Route by Severity' node executed"
echo "  ✓ Appropriate output path taken (0=HIGH, 1=MEDIUM, 2=LOW)"
echo "  ✓ 'Log to Error Sheet' node executed"
echo "  ✓ Alert nodes executed (if severity requires)"
echo ""

echo "Check System Health Monitor:"
echo "1. Filter by 'System Health Monitor v1.0'"
echo "2. Should see execution every 5 minutes"
echo "3. Latest execution should be within last 5 minutes"
echo "4. All nodes should show as executed successfully"
echo ""

record_test "MANUAL" "n8n executions show successful processing"

################################################################################
# SUMMARY
################################################################################

print_header "📊 TEST SUMMARY"

echo "Test execution completed at: $(date)"
echo ""
echo "Results:"
echo -e "  ${GREEN}Passed (Automated):${NC} $PASSED_TESTS"
echo -e "  ${RED}Failed (Automated):${NC} $FAILED_TESTS"
echo -e "  ${YELLOW}Manual Checks Required:${NC} $MANUAL_CHECKS"
echo -e "  ${BLUE}Total Tests:${NC} $TOTAL_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL AUTOMATED TESTS PASSED!${NC}"
else
    echo -e "${RED}⚠️  SOME AUTOMATED TESTS FAILED${NC}"
    echo "Review the failed tests above and check:"
    echo "  - Is Error Handler workflow ACTIVE in n8n?"
    echo "  - Is the webhook URL correct?"
    echo "  - Check n8n execution logs for errors"
fi

echo ""
echo "=================================="
echo "🔍 MANUAL VERIFICATION REQUIRED"
echo "=================================="
echo ""
echo "You must now verify the following manually:"
echo ""
echo "1. Google Sheets ($MANUAL_CHECKS checks)"
echo "   → $GOOGLE_SHEETS_URL"
echo "   → Check both 'System Health Log' and 'Error Log' tabs"
echo ""
echo "2. Slack (message verification)"
echo "   → Open Slack → #$SLACK_CHANNEL"
echo "   → Look for 3-4 messages from last few minutes"
echo ""
echo "3. n8n Executions (workflow verification)"
echo "   → https://polarmedia.app.n8n.cloud"
echo "   → Check 'Error Handler Template' executions"
echo "   → Check 'System Health Monitor v1.0' executions"
echo ""

echo "=================================="
echo "🎯 EXPECTED RESULTS SUMMARY"
echo "=================================="
echo ""
echo -e "${CYAN}LOW Severity (Test 3):${NC}"
echo "  Google Sheets: Yes | Slack: No | SMS: No"
echo ""
echo -e "${CYAN}MEDIUM Severity (Test 4):${NC}"
echo "  Google Sheets: Yes | Slack: Yes | SMS: No"
echo ""
echo -e "${CYAN}HIGH Severity (Test 5):${NC}"
echo "  Google Sheets: Yes | Slack: Yes | SMS: No (skipped)"
echo ""
echo -e "${CYAN}Recurring Errors (Test 6):${NC}"
echo "  Google Sheets: Yes (3 entries) | Slack: Yes (escalation) | SMS: No"
echo ""
echo -e "${CYAN}System Health Monitor:${NC}"
echo "  Google Sheets: Yes (every 5 min) | Slack: Only if issues | SMS: Only if CRITICAL"
echo ""

echo "=================================="
echo "✅ NEXT STEPS"
echo "=================================="
echo ""
echo "1. Complete manual verification steps above"
echo "2. If all checks pass → Monitoring system is fully working!"
echo "3. Optional: Connect Error Handler to production workflows"
echo "   (Workflow Settings → Error Workflow → 'Error Handler Template')"
echo "4. Optional: Set up UptimeRobot for external monitoring"
echo ""
echo -e "${GREEN}Test suite completed successfully!${NC}"
echo ""

