enum AppointmentStatus {
  requested,
  accepted,
  proposed,
  rejected,
  cancelledByPatient,
  cancelledByDoctor,
}

class Appointment {
  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.requestedDate,
    this.requestedTime,
    required this.status,
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final DateTime requestedDate;
  final String? requestedTime;
  final AppointmentStatus status;
}
