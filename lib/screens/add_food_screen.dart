import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/location_model.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _newLocationController = TextEditingController();
  
  String? _selectedLocationId;
  String _selectedBudget = 'low';

  @override
  void dispose() {
    _foodNameController.dispose();
    _newLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().user?.uid;

    if (userId == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Choice'),
        backgroundColor: const Color(0xFF16213e),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Food Name
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                hintText: 'e.g., Margherita Pizza 🍕',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF16213e),
              ),
            ),
            const SizedBox(height: 24),

            // Budget Selector
            const Text(
              'Budget',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBudgetButton('Low', 'low'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBudgetButton('High 💰', 'high'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Location Selector
            const Text(
              'Select Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            StreamBuilder<List<LocationModel>>(
              stream: _firestoreService.getLocations(userId),
              builder: (context, snapshot) {
                // Determine if data is still loading
                final isLoading = snapshot.connectionState == ConnectionState.waiting;

                if (isLoading) {
                  return Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213e),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                      ),
                    ),
                  );
                }

                final locations = snapshot.data ?? [];

                return Column(
                  children: [
                    // Location Dropdown
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213e),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedLocationId,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF16213e),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                          hint: const Text(
                            'Select location',
                            style: TextStyle(color: Colors.white70),
                          ),
                          items: locations.map((location) {
                            return DropdownMenuItem<String>(
                              value: location.id,
                              child: Row(
                                children: [
                                  const Icon(Icons.place, size: 18, color: Colors.white54),
                                  const SizedBox(width: 8),
                                  Text(
                                    location.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (locationId) {
                            setState(() {
                              _selectedLocationId = locationId;
                            });
                          },
                        ),
                      ),
                    ),

                    // Add New Location Row
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newLocationController,
                            decoration: const InputDecoration(
                              labelText: 'New Location',
                              hintText: 'e.g., Downtown',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF16213e),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (_newLocationController.text.isNotEmpty) {
                              await _firestoreService.addLocation(
                                userId,
                                _newLocationController.text,
                              );
                              _newLocationController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFe91e63),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                _submitFood(userId);
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.hovered)) {
                      return const Color(0xFFff6090); // lighter pink on hover
                    }
                    if (states.contains(WidgetState.pressed)) {
                      return const Color(0xFFc2185b); // darker pink on press
                    }
                    return const Color(0xFFe91e63); // default
                  },
                ),
                elevation: WidgetStateProperty.resolveWith<double>(
                  (states) => states.contains(WidgetState.hovered) ? 12 : 6,
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                shadowColor: WidgetStateProperty.all(
                  Colors.pinkAccent.withOpacity(0.5),
                ),
              ),
              child: const Text(
                'Add Food Choice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetButton(String label, String value) {
    final isSelected = _selectedBudget == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedBudget = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFe91e63) : const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white30,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _submitFood(String userId) async {
    if (_foodNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food name')),
      );
      return;
    }

    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    // Get location name
    final locations = await _firestoreService.getLocations(userId).first;
    final selectedLocation = locations.firstWhere(
      (loc) => loc.id == _selectedLocationId,
    );

    await _firestoreService.addFoodChoice(
      userId: userId,
      foodName: _foodNameController.text,
      locationIds: [selectedLocation.id],
      locationNames: [selectedLocation.name],
      budget: _selectedBudget,
    );

    // Clear form
    _foodNameController.clear();
    setState(() {
      _selectedLocationId = null;
      _selectedBudget = 'low';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food choice added! 🎉')),
    );
  }
}