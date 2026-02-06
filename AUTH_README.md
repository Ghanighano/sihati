# نظام المصادقة في تطبيق صحتي (Sihati)

## نظرة عامة

تم إضافة نظام مصادقة كامل باستخدام Firebase Phone Authentication يسمح للمستخدمين بتسجيل الدخول باستخدام رقم الهاتف.

## المكونات الرئيسية

### 1. طبقة Domain (`lib/src/domain/`)

#### `models/user_model.dart`
- موديل المستخدم يحتوي على:
  - `id`: معرّف المستخدم الفريد
  - `phoneNumber`: رقم الهاتف مع رمز الدولة
  - `displayName`: اسم المستخدم (اختياري)
  - `userType`: نوع المستخدم (patient/doctor)
  - `createdAt`: تاريخ إنشاء الحساب

#### `repositories/auth_repository.dart`
- واجهة abstract للمصادقة تحدد العمليات المطلوبة:
  - `verifyPhoneNumber()`: إرسال رمز OTP
  - `verifySmsCode()`: التحقق من الرمز
  - `signOut()`: تسجيل الخروج
  - `getCurrentUser()`: الحصول على المستخدم الحالي
  - `authStateChanges()`: مراقبة حالة المصادقة
  - `saveUserType()`: حفظ نوع المستخدم

### 2. طبقة Data (`lib/src/data/`)

#### `repositories/firebase_auth_repository.dart`
- تنفيذ مستودع المصادقة باستخدام Firebase Auth
- يتعامل مع جميع عمليات Firebase Authentication
- يحتوي على معالجة الأخطاء برسائل عربية

#### `providers/auth_providers.dart`
- Riverpod providers لإدارة حالة المصادقة:
  - `authRepositoryProvider`: مزود لمستودع المصادقة
  - `authStateProvider`: stream لحالة المصادقة
  - `currentUserProvider`: المستخدم الحالي
  - `phoneVerificationControllerProvider`: التحكم في عملية التحقق

### 3. طبقة UI (`lib/src/screens/auth/`)

#### `phone_input_screen.dart`
- شاشة إدخال رقم الهاتف
- تدعم رمز الدولة الجزائري (+213)
- تحقق من صحة رقم الهاتف
- واجهة مستخدم عربية مع RTL

#### `otp_verification_screen.dart`
- شاشة إدخال رمز التحقق (6 أرقام)
- مؤقت لإعادة إرسال الرمز (60 ثانية)
- انتقال تلقائي بين الحقول
- إمكانية إعادة إرسال الرمز

#### `user_type_screen.dart`
- شاشة اختيار نوع المستخدم (مريض/طبيب)
- حقل لإدخال اسم المستخدم
- تصميم جذاب مع أيقونات وألوان مختلفة

### 4. Router (`lib/src/router.dart`)

- مسارات المصادقة:
  - `/auth/phone`: إدخال رقم الهاتف
  - `/auth/verify-otp`: التحقق من OTP
  - `/auth/user-type`: اختيار نوع المستخدم

- منطق Redirect:
  - المستخدم غير المصادق يتم توجيهه لشاشة تسجيل الدخول
  - المستخدم المصادق لا يمكنه الوصول لشاشات المصادقة

### 5. Firebase Setup

#### `firebase_options.dart`
- ملف placeholder للتهيئة
- يحتوي على إعدادات وهمية للتطوير
- يجب استبداله بإعدادات Firebase الفعلية في الإنتاج

#### `main.dart`
- تهيئة Firebase قبل تشغيل التطبيق
- استخدام `ProviderScope` لـ Riverpod

## سير عمل المصادقة

1. **المستخدم يدخل رقم الهاتف** → PhoneInputScreen
2. **Firebase يرسل رمز OTP** → SMS
3. **المستخدم يدخل الرمز** → OtpVerificationScreen
4. **التحقق من الرمز** → Firebase Auth
5. **اختيار نوع المستخدم** → UserTypeScreen
6. **حفظ البيانات والانتقال** → HomeScreen

## دعم اللغة العربية والـ RTL

- التطبيق يدعم اللغة العربية بشكل كامل
- اتجاه النص من اليمين لليسار (RTL)
- جميع النصوص في واجهة المستخدم بالعربية
- رسائل الخطأ بالعربية

## الخطوات التالية للإنتاج

1. **إعداد Firebase Project**:
   - إنشاء مشروع Firebase على console.firebase.google.com
   - تفعيل Phone Authentication
   - تنزيل ملفات التهيئة (google-services.json للأندرويد، GoogleService-Info.plist للـ iOS)
   - استبدال `firebase_options.dart` بالإعدادات الفعلية

2. **إعداد Firestore** (اختياري):
   - لحفظ بيانات المستخدمين بشكل دائم
   - استبدال `_userDataCache` في FirebaseAuthRepository بـ Firestore

3. **اختبار على أجهزة حقيقية**:
   - Phone Authentication تحتاج جهاز حقيقي للاختبار
   - إضافة أرقام اختبار في Firebase Console للتطوير

## ملاحظات مهمة

- الكود الحالي يستخدم مخزن مؤقت في الذاكرة (`_userDataCache`) لحفظ نوع المستخدم
- في الإنتاج، يجب استخدام Firestore أو قاعدة بيانات أخرى
- رموز التحقق في التطوير تنتهي صلاحيتها بعد دقيقة واحدة
- Firebase Phone Auth لها حدود للاستخدام المجاني (10 SMS/يوم)

## الأمان

- جميع عمليات المصادقة تتم عبر Firebase
- رموز OTP صالحة لفترة محدودة
- معالجة الأخطاء بشكل آمن دون كشف معلومات حساسة
- التحقق من صحة المدخلات على مستوى الـ UI والـ Backend
