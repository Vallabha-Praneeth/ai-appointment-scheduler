
'''
This script provides a basic example of how to cancel an appointment in Python.

Appointments are stored in a list of dictionaries. Each dictionary represents an
appointment and has an "id", "patient_name", and "time" key.

The `cancel_appointment` function takes an appointment ID as input and removes the
corresponding appointment from the list.
'''

# Sample list of appointments
appointments = [
    {"id": 1, "patient_name": "John Doe", "time": "2025-11-10 10:00 AM"},
    {"id": 2, "patient_name": "Jane Smith", "time": "2025-11-10 11:00 AM"},
    {"id": 3, "patient_name": "Peter Jones", "time": "2025-11-10 12:00 PM"},
]

def cancel_appointment(appointment_id):
    """
    Cancels an appointment by removing it from the list of appointments.

    Args:
        appointment_id: The ID of the appointment to cancel.

    Returns:
        True if the appointment was successfully canceled, False otherwise.
    """
    global appointments
    initial_length = len(appointments)
    appointments = [appt for appt in appointments if appt["id"] != appointment_id]
    return len(appointments) < initial_length

# --- Example Usage ---

print("Appointments before cancellation:")
for appt in appointments:
    print(appt)

appointment_to_cancel = 2
if cancel_appointment(appointment_to_cancel):
    print(f"\nAppointment with ID {appointment_to_cancel} has been canceled.")
else:
    print(f"\nAppointment with ID {appointment_to_cancel} not found.")

print("\nAppointments after cancellation:")
for appt in appointments:
    print(appt)

