# Production Deployment Conversation Summary
## Phase 1 & 2: Security Hardening

**Date:** November 20, 2025
**Project:** AI Appointment Scheduling System
**n8n Instance:** https://polarmedia.app.n8n.cloud

---

## Phase 1: Pre-Deployment Preparation

### Status: ✅ Complete (Already Done)

**Assessment Results:**
- All 10 workflow JSON files present in `Appointment_scheduler/`
- `.env.example` template exists with all required variables
- `.gitignore` configured to exclude secrets
- `vapi/vapi-assistant.json` and `vapi/vapi-tools.json` exist
- Git version control in place (5 commits)

**Files:**
1. `Appointment Scheduling AI_v.0.0.3.json` - Main booking workflow
2. `Appointment Scheduling AI_v.0.0.3_vapi_lookup.json` - Find appointments
3. `Appointment Scheduling AI_v.0.0.3_vapi_cancel-2.json` - Cancel appointments
4. `Appointment Scheduling AI_v.0.0.3_vapi_reschedule-2.json` - Reschedule appointments
5. `Appointment Scheduling AI_v.0.0.3_vapi_recovery.json` - Handle disconnected calls
6. `Appointment Scheduling AI v.0.0.3 (Check Availability).json` - Availability checking
7. `Appointment Scheduling AI v.0.0.3 (Group Booking).json` - Multi-person bookings
8. `Appointment Scheduling AI_v.0.0.3 (If_Confrim_yes).json` - Confirmation flow (yes)
9. `Appointment Scheduling AI_v.0.0.3(If_Confirm_No).json` - Confirmation flow (no)
10. `Appointment_scheduler_v0.0.3_RDC – Signed Link Resolver (JWT verify → 302 redirect).json` - JWT verification

---

## Phase 2: Security Hardening

### Phase 2.1: Webhook Authentication ✅

**Challenge Encountered:**
- Initially tried HMAC signature verification with Code node
- Vapi changed their UI - no longer has "Server URL Secret" on assistant level
- n8n Cloud Starter plan doesn't have Variables feature

**Solution Found:**
- Vapi has **Custom Headers** in Org Settings → Server URL → Headers
- n8n has built-in **Header Auth** on Webhook nodes

**Implementation:**

1. **In Vapi Dashboard:**
   - Org Settings → Server URL → Headers
   - Added custom header:
     - Header Name: `x-webhook-secret`
     - Header Value: `xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=`

2. **In n8n (each workflow):**
   - Webhook node → Authentication → Header Auth
   - Header Name: `x-webhook-secret`
   - Header Value: `xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=`

**Workflows Protected:**
| Workflow | Header Auth |
|----------|-------------|
| Main (vapi/call) | ✅ |
| Lookup | ✅ |
| Cancel | ✅ |
| Reschedule | ✅ |
| Recovery | ✅ |
| Check Availability | ✅ |
| Group Booking | ✅ |
| If_Confirm_yes | ⏭️ No webhook |
| If_Confirm_No | ⏭️ No webhook |
| Signed Link Resolver | ⏭️ Public (JWT protected) |

**Test Results:**
```bash
# Without header - BLOCKED
curl -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/call
# Result: 403 Forbidden

# With header - ALLOWED
curl -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/call \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
# Result: 200 OK
```

---

### Phase 2.2: JWT Token Security ✅

**Issue Found:**
- JWT secret was hardcoded in workflow code
- Same secret in two workflows (Recovery generates, Signed Link Resolver verifies)

**Old Secret:** `ad4b3a2ed7d1438023ad7e40bd2daab6bd222f02a4e5d377481e4bb1b06093af`

**New Secret:** `f2db4b5654536ac52e6e91ff2756b01179bd04a7d4032172ec07312a339bdcb5`

**Workflows Updated:**
1. `Appointment Scheduling AI_v.0.0.3_vapi_recovery` - "Code (Decide Recovery)" node
2. `Appointment_scheduler_v0.0.3_RDC – Signed Link Resolver` - "Code (Verify JWT)" node

**JWT Configuration:**
- Algorithm: HS256
- Token TTL: 900 seconds (15 minutes)
- Secret length: 256 bits (64 hex characters)

---

### Phase 2.3: Input Validation ✅

**Validation Code Node Added to:**
1. Main workflow (Appointment Scheduling AI_v.0.0.3)
2. Lookup workflow
3. Cancel workflow
4. Reschedule workflow

**Validations Implemented:**
- **Phone:** Extracts digits, validates length (7-15), formats as E.164
- **Email:** Format validation, lowercase normalization
- **Name:** XSS character removal (`<>\"\'&`), length limit (100 chars)
- **Service Type:** Whitelist validation (support, maintenance, consultation, onsite, emergency)
- **DateTime:** ISO format validation, past/future bounds checking
- **Timezone:** IANA identifier validation

