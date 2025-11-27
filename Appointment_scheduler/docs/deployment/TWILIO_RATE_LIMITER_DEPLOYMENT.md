# Twilio Rate Limiter Deployment Guide

**Purpose:** Implement call rate limiting (5 calls/hour per phone number) using Twilio Functions to prevent spam and abuse.

**Status:** Ready to deploy
**Time Required:** 15-20 minutes
**Prerequisites:** Twilio account with admin access

---

## Overview

This solution implements **serverless rate limiting** that:
- ✅ Limits callers to 5 calls per hour
- ✅ Blocks repeated spam/robocalls
- ✅ Tracks call history per phone number
- ✅ Forwards legitimate calls to Vapi
- ✅ Provides detailed logging
- ✅ Fails open (allows calls if system error)

**Architecture:**
```
Incoming Call → Twilio Number → Rate Limiter Function → Check Sync Storage
                                                         ↓
                                    [Exceeded?] → Block call + Update stats
                                                         ↓
                                    [Within limit?] → Forward to Vapi + Track timestamp
```

---

## Step 1: Create Twilio Sync Service

**What:** Sync provides serverless storage for tracking call timestamps

**How:**

1. **Navigate to Sync Services:**
   - URL: https://console.twilio.com/us1/develop/sync/services
   - Or: Console → Develop → Sync → Services

2. **Create New Service:**
   - Click **"Create new Sync Service"** (blue button)
   - **Friendly Name:** `Rate Limiter Service`
   - **ACL Enabled:** Leave unchecked (default)
   - Click **"Create"**

3. **Copy Service SID:**
   - You'll see a Service SID like: `IS1234567890abcdef1234567890abcdef`
   - **COPY THIS** - you'll need it in Step 3
   - Save it temporarily in a notepad

**Verify:**
- You should see "Rate Limiter Service" in your Sync Services list
- Status should be "Active"

---

## Step 2: Create Twilio Function Service

**What:** Functions host your rate limiting code in Twilio's serverless environment

**How:**

1. **Navigate to Functions:**
   - URL: https://console.twilio.com/us1/develop/functions/services
   - Or: Console → Develop → Functions and Assets → Services

2. **Create New Service:**
   - Click **"Create Service"** (blue button)
   - **Service Name:** `Rate Limiter`
   - Click **"Next"**

3. **Add Function:**
   - Click **"Add +"** → **"Add Function"**
   - **Function Name:** `/rate-limiter` (must start with `/`)
   - **Visibility:** **Public** (important!)
   - Click **"Add"**

4. **Paste Code:**
   - Open the function you just created
   - **Delete all default code**
   - **Copy entire contents** of `twilio_rate_limiter.js`
   - **Paste** into the function editor

5. **Save:**
   - Click **"Save"** (not Deploy yet)

**Verify:**
- Function appears in the left sidebar as `/rate-limiter`
- Path shows as: `/rate-limiter`
- Visibility shows as: **Public**

---

## Step 3: Configure Environment Variables

**What:** Securely store configuration without hardcoding in code

**How:**

1. **Open Settings:**
   - In the Rate Limiter service, click **"Settings"** (left sidebar)
   - Scroll to **"Environment Variables"** section

2. **Add Variables:**
   - Click **"Add"** for each variable:

   | Key | Value | Description |
   |-----|-------|-------------|
   | `SYNC_SERVICE_SID` | `IS...` (from Step 1) | Your Sync Service SID |
   | `VAPI_PHONE_NUMBER` | Your Vapi number | Number to forward calls to |
   | `MAX_CALLS_PER_HOUR` | `5` | Rate limit threshold |

   **Example:**
   ```
   SYNC_SERVICE_SID = IS1234567890abcdef1234567890abcdef
   VAPI_PHONE_NUMBER = +12025551234
   MAX_CALLS_PER_HOUR = 5
   ```

3. **Save:**
   - No explicit save button - variables save automatically

**Verify:**
- All 3 variables appear in the Environment Variables list
- No typos in the Sync Service SID
- Vapi number includes country code (+1)

