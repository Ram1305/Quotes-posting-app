// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBV6Bo83eQ600u8JCB7kV5K4jKOMUgT9Tg',
    appId: '1:318582055704:web:470285f7869070069a746d',
    messagingSenderId: '318582055704',
    projectId: 'kavithai-d16c6',
    authDomain: 'kavithai-d16c6.firebaseapp.com',
    storageBucket: 'kavithai-d16c6.appspot.com',
    measurementId: 'G-152XFQMCR7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkU4gv0wM_3TGvMTFxPENxBxNzrHJQxJA',
    appId: '1:318582055704:android:9b3c03d93692e3a19a746d',
    messagingSenderId: '318582055704',
    projectId: 'kavithai-d16c6',
    storageBucket: 'kavithai-d16c6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1DoOvc2pIcXpO0Ilq-HqLkyLMEl8ndsA',
    appId: '1:318582055704:ios:39d54d22765f073a9a746d',
    messagingSenderId: '318582055704',
    projectId: 'kavithai-d16c6',
    storageBucket: 'kavithai-d16c6.appspot.com',
    iosBundleId: 'com.example.kavithaiquote',
  );
}
