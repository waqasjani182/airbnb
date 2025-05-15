import 'package:flutter/foundation.dart';
import 'user.dart';

class User2 {
  final int userId;
  final String? name;
  final String email;
  final String? address;
  final String? phoneNo;
  final String? profileImage;
  final List<String>? favoriteProperties;

  User2({
    required this.userId,
    this.name,
    required this.email,
    this.address,
    this.phoneNo,
    this.profileImage,
    this.favoriteProperties,
  });

  // Helper to get first name and last name
  String get firstName {
    if (name == null || name!.isEmpty) return '';
    final parts = name!.split(' ');
    return parts.first;
  }

  String get lastName {
    if (name == null || name!.isEmpty) return '';
    final parts = name!.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  // Helper to get full name
  String get fullName => name ?? '';

  User2 copyWith({
    int? userId,
    String? name,
    String? email,
    String? address,
    String? phoneNo,
    String? profileImage,
    List<String>? favoriteProperties,
  }) {
    return User2(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImage: profileImage ?? this.profileImage,
      favoriteProperties: favoriteProperties ?? this.favoriteProperties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_ID': userId,
      'name': name,
      'email': email,
      'address': address,
      'phone_No': phoneNo,
      'profile_image': profileImage,
      'favoriteProperties': favoriteProperties,
    };
  }

  factory User2.fromJson(Map<String, dynamic> json) {
    return User2(
      userId: json['user_ID'] is String
          ? int.parse(json['user_ID'])
          : json['user_ID'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      phoneNo: json['phone_No'],
      profileImage: json['profile_image'],
      favoriteProperties: json['favoriteProperties'] != null
          ? List<String>.from(json['favoriteProperties'])
          : null,
    );
  }

  // Convert to the original User model for backward compatibility
  User toUser() {
    return User(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phoneNo,
      isHost: false, // Default value as it's not provided in the new API
      profileImage: profileImage,
      address: address,
      createdAt: null, // Not provided in the new API
    );
  }

  // Create from the original User model
  factory User2.fromUser(User user) {
    return User2(
      userId: user.id,
      name: user.fullName,
      email: user.email,
      address: user.address,
      phoneNo: user.phone,
      profileImage: user.profileImage,
      favoriteProperties: user.favoriteProperties,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User2 &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.address == address &&
        other.phoneNo == phoneNo &&
        other.profileImage == profileImage &&
        listEquals(other.favoriteProperties, favoriteProperties);
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        address.hashCode ^
        phoneNo.hashCode ^
        profileImage.hashCode ^
        favoriteProperties.hashCode;
  }
}

// Import for backward compatibility
