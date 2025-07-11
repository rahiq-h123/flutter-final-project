// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyA3THc1oDJvz9_d227-8K2KGrd5dnJdbEo',
    appId: '1:653751793122:web:1837a17c80d5ab3760f5bb',
    messagingSenderId: '653751793122',
    projectId: 'mini-social-app-ab111',
    authDomain: 'mini-social-app-ab111.firebaseapp.com',
    storageBucket: 'mini-social-app-ab111.firebasestorage.app',
    measurementId: 'G-5WEZ586XKV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmibiBIcF2PB_mK673o8FgtGYZs0hL4Zg',
    appId: '1:653751793122:android:1033b2f8c0fda32260f5bb',
    messagingSenderId: '653751793122',
    projectId: 'mini-social-app-ab111',
    storageBucket: 'mini-social-app-ab111.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXoTzToz5sWDtKfXEoIitrC2Ng3S9fRQE',
    appId: '1:653751793122:ios:41acbf0bde4f6a9760f5bb',
    messagingSenderId: '653751793122',
    projectId: 'mini-social-app-ab111',
    storageBucket: 'mini-social-app-ab111.firebasestorage.app',
    iosBundleId: 'com.example.miniSocialApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXoTzToz5sWDtKfXEoIitrC2Ng3S9fRQE',
    appId: '1:653751793122:ios:41acbf0bde4f6a9760f5bb',
    messagingSenderId: '653751793122',
    projectId: 'mini-social-app-ab111',
    storageBucket: 'mini-social-app-ab111.firebasestorage.app',
    iosBundleId: 'com.example.miniSocialApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA3THc1oDJvz9_d227-8K2KGrd5dnJdbEo',
    appId: '1:653751793122:web:7ac193e421735b8d60f5bb',
    messagingSenderId: '653751793122',
    projectId: 'mini-social-app-ab111',
    authDomain: 'mini-social-app-ab111.firebaseapp.com',
    storageBucket: 'mini-social-app-ab111.firebasestorage.app',
    measurementId: 'G-MTDQLN67M7',
  );
}
