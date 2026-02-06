import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/auth_providers.dart';

class HomeSearchScreen extends ConsumerStatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  ConsumerState<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends ConsumerState<HomeSearchScreen> {
  String specialty = 'طب عام';
  String wilaya = 'الجزائر';
  String commune = 'باب الزوار';

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) {
        context.go('/auth/phone');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على بيانات المستخدم الحالي
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sihati'),
        actions: [
          IconButton(
            tooltip: 'مواعيدي',
            onPressed: () => context.push('/appointments'),
            icon: const Icon(Icons.event_note_rounded),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'الحساب',
            itemBuilder: (context) => [
              PopupMenuItem(
                child: currentUserAsync.when(
                  data: (user) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.displayName ?? 'مستخدم',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.phoneNumber ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  loading: () => const Text('جاري التحميل...'),
                  error: (_, __) => const Text('خطأ'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: _logout,
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('ابحث عن طبيب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _Select(label: 'التخصص', value: specialty, items: const ['طب عام', 'طب أسنان'], onChanged: (v) => setState(() => specialty = v)),
          const SizedBox(height: 12),
          _Select(label: 'الولاية', value: wilaya, items: const ['الجزائر'], onChanged: (v) => setState(() => wilaya = v)),
          const SizedBox(height: 12),
          _Select(label: 'البلدية', value: commune, items: const ['باب الزوار', 'حيدرة'], onChanged: (v) => setState(() => commune = v)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final qp = {'specialty': specialty, 'wilaya': wilaya, 'commune': commune};
              context.push(Uri(path: '/doctors', queryParameters: qp).toString());
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text('بحث'),
          ),
        ],
      ),
    );
  }
}

class _Select extends StatelessWidget {
  const _Select({required this.label, required this.value, required this.items, required this.onChanged});
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ),
    );
  }
}
