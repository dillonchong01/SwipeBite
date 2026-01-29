import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/food_choice.dart';
import '../models/location_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ==================== LOCATIONS ====================

  // Get all locations for a user
  Stream<List<LocationModel>> getLocations(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('locations')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LocationModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // Add a new location
  Future<String> addLocation(String userId, String locationName) async {
    final locationId = _uuid.v4();
    await _db
        .collection('users')
        .doc(userId)
        .collection('locations')
        .doc(locationId)
        .set({'name': locationName});
    return locationId;
  }

  // Update location name
  Future<void> updateLocation(
    String userId, 
    String locationId, 
    String newName
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('locations')
        .doc(locationId)
        .update({'name': newName});
  }

  // Delete location and all associated foods
  Future<void> deleteLocation(String userId, String locationId) async {
    // Delete all food choices for this location
    final foodSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('food_choices')
        .where('locationId', isEqualTo: locationId)
        .get();

    final batch = _db.batch();
    
    for (var doc in foodSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the location itself
    batch.delete(_db
        .collection('users')
        .doc(userId)
        .collection('locations')
        .doc(locationId));

    await batch.commit();
  }

  // ==================== FOOD CHOICES ====================

  // Get all food choices for a location
  Stream<List<FoodChoice>> getFoodChoicesByLocation(
    String userId, 
    String locationId
  ) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('food_choices')
        .where('locationId', isEqualTo: locationId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodChoice.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // Get all food choices for a user (all locations)
  Future<List<FoodChoice>> getAllFoodChoices(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('food_choices')
        .get();

    return snapshot.docs
        .map((doc) => FoodChoice.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  // Add food choice (creates one document per location)
  Future<void> addFoodChoice({
    required String userId,
    required String foodName,
    required List<String> locationIds,
    required List<String> locationNames,
    required String budget,
  }) async {
    final batch = _db.batch();

    for (int i = 0; i < locationIds.length; i++) {
      final foodId = _uuid.v4();
      final docRef = _db
          .collection('users')
          .doc(userId)
          .collection('food_choices')
          .doc(foodId);

      batch.set(docRef, {
        'name': foodName,
        'locationId': locationIds[i],
        'locationName': locationNames[i],
        'budget': budget,
        'freq': 1,
      });
    }

    await batch.commit();
  }

  // Update food choice
  Future<void> updateFoodChoice({
    required String userId,
    required String foodId,
    String? budget,
  }) async {
    final updates = <String, dynamic>{};
    if (budget != null) updates['budget'] = budget;

    await _db
        .collection('users')
        .doc(userId)
        .collection('food_choices')
        .doc(foodId)
        .update(updates);
  }

  // Delete food choice
  Future<void> deleteFoodChoice(String userId, String foodId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('food_choices')
        .doc(foodId)
        .delete();
  }

  // Increment frequency (atomic operation)
  Future<void> incrementFreq(String userId, String foodId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('food_choices')
        .doc(foodId)
        .update({'freq': FieldValue.increment(1)});
  }
}