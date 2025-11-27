#!/bin/bash

echo "========================================"
echo "🧪 ERROR HANDLER TESTING"
echo "========================================"
echo ""
echo "Test 1: Trigger Error Handler via Webhook"
echo "----------------------------------------"

response=$(curl -s -X POST "https://polarmedia.app.n8n.cloud/webhook/error-handler" \
  -H "Content-Type: application/json" \
  -d '{
    "error": {
      "message": "Test error for monitoring",
      "name": "TestError"
    },
    "node": {
      "name": "Test Node",
      "type": "test-type"
    }
  }')

echo "Response from webhook:"
echo "$response"
echo ""

echo "========================================"
echo "✅ WEBHOOK TEST COMPLETE"
echo "========================================"
echo ""
echo "NOW CHECK IN N8N:"
echo "1. Go to: https://polarmedia.app.n8n.cloud"
echo "2. Click 'Executions' in left sidebar"
echo "3. Find latest 'Error Handler Template' execution"
echo "4. Click on it to see execution flow"
echo ""
echo "WHAT TO VERIFY:"
echo "- Process Error Details: Check output has severity='MEDIUM'"
echo "- Route by Severity: Should route to output 1 (Slack)"
echo "- Send Email Alert (Slack): Should execute"
echo "- Log to Error Sheet: Should execute"
echo ""
echo "CHECK GOOGLE SHEETS:"
echo "https://docs.google.com/spreadsheets/d/1ewZhow8YltZJy9cNynnZ6-ei5v32XuRHKV8rPJ9l6JI"
echo "- Go to 'Error Log' tab"
echo "- Should see new entry with timestamp"
echo ""
echo "CHECK SLACK:"
echo "- Channel: #system-alerts-appointment_ai"
echo "- Should see error message"
echo ""
