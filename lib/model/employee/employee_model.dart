import 'package:flutter/material.dart';

enum EmployeeRole { admin, manager, employee, intern }

extension EmployeeRoleExt on EmployeeRole {
  String get label {
    switch (this) {
      case EmployeeRole.admin:
        return 'Admin';
      case EmployeeRole.manager:
        return 'Manager';
      case EmployeeRole.employee:
        return 'Employee';
      case EmployeeRole.intern:
        return 'Intern';
    }
  }

  Color get color {
    switch (this) {
      case EmployeeRole.admin:
        return const Color(0xFF9C27B0);
      case EmployeeRole.manager:
        return const Color(0xFF2196F3);
      case EmployeeRole.employee:
        return const Color(0xFF4CAF50);
      case EmployeeRole.intern:
        return const Color(0xFFFF9800);
    }
  }
}

class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final EmployeeRole role;
  final String? department;
  final String? jobTitle;
  final double salary;
  final String? profileImageUrl;
  final bool isActive;
  final String? address;
  final String? gender;
  final DateTime? dateOfBirth;
  final DateTime? joinDate;
  final DateTime? createdAt;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = EmployeeRole.employee,
    this.department,
    this.jobTitle,
    this.salary = 0,
    this.profileImageUrl,
    this.isActive = true,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.joinDate,
    this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json, String id) =>
      EmployeeModel(
        id: id,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        role: _parseRole(json['role']),
        department: json['department'],
        jobTitle: json['job_title'],
        salary: (json['salary'] as num?)?.toDouble() ?? 0,
        profileImageUrl: json['profile_image_url'],
        isActive: json['is_active'] ?? true,
        address: json['address'],
        gender: json['gender'],
        dateOfBirth: json['date_of_birth'] != null
            ? DateTime.tryParse(json['date_of_birth'].toString())
            : null,
        joinDate: json['join_date'] != null
            ? DateTime.tryParse(json['join_date'].toString())
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'department': department,
        'job_title': jobTitle,
        'salary': salary,
        'profile_image_url': profileImageUrl,
        'is_active': isActive,
        'address': address,
        'gender': gender,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'join_date': joinDate?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  static EmployeeRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return EmployeeRole.admin;
      case 'manager':
        return EmployeeRole.manager;
      case 'intern':
        return EmployeeRole.intern;
      default:
        return EmployeeRole.employee;
    }
  }
}
