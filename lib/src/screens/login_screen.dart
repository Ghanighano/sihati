import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sihati — Login')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'هذه نسخة نظيفة للـAPK (بدون Firebase/Maps الآن لتفادي مشاكل البناء).\nبعد ما يطلع APK بنجاح نرجّع Firebase وGoogle Maps خطوة بخطوة.',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'رقم الهاتف (تجريبي)')),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/home'),
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }
}
