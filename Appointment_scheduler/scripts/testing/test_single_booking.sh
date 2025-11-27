#!/bin/bash

# Test a single booking for Nov 26
curl -s -X POST 'https://polarmedia.app.n8n.cloud/webhook/vapi/call' \
  -H 'Content-Type: application/json' \
  -H 'x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=' \
  -d '{
    "message": {
      "type": "tool-calls",
      "toolCalls": [{
        "id": "test_booking_debug",
        "function": {
          "name": "function_tool",
          "arguments": {
            "name": "Debug Test",
            "email": "debug@test.com",
            "phone": "+19999999999",
            "title": "Debug Appointment",
            "startIso": "2025-11-26T14:00:00-06:00",
            "endIso": "2025-11-26T15:00:00-06:00",
            "timezone": "America/Chicago",
            "service_type": "consultation",
            "confirm": "yes"
          }
        }
      }]
    }
  }' | jq '.'
