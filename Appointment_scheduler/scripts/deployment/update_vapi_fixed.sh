#!/bin/bash

# Update Vapi Assistant - Fixed Version
set -e

ASSISTANT_ID="0353253e-cc69-4d36-a53e-ebaa150fd089"
API_KEY="897d1765-8294-48c1-85fc-6001de55f418"
PROMPT_FILE="../vapi/updated_assistant_prompt.txt"

echo "Reading updated prompt..."
SYSTEM_PROMPT=$(cat "$PROMPT_FILE")

echo "Creating payload..."
PAYLOAD=$(jq -n --arg content "$SYSTEM_PROMPT" '{
  "model": {
    "provider": "openai",
    "model": "gpt-4o",
    "messages": [{
      "role": "system",
      "content": $content
    }]
  }
}')

echo "Updating assistant $ASSISTANT_ID..."
RESPONSE=$(curl -s -X PATCH "https://api.vapi.ai/assistant/$ASSISTANT_ID" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

echo ""
echo "Response:"
echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo ""
    echo "✅ Update successful!"

    # Verify
    echo ""
    echo "Verifying update..."
    VERIFY=$(curl -s "https://api.vapi.ai/assistant/$ASSISTANT_ID" \
      -H "Authorization: Bearer $API_KEY")

    echo "$VERIFY" | jq -r '.model.messages[0].content' | grep -q "November 24, 2025" && echo "✅ Date verified"
    echo "$VERIFY" | jq -r '.model.messages[0].content' | grep -q "CRITICAL TOOL USAGE RULES" && echo "✅ Tool rules found"
    echo "$VERIFY" | jq -r '.model.messages[0].content' | grep -q "sameDayAvailable" && echo "✅ Alternatives logic found"
else
    echo "❌ Update failed"
    exit 1
fi
