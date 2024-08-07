import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  //Apple Sign In
  Future<void> appleLogin(BuildContext context) async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      // appleProvider.addScope('fullName');
      appleProvider.addScope('name');
      print("appleProvider: ${appleProvider.scopes}");
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
      // final appleCredential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [
      //     AppleIDAuthorizationScopes.email,
      //     AppleIDAuthorizationScopes.fullName,
      //   ],
      // );
      // final oAuthProvider = OAuthProvider("apple.com");
      // final credential = oAuthProvider.credential(
      //   idToken: appleCredential.identityToken,
      //   accessToken: appleCredential.authorizationCode,
      // );
      // await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
    }
  }

  void _onBirthdayValidated(AuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
