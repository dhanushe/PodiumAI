import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  // Auth State Mangement Using Shared Preferences Dependancy
  static String sharedPreferenceUserLoggedInKey = "LOGGEDIN";
  static String sharedPreferenceUserNameKey = "USERNAME";
  static String sharedPreferenceUserEmailKey = "USEREMAIL";
  static String sharedPreferenceFirstTimeKey = "FIRSTTIME";
  static String sharedPreferenceAbove13Key = "ABOVE13";

  // Checking If User's First Time Here
  static Future<bool> isUserFirstTime() async {
    print('Getting user first time status');
    final prefs = await SharedPreferences.getInstance();
    bool? exists = prefs.getBool(sharedPreferenceFirstTimeKey);
    return exists ?? true;
  }

  static Future<bool> setUserFirstTime(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceFirstTimeKey, value);
  }

  // Saving Data
  static Future<bool> saveUserLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceUserLoggedInKey, isLoggedIn);
  }

  static Future<bool> saveUserName(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserNameKey, username);
  }

  static Future<bool> saveUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserEmailKey, email);
  }

  static Future<void> saveIsAbove13(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saving user is above 13.: $email');
    final emails = await getAbove13Emails();
    emails.add(email);
    await prefs.setStringList(sharedPreferenceAbove13Key, emails.toList());
  }

  // Getting Data
  static Future<bool> getUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool? exists = prefs.getBool(sharedPreferenceUserLoggedInKey);
    return exists ?? false;
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.getString(sharedPreferenceUserNameKey);
    return exists ?? "";
  }

  Future<String> getUserNameNonStatic() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.getString(sharedPreferenceUserNameKey);
    return exists ?? "";
  }

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.getString(sharedPreferenceUserEmailKey);
    return exists ?? "";
  }

  static Future<Set<String>> getAbove13Emails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(sharedPreferenceAbove13Key)?.toSet() ??
        <String>{};
  }
}
