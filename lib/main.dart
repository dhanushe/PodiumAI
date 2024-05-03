import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lectifaisubmission/default_firebase_options.dart';
import 'package:lectifaisubmission/entry_point_screen.dart';
import 'package:lectifaisubmission/google_sign_in.dart';
import 'package:lectifaisubmission/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// educatorteacher!
// schoolteachereducator@gmail.com

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // App is Running on Web
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
  } else {
    // App is Running on Mobile
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'LectifAI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: "Touche",
        ),
        home: const EntryPointScreen(),
      ),
    );
  }
}
