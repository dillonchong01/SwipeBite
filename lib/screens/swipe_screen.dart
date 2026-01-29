import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../providers/auth_provider.dart';
import '../providers/swipe_provider.dart';
import '../services/firestore_service.dart';
import '../models/location_model.dart';
import '../widgets/food_card.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ConfettiController _confettiController = 
      ConfettiController(duration: const Duration(seconds: 3));
  final CardSwiperController _cardController = CardSwiperController();
  
  String? _selectedLocationId;

  @override
  void dispose() {
    _confettiController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().user?.uid;

    if (userId == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Column(
            children: [
              _buildLocationSelector(userId),
              if (_selectedLocationId != null)
                Consumer<SwipeProvider>(
                  builder: (_, swipeProvider, __) {
                    return _buildToggles(swipeProvider);
                  },
                ),
              Expanded(
                child: Consumer<SwipeProvider>(
                  builder: (_, swipeProvider, __) {
                    return swipeProvider.isDecisionMade
                        ? _buildDecisionMade(swipeProvider)
                        : _buildSwipeArea(userId, swipeProvider);
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Colors.pink,
                Colors.purple,
                Colors.blue,
                Colors.orange,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(String userId) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF16213e),
      child: StreamBuilder<List<LocationModel>>(
        stream: _firestoreService.getLocations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text(
              'No locations yet. Add one in Add Food tab!',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            );
          }

          final locations = snapshot.data!;

          return DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButton<String>(
                value: _selectedLocationId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1a1a2e),
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
                onChanged: (locationId) async {
                  if (locationId == null) return;
                  setState(() => _selectedLocationId = locationId);
                  await context
                      .read<SwipeProvider>()
                      .loadFoodsForLocation(userId, locationId);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggles(SwipeProvider swipeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggle(
            'Feeling Rich',
            swipeProvider.isRichMode,
            () => swipeProvider.toggleRichMode(),
          ),
          _buildToggle(
            'Feeling Adventurous',
            swipeProvider.isAdventurousMode,
            () => swipeProvider.toggleAdventurousMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFFe91e63), Color(0xFFff6090)],
                )
              : null,
          color: value ? null : const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: value ? Colors.transparent : Colors.white24,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeArea(String userId, SwipeProvider swipeProvider) {
    if (_selectedLocationId == null) {
      return const Center(
        child: Text(
          'Select a location to start swiping!',
          style: TextStyle(fontSize: 18, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (swipeProvider.swipeDeck.isEmpty) {
      return const Center(
        child: Text(
          'No foods available for this location.\nAdd some in the Add Food tab!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CardSwiper(
              controller: _cardController,
              cardsCount: 1,
              numberOfCardsDisplayed: 1,
              threshold: 25,
              maxAngle: 18,
              scale: 0.95,
              duration: const Duration(milliseconds: 420),
              allowedSwipeDirection: const AllowedSwipeDirection.only(
                left: true,
                right: true,
                up: false,
                down: false,
              ),
              onSwipe: (previousIndex, currentIndex, direction) {
                if (direction == CardSwiperDirection.right) {
                  _showLockInConfirmation(userId, swipeProvider);
                } else if (direction == CardSwiperDirection.left) {
                  swipeProvider.swipeLeft();
                }
                return true;
              },
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                return FoodCard(food: swipeProvider.swipeDeck.first);
              },
            ),
          ),
        ),
        // Permanent swipe direction indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left - Skip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swipe Left',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Right - Lock In
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Swipe Right',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Lock In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.green.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLockInConfirmation(String userId, SwipeProvider swipeProvider) {
    final foodName = swipeProvider.swipeDeck.first.name;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text(
              'Lock in this choice?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re about to lock in:',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            Text(
              foodName,
              style: const TextStyle(
                color: Color(0xFFe91e63),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will be your final decision!',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              swipeProvider.swipeLeft();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _confettiController.play();
              await swipeProvider.swipeRight(userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe91e63),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionMade(SwipeProvider swipeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎉',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 24),
          const Text(
            'Decision Made!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            swipeProvider.selectedFood?.name ?? '',
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFFe91e63),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => swipeProvider.reset(),
            child: const Text('Swipe Again'),
          ),
        ],
      ),
    );
  }
}