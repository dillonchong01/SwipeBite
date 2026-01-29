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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Base width ~420 works well for phones → web
        final scale = (constraints.maxWidth / 420).clamp(0.75, 1.0);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: food.budget == 'high'
                  ? const [
                      Color(0xFFffd89b),
                      Color(0xFFff8c42),
                      Color(0xFF19547b),
                    ]
                  : const [
                      Color(0xFF8e2de2),
                      Color(0xFF6a11cb),
                      Color(0xFF4a00e0),
                    ],
            ),
            borderRadius: BorderRadius.circular(24 * scale),
            boxShadow: [
              BoxShadow(
                color: (food.budget == 'high'
                        ? const Color(0xFFff8c42)
                        : const Color(0xFF8e2de2))
                    .withOpacity(0.4),
                blurRadius: 30 * scale,
                spreadRadius: 2 * scale,
                offset: Offset(0, 12 * scale),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle pattern overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24 * scale),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),

              // ⭐ High-budget star
              if (food.budget == 'high')
                Positioned(
                  top: 16 * scale,
                  right: 16 * scale,
                  child: Container(
                    padding: EdgeInsets.all(8 * scale),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 12 * scale,
                          spreadRadius: 1 * scale,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 28 * scale,
                    ),
                  ),
                ),

              // Decorative circles
              Positioned(
                top: -30 * scale,
                right: -30 * scale,
                child: Container(
                  width: 120 * scale,
                  height: 120 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -50 * scale,
                left: -50 * scale,
                child: Container(
                  width: 150 * scale,
                  height: 150 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32 * scale),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Food emoji
                      Container(
                        padding: EdgeInsets.all(20 * scale),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20 * scale,
                              spreadRadius: 2 * scale,
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _extractEmoji(food.name),
                            style: TextStyle(fontSize: 80 * scale),
                          ),
                        ),
                      ),
                      SizedBox(height: 32 * scale),

                      // Food name
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * scale,
                          vertical: 12 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5 * scale,
                          ),
                        ),
                        child: Text(
                          food.name
                              .replaceAll(
                                RegExp(
                                  r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
                                  unicode: true,
                                ),
                                '',
                              )
                              .trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * scale),

                      // Location
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * scale,
                          vertical: 10 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20 * scale,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              food.locationName,
                              style: TextStyle(
                                fontSize: 18 * scale,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _extractEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return emojiRegex.firstMatch(text)?.group(0) ?? '🍽️';
  }
}
