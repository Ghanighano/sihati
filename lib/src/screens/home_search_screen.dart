import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  String specialty = 'طب عام';
  String wilaya = 'الجزائر';
  String commune = 'باب الزوار';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sihati'),
        actions: [
          IconButton(
            tooltip: 'مواعيدي',
            onPressed: () => context.push('/appointments'),
            icon: const Icon(Icons.event_note_rounded),
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