---

## Step 4: Configure Dependencies (Optional)

**What:** Ensure Twilio SDK is available (usually pre-installed)

**How:**

1. **Check Dependencies:**
   - Still in Settings, scroll to **"Dependencies"** section
   - Look for: `twilio` package

2. **If Missing, Add:**
   - Click **"Add"**
   - **Module:** `twilio`
   - **Version:** `latest` (or `5.3.4`)
   - Click **"Add"**

**Verify:**
- `twilio` package appears in Dependencies list
- Version shows as 3.x.x or higher

---

## Step 5: Deploy the Function

**What:** Publish your function to make it accessible via webhook

**How:**

1. **Deploy:**
   - Click **"Deploy All"** (blue button at bottom)
   - Wait for deployment (10-30 seconds)
   - Look for green success message: "Build successful"

2. **Copy Function URL:**
   - After deployment, click on `/rate-limiter` function
   - Look for **"Copy URL"** button (near function name)
   - Click to copy
   - URL format: `https://rate-limiter-XXXX-dev.twil.io/rate-limiter`
   - **SAVE THIS URL** - you'll need it in Step 6

**Verify:**
- Green "Build successful" message appears
- Function URL is accessible (copy it to clipboard)
- Deployment timestamp shows current time

---

## Step 6: Configure Your Twilio Phone Number

**What:** Route incoming calls through the rate limiter before forwarding to Vapi

**How:**

1. **Navigate to Phone Numbers:**
   - URL: https://console.twilio.com/us1/develop/phone-numbers/manage/incoming
   - Or: Console → Develop → Phone Numbers → Manage → Active numbers

2. **Select Your Number:**
   - Click on: **+14694365607** (or your Twilio number)

3. **Configure Voice Webhook:**
   - Scroll to **"Voice Configuration"** section
   - **Configure with:** Webhooks, TwiML Bins, Functions, Studio, or Proxy
   - **A call comes in:**
     - Select: **Webhook**
     - **URL:** Paste your Function URL from Step 5
     - **HTTP Method:** **POST**
   - Leave other settings as default

4. **Save:**
   - Scroll to bottom
   - Click **"Save configuration"**

**Verify:**
- Voice webhook shows your Function URL
- Method is set to POST
- Save confirmation appears

---

## Step 7: Test the Rate Limiter

**What:** Verify rate limiting works correctly

### Test 1: Normal Call Flow

1. **Make a test call:**
   - Call your Twilio number: **+14694365607**
   - Expected: Call goes through, forwards to Vapi

2. **Check logs:**
   - Go to: Functions → Rate Limiter → Logs
   - Look for: `[Rate Limiter] ALLOWED: +1...`
   - Should show: `(1/5 calls in last hour)`

### Test 2: Rate Limit Enforcement

1. **Make 5 more calls** within 5 minutes (total 6 calls):
   - Calls 2-5: Should go through
   - Call 6: Should be blocked

2. **Expected on 6th call:**
   - Message: "You have exceeded the maximum number of calls allowed. Please try again later."
   - Call hangs up

3. **Check logs:**
   - Should show: `[Rate Limiter] BLOCKED: +1... exceeded rate limit (5/5 calls in last hour)`

### Test 3: Different Phone Number

1. **Call from a different phone number:**
   - Expected: Call goes through (rate limit is per-number)

### Test 4: Wait and Retry

1. **Wait 1 hour after first call**
2. **Call again from the blocked number:**
   - Expected: Call goes through (old timestamps expired)

---

## Step 8: Monitor and Verify

### View Call Logs

1. **Function Logs:**
   - Go to: Functions → Rate Limiter → Logs
   - View real-time call processing

2. **Log Entries to Look For:**
   ```
   [Rate Limiter] Incoming call from +1234567890
   [Rate Limiter] Found existing document: 3 previous calls
   [Rate Limiter] ALLOWED: +1234567890 (3/5 calls in last hour)
   ```

   Or when blocked:
   ```
   [Rate Limiter] BLOCKED: +1234567890 exceeded rate limit (5/5 calls in last hour)
   ```

