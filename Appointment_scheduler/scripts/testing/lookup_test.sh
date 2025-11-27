#!/bin/bash
curl -s -X POST https://polarmedia.app.n8n.cloud/webhook/vapi-lookup \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=" \
  -d '{"bookingId": "mppqagl0ntsou80cse2gktq7gk"}' | python3 -m json.tool
