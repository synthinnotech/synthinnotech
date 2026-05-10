class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? department;
  final String? jobTitle;
  final double salary;
  final String? profileImageUrl;
  final bool isActive;
  final String? address;
  final String? gender;
  final String? dateOfBirth;
  final String? dateOfJoining;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'employee',
    this.department,
    this.jobTitle,
    this.salary = 0,
    this.profileImageUrl,
    this.isActive = true,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.dateOfJoining,
    this.createdAt,
  });

  String get staffName => name;
  bool get isAdminUser => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] ?? json['id']?.toString() ?? '',
        name: json['name'] ?? json['staff_name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        role: json['role'] ?? (json['is_admin'] == 1 ? 'admin' : 'employee'),
        department: json['department'],
        jobTitle: json['job_title'],
        salary: (json['salary'] as num?)?.toDouble() ?? 0,
        profileImageUrl: json['profile_image_url'],
        isActive: json['is_active'] ?? (json['status'] == 1),
        address: json['address'],
        gender: json['gender'],
        dateOfBirth: json['dob'] ?? json['date_of_birth'],
        dateOfJoining: json['doj'] ?? json['date_of_joining'],
        createdAt: json['created_at'] != null
            ? (json['created_at'] is int
                ? DateTime.fromMillisecondsSinceEpoch(
                    (json['created_at'] as int) * 1000)
                : DateTime.tryParse(json['created_at'].toString()))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'department': department,
        'job_title': jobTitle,
        'salary': salary,
        'profile_image_url': profileImageUrl,
        'is_active': isActive,
        'address': address,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'date_of_joining': dateOfJoining,
        'created_at': createdAt?.millisecondsSinceEpoch,
      };

  AppUser copyWith({
    String? name,
    String? phone,
    String? role,
    String? department,
    String? jobTitle,
    double? salary,
    String? profileImageUrl,
    bool? isActive,
    String? address,
    String? gender,
  }) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        department: department ?? this.department,
        jobTitle: jobTitle ?? this.jobTitle,
        salary: salary ?? this.salary,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        isActive: isActive ?? this.isActive,
        address: address ?? this.address,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth,
        dateOfJoining: dateOfJoining,
        createdAt: createdAt,
      );
}
