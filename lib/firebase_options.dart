import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCBSo-9Esf8g0XeL4rVppyADFxQxHE3HNQ",
    authDomain: "swipebite-35203.firebaseapp.com",
    projectId: "swipebite-35203",
    storageBucket: "swipebite-35203.firebasestorage.app",
    messagingSenderId: "260331152118",
    appId: "1:260331152118:web:76c901f6a9836ee5e382d7"
  );
}