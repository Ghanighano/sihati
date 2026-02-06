import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_repos.dart';

class DoctorDetailsScreen extends ConsumerWidget {
  const DoctorDetailsScreen({super.key, required this.doctorId});
  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(doctorRepoProvider);
    final d = repo.byId(doctorId);

    return Scaffold(
      appBar: AppBar(title: const Text('ملف الطبيب')),
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
                        Text(d.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(d.specialty, style: const TextStyle(color: Color(0xFF475569))),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(d.address)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(d.phone),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/doctor/${d.id}/request'),
                  icon: const Icon(Icons.event_available_rounded),
                  label: const Text('طلب موعد'),
                ),
              ],
            ),
    );
  }
}
