#!/bin/bash

# Analytics Dashboard - All Scenarios Test Script
# Tests: 10 bookings, 5 reschedules, 3 cancels, 5 group bookings
# Total: 23 operations to populate analytics data

WEBHOOK_BASE="https://polarmedia.app.n8n.cloud/webhook/vapi"
TEST_PHONE="+919494348091"

echo "========================================="
echo "Analytics Dashboard - All Scenarios Test"
echo "========================================="
echo ""
echo "This will create:"
echo "  - 10 initial bookings (various service types)"
echo "  - 5 reschedules"
echo "  - 3 cancellations"
echo "  - 5 group bookings"
echo ""
echo "Expected revenue in Analytics Dashboard:"
echo "  Consultation (3): 3 x \$100 = \$300"
echo "  Maintenance (2): 2 x \$150 = \$300"
echo "  Support (2): 2 x \$75 = \$150"
echo "  Onsite (1): 1 x \$200 = \$200"
echo "  Emergency (1): 1 x \$250 = \$250"
echo "  Group Booking (5): 5 x \$300 = \$1,500"
echo "  Cancelled (3): \$0 (revenue only counted for Completed)"
echo "========================================="
echo ""

# Array to store booking IDs for reschedule/cancel operations
declare -a BOOKING_IDS

# Function to extract bookingId from response
extract_booking_id() {
    echo "$1" | grep -o '"bookingId":"[^"]*"' | cut -d'"' -f4
}

# Function to generate datetime (past dates for "Completed" status)
generate_past_datetime() {
    local days_ago=$1
    local hour=$2
    date -v-${days_ago}d -v${hour}H -v0M -v0S "+%Y-%m-%dT%H:%M:%S-06:00"
}

# Function to generate future datetime (for "Scheduled" status)
generate_future_datetime() {
    local days_ahead=$1
    local hour=$2
    date -v+${days_ahead}d -v${hour}H -v0M -v0S "+%Y-%m-%dT%H:%M:%S-06:00"
}

echo "PHASE 1: Creating 10 Initial Bookings"
echo "======================================"
echo ""

# Booking 1: Consultation (past - will be "Completed")
echo "[1/10] Creating Consultation appointment..."
START=$(generate_past_datetime 5 10)
END=$(generate_past_datetime 5 11)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Consultation\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"John Doe\",
    \"phone\": \"${TEST_PHONE}\",
    \"service_type\": \"consultation\",
    \"email\": \"john.doe@example.com\"
  }")
BOOKING_IDS[0]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[0]}"
sleep 1

# Booking 2: Maintenance (past)
echo "[2/10] Creating Maintenance appointment..."
START=$(generate_past_datetime 8 14)
END=$(generate_past_datetime 8 15)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Maintenance\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Jane Smith\",
    \"phone\": \"+12145552222\",
    \"service_type\": \"maintenance\",
    \"email\": \"jane.smith@example.com\"
  }")
BOOKING_IDS[1]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[1]}"
sleep 1

# Booking 3: Support (past)
echo "[3/10] Creating Support appointment..."
START=$(generate_past_datetime 12 11)
END=$(generate_past_datetime 12 12)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Support\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Bob Johnson\",
    \"phone\": \"+12145553333\",
    \"service_type\": \"support\",
    \"email\": \"bob.johnson@example.com\"
  }")
BOOKING_IDS[2]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[2]}"
sleep 1

# Booking 4: Onsite (past)
echo "[4/10] Creating Onsite appointment..."
START=$(generate_past_datetime 15 13)
END=$(generate_past_datetime 15 15)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Onsite\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Alice Brown\",
    \"phone\": \"+12145554444\",
    \"service_type\": \"onsite\",
    \"email\": \"alice.brown@example.com\"
  }")
BOOKING_IDS[3]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[3]}"
sleep 1

# Booking 5: Emergency (past)
echo "[5/10] Creating Emergency appointment..."
START=$(generate_past_datetime 3 16)
END=$(generate_past_datetime 3 17)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Emergency\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Charlie Davis\",
    \"phone\": \"+12145555555\",
    \"service_type\": \"emergency\",
    \"email\": \"charlie.davis@example.com\"
  }")
BOOKING_IDS[4]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[4]}"
sleep 1

# Booking 6: Consultation (future - will be "Scheduled")
echo "[6/10] Creating Consultation appointment (future)..."
START=$(generate_future_datetime 3 10)
END=$(generate_future_datetime 3 11)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Consultation\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"David Wilson\",
    \"phone\": \"+12145556666\",
    \"service_type\": \"consultation\",
    \"email\": \"david.wilson@example.com\"
  }")
BOOKING_IDS[5]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[5]}"
sleep 1

