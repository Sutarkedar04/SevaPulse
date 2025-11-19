class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType; // 'patient' or 'doctor'
  final String? profileImage;
  final DateTime createdAt;
  final String? specialization; // For doctors
  final String? experience; // For doctors
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender; // Add this field

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
    this.gender, // Add this parameter
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['userType'] ?? 'patient',
      profileImage: json['profileImage'],
      specialization: json['specialization'],
      experience: json['experience'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'], // Add this line
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

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
      'gender': gender, // Add this line
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
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
    String? gender, // Add this parameter
  }) {
    return User(
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
      gender: gender ?? this.gender, // Add this line
    );
  }
}