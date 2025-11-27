# Quick Start Guide - Vapi Testing

**Goal:** Update Vapi assistant and run all tests

---

## 1️⃣ Update Vapi Assistant (Required)

```bash
# Set your Vapi Private Key
export VAPI_PRIVATE_KEY="sk-your-key-here"

# Run update script
cd /Users/anitavallabha/claude/Appointment_scheduler
./update_vapi_assistant.sh
```

**Look for these confirmations:**
- ✅ Date verification passed: TODAY is November 24, 2025
- ✅ CRITICAL TOOL USAGE RULES section found
- ✅ Time interpretation rule found
- ✅ sameDayAvailable logic found

---

## 2️⃣ Run All Tests

```bash
cd /Users/anitavallabha/claude/Appointment_scheduler
./run_all_tests.sh
```

**Expected:** 8/8 tests pass

If tests fail, check:
1. Are all n8n workflows active?
2. Is webhook secret correct?
3. Check n8n execution logs

---

## 3️⃣ Test Voice Calls

Call Vapi and test:

**Test A: "I want to book tomorrow at 10"**
- Should use `function_tool` directly
- Should NOT call `check_availability_tool`

**Test B: "What times are available?"**
- Should call `check_availability_tool`
- Should present 5 slots

**Test C: Request taken slot**
- Should say "That time isn't available, but I have other options on the same day"
- Should read ACTUAL times from response

---

## 4️⃣ Verify Results

- [ ] Check Google Calendar for appointments
- [ ] Check Twilio logs for SMS delivery
- [ ] Verify Vapi call logs show correct tool selection

---

## Files Created

1. `vapi_testing_plan.md` - Detailed test scenarios
2. `update_vapi_assistant.sh` - Vapi update script
3. `run_all_tests.sh` - Automated test suite
4. `../vapi/updated_assistant_prompt.txt` - New system prompt
5. `TESTING_SUMMARY.md` - Complete documentation
6. `QUICK_START.md` - This file

---

## Need Help?

- **Update failed?** Check Vapi Private Key is valid
- **Tests failing?** Check n8n workflows are active
- **Wrong tool called?** Verify Vapi update completed successfully

See `TESTING_SUMMARY.md` for full details.
