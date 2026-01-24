import 'package:flutter/material.dart';
import '../models/food_choice.dart';

class FoodCard extends StatelessWidget {
  final FoodChoice food;

  const FoodCard({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: food.budget == 'high'
              ? [
                  const Color(0xFFffd89b),
                  const Color(0xFF19547b),
                ]
              : [
                  const Color(0xFF8e2de2),
                  const Color(0xFF4a00e0),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Food emoji (if present in name)
              Text(
                _extractEmoji(food.name),
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              
              // Food name
              Text(
                food.name.replaceAll(RegExp(r'[^\w\s]'), ''),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Location
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  food.locationName,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Budget indicator
              if (food.budget == 'high')
                const Text(
                  '💰 High Budget',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    final match = emojiRegex.firstMatch(text);
    return match?.group(0) ?? '🍽️';
  }
}