### View Sync Data

1. **Navigate to Sync:**
   - Go to: Sync → Services → Rate Limiter Service → Documents

2. **Check Documents:**
   - Each caller has a document: `rate_limit_+1234567890`
   - Click on a document to view data:
     ```json
     {
       "timestamps": [1732694400000, 1732694460000],
       "lastAllowed": 1732694460000,
       "totalAllowed": 2,
       "totalBlocked": 0
     }
     ```

### Metrics to Track

| Metric | Where to Find | What to Look For |
|--------|---------------|------------------|
| **Total Calls** | Function invocations | Steady increase |
| **Allowed Calls** | Sync Documents → `totalAllowed` | Legitimate traffic |
| **Blocked Calls** | Sync Documents → `totalBlocked` | Spam/abuse attempts |
| **Error Rate** | Function Logs | Should be near 0% |

---

## Troubleshooting

### Issue: Calls Not Being Rate Limited

**Symptoms:** All calls go through, even after 5+ calls

**Solutions:**

1. **Check Environment Variables:**
   - Verify `SYNC_SERVICE_SID` is correct
   - Verify `MAX_CALLS_PER_HOUR` is set to `5`

2. **Check Function Logs:**
   - Look for errors creating/updating Sync documents
   - Check for: `ERROR: Missing required environment variables`

3. **Verify Sync Service:**
   - Ensure Sync Service is "Active"
   - Check for rate limit errors (20 reads/sec max)

### Issue: All Calls Being Blocked

**Symptoms:** Even first call from a number is blocked

**Solutions:**

1. **Check Sync Documents:**
   - Go to Sync → Rate Limiter Service → Documents
   - Delete all documents to reset
   - Re-test

2. **Check System Time:**
   - Ensure server time is correct
   - Timestamps should be recent (within last hour)

### Issue: Calls Not Reaching Vapi

**Symptoms:** Calls allowed but don't reach Vapi assistant

**Solutions:**

1. **Verify VAPI_PHONE_NUMBER:**
   - Must include country code: `+12025551234`
   - No spaces or special characters

2. **Check Dial Configuration:**
   - Verify `<Dial>` timeout (30 seconds)
   - Check Vapi number is active and accessible

3. **Test Direct Dial:**
   - Temporarily remove rate limiting
   - Test direct dial to Vapi number

### Issue: Function Errors in Logs

**Symptoms:** Errors in Function logs, calls fail

**Common Errors:**

1. **"SYNC_SERVICE_SID is not defined"**
   - Solution: Add environment variable in Step 3

2. **"20404: Document not found"**
   - Solution: Normal on first call, function creates document automatically

3. **"429: Too Many Requests"**
   - Solution: Sync rate limit exceeded, consider using external DB

4. **"Timeout"**
   - Solution: Increase Function timeout in Settings → Advanced

### Issue: Sync Documents Growing Too Large

**Symptoms:** Documents have hundreds of timestamps

**Solutions:**

1. **Current Code:** Automatically cleans up old timestamps (> 1 hour)

2. **If Still Growing:**
   - Add TTL to Sync documents:
     ```javascript
     ttl: 3600  // 1 hour in seconds
     ```

3. **Manual Cleanup:**
   - Delete old documents via API or Console

---

## Security Considerations

### Current Security

✅ **Implemented:**
- Rate limiting prevents brute force attacks
- Sync documents isolated per phone number
- Environment variables for secrets
- Fail-open prevents legitimate call blocking

⚠️ **Not Implemented:**
- Webhook authentication (Twilio validates automatically)
- Caller ID verification (can be spoofed)
- IP-based blocking

### Recommended Enhancements

1. **Add Webhook Validation:**
   ```javascript
   const crypto = require('crypto');
   const twilioSignature = event.request.headers['x-twilio-signature'];
   // Validate signature
   ```

