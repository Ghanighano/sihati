import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_repos.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key, required this.specialty, required this.wilaya, required this.commune});

  final String specialty;
  final String wilaya;
  final String commune;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(doctorRepoProvider);
    final doctors = repo.search(specialty: specialty, wilaya: wilaya, commune: commune);

    return Scaffold(
      appBar: AppBar(title: const Text('الأطباء')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('فلترة: $specialty • $wilaya • $commune', style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (doctors.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('لا يوجد نتائج الآن'))),
          for (final d in doctors) ...[
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/doctor/${d.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.local_hospital_rounded, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(d.specialty, style: const TextStyle(color: Color(0xFF475569))),
                            const SizedBox(height: 6),
                            Text(d.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                              Text(d.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Text('(${d.ratingCount})', style: const TextStyle(color: Color(0xFF64748B))),
                        ],
                      )
                    ],
                  ),
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
