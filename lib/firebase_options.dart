import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration generated from `android/app/google-services.json`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web.');
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      _ => throw UnsupportedError(
        'Firebase is only configured for Android in this app.',
      ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4CpKCR50TYq6HWUawvidddUGrjMsrnk8',
    appId: '1:561252545060:android:be1fae8bd900e598441eb1',
    messagingSenderId: '561252545060',
    projectId: 'web-to-app---mak-apps',
    storageBucket: 'web-to-app---mak-apps.firebasestorage.app',
  );
}
