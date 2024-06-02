import 'package:clay_containers/clay_containers.dart';
import 'package:clay_containers/widgets/clay_animated_container.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final Widget svg = SvgPicture.asset(
  final Widget svg = SvgPicture.asset(
    'assets/Recordingicon2.svg',
    semanticsLabel: 'Recording Icon Logo',
    width: 250,
    height: 250,
  );

  int depth = 15;
  double spread = 15.0;

  Future<void> _launchUrl(_url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double _bottomPaddingForButton = 150.0;
    const double _buttonHeight = 56.0;
    const double _buttonWidth = 200.0;
    const double _pagePadding = 16.0;
    const double _pageBreakpoint = 768.0;
    const double _heroImageHeight = 250.0;
    const Color _lightThemeShadowColor = Color(0xFFE4E4E4);
    const Color _darkThemeShadowColor = Color(0xFF121212);
    const Color _darkSabGradientColor = Color(0xFF313236);
    final materialColorsInGrid = allMaterialColors.take(20).toList();
    final materialColorsInSliverList = allMaterialColors.sublist(20, 25);
    bool _isLightTheme = false;

    SliverWoltModalSheetPage page1(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return WoltModalSheetPage(
        backgroundColor: kPrimaryDark,
        hasSabGradient: false,
        isTopBarLayerAlwaysVisible: false,
        hasTopBarLayer: false,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              // Get Started
              Row(
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      color: kPrimaryLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(MdiIcons.close, color: kPrimaryLight),
                    onPressed: Navigator.of(modalSheetContext).pop,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "You consent to be sharing your name, and email with us when you authenticate. We'll never share this information with anyone else.",
                style: TextStyle(
                  color: kPrimaryLight,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              // Rounded Next Button kPrimaryPurple
              GestureDetector(
                onTap: () {
                  WoltModalSheet.of(modalSheetContext).showNext();
                },
                child: ClayAnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  color: kPrimaryDark,
                  emboss: false,
                  borderRadius: 50,
                  depth: this.depth,
                  spread: this.spread,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: kPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          MdiIcons.arrowRight,
                          color: kPrimaryLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    SliverWoltModalSheetPage page2(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return WoltModalSheetPage(
        backgroundColor: kPrimaryDark,
        hasSabGradient: false,
        isTopBarLayerAlwaysVisible: false,
        hasTopBarLayer: false,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              // Get Started
              Row(
                children: [
                  Text(
                    'Policy Agreement',
                    style: TextStyle(
                      color: kPrimaryLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(MdiIcons.close, color: kPrimaryLight),
                    onPressed: Navigator.of(modalSheetContext).pop,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(Icons.launch, color: kPrimaryDark),
                  title: Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: kPrimaryDark,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    // Open Privacy Policy
                    this._launchUrl(
                        Uri.parse('https://podiumai.vercel.app/privacy'));
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(Icons.launch, color: kPrimaryDark),
                  title: Text(
                    "Terms of Service",
                    style: TextStyle(
                      color: kPrimaryDark,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    // Open Terms of Service
                    this._launchUrl(
                        Uri.parse('https://podiumai.vercel.app/tos'));
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                "By clicking 'Login', you agree to our Terms of Service and Privacy Policy.",
                style: TextStyle(
                  color: kPrimaryLight,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              // Rounded Next Button kPrimaryPurple
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  final provider =
                      Provider.of<GoogleSignInProvider>(context, listen: false);
                  provider.googleLogin(context);
                },
                child: ClayAnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  color: kPrimaryDark,
                  emboss: false,
                  borderRadius: 50,
                  depth: this.depth,
                  spread: this.spread,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MdiIcons.google,
                          color: kPrimaryLight,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Login',
                          style: TextStyle(
                            color: kPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryDark, kPrimaryDark],
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
                  'Podium',
                  style: TextStyle(
                    color: kPrimaryLight,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Click. Record. Learn. Repeat.',
                    style: TextStyle(
                      color: kPrimaryLight,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(),
                  flex: 3,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      this.depth = 0;
                      this.spread = 0;
                    });
                    // wait 1 second
                    Future.delayed(Duration(milliseconds: 300), () {
                      setState(() {
                        this.depth = 15;
                        this.spread = 15.0;
                      });
                    });
                    Future.delayed(Duration(milliseconds: 500), () {
                      // final provider = Provider.of<GoogleSignInProvider>(
                      //     context,
                      //     listen: false);
                      // provider.googleLogin(context);
                      WoltModalSheet.show<void>(
                        context: context,
                        pageListBuilder: (modalSheetContext) {
                          final textTheme = Theme.of(context).textTheme;
                          return [
                            page1(modalSheetContext, textTheme),
                            page2(modalSheetContext, textTheme),
                          ];
                        },
                        modalTypeBuilder: (context) {
                          final size = MediaQuery.sizeOf(context).width;
                          if (size < _pageBreakpoint) {
                            return WoltModalType.bottomSheet;
                          } else {
                            return WoltModalType.dialog;
                          }
                        },
                        onModalDismissedWithBarrierTap: () {
                          debugPrint('Closed modal sheet with barrier tap');
                          Navigator.of(context).pop();
                        },
                        maxDialogWidth: 560,
                        minDialogWidth: 400,
                        minPageHeight: 0.0,
                        maxPageHeight: 0.9,
                      );
                    });
                  },
                  child: ClayAnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    color: kPrimaryDark,
                    emboss: false,
                    borderRadius: 50,
                    depth: this.depth,
                    spread: this.spread,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            MdiIcons.google,
                            color: kPrimaryLight,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Authenticate',
                            style: TextStyle(
                              color: kPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.all(20),
                //   child: ElevatedButton.icon(
                //     icon: new Icon(MdiIcons.google, color: kPrimaryLight),
                //     label: Text(
                //       'Login with Google',
                //       style: TextStyle(
                //           color: kPrimaryLight, fontWeight: FontWeight.bold),
                //     ),
                //     onPressed: () {
                // final provider = Provider.of<GoogleSignInProvider>(
                //     context,
                //     listen: false);
                // provider.googleLogin(context);
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: kPrimaryGray,
                //       shadowColor: Colors.transparent,
                //       padding:
                //           EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(15),
                //       ),
                //       side: BorderSide(color: kPrimaryGray),
                //       textStyle: TextStyle(
                //         color: Colors.black,
                //         fontSize: 16,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorTile extends StatelessWidget {
  final Color color;

  const ColorTile({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: 600,
      child: Center(
        child: Text(
          color.toString(),
          style: TextStyle(
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

List<Color> get allMaterialColors {
  List<Color> allMaterialColorsWithShades = [];

  for (MaterialColor color in Colors.primaries) {
    allMaterialColorsWithShades.add(color.shade100);
    allMaterialColorsWithShades.add(color.shade200);
    allMaterialColorsWithShades.add(color.shade300);
    allMaterialColorsWithShades.add(color.shade400);
    allMaterialColorsWithShades.add(color.shade500);
    allMaterialColorsWithShades.add(color.shade600);
    allMaterialColorsWithShades.add(color.shade700);
    allMaterialColorsWithShades.add(color.shade800);
    allMaterialColorsWithShades.add(color.shade900);
  }
  return allMaterialColorsWithShades;
}
