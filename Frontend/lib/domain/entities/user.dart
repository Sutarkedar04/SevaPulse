// lib/domain/entities/user.dart
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType;
  final String? profileImage;
  final DateTime createdAt;
  final String? specialization;
  final String? experience;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    required this.createdAt,
    this.specialization,
    this.experience,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
  });

  bool get isPatient => userType == 'patient';
  bool get isDoctor => userType == 'doctor';
  bool get isAdmin => userType == 'admin';

  String get displayName => name.split(' ').first;
  String get initials {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? userType,
    String? profileImage,
    DateTime? createdAt,
    String? specialization,
    String? experience,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      specialization: specialization ?? this.specialization,
      experience: experience ?? this.experience,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
    );
  }
}