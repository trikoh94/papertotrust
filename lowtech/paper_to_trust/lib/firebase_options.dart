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
    apiKey: "AIzaSyBYn8uy63e1AVuQPw2OwCojtuUi0HwfjZg",
    authDomain: "papertotrust.firebaseapp.com",
    projectId: "papertotrust",
    storageBucket: "papertotrust.firebasestorage.app",
    messagingSenderId: "5865161016",
    appId: "1:5865161016:web:7b4554a7ad96e485c2c1cd",
    measurementId: "G-3WP4HHSL44",
  );
}
