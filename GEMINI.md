# GEMINI.md: AI Appointment Scheduler

## Project Overview

This project is an AI-powered appointment scheduling assistant built on the **n8n** workflow automation platform. It uses a voice AI assistant from **Vapi** to handle user interactions over the phone, and integrates with **Google Calendar** for scheduling and **Twilio** for sending SMS reminders. The AI's natural language understanding is powered by **OpenAI's GPT models**.

The system is designed to handle the entire appointment lifecycle, including:

*   Booking new appointments
*   Confirming, canceling, and rescheduling existing appointments
*   Sending automated reminders

## Architecture

The project follows a webhook-based architecture:

1.  The **Vapi voice assistant** acts as the front-end, interacting with users over the phone.
2.  When a user wants to perform an action (e.g., book an appointment), the Vapi assistant calls a **webhook URL**.
3.  The webhook triggers an **n8n workflow**, which executes the required logic (e.g., checking Google Calendar, sending an SMS).
4.  The n8n workflow then returns a response to the Vapi assistant, which communicates the result to the user.

## Building and Running

This is an n8n project, so there is no traditional build process. The workflows are defined in the JSON files and are likely imported into an n8n instance.

**To run the project:**

1.  **Import the workflows:** The JSON files in this directory should be imported into an n8n instance.
    *   The n8n instance URL is: `https://polarmedia.app.n8n.cloud` (this should be replaced with your actual production URL).
2.  **Activate the workflows:** Once imported, the workflows need to be activated in the n8n UI.
3.  **Trigger the workflows:** The workflows are triggered by making HTTP requests to their webhook URLs. The main webhook URL can be found in the `Webhook` node of the `Appointment Scheduling AI_v.0.0.3 (Prod).json` workflow.

## Development Conventions

*   **Workflows as JSON:** The n8n workflows are stored as JSON files. Each file represents a separate workflow or sub-workflow.
*   **Naming Conventions:** The workflow files are named to indicate their purpose and version (e.g., `Appointment Scheduling AI_v.0.0.3 (Prod).json`). Sub-workflows are named based on the conditions that trigger them (e.g., `... (If_Confrim_yes).json`).
*   **Vapi Configuration:** The `vapi/` directory contains the configuration for the Vapi voice assistant:
    *   `vapi-assistant.json`: Defines the assistant's persona, voice, and system prompts.
    *   `vapi-tools.json`: Defines the functions (tools) that the assistant can call. These functions correspond to the n8n webhook URLs.
*   **Custom Logic:** Custom logic within the n8n workflows is written in JavaScript, inside the `Code` nodes.

## Production Readiness

Before deploying this project to a production environment, it is important to address several areas to ensure the system is robust, secure, and maintainable. Key recommendations include:

*   **Configuration Management:** Externalize all configuration (e.g., API keys, calendar IDs) to environment variables.
*   **Security:** Secure webhooks and manage secrets properly.
*   **Error Handling:** Implement comprehensive error handling in all workflows.
*   **Testing:** Develop a suite of automated tests for your workflows.
*   **Monitoring:** Set up logging and monitoring to observe the health of your system.

For detailed instructions on how to implement these recommendations, please refer to the [Project_Workflow.md](../Project_Workflow.md) file.