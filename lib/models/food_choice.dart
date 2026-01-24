class FoodChoice {
  final String id;
  final String name;
  final String locationId;
  final String locationName;
  final String budget; // "high" or "low"
  final int freq;

  FoodChoice({
    required this.id,
    required this.name,
    required this.locationId,
    required this.locationName,
    required this.budget,
    required this.freq,
  });

  factory FoodChoice.fromFirestore(String id, Map<String, dynamic> data) {
    return FoodChoice(
      id: id,
      name: data['name'] ?? '',
      locationId: data['locationId'] ?? '',
      locationName: data['locationName'] ?? '',
      budget: data['budget'] ?? 'low',
      freq: data['freq'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'locationId': locationId,
      'locationName': locationName,
      'budget': budget,
      'freq': freq,
    };
  }
}