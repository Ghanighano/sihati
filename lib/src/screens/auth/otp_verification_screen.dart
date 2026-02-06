import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_providers.dart';

/// شاشة إدخال رمز OTP
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.phoneNumber,
  });

  final String? phoneNumber;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    final code = _getOtpCode();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال الرمز كاملاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = await ref
        .read(phoneVerificationControllerProvider.notifier)
        .verifySmsCode(code);

    if (user != null && mounted) {
      // التحقق نجح، الانتقال إلى شاشة اختيار نوع المستخدم
      context.go('/auth/user-type');
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    final phoneNumber = widget.phoneNumber;
    if (phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في رقم الهاتف'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // إعادة إرسال الرمز
    await ref
        .read(phoneVerificationControllerProvider.notifier)
        .verifyPhoneNumber(phoneNumber);
    
    _startTimer();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة إرسال الرمز'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verificationState = ref.watch(phoneVerificationControllerProvider);

    // الاستماع لتغييرات الحالة
    ref.listen<PhoneVerificationState>(
      phoneVerificationControllerProvider,
      (previous, next) {
        if (next.status == PhoneVerificationStatus.error) {
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
        title: const Text('التحقق من الهاتف'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth/phone'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // أيقونة الرسالة
              Icon(
                Icons.message_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 32),
              
              // العنوان
              Text(
                'أدخل رمز التحقق',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // الوصف
              Text(
                'أرسلنا رمز التحقق إلى\n${widget.phoneNumber ?? "رقم الهاتف"}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // حقول إدخال OTP
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return _buildOtpField(index);
                  }),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // زر التحقق
              FilledButton(
                onPressed: verificationState.isLoading ? null : _verifyOtp,
                child: verificationState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('تأكيد'),
              ),
              
              const SizedBox(height: 24),
              
              // إعادة إرسال الرمز
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _resendCode,
                        child: Text(
                          'إعادة إرسال الرمز',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        'إعادة الإرسال بعد $_remainingSeconds ثانية',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.all(8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // الانتقال إلى الحقل التالي
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // آخر حقل، إخفاء لوحة المفاتيح
              _focusNodes[index].unfocus();
              // محاولة التحقق تلقائياً
              _verifyOtp();
            }
          }
        },
        onTap: () {
          // تحديد النص عند الضغط
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
      ),
    );
  }
}