2. **Add IP Whitelist:**
   - Only allow calls from known Twilio IPs

3. **Add Admin Bypass:**
   - Whitelist specific numbers (your own, test numbers)

4. **Add Logging to External Service:**
   - Send blocked call data to monitoring system

---

## Cost Analysis

### Twilio Sync Pricing

- **Document Reads:** $0.0001 per read (2 reads per call)
- **Document Writes:** $0.0005 per write (1 write per call)
- **Storage:** $0.10 per GB-month

**Per 1,000 Calls:**
- Reads: 2,000 × $0.0001 = $0.20
- Writes: 1,000 × $0.0005 = $0.50
- **Total: ~$0.70**

### Twilio Functions Pricing

- **Free Tier:** 10,000 invocations/month
- **Paid:** $0.00002 per invocation after free tier

**Total Monthly Cost (1,000 calls/month):**
- Sync: $0.70
- Functions: Free (under 10k)
- **Total: ~$0.70/month**

---

## Alternative: External Database

If you exceed Sync limits (20 reads/sec) or want cheaper storage:

### Option 1: Use Redis (Upstash)

**Pros:**
- Faster than Sync
- Higher rate limits
- Built-in TTL

**Setup:**
1. Create free Upstash account: https://upstash.com
2. Create Redis database
3. Update Function to use Redis client

### Option 2: Use PostgreSQL (Supabase)

**Pros:**
- Relational data
- Better querying
- Free tier: 500 MB

**Setup:**
1. Create Supabase account: https://supabase.com
2. Create table: `call_logs`
3. Update Function to use Supabase client

---

## Maintenance

### Daily

- ✅ Check Function logs for errors
- ✅ Monitor blocked call rate

### Weekly

- ✅ Review Sync Documents (should auto-clean)
- ✅ Check for unusual patterns (spam attacks)
- ✅ Verify environment variables

### Monthly

- ✅ Review Twilio billing (Sync usage)
- ✅ Analyze blocked vs allowed ratio
- ✅ Update MAX_CALLS_PER_HOUR if needed

---

## Next Steps

After deploying rate limiting, consider:

1. **Smart Reminder System** (#1 priority enhancement)
   - Reduces no-shows by 40-60%
   - Sends SMS reminders before appointments

2. **Analytics Dashboard**
   - Track call patterns
   - Identify spam sources
   - Monitor rate limit effectiveness

3. **Advanced Blocking**
   - Block silent calls
   - Block international spam
   - Integrate with spam detection APIs

---

## Support & Resources

**Documentation:**
- [Twilio Functions](https://www.twilio.com/docs/serverless/functions-assets/functions)
- [Twilio Sync](https://www.twilio.com/docs/sync)
- [TwiML Voice](https://www.twilio.com/docs/voice/twiml)

**Troubleshooting:**
- Function Logs: Console → Functions → Rate Limiter → Logs
- Sync Documents: Console → Sync → Rate Limiter Service → Documents
- Phone Number Config: Console → Phone Numbers → Active Numbers

**Questions?**
- Check `twilio_rate_limiter.js` for inline documentation
- Review Function logs for error details
- Test with curl to isolate issues

---

## Summary Checklist

- [ ] Created Twilio Sync Service
- [ ] Copied Sync Service SID
- [ ] Created Twilio Function Service
- [ ] Added `/rate-limiter` function
- [ ] Pasted code from `twilio_rate_limiter.js`
- [ ] Configured 3 environment variables
- [ ] Deployed the function
- [ ] Copied Function URL
- [ ] Updated phone number voice webhook
- [ ] Tested with 1-2 calls (should work)
- [ ] Tested with 6+ calls (6th should block)
- [ ] Verified logs show ALLOWED/BLOCKED messages
- [ ] Checked Sync documents are being created

**Status:** ✅ Ready to deploy!

---

**Created:** 2025-11-27
**Version:** 1.0
**Author:** Claude Code
**File:** `TWILIO_RATE_LIMITER_DEPLOYMENT.md`
