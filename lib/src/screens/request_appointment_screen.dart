import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/mock_repos.dart';

class RequestAppointmentScreen extends ConsumerStatefulWidget {
  const RequestAppointmentScreen({super.key, required this.doctorId});
  final String doctorId;

  @override
  ConsumerState<RequestAppointmentScreen> createState() => _RequestAppointmentScreenState();
}

class _RequestAppointmentScreenState extends ConsumerState<RequestAppointmentScreen> {
  DateTime? _day;
  String? _time;

  @override
  Widget build(BuildContext context) {
    final docRepo = ref.watch(doctorRepoProvider);
    final apptRepo = ref.watch(apptRepoProvider);
    final d = docRepo.byId(widget.doctorId);

    return Scaffold(
      appBar: AppBar(title: const Text('طلب موعد')),
      body: d == null
          ? const Center(child: Text('الطبيب غير موجود'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(d.specialty, style: const TextStyle(color: Color(0xFF475569))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(now.year, now.month, now.day),
                      lastDate: DateTime(now.year + 1),
                      initialDate: _day ?? now,
                    );
                    if (picked != null) setState(() => _day = picked);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(_day == null ? 'اختر اليوم (إجباري)' : DateFormat('yyyy-MM-dd').format(_day!)),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'الساعة (اختياري)'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _time,
                      isExpanded: true,
                      hint: const Text('بدون ساعة (اليوم فقط)'),
                      items: const ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _time = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _day == null
                      ? null
                      : () {
                          apptRepo.request(doctor: d, day: _day!, time: _time);
                          context.go('/appointments');
                        },
                  child: const Text('إرسال الطلب'),
                ),
              ],
            ),
    );
  }
}
