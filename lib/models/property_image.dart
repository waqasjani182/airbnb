class PropertyImage {
  final int id;
  final int propertyId;
  final String imageUrl;
  final bool isPrimary;
  final String createdAt;

  PropertyImage({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    required this.isPrimary,
    required this.createdAt,
  });

  PropertyImage copyWith({
    int? id,
    int? propertyId,
    String? imageUrl,
    bool? isPrimary,
    String? createdAt,
  }) {
    return PropertyImage(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'created_at': createdAt,
    };
  }

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'],
      propertyId: json['property_id'],
      imageUrl: json['image_url'],
      isPrimary: json['is_primary'] ?? false,
      createdAt: json['created_at'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyImage &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.imageUrl == imageUrl &&
        other.isPrimary == isPrimary &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        imageUrl.hashCode ^
        isPrimary.hashCode ^
        createdAt.hashCode;
  }
}