# Booking 7: Maintenance (future)
echo "[7/10] Creating Maintenance appointment (future)..."
START=$(generate_future_datetime 5 14)
END=$(generate_future_datetime 5 15)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Maintenance\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Eva Martinez\",
    \"phone\": \"+12145557777\",
    \"service_type\": \"maintenance\",
    \"email\": \"eva.martinez@example.com\"
  }")
BOOKING_IDS[6]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[6]}"
sleep 1

# Booking 8: Support (future)
echo "[8/10] Creating Support appointment (future)..."
START=$(generate_future_datetime 7 11)
END=$(generate_future_datetime 7 12)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Support\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Frank Garcia\",
    \"phone\": \"+12145558888\",
    \"service_type\": \"support\",
    \"email\": \"frank.garcia@example.com\"
  }")
BOOKING_IDS[7]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[7]}"
sleep 1

# Booking 9: Consultation (past)
echo "[9/10] Creating Consultation appointment..."
START=$(generate_past_datetime 20 15)
END=$(generate_past_datetime 20 16)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Consultation\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Grace Lee\",
    \"phone\": \"+12145559999\",
    \"service_type\": \"consultation\",
    \"email\": \"grace.lee@example.com\"
  }")
BOOKING_IDS[8]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[8]}"
sleep 1

# Booking 10: Standard (past)
echo "[10/10] Creating Standard appointment..."
START=$(generate_past_datetime 25 12)
END=$(generate_past_datetime 25 13)
RESPONSE=$(curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Standard\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Henry Taylor\",
    \"phone\": \"+12145550000\",
    \"service_type\": \"standard\",
    \"email\": \"henry.taylor@example.com\"
  }")
BOOKING_IDS[9]=$(extract_booking_id "$RESPONSE")
echo "✓ Created: ${BOOKING_IDS[9]}"
sleep 2

echo ""
echo "PHASE 2: Rescheduling 5 Appointments"
echo "======================================"
echo ""

# Reschedule 1
echo "[1/5] Rescheduling booking ${BOOKING_IDS[0]}..."
NEW_START=$(generate_past_datetime 4 11)
NEW_END=$(generate_past_datetime 4 12)
curl -s -X POST "${WEBHOOK_BASE}/reschedule" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[0]}\",
    \"newStartIso\": \"${NEW_START}\",
    \"newEndIso\": \"${NEW_END}\",
    \"timezone\": \"America/Chicago\"
  }" > /dev/null
echo "✓ Rescheduled to new time"
sleep 1

# Reschedule 2
echo "[2/5] Rescheduling booking ${BOOKING_IDS[1]}..."
NEW_START=$(generate_past_datetime 7 10)
NEW_END=$(generate_past_datetime 7 11)
curl -s -X POST "${WEBHOOK_BASE}/reschedule" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[1]}\",
    \"newStartIso\": \"${NEW_START}\",
    \"newEndIso\": \"${NEW_END}\",
    \"timezone\": \"America/Chicago\"
  }" > /dev/null
echo "✓ Rescheduled to new time"
sleep 1

# Reschedule 3
echo "[3/5] Rescheduling booking ${BOOKING_IDS[5]}..."
NEW_START=$(generate_future_datetime 4 14)
NEW_END=$(generate_future_datetime 4 15)
curl -s -X POST "${WEBHOOK_BASE}/reschedule" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[5]}\",
    \"newStartIso\": \"${NEW_START}\",
    \"newEndIso\": \"${NEW_END}\",
    \"timezone\": \"America/Chicago\"
  }" > /dev/null
echo "✓ Rescheduled to new time"
sleep 1

# Reschedule 4
echo "[4/5] Rescheduling booking ${BOOKING_IDS[6]}..."
NEW_START=$(generate_future_datetime 6 13)
NEW_END=$(generate_future_datetime 6 14)
curl -s -X POST "${WEBHOOK_BASE}/reschedule" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[6]}\",
    \"newStartIso\": \"${NEW_START}\",
    \"newEndIso\": \"${NEW_END}\",
    \"timezone\": \"America/Chicago\"
  }" > /dev/null
echo "✓ Rescheduled to new time"
sleep 1

# Reschedule 5
echo "[5/5] Rescheduling booking ${BOOKING_IDS[7]}..."
NEW_START=$(generate_future_datetime 8 15)
NEW_END=$(generate_future_datetime 8 16)
curl -s -X POST "${WEBHOOK_BASE}/reschedule" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[7]}\",
    \"newStartIso\": \"${NEW_START}\",
    \"newEndIso\": \"${NEW_END}\",
    \"timezone\": \"America/Chicago\"
  }" > /dev/null
echo "✓ Rescheduled to new time"
sleep 2

echo ""
echo "PHASE 3: Cancelling 3 Appointments"
echo "===================================="
echo ""

