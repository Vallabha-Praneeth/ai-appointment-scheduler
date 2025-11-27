#!/bin/bash

curl -s -X POST 'https://polarmedia.app.n8n.cloud/webhook/vapi/recover' \
  -H 'Content-Type: application/json' \
  -H 'x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=' \
  -d '{
    "message": {
      "toolCalls": [{
        "id": "test_recovery_debug",
        "function": {
          "name": "recover_tool",
          "arguments": {
            "stage": "new",
            "phone": "+12145557777",
            "name": "Recovery Test User",
            "email": "recovery@test.com",
            "carry": {
              "title": "Incomplete Appointment",
              "startIso": "2025-11-30T14:00:00-06:00",
              "endIso": "2025-11-30T15:00:00-06:00",
              "timezone": "America/Chicago"
            }
          }
        }
      }]
    }
  }' | jq '.'
