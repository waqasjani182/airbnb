class PropertyStatus {
  final int propertyId;
  final String title;
  final String status; // 'active' or 'maintenance'
  final bool isActive;
  final bool canAcceptBookings;
  final String? maintenanceReason;

  PropertyStatus({
    required this.propertyId,
    required this.title,
    required this.status,
    required this.isActive,
    required this.canAcceptBookings,
    this.maintenanceReason,
  });

  PropertyStatus copyWith({
    int? propertyId,
    String? title,
    String? status,
    bool? isActive,
    bool? canAcceptBookings,
    String? maintenanceReason,
  }) {
    return PropertyStatus(
      propertyId: propertyId ?? this.propertyId,
      title: title ?? this.title,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      canAcceptBookings: canAcceptBookings ?? this.canAcceptBookings,
      maintenanceReason: maintenanceReason ?? this.maintenanceReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'title': title,
      'status': status,
      'is_active': isActive,
      'can_accept_bookings': canAcceptBookings,
      if (maintenanceReason != null) 'maintenance_reason': maintenanceReason,
    };
  }

  factory PropertyStatus.fromJson(Map<String, dynamic> json) {
    return PropertyStatus(
      propertyId: json['property_id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? 'active',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      canAcceptBookings: json['can_accept_bookings'] == 1 || json['can_accept_bookings'] == true,
      maintenanceReason: json['maintenance_reason'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyStatus &&
        other.propertyId == propertyId &&
        other.title == title &&
        other.status == status &&
        other.isActive == isActive &&
        other.canAcceptBookings == canAcceptBookings &&
        other.maintenanceReason == maintenanceReason;
  }

  @override
  int get hashCode {
    return propertyId.hashCode ^
        title.hashCode ^
        status.hashCode ^
        isActive.hashCode ^
        canAcceptBookings.hashCode ^
        maintenanceReason.hashCode;
  }

  @override
  String toString() {
    return 'PropertyStatus(propertyId: $propertyId, title: $title, status: $status, isActive: $isActive, canAcceptBookings: $canAcceptBookings, maintenanceReason: $maintenanceReason)';
  }

  // Helper getters
  bool get isInMaintenance => status == 'maintenance';
  bool get isAvailableForBooking => status == 'active' && isActive;
  bool get isVisible => isAvailableForBooking;

  String get statusDisplayText {
    if (isInMaintenance) {
      return 'Under Maintenance';
    } else if (!isActive) {
      return 'Disabled';
    } else {
      return 'Active';
    }
  }

  String get statusDescription {
    if (isInMaintenance) {
      return maintenanceReason ?? 'Property is under maintenance';
    } else if (!isActive) {
      return 'Property is temporarily disabled';
    } else {
      return 'Property is active and accepting bookings';
    }
  }
}

class PropertyStatusResponse {
  final String message;
  final PropertyStatus? propertyStatus;
  final String? maintenanceReason;

  PropertyStatusResponse({
    required this.message,
    this.propertyStatus,
    this.maintenanceReason,
  });

  factory PropertyStatusResponse.fromJson(Map<String, dynamic> json) {
    PropertyStatus? status;
    
    // Handle different response formats
    if (json['property'] != null) {
      status = PropertyStatus.fromJson(json['property']);
    } else if (json.containsKey('property_id')) {
      status = PropertyStatus.fromJson(json);
    }

    return PropertyStatusResponse(
      message: json['message'] ?? '',
      propertyStatus: status,
      maintenanceReason: json['maintenance_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (propertyStatus != null) 'property': propertyStatus!.toJson(),
      if (maintenanceReason != null) 'maintenance_reason': maintenanceReason,
    };
  }
}

// Request models
class SetMaintenanceRequest {
  final String maintenanceReason;

  SetMaintenanceRequest({required this.maintenanceReason});

  Map<String, dynamic> toJson() {
    return {
      'maintenance_reason': maintenanceReason,
    };
  }
}

class ToggleStatusRequest {
  final bool isActive;

  ToggleStatusRequest({required this.isActive});

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
    };
  }
}
