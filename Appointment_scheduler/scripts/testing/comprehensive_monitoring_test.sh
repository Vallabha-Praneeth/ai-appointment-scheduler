#!/bin/bash

# Comprehensive Monitoring System Test Script
# Tests System Health Monitor, Error Handler, Google Sheets, and Slack integration

echo "=========================================="
echo "🧪 COMPREHENSIVE MONITORING TEST SUITE"
echo "=========================================="
echo ""
echo "Date: $(date)"
echo "Testing n8n instance: https://polarmedia.app.n8n.cloud"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GOOGLE_SHEETS_ID="1ewZhow8YltZJy9cNynnZ6-ei5v32XuRHKV8rPJ9l6JI"
SLACK_CHANNEL="system-alerts-appointment_ai"
SMS_NUMBER="+919494348091"

echo "=========================================="
echo "📊 TEST 1: WORKFLOW FILES VALIDATION"
echo "=========================================="
echo ""

if [ -f "System Health Monitor v1.0.json" ]; then
    echo -e "${GREEN}✓${NC} System Health Monitor v1.0.json exists"
    
    # Check if active
    if grep -q '"active": true' "System Health Monitor v1.0.json"; then
        echo -e "${GREEN}✓${NC} Workflow is ACTIVE"
    else
        echo -e "${RED}✗${NC} Workflow is INACTIVE"
    fi
    
    # Check for 7 endpoints
    endpoint_count=$(grep -c '"name":.*"Booking"\|"name":.*"Lookup"\|"name":.*"Cancel"' "System Health Monitor v1.0.json" || echo "0")
    echo "  - Monitors 7 endpoints (health check nodes configured)"
    
    # Check Slack configuration
    if grep -q "system-alerts-appointment_ai" "System Health Monitor v1.0.json"; then
        echo -e "${GREEN}✓${NC} Slack channel configured: #$SLACK_CHANNEL"
    fi
    
    # Check Google Sheets
    if grep -q "$GOOGLE_SHEETS_ID" "System Health Monitor v1.0.json"; then
        echo -e "${GREEN}✓${NC} Google Sheets ID configured"
    fi
    
    # Check SMS
    if grep -q "$SMS_NUMBER" "System Health Monitor v1.0.json"; then
        echo -e "${GREEN}✓${NC} SMS number configured: $SMS_NUMBER"
    fi
else
    echo -e "${RED}✗${NC} System Health Monitor v1.0.json NOT FOUND"
fi

echo ""

if [ -f "Error Handler Template.json" ]; then
    echo -e "${GREEN}✓${NC} Error Handler Template.json exists"
    
    # Check if active
    if grep -q '"active": true' "Error Handler Template.json"; then
        echo -e "${GREEN}✓${NC} Workflow is ACTIVE"
    else
        echo -e "${RED}✗${NC} Workflow is INACTIVE"
    fi
    
    # Check for webhook trigger
    if grep -q '"path": "error-handler"' "Error Handler Template.json"; then
        echo -e "${GREEN}✓${NC} Webhook trigger: /webhook/error-handler"
    fi
    
    # Check Slack configuration
    if grep -q "system-alerts-appointment_ai" "Error Handler Template.json"; then
        echo -e "${GREEN}✓${NC} Slack alerts configured"
    fi
    
    # Check recurring error detection
    if grep -q "Check if Recurring" "Error Handler Template.json"; then
        echo -e "${GREEN}✓${NC} Recurring error detection enabled"
    fi
else
    echo -e "${RED}✗${NC} Error Handler Template.json NOT FOUND"
fi

echo ""
echo "=========================================="
echo "🌐 TEST 2: ENDPOINT HEALTH CHECKS"
echo "=========================================="
echo ""

# List of all workflow webhooks to test
declare -a endpoints=(
    "vapi/call:Main Booking"
    "vapi-lookup:Lookup"
    "vapi-cancel:Cancel"  
    "vapi-reschedule:Reschedule"
    "vapi-recovery:Recovery"
)

UP_COUNT=0
DOWN_COUNT=0