# Cancel 1
echo "[1/3] Cancelling booking ${BOOKING_IDS[2]}..."
curl -s -X POST "${WEBHOOK_BASE}/cancel" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[2]}\",
    \"phone\": \"+12145553333\"
  }" > /dev/null
echo "✓ Cancelled"
sleep 1

# Cancel 2
echo "[2/3] Cancelling booking ${BOOKING_IDS[3]}..."
curl -s -X POST "${WEBHOOK_BASE}/cancel" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[3]}\",
    \"phone\": \"+12145554444\"
  }" > /dev/null
echo "✓ Cancelled"
sleep 1

# Cancel 3
echo "[3/3] Cancelling booking ${BOOKING_IDS[8]}..."
curl -s -X POST "${WEBHOOK_BASE}/cancel" \
  -H "Content-Type: application/json" \
  -d "{
    \"bookingId\": \"${BOOKING_IDS[8]}\",
    \"phone\": \"+12145559999\"
  }" > /dev/null
echo "✓ Cancelled"
sleep 2

echo ""
echo "PHASE 4: Creating 5 Group Bookings"
echo "===================================="
echo ""

# Group Booking 1 (past)
echo "[1/5] Creating Group Booking..."
START=$(generate_past_datetime 10 10)
END=$(generate_past_datetime 10 12)
curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Group Booking\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Corporate Team A\",
    \"phone\": \"+12145551111\",
    \"service_type\": \"group\",
    \"email\": \"team-a@corp.com\"
  }" > /dev/null
echo "✓ Created"
sleep 1

# Group Booking 2 (past)
echo "[2/5] Creating Group Booking..."
START=$(generate_past_datetime 18 14)
END=$(generate_past_datetime 18 16)
curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Group Booking\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Corporate Team B\",
    \"phone\": \"+12145552222\",
    \"service_type\": \"group\",
    \"email\": \"team-b@corp.com\"
  }" > /dev/null
echo "✓ Created"
sleep 1

# Group Booking 3 (past)
echo "[3/5] Creating Group Booking..."
START=$(generate_past_datetime 22 11)
END=$(generate_past_datetime 22 13)
curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Group Booking\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Corporate Team C\",
    \"phone\": \"+12145553333\",
    \"service_type\": \"group\",
    \"email\": \"team-c@corp.com\"
  }" > /dev/null
echo "✓ Created"
sleep 1

# Group Booking 4 (future)
echo "[4/5] Creating Group Booking (future)..."
START=$(generate_future_datetime 10 10)
END=$(generate_future_datetime 10 12)
curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Group Booking\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Corporate Team D\",
    \"phone\": \"+12145554444\",
    \"service_type\": \"group\",
    \"email\": \"team-d@corp.com\"
  }" > /dev/null
echo "✓ Created"
sleep 1

# Group Booking 5 (future)
echo "[5/5] Creating Group Booking (future)..."
START=$(generate_future_datetime 12 14)
END=$(generate_future_datetime 12 16)
curl -s -X POST "${WEBHOOK_BASE}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Group Booking\",
    \"startIso\": \"${START}\",
    \"endIso\": \"${END}\",
    \"timezone\": \"America/Chicago\",
    \"name\": \"Corporate Team E\",
    \"phone\": \"+12145555555\",
    \"service_type\": \"group\",
    \"email\": \"team-e@corp.com\"
  }" > /dev/null
echo "✓ Created"
sleep 2

echo ""
echo "========================================="
echo "✓ ALL TESTS COMPLETE!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Created: 10 initial bookings"
echo "  - Rescheduled: 5 appointments"
echo "  - Cancelled: 3 appointments"
echo "  - Group bookings: 5 appointments"
echo ""
echo "Next Steps:"
echo "  1. Run Analytics Data Collector workflow in n8n"
echo "  2. Check Google Sheet (Analytics_Raw_Data tab):"
echo "     https://docs.google.com/spreadsheets/d/1o0uh4psHE3G21bGikv76wP6Jufj0TKz_W-VQv1QxSAc/edit"
echo "  3. Check Dashboard tab for metrics and charts"
echo ""
echo "Expected Data:"
echo "  - Past appointments: Status = 'Completed', Revenue counted"
echo "  - Future appointments: Status = 'Scheduled', Revenue = \$0"
echo "  - Cancelled: Status = 'Cancelled', Revenue = \$0"
echo ""
echo "Service Type Revenue Map:"
echo "  Consultation: \$100"
echo "  Maintenance: \$150"
echo "  Support: \$75"
echo "  Onsite: \$200"
echo "  Emergency: \$250"
echo "  Group Booking: \$300"
echo "  Standard: \$100"
echo "========================================="
