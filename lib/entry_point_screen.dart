import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/error_auth.dart';
import 'package:lectifaisubmission/helper_functions.dart';
import 'package:lectifaisubmission/login_screen.dart';

import '../home_screen.dart';
import 'database.dart';

class EntryPointScreen extends StatefulWidget {
  const EntryPointScreen({Key? key}) : super(key: key);

  @override
  State<EntryPointScreen> createState() => _EntryPointScreenState();
}

class _EntryPointScreenState extends State<EntryPointScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            // Save Data Locally
            HelperFunctions.saveUserLoggedIn(true);
            HelperFunctions.saveUserEmail(firebaseAuth.currentUser!.email!);
            HelperFunctions.saveUserName(
                firebaseAuth.currentUser!.displayName!);
            Constants.myName = firebaseAuth.currentUser!.displayName!;
            uploadUserInfo({
              'email': firebaseAuth.currentUser!.email,
              'name': firebaseAuth.currentUser!.displayName,
              'isStudent': '',
            });
          } else if (snapshot.hasError) {
            return ErrorAuth(
                title: 'Error', centerText: snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapshot.hasData ? const HomeScreen() : LoginScreen();
        }),
      ),
    );
  }

  void uploadUserInfo(Map<String, dynamic> userInfoMap) async {
    await databaseMethods.uploadUserInfo(userInfoMap);
  }
}
