import 'property2.dart';

class PropertyResponse {
  final List<Property2> properties;
  final Map<String, dynamic> pagination;

  PropertyResponse({
    required this.properties,
    required this.pagination,
  });

  int get total => pagination['total'] ?? 0;
  int get page => pagination['page'] ?? 1;
  int get limit => pagination['limit'] ?? 10;
  int get pages => pagination['pages'] ?? 1;

  PropertyResponse copyWith({
    List<Property2>? properties,
    Map<String, dynamic>? pagination,
  }) {
    return PropertyResponse(
      properties: properties ?? this.properties,
      pagination: pagination ?? this.pagination,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'properties': properties.map((property) => property.toJson()).toList(),
      'pagination': pagination,
    };
  }

  factory PropertyResponse.fromJson(Map<String, dynamic> json) {
    List<Property2> propertiesList = [];
    if (json['properties'] != null && json['properties'] is List) {
      propertiesList = (json['properties'] as List)
          .map((propertyJson) => Property2.fromJson(propertyJson))
          .toList();
    }

    return PropertyResponse(
      properties: propertiesList,
      pagination: json['pagination'] ?? {'total': 0, 'page': 1, 'limit': 10, 'pages': 1},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyResponse &&
        other.properties.length == properties.length &&
        other.pagination.toString() == pagination.toString();
  }

  @override
  int get hashCode {
    return properties.hashCode ^ pagination.hashCode;
  }
}
