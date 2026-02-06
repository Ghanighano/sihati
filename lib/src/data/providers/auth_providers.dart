import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';

/// Provider لمستودع المصادقة
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Provider لحالة المصادقة (stream)
/// يصدر null عند عدم تسجيل الدخول، أو UserModel عند تسجيل الدخول
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Provider للمستخدم الحالي
/// يصدر null إذا لم يكن هناك مستخدم مسجل دخوله
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getCurrentUser();
});

/// حالة عملية التحقق من رقم الهاتف
enum PhoneVerificationStatus {
  initial,       // الحالة الابتدائية
  codeSending,   // جاري إرسال الرمز
  codeSent,      // تم إرسال الرمز
  verifying,     // جاري التحقق من الرمز
  verified,      // تم التحقق بنجاح
  error,         // حدث خطأ
}

/// حالة التحقق من رقم الهاتف
class PhoneVerificationState {
  PhoneVerificationState({
    this.status = PhoneVerificationStatus.initial,
    this.verificationId,
    this.phoneNumber,
    this.error,
    this.forceResendingToken,
  });

  final PhoneVerificationStatus status;
  final String? verificationId;
  final String? phoneNumber;
  final String? error;
  final int? forceResendingToken;

  bool get isLoading =>
      status == PhoneVerificationStatus.codeSending ||
      status == PhoneVerificationStatus.verifying;

  PhoneVerificationState copyWith({
    PhoneVerificationStatus? status,
    String? verificationId,
    String? phoneNumber,
    String? error,
    int? forceResendingToken,
  }) {
    return PhoneVerificationState(
      status: status ?? this.status,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      error: error ?? this.error,
      forceResendingToken: forceResendingToken ?? this.forceResendingToken,
    );
  }
}

/// Controller للتحكم في عملية التحقق من رقم الهاتف
class PhoneVerificationController extends StateNotifier<PhoneVerificationState> {
  PhoneVerificationController(this._authRepository)
      : super(PhoneVerificationState());

  final AuthRepository _authRepository;

  /// إرسال رمز التحقق إلى رقم الهاتف
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    state = state.copyWith(
      status: PhoneVerificationStatus.codeSending,
      phoneNumber: phoneNumber,
      error: null,
    );

    await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (String verificationId, int? forceResendingToken) {
        state = state.copyWith(
          status: PhoneVerificationStatus.codeSent,
          verificationId: verificationId,
          forceResendingToken: forceResendingToken,
        );
      },
      verificationCompleted: (UserModel user) {
        state = state.copyWith(
          status: PhoneVerificationStatus.verified,
        );
      },
      verificationFailed: (String error) {
        state = state.copyWith(
          status: PhoneVerificationStatus.error,
          error: error,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // لا حاجة لتحديث الحالة هنا
      },
    );
  }

  /// التحقق من رمز SMS
  Future<UserModel?> verifySmsCode(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(
        status: PhoneVerificationStatus.error,
        error: 'رمز التحقق غير موجود',
      );
      return null;
    }

    state = state.copyWith(
      status: PhoneVerificationStatus.verifying,
      error: null,
    );

    try {
      final user = await _authRepository.verifySmsCode(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );

      if (user != null) {
        state = state.copyWith(
          status: PhoneVerificationStatus.verified,
        );
        return user;
      } else {
        state = state.copyWith(
          status: PhoneVerificationStatus.error,
          error: 'فشل التحقق من الرمز',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        status: PhoneVerificationStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  /// إعادة تعيين الحالة
  void reset() {
    state = PhoneVerificationState();
  }
}

/// Provider لـ PhoneVerificationController
final phoneVerificationControllerProvider =
    StateNotifierProvider<PhoneVerificationController, PhoneVerificationState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return PhoneVerificationController(authRepository);
});
