import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/doctor.dart';
import '../domain/appointment.dart';

class MockDoctorRepo {
  static final _doctors = <Doctor>[
    Doctor(
      id: 'd1',
      name: 'د. أمين بن يوسف',
      specialty: 'طب عام',
      wilaya: 'الجزائر',
      commune: 'باب الزوار',
      address: 'شارع الاستقلال، باب الزوار',
      phone: '0550 00 00 01',
      approved: true,
      rating: 4.6,
      ratingCount: 128,
    ),
    Doctor(
      id: 'd2',
      name: 'د. سارة قسوم',
      specialty: 'طب أسنان',
      wilaya: 'الجزائر',
      commune: 'حيدرة',
      address: 'حي 1000 مسكن، حيدرة',
      phone: '0550 00 00 02',
      approved: true,
      rating: 4.2,
      ratingCount: 61,
    ),
  ];

  List<Doctor> search({required String specialty, required String wilaya, required String commune}) {
    return _doctors
        .where((d) => d.approved)
        .where((d) => d.specialty == specialty)
        .where((d) => d.wilaya == wilaya)
        .where((d) => d.commune == commune)
        .toList();
  }

  Doctor? byId(String id) => _doctors.where((d) => d.id == id).cast<Doctor?>().firstWhere((d) => d != null, orElse: () => null);
}

class MockAppointmentsRepo {
  final _uuid = const Uuid();
  final _items = <Appointment>[];

  List<Appointment> listMine() => List.unmodifiable(_items);

  void request({required Doctor doctor, required DateTime day, String? time}) {
    _items.insert(
      0,
      Appointment(
        id: _uuid.v4(),
        doctorId: doctor.id,
        doctorName: doctor.name,
        requestedDate: DateTime(day.year, day.month, day.day),
        requestedTime: time,
        status: AppointmentStatus.requested,
      ),
    );
  }

  void cancel(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final old = _items[i];
    _items[i] = Appointment(
      id: old.id,
      doctorId: old.doctorId,
      doctorName: old.doctorName,
      requestedDate: old.requestedDate,
      requestedTime: old.requestedTime,
      status: AppointmentStatus.cancelledByPatient,
    );
  }
}

final doctorRepoProvider = Provider((ref) => MockDoctorRepo());
final apptRepoProvider = Provider((ref) => MockAppointmentsRepo());
