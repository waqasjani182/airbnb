class Amenity {
  final int id;
  final String name;
  final String icon;
  final String createdAt;

  Amenity({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
  });

  Amenity copyWith({
    int? id,
    String? name,
    String? icon,
    String? createdAt,
  }) {
    return Amenity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'created_at': createdAt,
    };
  }

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      createdAt: json['created_at'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Amenity &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        createdAt.hashCode;
  }
}
