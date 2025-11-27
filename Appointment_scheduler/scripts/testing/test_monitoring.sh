#!/bin/bash

echo "🧪 TESTING MONITORING SYSTEM"
echo "=============================="
echo ""

echo "TEST 1: Check System Health Monitor Status"
echo "-------------------------------------------"
curl -s -I https://polarmedia.app.n8n.cloud/webhook/vapi/call 2>&1 | head -5
echo ""

echo "TEST 2: Trigger Error in Main Booking Workflow"
echo "------------------------------------------------"
echo "Sending empty payload to trigger validation error..."
curl -X POST "https://polarmedia.app.n8n.cloud/webhook/vapi/call" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{}' 2>&1 | head -10
echo ""

echo "TEST 3: Check All Monitored Endpoints"
echo "--------------------------------------"

endpoints="call lookup cancel reschedule recovery"

for endpoint in $endpoints; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "https://polarmedia.app.n8n.cloud/webhook/vapi/$endpoint" 2>/dev/null)
    if [ "$status" = "200" ] || [ "$status" = "405" ]; then
        echo "✅ $endpoint - UP (HTTP $status)"
    else
        echo "⚠️  $endpoint - Status: HTTP $status"
    fi
done

echo ""
echo "=============================="
echo "WHAT TO CHECK NOW IN N8N:"
echo "=============================="
echo "1. Go to n8n → Executions (left sidebar)"
echo "2. Look for 'System Health Monitor v1.0' - should run every 5 min"
echo "3. Look for 'Error Handler Template' - may have executed if error caught"
echo "4. Check 'Appointment Scheduling AI_v.0.0.3' execution logs"
echo ""
echo "WHAT TO CHECK IN GOOGLE SHEETS:"
echo "================================"
echo "Sheet: https://docs.google.com/spreadsheets/d/1ewZhow8YltZJy9cNynnZ6-ei5v32XuRHKV8rPJ9l6JI"
echo "1. 'System Health Log' tab - should have entries every 5 min"
echo "2. 'Error Log' tab - should have error entries if caught"
echo ""
echo "WHAT TO CHECK IN SLACK:"
echo "======================="
echo "Channel: #system-alerts-appointment_ai"
echo "- Should see health alerts if any workflows down"
echo "- Should see error messages if Error Handler triggered"
echo ""
