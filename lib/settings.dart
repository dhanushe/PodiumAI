import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lectifaisubmission/database.dart';
import 'package:lectifaisubmission/constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = DatabaseMethods();

  String selectedLanguage = 'English (United States)';

  List<String> languageOptions = [
    'Arabic (Saudi Arabia)',
    'Cantonese (China mainland)',
    'Catalan (Spain)',
    'Chinese (China mainland)',
    'Chinese (Hong Kong)',
    'Chinese (Taiwan)',
    'Croatian (Croatia)',
    'Czech (Czechia)',
    'Danish (Denmark)',
    'Dutch (Belgium)',
    'Dutch (Netherlands)',
    'English (Australia)',
    'English (Canada)',
    'English (India)',
    'English (Indonesia)',
    'English (Ireland)',
    'English (New Zealand)',
    'English (Philippines)',
    'English (Saudi Arabia)',
    'English (Singapore)',
    'English (South Africa)',
    'English (United Arab Emirates)',
    'English (United Kingdom)',
    'English (United States)',
    'Finnish (Finland)',
    'French (Belgium)',
    'French (Canada)',
    'French (France)',
    'French (Switzerland)',
    'German (Austria)',
    'German (Germany)',
    'German (Switzerland)',
    'Greek (Greece)',
    'Hebrew (Israel)',
    'Hindi (India)',
    'Hindi (Latin)',
    'Hungarian (Hungary)',
    'Indonesian (Indonesia)',
    'Italian (Italy)',
    'Italian (Switzerland)',
    'Japanese (Japan)',
    'Korean (South Korea)',
    'Malay (Malaysia)',
    'Norwegian Bokmål (Norway)',
    'Polish (Poland)',
    'Portuguese (Brazil)',
    'Portuguese (Portugal)',
    'Romanian (Romania)',
    'Russian (Russia)',
    'Shanghainese (China mainland)',
    'Slovak (Slovakia)',
    'Spanish (Chile)',
    'Spanish (Colombia)',
    'Spanish (Latin America)',
    'Spanish (Mexico)',
    'Spanish (Spain)',
    'Spanish (United States)',
    'Swedish (Sweden)',
    'Thai (Thailand)',
    'Turkish (Türkiye)',
    'Ukrainian (Ukraine)',
    'Vietnamese (Vietnam)',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseMethods
        .getUserLanguage(firebaseAuth.currentUser!.email!)
        .then((value) {
      setState(() {
        if (value == null) {
          selectedLanguage = 'English (United States)';
        } else {
          selectedLanguage = value;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 35.0, top: 15.0, right: 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.translate(
                      offset: const Offset(-15, 0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: kPrimaryLight,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Text(
                  'Settings',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: kPrimaryLight,
                  ),
                ),

                const SizedBox(height: 16),

                // Transcription Language
                // Transcription Language
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transcription Language',
                        style: TextStyle(color: kPrimaryLight)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedLanguage,
                      dropdownColor: kPrimaryDark,
                      style: TextStyle(color: kPrimaryLight),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLanguage = newValue!;
                          databaseMethods.updateUserLanguage(
                              firebaseAuth.currentUser!.email!, newValue);
                        });
                      },
                      items: languageOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: kPrimaryLight)),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                ListTile(
                  tileColor: kPrimaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text('Delete Account',
                      style: TextStyle(color: kPrimaryLight)),
                  trailing: IconButton(
                    icon:
                        Icon(FeatherIcons.alertTriangle, color: kPrimaryLight),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: kPrimaryDark,
                            title: Text('Delete Account',
                                style: TextStyle(color: kPrimaryLight)),
                            content: Text(
                                'Are you sure you want to delete your account?',
                                style: TextStyle(color: kPrimaryLight)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel',
                                    style: TextStyle(color: kPrimaryLight)),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Delete the user's account
                                  // databaseMethods.deleteUserAccount(firebaseAuth.currentUser!.email!);
                                  firebaseAuth.currentUser!.delete();
                                  Navigator.pop(context);
                                  // Navigate back to the login screen or show a success message
                                },
                                child: Text('Delete',
                                    style: TextStyle(color: kPrimaryLight)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