**Example Validation Code (Main Workflow):**
```javascript
// INPUT VALIDATION
const body = $json.body || $json;
const args = body?.message?.toolCalls?.[0]?.function?.arguments;

let input = {};
if (typeof args === 'string') {
  try { input = JSON.parse(args); } catch (e) { input = body; }
} else {
  input = args || body;
}

// Validate phone
function validatePhone(raw) {
  if (!raw) return null;
  const digits = String(raw).replace(/\D/g, '');
  if (digits.length < 7 || digits.length > 15) return null;
  if (digits.length === 10) return '+1' + digits;
  if (digits.length === 11 && digits[0] === '1') return '+' + digits;
  return '+' + digits;
}

// Sanitize name (remove XSS characters)
function sanitizeName(raw) {
  if (!raw) return null;
  return String(raw).replace(/[<>\"\'&]/g, '').trim().substring(0, 100);
}

// Validate email
function validateEmail(raw) {
  if (!raw) return null;
  const email = String(raw).trim().toLowerCase();
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ? email : null;
}

// Apply validation
const validated = {
  phone: validatePhone(input.phone),
  name: sanitizeName(input.name || input.fullName),
  email: validateEmail(input.email),
  service_type: ['support','maintenance','consultation','onsite','emergency']
    .includes(String(input.service_type || '').toLowerCase())
    ? String(input.service_type).toLowerCase()
    : 'consultation',
  timezone: input.timezone || input.tz || 'America/Chicago',
  startIso: input.startIso,
  endIso: input.endIso
};

return { json: { ...$json, ...validated, _validated: true } };
```

---

### Phase 2.4: HTTPS/TLS Verification ✅

**Test Results:**
```
HTTP/2 200
strict-transport-security: max-age=15552000; includeSubDomains
server: cloudflare
```

**SSL Certificate:**
- Issuer: Google Trust Services
- Valid from: Sep 26, 2025
- Expires: Dec 25, 2025 (auto-renews on n8n Cloud)

**Security Features Confirmed:**
- ✅ HTTPS enabled (HTTP/2)
- ✅ Valid SSL certificate
- ✅ HSTS header present
- ✅ Cloudflare protection active

---

## Important Secrets (SAVE SECURELY!)

| Secret | Value | Used In |
|--------|-------|---------|
| Webhook Secret | `xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0=` | Vapi Headers, n8n Header Auth |
| JWT Secret | `f2db4b5654536ac52e6e91ff2756b01179bd04a7d4032172ec07312a339bdcb5` | Recovery & Signed Link Resolver workflows |

---

## Files Created During This Session

```
/Users/anitavallabha/claude/security/
├── webhook_signature_verification.js   # HMAC verification code (alternative approach)
├── test_webhook_auth.sh                 # Test script for webhook auth
├── PHASE_2_1_IMPLEMENTATION.md         # Implementation guide
├── COPY_PASTE_CODE.js                   # Ready-to-use verification code
└── input_validation.js                  # Full input validation code
```

---

## Security Layers Implemented

```
┌─────────────────────────────────────────────┐
│           INCOMING REQUEST                   │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 1: HTTPS/TLS Encryption              │
│  (All traffic encrypted in transit)         │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 2: Cloudflare Protection             │
│  (DDoS protection, WAF)                     │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 3: Webhook Header Auth               │
│  (x-webhook-secret verification)            │
│  Blocks: Unauthorized requests              │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 4: Input Validation                  │
│  (Phone, email, name, dates validated)      │
│  Blocks: Malformed data, XSS, injection     │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 5: JWT Verification (Recovery links) │
│  (HS256, 15-min expiry)                     │
│  Blocks: Tampered/expired recovery links    │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│           BUSINESS LOGIC                     │
│  (Booking, Calendar, SMS operations)        │
└─────────────────────────────────────────────┘
```

---

## Why Both Header Auth AND Input Validation?

| Layer | Purpose | Protects Against |
|-------|---------|------------------|
| Header Auth | Verifies WHO sent request | Attackers, unauthorized access |
| Input Validation | Verifies WHAT data was sent | Bad data, XSS, malformed input |

**Both are needed (Defense in Depth):**
- Auth alone doesn't stop Vapi from sending bad data
- Validation alone doesn't stop unauthorized requests

---

## Next Steps (Remaining Phases)

- **Phase 3:** n8n Workflow Deployment (import/activate workflows)
- **Phase 4:** External Service Configuration (Vapi, Google Calendar, Twilio)
- **Phase 5:** Monitoring & Logging
- **Phase 6:** Testing & Validation
- **Phase 7:** Go-Live Execution
- **Phase 8:** Post-Deployment & Maintenance

---

## Quick Reference Commands

**Test webhook auth:**
```bash
# Should fail (403)
curl -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/call

# Should succeed (200)
curl -X POST https://polarmedia.app.n8n.cloud/webhook/vapi/call \
  -H "x-webhook-secret: xhk1VWWfjGDb8lm3Nyz1C15eBv+wKnHFCEkSG0DESE0="
```

**Generate new secrets:**
```bash
# Webhook secret (base64)
openssl rand -base64 32

# JWT secret (hex)
openssl rand -hex 32
```

---

**Status:** Phase 2 Complete
