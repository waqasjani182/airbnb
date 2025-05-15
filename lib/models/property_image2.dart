class PropertyImage2 {
  final int pictureId;
  final int propertyId;
  final String imageUrl;

  PropertyImage2({
    required this.pictureId,
    required this.propertyId,
    required this.imageUrl,
  });

  PropertyImage2 copyWith({
    int? pictureId,
    int? propertyId,
    String? imageUrl,
  }) {
    return PropertyImage2(
      pictureId: pictureId ?? this.pictureId,
      propertyId: propertyId ?? this.propertyId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'picture_id': pictureId,
      'property_id': propertyId,
      'image_url': imageUrl,
    };
  }

  factory PropertyImage2.fromJson(Map<String, dynamic> json) {
    return PropertyImage2(
      pictureId: json['picture_id'],
      propertyId: json['property_id'],
      imageUrl: json['image_url'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyImage2 &&
        other.pictureId == pictureId &&
        other.propertyId == propertyId &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return pictureId.hashCode ^ propertyId.hashCode ^ imageUrl.hashCode;
  }
}