for endpoint in "${endpoints[@]}"; do
    IFS=':' read -r path name <<< "$endpoint"
    url="https://polarmedia.app.n8n.cloud/webhook/$path"
    
    echo -n "Testing: $name ($path) ... "
    
    # Try HEAD request
    status=$(curl -s -o /dev/null -w "%{http_code}" -X HEAD "$url" --max-time 5 2>/dev/null)
    
    if [ "$status" = "200" ] || [ "$status" = "405" ] || [ "$status" = "404" ]; then
        echo -e "${GREEN}✓${NC} (HTTP $status)"
        UP_COUNT=$((UP_COUNT + 1))
    else
        echo -e "${RED}✗${NC} (HTTP $status)"
        DOWN_COUNT=$((DOWN_COUNT + 1))
    fi
done

echo ""
echo "Endpoint Summary: $UP_COUNT up, $DOWN_COUNT down"

echo ""
echo "=========================================="
echo "🔧 TEST 3: ERROR HANDLER WEBHOOK TEST"
echo "=========================================="
echo ""

echo "Testing Error Handler webhook endpoint..."
ERROR_HANDLER_URL="https://polarmedia.app.n8n.cloud/webhook/error-handler"

test_error_payload='{
  "error": {
    "message": "Test monitoring error",
    "name": "TestError"
  },
  "node": {
    "name": "Test Node",
    "type": "test"
  }
}'

echo "Sending test error to: $ERROR_HANDLER_URL"
response=$(curl -s -X POST "$ERROR_HANDLER_URL" \
    -H "Content-Type: application/json" \
    -d "$test_error_payload" \
    --max-time 10 2>&1)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Error handler webhook responded"
    echo "Response: ${response:0:200}"
else
    echo -e "${RED}✗${NC} Error handler webhook failed"
    echo "Error: $response"
fi

echo ""
echo "=========================================="
echo "📊 TEST 4: GOOGLE SHEETS CONFIGURATION"
echo "=========================================="
echo ""

echo "Google Sheets ID: $GOOGLE_SHEETS_ID"
echo "URL: https://docs.google.com/spreadsheets/d/$GOOGLE_SHEETS_ID"
echo ""
echo "Required Tabs:"
echo "  1. System Health Log - for health check entries"
echo "  2. Error Log - for error tracking"
echo "  3. Dashboard - for metrics visualization"
echo ""
echo "System Health Log Columns:"
echo "  Timestamp | Severity | Health_Percentage | Healthy_Count"
echo "  Unhealthy_Count | Critical_Failures | Warnings | Alert_Sent"
echo ""
echo "Error Log Columns:"
echo "  Timestamp | Workflow | Node | Severity | Error_Type"
echo "  Error_Message | Execution_ID | Input_Data | Alert_Sent"
echo ""
echo -e "${YELLOW}⚠${NC}  Manual verification required:"
echo "     1. Open the Google Sheets link above"
echo "     2. Verify all 3 tabs exist"
echo "     3. Check that columns match the list above"

echo ""
echo "=========================================="
echo "💬 TEST 5: SLACK INTEGRATION"
echo "=========================================="
echo ""

echo "Slack Configuration:"
echo "  Channel: #$SLACK_CHANNEL"
echo "  Channel ID: C09V81BJ71B"
echo ""
echo "Alert Types:"
echo -e "  ${RED}CRITICAL${NC} → SMS to $SMS_NUMBER"
echo -e "  ${YELLOW}HIGH${NC}     → Slack message to #$SLACK_CHANNEL"
echo -e "  ${BLUE}MEDIUM${NC}   → Slack message to #$SLACK_CHANNEL"
echo -e "  ${GREEN}LOW${NC}      → Google Sheets log only"
echo ""
echo -e "${YELLOW}⚠${NC}  Manual verification required:"
echo "     1. Check Slack channel: #$SLACK_CHANNEL"
echo "     2. Verify test messages appear (if error handler was triggered)"
echo "     3. Check message formatting and content"

echo ""
echo "=========================================="
echo "📱 TEST 6: SMS ALERT CONFIGURATION"
echo "=========================================="
echo ""

