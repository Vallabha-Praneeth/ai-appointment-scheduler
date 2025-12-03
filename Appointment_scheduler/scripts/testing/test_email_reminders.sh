#!/bin/bash

# Test Email Reminders - 24h and 4h workflows
# This creates a test appointment for tomorrow to trigger the reminder system

echo "========================================="
echo "Email Reminder System - Test"
echo "========================================="
echo ""

# Calculate tomorrow's date
TOMORROW=$(date -v+1d "+%Y-%m-%d")
echo "Creating test appointment for: $TOMORROW at 2:00 PM"
echo ""

# Your email address - CHANGE THIS!
YOUR_EMAIL="praneeth@thepolarmedia.com"

echo "⚠️  IMPORTANT: Update YOUR_EMAIL in this script first!"
echo "   Current email: $YOUR_EMAIL"
echo ""
read -p "Press ENTER to continue or Ctrl+C to cancel and update the email..."

echo ""
echo "Creating test appointment..."
echo ""

# Create test appointment with email
RESPONSE=$(curl -s -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/call \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Consultation\",
    \"startIso\": \"${TOMORROW}T14:00:00-06:00\",
    \"endIso\": \"${TOMORROW}T15:00:00-06:00\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Email Test User\",
    \"phone\": \"+919494348091\",
    \"service_type\": \"consultation\",
    \"email\": \"${YOUR_EMAIL}\"
  }")

echo "Response: $RESPONSE"
echo ""

if echo "$RESPONSE" | grep -q "booked"; then
  echo "✓ Test appointment created successfully!"
  echo ""
  echo "Next steps:"
  echo "========================================="
  echo ""
  echo "1. Go to n8n: https://polarmedia.app.n8n.cloud"
  echo ""
  echo "2. Open 'Smart Reminder System 24h' workflow"
  echo ""
  echo "3. Click 'Execute Workflow' button (manual test)"
  echo ""
  echo "4. Check your email inbox for:"
  echo "   - From: quantumops9@gmail.com"
  echo "   - Subject: Reminder: Appointment tomorrow at 2:00 PM"
  echo ""
  echo "5. Check your phone (+919494348091) for SMS"
  echo ""
  echo "6. Verify both arrived successfully!"
  echo ""
  echo "========================================="
else
  echo "✗ Failed to create test appointment"
  echo "Check the error message above"
fi

echo ""
echo "Note: The actual reminders will send automatically:"
echo "  - 24h reminder: Tomorrow at 9:00 AM"
echo "  - 4h reminder: Tomorrow at 10:00 AM (4h before 2:00 PM)"
