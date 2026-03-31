class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType; // 'patient' or 'doctor'
  final String? profileImage;
  final DateTime createdAt;
  final String? specialization;
  final String? experience;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;

  User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['userType'] ?? json['role'] ?? 'patient',
      profileImage: json['profileImage'] ?? json['profilePicture'],
      specialization: json['specialization'],
      experience: json['experience']?.toString(),
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String? get qualification => null;

  String? get hospital => null;

  double? get rating => null;

  String? get bio => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'profileImage': profileImage,
      'specialization': specialization,
      'experience': experience,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String? operator [](String other) {
    return null;
  }
}