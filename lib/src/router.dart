import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers/auth_providers.dart';
import 'screens/auth/phone_input_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/user_type_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_search_screen.dart';
import 'screens/doctor_list_screen.dart';
import 'screens/doctor_details_screen.dart';
import 'screens/request_appointment_screen.dart';
import 'screens/my_appointments_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // مراقبة حالة المصادقة
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/auth/phone',
    redirect: (context, state) {
      // الحصول على حالة المصادقة
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // إذا كان المستخدم مسجل دخوله ويحاول الوصول لصفحات المصادقة
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // إذا لم يكن المستخدم مسجل دخوله ويحاول الوصول لصفحة محمية
      if (!isAuthenticated && !isAuthRoute && state.matchedLocation != '/login') {
        return '/auth/phone';
      }

      // السماح بالمرور
      return null;
    },
    routes: [
      // مسارات المصادقة
      GoRoute(
        path: '/auth/phone',
        builder: (_, __) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/auth/verify-otp',
        builder: (context, state) => OtpVerificationScreen(
          phoneNumber: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/auth/user-type',
        builder: (_, __) => const UserTypeScreen(),
      ),
      
      // المسار القديم للتوافق
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      
      // المسارات المحمية
      GoRoute(path: '/home', builder: (_, __) => const HomeSearchScreen()),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => DoctorListScreen(
          specialty: state.uri.queryParameters['specialty'] ?? '',
          wilaya: state.uri.queryParameters['wilaya'] ?? '',
          commune: state.uri.queryParameters['commune'] ?? '',
        ),
      ),
      GoRoute(
        path: '/doctor/:id',
        builder: (context, state) => DoctorDetailsScreen(doctorId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/doctor/:id/request',
        builder: (context, state) => RequestAppointmentScreen(doctorId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/appointments', builder: (_, __) => const MyAppointmentsScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString()))),
  );
});
