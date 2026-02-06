import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_providers.dart';

/// شاشة إدخال رقم الهاتف
class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // رمز الدولة الافتراضي للجزائر
  final String _countryCode = '+213';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _getFullPhoneNumber() {
    String phone = _phoneController.text.trim();
    // إزالة الصفر الأول إذا كان موجوداً (الصيغة المحلية في الجزائر)
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    return '$_countryCode$phone';
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    final fullPhoneNumber = _getFullPhoneNumber();
    
    // إرسال رمز التحقق
    await ref.read(phoneVerificationControllerProvider.notifier)
        .verifyPhoneNumber(fullPhoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verificationState = ref.watch(phoneVerificationControllerProvider);

    // الاستماع لتغييرات الحالة والانتقال إلى شاشة OTP
    ref.listen<PhoneVerificationState>(
      phoneVerificationControllerProvider,
      (previous, next) {
        if (next.status == PhoneVerificationStatus.codeSent) {
          context.go('/auth/verify-otp', extra: next.phoneNumber);
        } else if (next.status == PhoneVerificationStatus.verified) {
          // التحقق التلقائي نجح (Android)
          context.go('/auth/user-type');
        } else if (next.status == PhoneVerificationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error ?? 'حدث خطأ'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // أيقونة الهاتف
                Icon(
                  Icons.phone_android_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                
                const SizedBox(height: 32),
                
                // العنوان
                Text(
                  'أدخل رقم هاتفك',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // الوصف
                Text(
                  'سنرسل لك رمز تحقق عبر رسالة SMS',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // حقل إدخال رقم الهاتف
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رمز الدولة
                      Container(
                        width: 80,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            _countryCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // حقل الإدخال
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            hintText: '5XX XXX XXX',
                            hintTextDirection: TextDirection.ltr,
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            
                            // إزالة الصفر الأول إن وجد
                            String phone = value.trim();
                            if (phone.startsWith('0')) {
                              phone = phone.substring(1);
                            }
                            
                            if (phone.length != 9) {
                              return 'رقم الهاتف يجب أن يكون 9 أرقام';
                            }
                            
                            if (!phone.startsWith('5') &&
                                !phone.startsWith('6') &&
                                !phone.startsWith('7')) {
                              return 'رقم الهاتف غير صحيح';
                            }
                            
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // زر إرسال الرمز
                FilledButton(
                  onPressed: verificationState.isLoading ? null : _sendVerificationCode,
                  child: verificationState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('إرسال رمز التحقق'),
                ),
                
                const SizedBox(height: 16),
                
                // معلومات إضافية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تأكد من إدخال رقم هاتف صحيح وفعّال',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
