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
  
  final Set<String> _selectedLocationIds = {};
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
              'Select Locations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            StreamBuilder<List<LocationModel>>(
              stream: _firestoreService.getLocations(userId),
              builder: (context, snapshot) {
                // Determine if data is still loading
                final isLoading = snapshot.connectionState == ConnectionState.waiting;

                return Stack(
                  children: [
                    // Main content (locations + add new location)
                    Column(
                      children: [
                        if (snapshot.hasData)
                          ...snapshot.data!.map((location) => CheckboxListTile(
                                title: Text(location.name),
                                value: _selectedLocationIds.contains(location.id),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedLocationIds.add(location.id);
                                    } else {
                                      _selectedLocationIds.remove(location.id);
                                    }
                                  });
                                },
                                tileColor: const Color(0xFF16213e),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )),

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
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Full-page loader overlay
                    if (isLoading)
                      Container(
                        color: Colors.black54, // semi-transparent overlay
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.pinkAccent,
                          ),
                        ),
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

    if (_selectedLocationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one location')),
      );
      return;
    }

    // Get location names
    final locations = await _firestoreService.getLocations(userId).first;
    final selectedLocations = locations
        .where((loc) => _selectedLocationIds.contains(loc.id))
        .toList();

    await _firestoreService.addFoodChoice(
      userId: userId,
      foodName: _foodNameController.text,
      locationIds: selectedLocations.map((l) => l.id).toList(),
      locationNames: selectedLocations.map((l) => l.name).toList(),
      budget: _selectedBudget,
    );

    // Clear form
    _foodNameController.clear();
    _selectedLocationIds.clear();
    setState(() => _selectedBudget = 'low');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food choice added! 🎉')),
    );
  }
}