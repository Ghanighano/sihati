import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mock_repos.dart';
import '../domain/appointment.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(apptRepoProvider);
    final items = repo.listMine();

    return Scaffold(
      appBar: AppBar(title: const Text('مواعيدي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (items.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('لا يوجد مواعيد بعد.'))),
          for (final a in items) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.doctorName, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text('اليوم: ${DateFormat('yyyy-MM-dd').format(a.requestedDate)}${a.requestedTime == null ? '' : ' • الساعة: ${a.requestedTime}'}'),
                    const SizedBox(height: 6),
                    Text('الحالة: ${a.status.name}', style: const TextStyle(color: Color(0xFF475569))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                showDragHandle: true,
                                builder: (ctx) => ListView(
                                  padding: const EdgeInsets.all(16),
                                  shrinkWrap: true,
                                  children: [
                                    const Text('سأتأخر', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(height: 12),
                                    for (final m in const [10, 20, 30])
                                      ListTile(
                                        title: Text('$m دقيقة'),
                                        leading: const Icon(Icons.schedule_rounded),
                                        onTap: () {
                                          Navigator.of(ctx).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('تم إرسال إشعار: سأتأخر $m دقيقة (تجريبي).')),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('سأتأخر'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: a.status == AppointmentStatus.cancelledByPatient
                                ? null
                                : () {
                                    repo.cancel(a.id);
                                    (context as Element).markNeedsBuild();
                                  },
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                            child: const Text('إلغاء'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ]
        ],
      ),
    );
  }
}
