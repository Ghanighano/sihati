/// نوع المستخدم في النظام
enum UserType {
  patient,  // مريض
  doctor,   // طبيب
}

/// موديل المستخدم - يمثل بيانات المستخدم في النظام
class UserModel {
  UserModel({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    required this.userType,
    required this.createdAt,
  });

  /// معرّف المستخدم الفريد
  final String id;
  
  /// رقم هاتف المستخدم مع رمز الدولة (مثال: +213XXXXXXXXX)
  final String phoneNumber;
  
  /// اسم المستخدم (اختياري)
  final String? displayName;
  
  /// نوع المستخدم (مريض أو طبيب)
  final UserType userType;
  
  /// تاريخ إنشاء الحساب
  final DateTime createdAt;

  /// نسخ الموديل مع تحديث بعض الحقول
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? displayName,
    UserType? userType,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// تحويل من JSON إلى UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String?,
      userType: UserType.values.firstWhere(
        (e) => e.name == json['userType'],
        orElse: () => UserType.patient,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// تحويل من UserModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'userType': userType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phoneNumber: $phoneNumber, displayName: $displayName, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
