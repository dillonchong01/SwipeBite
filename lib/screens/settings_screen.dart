import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/location_model.dart';
import '../models/food_choice.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().user?.uid;

    if (userId == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF16213e),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<LocationModel>>(
        stream: FirestoreService().getLocations(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final locations = snapshot.data!;

          if (locations.isEmpty) {
            return const Center(
              child: Text(
                'No locations yet.\nAdd one in the Add Food tab!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              return _LocationCard(
                userId: userId,
                location: locations[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String userId;
  final LocationModel location;

  const _LocationCard({
    required this.userId,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Card(
      color: const Color(0xFF16213e),
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          location.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showRenameDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _showDeleteDialog(context, firestoreService),
            ),
          ],
        ),
        children: [
          StreamBuilder<List<FoodChoice>>(
            stream: firestoreService.getFoodChoicesByLocation(
              userId,
              location.id,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              final foods = snapshot.data!;

              if (foods.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No foods yet'),
                );
              }

              return Column(
                children: foods.map((food) {
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                      food.budget == 'high' ? 'High Budget 💰' : 'Low Budget',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle budget
                        IconButton(
                          icon: Icon(
                            food.budget == 'high' 
                              ? Icons.attach_money 
                              : Icons.money_off,
                            color: food.budget == 'high' 
                              ? Colors.green 
                              : Colors.grey,
                          ),
                          onPressed: () {
                            firestoreService.updateFoodChoice(
                              userId: userId,
                              foodId: food.id,
                              budget: food.budget == 'high' ? 'low' : 'high',
                            );
                          },
                        ),
                        // Delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            firestoreService.deleteFoodChoice(userId, food.id);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: location.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                FirestoreService().updateLocation(
                  userId,
                  location.id,
                  controller.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text(
          'Are you sure you want to delete "${location.name}"? '
          'This will also delete all food choices in this location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              firestoreService.deleteLocation(userId, location.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}