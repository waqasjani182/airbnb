class PropertyAmenity {
  final int id;
  final String name;
  final String icon;
  final String createdAt;
  final int propertyId;

  PropertyAmenity({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    this.propertyId = 0, // Make propertyId optional with default value of 0
  });

  PropertyAmenity copyWith({
    int? id,
    String? name,
    String? icon,
    String? createdAt,
    int? propertyId,
  }) {
    return PropertyAmenity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      propertyId: propertyId ?? this.propertyId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'created_at': createdAt,
      'property_id': propertyId,
    };
  }

  factory PropertyAmenity.fromJson(Map<String, dynamic> json) {
    return PropertyAmenity(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      createdAt: json['created_at'],
      propertyId:
          json['property_id'] ?? 0, // Default to 0 if property_id is null
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyAmenity &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.createdAt == createdAt &&
        other.propertyId == propertyId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        createdAt.hashCode ^
        propertyId.hashCode;
  }
}
