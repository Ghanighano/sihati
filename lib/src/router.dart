import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/home_search_screen.dart';
import 'screens/doctor_list_screen.dart';
import 'screens/doctor_details_screen.dart';
import 'screens/request_appointment_screen.dart';
import 'screens/my_appointments_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
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
