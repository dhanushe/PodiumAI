import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final _googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future<void> googleLogin(BuildContext context) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    final email = googleUser.email;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    if (!context.mounted) {
      print("context is not mounted");
      logout();
      return;
    }

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future logout() async {
    await _googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
  }

  void _onBirthdayValidated(AuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
