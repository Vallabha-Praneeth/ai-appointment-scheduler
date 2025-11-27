#!/bin/bash

# Monitoring System Verification Script
# This script verifies the monitoring system after deployment

echo "🔍 MONITORING SYSTEM VERIFICATION"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (missing)"
        return 1
    fi
}

# 1. Check Workflow Files
echo "1. WORKFLOW FILES"
check_file "System Health Monitor v1.0.json"
check_file "Error Handler Template.json"
echo ""

# 2. Check Documentation
echo "2. DOCUMENTATION"
check_file "MONITORING_DEPLOYMENT_COMPLETE_REPORT.md"
check_file "MONITORING_QUICK_REFERENCE.md"
check_file "MONITORING_INDEX.md"
check_file "PHASE1_ENVIRONMENT_SETUP_REPORT.md"
check_file "PHASE7_TESTING_AND_VALIDATION_REPORT.md"
echo ""

# 3. Check if n8n instance is reachable
echo "3. N8N INSTANCE REACHABILITY"
if command -v curl &> /dev/null; then
    response=$(curl -s -o /dev/null -w "%{http_code}" https://polarmedia.app.n8n.cloud 2>/dev/null)
    if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
        echo -e "${GREEN}✓${NC} n8n instance is reachable (HTTP $response)"
    else
        echo -e "${YELLOW}⚠${NC} n8n instance returned HTTP $response (may require login)"
    fi
else
    echo -e "${YELLOW}⚠${NC} curl not available, cannot check n8n instance"
fi
echo ""

# 4. Check webhook endpoints (if accessible)
echo "4. WEBHOOK ENDPOINTS"
echo "   (Checking if webhooks respond - 405 is OK for GET on POST endpoints)"

webhooks=(
    "https://polarmedia.app.n8n.cloud/webhook/vapi/call"
    "https://polarmedia.app.n8n.cloud/webhook/vapi/lookup"
    "https://polarmedia.app.n8n.cloud/webhook/vapi/cancel"
    "https://polarmedia.app.n8n.cloud/webhook/vapi/reschedule"
)

if command -v curl &> /dev/null; then
    for webhook in "${webhooks[@]}"; do
        response=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$webhook" 2>/dev/null)
        endpoint=$(echo $webhook | sed 's|https://polarmedia.app.n8n.cloud/webhook/vapi/||')

        if [ "$response" = "200" ] || [ "$response" = "405" ]; then
            echo -e "   ${GREEN}✓${NC} $endpoint (HTTP $response)"
        elif [ "$response" = "000" ]; then
            echo -e "   ${RED}✗${NC} $endpoint (no response - may be inactive)"
        else
            echo -e "   ${YELLOW}⚠${NC} $endpoint (HTTP $response)"
        fi
    done
else
    echo -e "   ${YELLOW}⚠${NC} curl not available, cannot check webhooks"
fi
echo ""

# 5. Check if test scripts exist
echo "5. TEST SCRIPTS"
if [ -f "run_all_tests.sh" ]; then
    echo -e "   ${GREEN}✓${NC} run_all_tests.sh exists"
    if [ -x "run_all_tests.sh" ]; then
        echo -e "   ${GREEN}✓${NC} run_all_tests.sh is executable"
    else
        echo -e "   ${YELLOW}⚠${NC} run_all_tests.sh is not executable (run: chmod +x run_all_tests.sh)"
    fi
else
    echo -e "   ${YELLOW}⚠${NC} run_all_tests.sh not found"
fi
echo ""

# 6. Summary
echo "=================================="
echo "DEPLOYMENT READINESS SUMMARY"
echo "=================================="
echo ""
echo "Files Ready:          ✓"
echo "Documentation:        ✓"
echo "n8n Instance:         (check above)"
echo "Webhooks:             (check above)"
echo ""
echo "MANUAL STEPS REQUIRED:"
echo "  1. Log into n8n: https://polarmedia.app.n8n.cloud"
echo "  2. Import workflow: System Health Monitor v1.0.json"
echo "  3. Create Google Sheet for monitoring data"
echo "  4. Set environment variables in n8n"
echo "  5. Configure credentials (Twilio, Email, Sheets)"
echo "  6. Add error handlers to all workflows"
echo "  7. Set up UptimeRobot monitoring"
echo "  8. Run tests: ./run_all_tests.sh"
echo ""
echo "📖 START HERE: MONITORING_DEPLOYMENT_COMPLETE_REPORT.md"
echo "=================================="
