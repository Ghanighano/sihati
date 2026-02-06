import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class SihatiApp extends ConsumerWidget {
  const SihatiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Sihati',
      theme: SihatiTheme.light(),
      // دعم اللغة العربية والاتجاه من اليمين لليسار
      locale: const Locale('ar', 'DZ'),
      supportedLocales: const [
        Locale('ar', 'DZ'), // العربية - الجزائر
        Locale('ar', ''),   // العربية - عامة
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      routerConfig: router,
    );
  }
}
