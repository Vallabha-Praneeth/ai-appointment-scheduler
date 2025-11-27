#!/bin/bash
curl -s -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/recover \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{
    "phone": "+12145551234",
    "stage": "booking"
  }' | python3 -m json.tool
