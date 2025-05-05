import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final bool isHost;
  final String? profileImage;
  final String? address;
  final String? createdAt;
  final List<String>? favoriteProperties;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.isHost,
    this.profileImage,
    this.address,
    this.createdAt,
    this.favoriteProperties,
  });

  // Helper to get full name
  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    bool? isHost,
    String? profileImage,
    String? address,
    String? createdAt,
    List<String>? favoriteProperties,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isHost: isHost ?? this.isHost,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      favoriteProperties: favoriteProperties ?? this.favoriteProperties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'is_host': isHost,
      'profile_image': profileImage,
      'address': address,
      'created_at': createdAt,
      'favoriteProperties': favoriteProperties,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      isHost: json['is_host'] ?? false,
      profileImage: json['profile_image'],
      address: json['address'],
      createdAt: json['created_at'],
      favoriteProperties: json['favoriteProperties'] != null
          ? List<String>.from(json['favoriteProperties'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.phone == phone &&
        other.isHost == isHost &&
        other.profileImage == profileImage &&
        other.address == address &&
        other.createdAt == createdAt &&
        listEquals(other.favoriteProperties, favoriteProperties);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        isHost.hashCode ^
        profileImage.hashCode ^
        address.hashCode ^
        createdAt.hashCode ^
        favoriteProperties.hashCode;
  }
}
