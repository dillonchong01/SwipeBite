class LocationModel {
  final String id;
  final String name;

  LocationModel({
    required this.id,
    required this.name,
  });

  factory LocationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return LocationModel(
      id: id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}