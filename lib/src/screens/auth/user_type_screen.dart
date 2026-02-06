import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_providers.dart';
import '../../domain/models/user_model.dart';

/// شاشة اختيار نوع المستخدم (مريض أو طبيب)
class UserTypeScreen extends ConsumerStatefulWidget {
  const UserTypeScreen({super.key});

  @override
  ConsumerState<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends ConsumerState<UserTypeScreen> {
  UserType? _selectedUserType;
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار نوع الحساب'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال الاسم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final currentUser = await authRepository.getCurrentUser();

      if (currentUser == null) {
        throw Exception('لم يتم العثور على المستخدم');
      }

      // حفظ نوع المستخدم والاسم
      await authRepository.saveUserType(
        userId: currentUser.id,
        userType: _selectedUserType!,
        displayName: _nameController.text.trim(),
      );

      if (mounted) {
        // الانتقال إلى الشاشة الرئيسية
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إكمال التسجيل'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // أيقونة المستخدم
              Icon(
                Icons.person_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 32),
              
              // العنوان
              Text(
                'مرحباً بك في صحتي',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // الوصف
              Text(
                'ساعدنا لنتعرف عليك بشكل أفضل',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // حقل الاسم
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  hintText: 'أدخل اسمك',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 32),
              
              // عنوان اختيار نوع الحساب
              Text(
                'اختر نوع الحساب',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // بطاقة مريض
              _buildUserTypeCard(
                userType: UserType.patient,
                title: 'مريض',
                description: 'أبحث عن طبيب وأريد حجز موعد',
                icon: Icons.medical_services_rounded,
                color: const Color(0xFF0EA5A6),
              ),
              
              const SizedBox(height: 16),
              
              // بطاقة طبيب
              _buildUserTypeCard(
                userType: UserType.doctor,
                title: 'طبيب',
                description: 'أريد عرض خدماتي واستقبال المرضى',
                icon: Icons.local_hospital_rounded,
                color: const Color(0xFF0E6BA5),
              ),
              
              const SizedBox(height: 32),
              
              // زر المتابعة
              FilledButton(
                onPressed: _isLoading ? null : _saveAndContinue,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required UserType userType,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedUserType == userType;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // الأيقونة
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // علامة الاختيار
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 28,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey[400],
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
