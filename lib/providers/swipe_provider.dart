import 'dart:math';
import 'package:flutter/material.dart';
import '../models/food_choice.dart';
import '../services/firestore_service.dart';

class SwipeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<FoodChoice> _allFoods = [];
  List<FoodChoice> _swipeDeck = [];
  String? _selectedLocationId;
  bool _isRichMode = false;
  bool _isAdventurousMode = false;
  bool _isDecisionMade = false;
  FoodChoice? _selectedFood;

  List<FoodChoice> get swipeDeck => _swipeDeck;
  String? get selectedLocationId => _selectedLocationId;
  bool get isRichMode => _isRichMode;
  bool get isAdventurousMode => _isAdventurousMode;
  bool get isDecisionMade => _isDecisionMade;
  FoodChoice? get selectedFood => _selectedFood;

  // Load foods for selected location
  Future<void> loadFoodsForLocation(
    String userId, 
    String locationId
  ) async {
    _selectedLocationId = locationId;
    _allFoods = await _firestoreService.getAllFoodChoices(userId);
    _allFoods = _allFoods
        .where((food) => food.locationId == locationId)
        .toList();
    
    _refreshDeck();
    notifyListeners();
  }

  // Weighted random selection
  void _refreshDeck() {
    if (_allFoods.isEmpty) {
      _swipeDeck = [];
      return;
    }

    // Create weighted list based on toggles
    List<FoodChoice> candidates = _allFoods.where((food) {
      if (_isRichMode && food.budget == 'low') return false;
      return true;
    }).toList();

    if (candidates.isEmpty) {
      _swipeDeck = [];
      return;
    }

    // Calculate weights
    List<double> weights = candidates.map((food) {
      double weight = food.freq.toDouble();
      
      // Adventurous mode inverts frequency (lower freq = higher probability)
      if (_isAdventurousMode) {
        int maxFreq = candidates.map((f) => f.freq).reduce(max);
        weight = (maxFreq - food.freq + 1).toDouble();
      }
      
      return weight;
    }).toList();

    // Weighted random selection
    double totalWeight = weights.reduce((a, b) => a + b);
    double random = Random().nextDouble() * totalWeight;
    
    double cumulative = 0;
    for (int i = 0; i < candidates.length; i++) {
      cumulative += weights[i];
      if (random <= cumulative) {
        _swipeDeck = [candidates[i]];
        break;
      }
    }
    
    // Fallback
    if (_swipeDeck.isEmpty) {
      _swipeDeck = [candidates[Random().nextInt(candidates.length)]];
    }
  }

  // Toggle modes
  void toggleRichMode() {
    _isRichMode = !_isRichMode;
    notifyListeners();
  }

  void toggleAdventurousMode() {
    _isAdventurousMode = !_isAdventurousMode;
    notifyListeners();
  }

  // Swipe left (skip)
  void swipeLeft() {
    if (_isDecisionMade) return;
    _refreshDeck();
    notifyListeners();
  }

  // Swipe right (lock in)
  Future<void> swipeRight(String userId) async {
    if (_swipeDeck.isEmpty || _isDecisionMade) return;
    
    _selectedFood = _swipeDeck.first;
    _isDecisionMade = true;
    
    // Increment frequency in Firestore
    await _firestoreService.incrementFreq(userId, _selectedFood!.id);
    
    notifyListeners();
  }

  // Reset session
  void reset() {
    _isDecisionMade = false;
    _selectedFood = null;
    _refreshDeck();
    notifyListeners();
  }

  // Clear all
  void clear() {
    _allFoods = [];
    _swipeDeck = [];
    _selectedLocationId = null;
    _isRichMode = false;
    _isAdventurousMode = false;
    _isDecisionMade = false;
    _selectedFood = null;
    notifyListeners();
  }
}