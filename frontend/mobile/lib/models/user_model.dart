class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final String? address;
  final String? profileImage;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.address,
    this.profileImage,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName:
          json['fullName']?.toString() ?? '',
      email:
          json['email']?.toString() ?? '',
      phone:
          json['phone']?.toString(),
      role:
          json['role']?.toString() ?? '',
      address:
          json['address']?.toString(),
      profileImage:
          json['profileImage']?.toString(),
      isActive:
          json['isActive'] is bool
              ? json['isActive'] as bool
              : true,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt']
                      .toString(),
                )
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(
                  json['updatedAt']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? address,
    String? profileImage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName:
          fullName ?? this.fullName,
      email:
          email ?? this.email,
      phone:
          phone ?? this.phone,
      role:
          role ?? this.role,
      address:
          address ?? this.address,
      profileImage:
          profileImage ??
          this.profileImage,
      isActive:
          isActive ?? this.isActive,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }
}