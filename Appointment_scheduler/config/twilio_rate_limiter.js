/**
 * Twilio Function: Rate Limiter for Incoming Calls
 *
 * Purpose: Prevent spam/abuse by limiting calls to 5 per hour per phone number
 *
 * Features:
 * - Sliding window rate limiting (5 calls/hour)
 * - Uses Twilio Sync for serverless storage
 * - Blocks repeated/silent calls
 * - Forwards legitimate calls to Vapi
 *
 * Deploy to: Twilio Functions (https://console.twilio.com/us1/develop/functions/services)
 *
 * Environment Variables Required:
 * - SYNC_SERVICE_SID: Your Twilio Sync Service SID
 * - VAPI_PHONE_NUMBER: The Vapi phone number to forward to (e.g., +1234567890)
 * - MAX_CALLS_PER_HOUR: (optional) Default is 5
 *
 * Webhook Configuration:
 * Configure your Twilio phone number to point to this Function URL as the voice webhook
 */

exports.handler = async function(context, event, callback) {
  const twiml = new Twilio.twiml.VoiceResponse();

  // Configuration
  const MAX_CALLS_PER_HOUR = parseInt(context.MAX_CALLS_PER_HOUR) || 5;
  const WINDOW_HOURS = 1;
  const SYNC_SERVICE_SID = context.SYNC_SERVICE_SID;
  const VAPI_PHONE_NUMBER = context.VAPI_PHONE_NUMBER;

  // Get caller information
  const callerNumber = event.From;
  const calledNumber = event.To;
  const callSid = event.CallSid;

  console.log(`[Rate Limiter] Incoming call from ${callerNumber} to ${calledNumber}`);

  // Validate required configuration
  if (!SYNC_SERVICE_SID || !VAPI_PHONE_NUMBER) {
    console.error('[Rate Limiter] ERROR: Missing required environment variables');
    twiml.say('Service temporarily unavailable. Please try again later.');
    twiml.hangup();
    return callback(null, twiml);
  }

  try {
    // Initialize Twilio client
    const client = context.getTwilioClient();

    // Normalize phone number for storage (remove special chars)
    const normalizedNumber = callerNumber.replace(/[^0-9+]/g, '');
    const documentName = `rate_limit_${normalizedNumber}`;

    // Get or create Sync Document for this phone number
    let document;
    let callTimestamps = [];

    try {
      // Try to fetch existing document
      document = await client.sync.v1
        .services(SYNC_SERVICE_SID)
        .documents(documentName)
        .fetch();

      callTimestamps = document.data.timestamps || [];
      console.log(`[Rate Limiter] Found existing document: ${callTimestamps.length} previous calls`);

    } catch (error) {
      // Document doesn't exist, create it
      if (error.code === 20404) {
        console.log(`[Rate Limiter] Creating new document for ${callerNumber}`);
        document = await client.sync.v1
          .services(SYNC_SERVICE_SID)
          .documents
          .create({
            uniqueName: documentName,
            data: { timestamps: [] }
          });
        callTimestamps = [];
      } else {
        throw error;
      }
    }

    // Current timestamp
    const now = Date.now();
    const hourAgo = now - (WINDOW_HOURS * 60 * 60 * 1000);

    // Filter out timestamps older than the window
    const recentCalls = callTimestamps.filter(ts => ts > hourAgo);

    // Check if rate limit exceeded
    if (recentCalls.length >= MAX_CALLS_PER_HOUR) {
      console.log(`[Rate Limiter] BLOCKED: ${callerNumber} exceeded rate limit (${recentCalls.length}/${MAX_CALLS_PER_HOUR} calls in last hour)`);

      // Block the call
      twiml.say({
        voice: 'Polly.Joanna'
      }, 'You have exceeded the maximum number of calls allowed. Please try again later.');
      twiml.hangup();

      // Update document with current timestamp (still track blocked calls)
      await client.sync.v1
        .services(SYNC_SERVICE_SID)
        .documents(documentName)
        .update({
          data: {
            timestamps: [...recentCalls, now],
            lastBlocked: now,
            totalBlocked: (document.data.totalBlocked || 0) + 1
          }
        });

      return callback(null, twiml);
    }

    // Rate limit not exceeded - allow the call
    console.log(`[Rate Limiter] ALLOWED: ${callerNumber} (${recentCalls.length}/${MAX_CALLS_PER_HOUR} calls in last hour)`);

    // Forward to Vapi using <Dial>
    const dial = twiml.dial({
      callerId: calledNumber,  // Use the original Twilio number as caller ID
      timeout: 30,
      action: '/rate-limiter-status',  // Optional: callback URL for call status
      method: 'POST'
    });

    dial.number(VAPI_PHONE_NUMBER);

    // Update document with new timestamp
    await client.sync.v1
      .services(SYNC_SERVICE_SID)
      .documents(documentName)
      .update({
        data: {
          timestamps: [...recentCalls, now],
          lastAllowed: now,
          totalAllowed: (document.data.totalAllowed || 0) + 1
        }
      });

    return callback(null, twiml);

  } catch (error) {
    console.error(`[Rate Limiter] ERROR: ${error.message}`);
    console.error(error.stack);

    // On error, fail open (allow the call) rather than fail closed
    // This prevents legitimate callers from being blocked due to system issues
    twiml.say('Please hold while we connect your call.');

    const dial = twiml.dial({
      callerId: calledNumber,
      timeout: 30
    });
    dial.number(VAPI_PHONE_NUMBER);

    return callback(null, twiml);
  }
};


/**
 * DEPLOYMENT INSTRUCTIONS:
 *
 * 1. Create Twilio Sync Service:
 *    - Go to: https://console.twilio.com/us1/develop/sync/services
 *    - Click "Create new Sync Service"
 *    - Name it: "Rate Limiter Service"
 *    - Copy the Service SID (starts with IS...)
 *
 * 2. Create Twilio Function:
 *    - Go to: https://console.twilio.com/us1/develop/functions/services
 *    - Create new Service: "Rate Limiter"
 *    - Add this function as a new Function
 *    - Path: /rate-limiter
 *    - Set as "Public" (accessible via webhook)
 *
 * 3. Configure Environment Variables:
 *    - In the Function Service Settings → Environment Variables:
 *      - SYNC_SERVICE_SID: (your Sync Service SID from step 1)
 *      - VAPI_PHONE_NUMBER: (your Vapi forwarding number)
 *      - MAX_CALLS_PER_HOUR: 5 (optional)
 *
 * 4. Add Dependencies:
 *    - In the Function Service Settings → Dependencies:
 *      - twilio: latest (usually pre-installed)
 *
 * 5. Deploy the Function:
 *    - Click "Deploy All"
 *    - Copy the deployed Function URL
 *
 * 6. Configure Your Twilio Phone Number:
 *    - Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/incoming
 *    - Click on your phone number (+14694365607)
 *    - Under "Voice Configuration":
 *      - A CALL COMES IN: Webhook
 *      - URL: (paste your Function URL from step 5)
 *      - HTTP: POST
 *    - Click Save
 *
 * 7. Test:
 *    - Call your Twilio number 6 times within an hour
 *    - First 5 calls should go through
 *    - 6th call should be blocked with rate limit message
 *
 * 8. Monitor:
 *    - View logs: Functions → Logs
 *    - View Sync data: Sync → Services → Rate Limiter Service → Documents
 */
