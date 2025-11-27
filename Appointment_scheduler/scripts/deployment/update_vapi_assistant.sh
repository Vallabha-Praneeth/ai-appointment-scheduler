#!/bin/bash

# Update Vapi Assistant Configuration Script
# This script updates the assistant's system prompt with the latest version

set -e

# Configuration
ASSISTANT_ID="cda9d127-ac08-45d3-93d7-3d18ad9570fc"
VAPI_API_URL="https://api.vapi.ai"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if VAPI_PRIVATE_KEY is set
if [ -z "$VAPI_PRIVATE_KEY" ]; then
    echo -e "${RED}Error: VAPI_PRIVATE_KEY environment variable is not set${NC}"
    echo "Please export your Vapi private key:"
    echo "  export VAPI_PRIVATE_KEY='your_key_here'"
    exit 1
fi

# Read the updated prompt
PROMPT_FILE="../vapi/updated_assistant_prompt.txt"
if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}Error: Prompt file not found at $PROMPT_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}Reading updated prompt from $PROMPT_FILE${NC}"
SYSTEM_PROMPT=$(cat "$PROMPT_FILE")

# Create JSON payload
PAYLOAD=$(jq -n \
  --arg content "$SYSTEM_PROMPT" \
  '{
    "model": {
      "messages": [{
        "role": "system",
        "content": $content
      }]
    }
  }')

# Backup current configuration
echo -e "${YELLOW}Backing up current assistant configuration...${NC}"
curl -s "$VAPI_API_URL/assistant/$ASSISTANT_ID" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  > "vapi_assistant_backup_$(date +%Y%m%d_%H%M%S).json"

echo -e "${GREEN}Backup saved${NC}"

# Update the assistant
echo -e "${YELLOW}Updating assistant $ASSISTANT_ID...${NC}"
RESPONSE=$(curl -s -X PATCH "$VAPI_API_URL/assistant/$ASSISTANT_ID" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Check if update was successful
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Assistant updated successfully!${NC}"
    echo ""
    echo "Updated fields:"
    echo "$RESPONSE" | jq '.model.messages[0].content' | head -20
    echo "..."
else
    echo -e "${RED}❌ Failed to update assistant${NC}"
    echo "Response:"
    echo "$RESPONSE" | jq '.'
    exit 1
fi

# Verify the update
echo ""
echo -e "${YELLOW}Verifying update...${NC}"
VERIFY_RESPONSE=$(curl -s "$VAPI_API_URL/assistant/$ASSISTANT_ID" \
  -H "Authorization: Bearer $VAPI_PRIVATE_KEY")

# Check if TODAY date is correct in the prompt
if echo "$VERIFY_RESPONSE" | jq -r '.model.messages[0].content' | grep -q "TODAY is November 24, 2025"; then
    echo -e "${GREEN}✅ Date verification passed: TODAY is November 24, 2025${NC}"
else
    echo -e "${RED}⚠️  Warning: Date may not be updated correctly${NC}"
fi

# Check if CRITICAL TOOL USAGE RULES section exists
if echo "$VERIFY_RESPONSE" | jq -r '.model.messages[0].content' | grep -q "CRITICAL TOOL USAGE RULES"; then
    echo -e "${GREEN}✅ CRITICAL TOOL USAGE RULES section found${NC}"
else
    echo -e "${RED}⚠️  Warning: CRITICAL TOOL USAGE RULES section not found${NC}"
fi

# Check if time interpretation rule exists
if echo "$VERIFY_RESPONSE" | jq -r '.model.messages[0].content' | grep -q "When user says \"10\" without AM/PM"; then
    echo -e "${GREEN}✅ Time interpretation rule found${NC}"
else
    echo -e "${RED}⚠️  Warning: Time interpretation rule not found${NC}"
fi

# Check if sameDayAvailable logic exists
if echo "$VERIFY_RESPONSE" | jq -r '.model.messages[0].content' | grep -q "sameDayAvailable"; then
    echo -e "${GREEN}✅ sameDayAvailable logic found${NC}"
else
    echo -e "${RED}⚠️  Warning: sameDayAvailable logic not found${NC}"
fi

echo ""
echo -e "${GREEN}Update complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Test the assistant with: 'I want to book an appointment tomorrow at 10'"
echo "2. Verify function_tool is called (not check_availability_tool)"
echo "3. Run the full test suite from vapi_testing_plan.md"
