# AI Appointment Scheduler

---

## Project Description

This project is an AI-powered appointment scheduling assistant built on the n8n workflow automation platform. It uses a voice AI assistant from Vapi to handle user interactions over the phone, and integrates with Google Calendar for scheduling and Twilio for sending SMS reminders.

---

## Kanban Board

```mermaid
kanban
    title Appointment Scheduler Project
    section To Do
        Implement conflict handling: 2d
        Support more calendar providers: 3d
        Create analytics dashboard: 5d
    section In Progress
        Develop booking workflow: 3d
        Integrate Twilio for SMS: 2d
    section Done
        User authentication: 1d
        Vapi voice assistant setup: 2d
        Google Calendar integration: 2d
        OpenAI model integration: 2d
```

---

## Workflow Tree

```mermaid
graph TD
    A[User calls Vapi Voice Assistant] --> B{User wants to...};
    B --> C[Book an appointment];
    B --> D[Confirm an appointment];
    B --> E[Cancel an appointment];
    B --> F[Reschedule an appointment];

    C --> G[Vapi calls n8n webhook for booking];
    G --> H[n8n workflow checks Google Calendar for availability];
    H --> I{Is slot available?};
    I -->|Yes| J[n8n creates event in Google Calendar];
    J --> K[n8n sends confirmation SMS via Twilio];
    K --> L[Vapi confirms booking to the user];
    I -->|No| M[Vapi informs user that the slot is not available];
```

---

## Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant Vapi
    participant n8n
    participant Google Calendar
    participant Twilio

    User->>Vapi: Calls and requests to book an appointment
    Vapi->>n8n: POST /webhook/book (with appointment details)
    n8n->>Google Calendar: Check availability
    Google Calendar-->>n8n: Returns availability
    alt Slot is available
        n8n->>Google Calendar: Create event
        Google Calendar-->>n8n: Event created
        n8n->>Twilio: Send confirmation SMS
        Twilio-->>n8n: SMS sent
        n8n-->>Vapi: { result: 'booked', ... }
        Vapi->>User: "Your appointment is booked!"
    else Slot is not available
        n8n-->>Vapi: { result: 'no_free_slot', ... }
        Vapi->>User: "That time is not available."
    end
```

---

## Gantt Chart

```mermaid
gantt
    title Appointment Scheduler Project Timeline
    dateFormat  YYYY-MM-DD
    section Project Setup
    Initial setup           :done,    des1, 2025-11-01, 2d
    Vapi integration        :done,    des2, 2025-11-03, 3d
    Google Calendar setup   :done,    des3, 2025-11-03, 2d

    section Core Features
    Booking workflow        :active,  des4, 2025-11-06, 5d
    Cancellation workflow   :         des5, 2025-11-11, 3d
    Rescheduling workflow   :         des6, 2025-11-14, 3d

    section Advanced Features
    Twilio reminders        :         des7, 2025-11-19, 4d
    Analytics dashboard     :         des8, 2025-11-25, 5d
```

---

## Pie Chart: Appointment Types

```mermaid
pie
    title Appointment Types
    "Consultation" : 45
    "Support" : 25
    "Maintenance" : 15
    "Onsite" : 10
    "Emergency" : 5
```

---

## Production Readiness

For detailed instructions on how to make this project production-ready, please refer to the `Project_Workflow.md` file.