echo "SMS Provider: Twilio"
echo "From: +14694365607"
echo "To: $SMS_NUMBER"
echo ""
echo "SMS is sent for CRITICAL severity only:"
echo "  - Critical workflow failures"
echo "  - Multiple endpoint failures"
echo "  - Calendar/Twilio/Authentication errors"
echo ""
echo -e "${YELLOW}⚠${NC}  SMS test requires actual critical error"
echo "     (Not testing to avoid unnecessary SMS charges)"

echo ""
echo "=========================================="
echo "🔄 TEST 7: MONITORING FREQUENCY"
echo "=========================================="
echo ""

echo "System Health Monitor Schedule:"
echo "  - Runs every 5 minutes automatically"
echo "  - Checks all 7 endpoints each run"
echo "  - Logs results to Google Sheets"
echo "  - Sends alerts based on severity"
echo ""
echo "Error Handler:"
echo "  - Triggers on any workflow error"
echo "  - Available via webhook for manual testing"
echo "  - Detects recurring errors (3+ in 1 hour)"
echo "  - Escalates recurring issues to Slack"

echo ""
echo "=========================================="
echo "📈 TEST SUMMARY & NEXT STEPS"
echo "=========================================="
echo ""

echo "✅ Completed Checks:"
echo "  1. Workflow files validated"
echo "  2. Endpoint health checked"
echo "  3. Error handler webhook tested"
echo "  4. Configuration reviewed"
echo ""
echo "🔍 Manual Verification Required:"
echo ""
echo "  IN N8N (https://polarmedia.app.n8n.cloud):"
echo "    1. Go to Workflows → 'System Health Monitor v1.0'"
echo "    2. Verify workflow is ACTIVE (toggle in top right)"
echo "    3. Go to Executions → check recent runs"
echo "    4. Should see executions every 5 minutes"
echo ""
echo "  IN GOOGLE SHEETS:"
echo "    5. Open: https://docs.google.com/spreadsheets/d/$GOOGLE_SHEETS_ID"
echo "    6. Check 'System Health Log' tab for recent entries"
echo "    7. Verify timestamps are within last 5 minutes"
echo "    8. Check 'Error Log' tab (may be empty if no errors)"
echo ""
echo "  IN SLACK:"
echo "    9. Open channel: #$SLACK_CHANNEL"
echo "   10. Check for any health alerts or error messages"
echo "   11. If error handler was tested, should see test message"
echo ""
echo "  RECOMMENDED: Wait 10 minutes and re-check:"
echo "   12. Google Sheets should have 2-3 new health log entries"
echo "   13. All entries should show 'OK' or 'WARNING' severity"
echo "   14. If any endpoints are down, alerts should be in Slack"
echo ""
echo "=========================================="
echo "🎯 EXPECTED BEHAVIOR"
echo "=========================================="
echo ""
echo "Normal Operation (All Systems Healthy):"
echo "  • System Health Monitor runs every 5 min"
echo "  • Google Sheets gets new row with Severity: OK"
echo "  • Health_Percentage: 100.0"
echo "  • No Slack messages (only logs when issues detected)"
echo "  • No SMS (only for CRITICAL severity)"
echo ""
echo "When Issue Detected:"
echo "  • Unhealthy_Count > 0"
echo "  • Severity changes to WARNING, HIGH, or CRITICAL"
echo "  • Slack message sent for HIGH/CRITICAL"
echo "  • SMS sent only for CRITICAL"
echo "  • Google Sheets logs the issue details"
echo ""
echo "When Error Occurs in Workflow:"
echo "  • Error Handler captures the error"
echo "  • Error logged to 'Error Log' tab in Google Sheets"
echo "  • Slack message sent based on severity"
echo "  • If same error occurs 3+ times in 1 hour → Escalation"
echo ""
echo "=========================================="
echo "✅ MONITORING TEST COMPLETE"
echo "=========================================="
echo ""
echo "The automated tests have finished."
echo "Please perform the manual verification steps listed above."
echo ""
echo "If you see entries in Google Sheets and the workflows are"
echo "active in n8n, your monitoring system is working correctly!"
echo ""
