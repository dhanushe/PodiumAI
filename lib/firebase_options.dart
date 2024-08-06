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
    apiKey: 'AIzaSyALsOIlKAwYTivmAWOxWqlhgp1PyGhO0Zg',
    appId: '1:294198838372:web:f595fceafdfd322f9b0b71',
    messagingSenderId: '294198838372',
    projectId: 'lectfai',
    authDomain: 'lectfai.firebaseapp.com',
    storageBucket: 'lectfai.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUeapO18K65xp8Q_7jAuIYK7y9YfDE0qo',
    appId: '1:294198838372:android:56e0d9d3f37b847e9b0b71',
    messagingSenderId: '294198838372',
    projectId: 'lectfai',
    storageBucket: 'lectfai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBuTuaFOQjUlNmyi_pp4eiQFPGGzQx9OQ',
    appId: '1:294198838372:ios:62e3c0c7d83a65c69b0b71',
    messagingSenderId: '294198838372',
    projectId: 'lectfai',
    storageBucket: 'lectfai.appspot.com',
    androidClientId: '294198838372-hurk0n2praccgpb87djc03cmp6k3rg2c.apps.googleusercontent.com',
    iosClientId: '294198838372-8vfs87s60bcuaoeetsf8fggctukhmtsk.apps.googleusercontent.com',
    iosBundleId: 'com.dhanushe.lectifai',
  );
}
