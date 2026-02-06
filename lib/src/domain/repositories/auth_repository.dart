import '../models/user_model.dart';

/// واجهة مستودع المصادقة - تحدد العمليات المطلوبة لنظام المصادقة
/// 
/// هذه واجهة abstract تسمح بتبديل تنفيذ المصادقة (Firebase، أو أي نظام آخر)
/// دون تغيير طبقة UI أو المنطق
abstract class AuthRepository {
  /// التحقق من رقم الهاتف وإرسال رمز OTP
  /// 
  /// [phoneNumber] - رقم الهاتف بصيغة دولية (مثال: +213XXXXXXXXX)
  /// [codeSent] - دالة يتم استدعاؤها عند إرسال الرمز بنجاح
  /// [verificationCompleted] - دالة يتم استدعاؤها عند اكتمال التحقق تلقائياً (Android)
  /// [verificationFailed] - دالة يتم استدعاؤها عند فشل التحقق
  /// [codeAutoRetrievalTimeout] - دالة يتم استدعاؤها عند انتهاء وقت استرجاع الرمز التلقائي
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? forceResendingToken) codeSent,
    required void Function(UserModel user) verificationCompleted,
    required void Function(String error) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  });

  /// التحقق من رمز SMS والحصول على المستخدم
  /// 
  /// [verificationId] - معرّف التحقق الذي تم الحصول عليه من verifyPhoneNumber
  /// [smsCode] - رمز التحقق الذي أدخله المستخدم
  /// 
  /// Returns: UserModel إذا كان التحقق ناجحاً، وإلا null
  Future<UserModel?> verifySmsCode({
    required String verificationId,
    required String smsCode,
  });

  /// تسجيل خروج المستخدم الحالي
  Future<void> signOut();

  /// الحصول على المستخدم الحالي المسجل دخوله
  /// 
  /// Returns: UserModel إذا كان هناك مستخدم مسجل دخوله، وإلا null
  Future<UserModel?> getCurrentUser();

  /// مراقبة حالة المصادقة (stream)
  /// 
  /// Returns: Stream يصدر null عند تسجيل الخروج، أو UserModel عند تسجيل الدخول
  Stream<UserModel?> authStateChanges();

  /// حفظ نوع المستخدم (مريض/طبيب) بعد التسجيل
  /// 
  /// [userId] - معرّف المستخدم
  /// [userType] - نوع المستخدم (patient أو doctor)
  /// [displayName] - اسم المستخدم (اختياري)
  Future<void> saveUserType({
    required String userId,
    required UserType userType,
    String? displayName,
  });
}
