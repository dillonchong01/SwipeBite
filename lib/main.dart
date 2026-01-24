import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/swipe_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SwipeBiteApp());
}

class SwipeBiteApp extends StatelessWidget {
  const SwipeBiteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SwipeProvider()),
      ],
      child: MaterialApp(
        title: 'SwipeBite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: const Color(0xFF1a1a2e),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFe91e63),
            secondary: Color(0xFF9c27b0),
            surface: Color(0xFF16213e),
          ),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authProvider.user == null 
              ? const LoginScreen() 
              : const HomeScreen();
          },
        ),
      ),
    );
  }
}