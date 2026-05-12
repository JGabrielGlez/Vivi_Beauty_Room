import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPdIsQQZ2QClgYotCk-cc5XkyNbIsYwbo',
    appId: '1:748070412360:android:87965da70ab584c4cb387d',
    messagingSenderId: '748070412360',
    projectId: 'vivi-beauty-room',
    storageBucket: 'vivi-beauty-room.firebasestorage.app',
  );
}
