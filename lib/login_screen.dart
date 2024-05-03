import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final Widget svg = SvgPicture.asset(
    'assets/Educationillustration.svg',
    semanticsLabel: 'Recording Icon Logo',
    width: 200,
    height: 200,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF18171e), Color(0xFF25242c)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                svg,
                SizedBox(height: 50),
                Text(
                  'LectifAI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Seamlessly sync your lectures, resources, and collaborations, enhancing learning on the go.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(),
                  flex: 3,
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton.icon(
                    icon: new Icon(MdiIcons.google, color: kPrimaryLight),
                    label: Text(
                      'Login with Google',
                      style: TextStyle(
                          color: kPrimaryLight, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false);
                      provider.googleLogin(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGray,
                      shadowColor: Colors.transparent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      side: BorderSide(color: kPrimaryGray),
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
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
