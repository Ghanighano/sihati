import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// تنفيذ مستودع المصادقة باستخدام Firebase Auth
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  // مخزن مؤقت لبيانات المستخدمين (في production، استخدم Firestore)
  final Map<String, Map<String, dynamic>> _userDataCache = {};

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? forceResendingToken) codeSent,
    required void Function(UserModel user) verificationCompleted,
    required void Function(String error) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // التحقق التلقائي (Android فقط)
          try {
            final userCredential = await _firebaseAuth.signInWithCredential(credential);
            if (userCredential.user != null) {
              final user = await _createUserModelFromFirebaseUser(userCredential.user!);
              verificationCompleted(user);
            }
          } catch (e) {
            verificationFailed('فشل التحقق التلقائي: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'رقم الهاتف غير صحيح';
              break;
            case 'too-many-requests':
              errorMessage = 'عدد كبير من المحاولات. يرجى المحاولة لاحقاً';
              break;
            case 'quota-exceeded':
              errorMessage = 'تم تجاوز الحد المسموح. يرجى المحاولة لاحقاً';
              break;
            default:
              errorMessage = 'حدث خطأ: ${e.message ?? e.code}';
          }
          verificationFailed(errorMessage);
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          codeSent(verificationId, forceResendingToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          codeAutoRetrievalTimeout(verificationId);
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      verificationFailed('خطأ في إرسال الرمز: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // إنشاء بيانات اعتماد من رمز التحقق
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // تسجيل الدخول باستخدام بيانات الاعتماد
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        return await _createUserModelFromFirebaseUser(userCredential.user!);
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('خطأ في التحقق من الرمز: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e);
    } catch (e) {
      debugPrint('خطأ غير متوقع: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    
    return await _createUserModelFromFirebaseUser(firebaseUser);
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _createUserModelFromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<void> saveUserType({
    required String userId,
    required UserType userType,
    String? displayName,
  }) async {
    // حفظ بيانات المستخدم في المخزن المؤقت
    // في production، استخدم Firestore أو قاعدة بيانات أخرى
    _userDataCache[userId] = {
      'userType': userType.name,
      'displayName': displayName,
      'savedAt': DateTime.now().toIso8601String(),
    };
    
    debugPrint('تم حفظ نوع المستخدم: $userType للمستخدم: $userId');
  }

  /// إنشاء UserModel من Firebase User
  Future<UserModel> _createUserModelFromFirebaseUser(User firebaseUser) async {
    final userId = firebaseUser.uid;
    final phoneNumber = firebaseUser.phoneNumber ?? '';
    
    // استرجاع بيانات المستخدم من المخزن المؤقت
    final userData = _userDataCache[userId];
    
    return UserModel(
      id: userId,
      phoneNumber: phoneNumber,
      displayName: userData?['displayName'] as String?,
      userType: userData != null
          ? UserType.values.firstWhere(
              (e) => e.name == userData['userType'],
              orElse: () => UserType.patient,
            )
          : UserType.patient,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// الحصول على رسالة خطأ مناسبة من FirebaseAuthException
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'invalid-verification-id':
        return 'رمز التحقق منتهي الصلاحية';
      case 'session-expired':
        return 'انتهت صلاحية الجلسة. يرجى المحاولة مرة أخرى';
      case 'too-many-requests':
        return 'عدد كبير من المحاولات. يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ: ${e.message ?? e.code}';
    }
  }
}
