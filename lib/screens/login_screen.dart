import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Text(
                    '🍔',
                    style: TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  const Text(
                    'SwipeBite',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Swipe your way to delicious decisions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  
                  // Google Sign-In Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await context.read<AuthProvider>().signInWithGoogle();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign in failed: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.hovered)) {
                            return const Color(0xFFff6090); // lighter pink on hover
                          }
                          if (states.contains(MaterialState.pressed)) {
                            return const Color(0xFFc2185b); // darker pink on press
                          }
                          return const Color(0xFFe91e63); // default button color
                        },
                      ),
                      elevation: MaterialStateProperty.resolveWith<double>(
                        (states) => states.contains(MaterialState.hovered) ? 12 : 6,
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      shadowColor: MaterialStateProperty.all(
                        Colors.pinkAccent.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}