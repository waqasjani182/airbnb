class Facility {
  final int facilityId;
  final String facilityType;
  final int? propertyId;

  Facility({
    required this.facilityId,
    required this.facilityType,
    this.propertyId,
  });

  Facility copyWith({
    int? facilityId,
    String? facilityType,
    int? propertyId,
  }) {
    return Facility(
      facilityId: facilityId ?? this.facilityId,
      facilityType: facilityType ?? this.facilityType,
      propertyId: propertyId ?? this.propertyId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facility_id': facilityId,
      'facility_type': facilityType,
      'property_id': propertyId,
    };
  }

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      facilityId: json['facility_id'],
      facilityType: json['facility_type'],
      propertyId: json['property_id'], // This might be null from the API
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Facility &&
        other.facilityId == facilityId &&
        other.facilityType == facilityType &&
        other.propertyId == propertyId;
  }

  @override
  int get hashCode {
    return facilityId.hashCode ^ facilityType.hashCode ^ propertyId.hashCode;
  }
}
