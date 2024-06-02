import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lectifaisubmission/class.dart';
import 'package:lectifaisubmission/class_card.dart';
import 'package:lectifaisubmission/class_detail_screen.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/create_class.dart';
import 'package:lectifaisubmission/database.dart';
import 'package:lectifaisubmission/google_sign_in.dart';
import 'package:lectifaisubmission/helper_functions.dart';
import 'package:lectifaisubmission/lecture.dart';
import 'package:lectifaisubmission/lecture_card.dart';
import 'package:lectifaisubmission/lecture_detail_screen.dart';
import 'package:lectifaisubmission/settings.dart';
import 'package:lectifaisubmission/speech_api.dart';
import 'package:lectifaisubmission/speech_recognition_sheet.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required, this.accountWasJustCreated})
      : super(key: key);

  final bool? accountWasJustCreated;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  List<Lecture> lectures = [];

  String transcription = 'Press the microphone button to start recording...';

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  Stream? transcriptsStream;
  DatabaseMethods databaseMethods = DatabaseMethods();

  String isStudent = '';

  String enteredClassCode = '';
  String enteredOwnerName = '';

  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    // var provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    // provider.logout();

    // HelperFunctions.saveUserLoggedIn(false);
    // HelperFunctions.saveUserEmail('');
    // HelperFunctions.saveUserName('');
    uploadUserInfo();
    _initSpeech();
  }

  void uploadUserInfo() async {
    await databaseMethods.uploadUserInfo({
      'email': firebaseAuth.currentUser!.email,
      'name': firebaseAuth.currentUser!.displayName,
      'isStudent': '',
    }).then((value) {
      print('value is $value');
      if (value == 'student') {
        setState(() {
          isStudent = 'student';
          getUserTranscripts('student');
        });
      } else if (value == 'teacher') {
        setState(() {
          isStudent = 'teacher';
          getUserTranscripts('teacher');
        });
      } else if (value == '') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Welcome to Podium'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you a student or a teacher? This will help us tailor your experience.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    databaseMethods.updateStudentTeacherStatus(
                        firebaseAuth.currentUser!.email!,
                        firebaseAuth.currentUser!.displayName!,
                        'student');

                    Navigator.of(context).pop();
                    setState(() {
                      getUserTranscripts('student');
                      isStudent = 'student';
                    });

                    seeDemoDialog();
                  },
                  child: Text('Student'),
                ),
                TextButton(
                  onPressed: () {
                    databaseMethods.updateStudentTeacherStatus(
                        firebaseAuth.currentUser!.email!,
                        firebaseAuth.currentUser!.displayName!,
                        'teacher');
                    Navigator.of(context).pop();
                    setState(() {
                      getUserTranscripts('teacher');
                      isStudent = 'teacher';
                    });

                    seeDemoDialog();
                  },
                  child: Text('Teacher'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  seeDemoDialog() {
    // Show a popup asking users to see a demo on youtube
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // first name of the user
          title: Text('Welcome ${firebaseAuth.currentUser!.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Would you like to see a demo on how to use Podium on Youtube?',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, I will try it out!'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                launchUrl(Uri.parse('https://youtu.be/Qd5uHBhHZqg'));
              },
              child: Text('Yes, show me!'),
            ),
          ],
        );
      },
    );
  }

  getUserTranscripts(String isStudent) async {
    if (_selectedSegment == 0) {
      print("getting transcripts for segment 0");
      await databaseMethods
          .getTranscripts(firebaseAuth.currentUser!.email!)
          .then((val) {
        setState(() {
          transcriptsStream = val;
        });
      });
    } else if (_selectedSegment == 1) {
      print("segment is 1");
      print('studentstatus $isStudent');
      print("getting classes");
      await databaseMethods
          .getClassesThatIAmEnrolledIn(firebaseAuth.currentUser!.email!,
              firebaseAuth.currentUser!.displayName!, isStudent)
          .then((val) {
        setState(() {
          transcriptsStream = val;
          print("finished getting transcripts for segment 1");
          debugPrint("Transcripts: $transcriptsStream");
        });
      });
    }
  }

  // getUserTranscripts(String isStudent) async {
  //   if (_selectedSegment == 0) {
  //     print("segment is 0");
  // await databaseMethods
  //     .getTranscripts(firebaseAuth.currentUser!.email!)
  //     .then((val) {
  //   setState(() {
  //     transcriptsStream = val;
  //     debugPrint("Transcripts: $transcriptsStream");
  //   });
  // });
  //   } else {
  //     if (isStudent == 'student') {
  //       print("segment is 1 and is student");
  // await databaseMethods
  //     .getClassesThatIAmEnrolledIn(firebaseAuth.currentUser!.email!,
  //         firebaseAuth.currentUser!.displayName!)
  //     .then((val) {
  //   setState(() {
  //     transcriptsStream = val;
  //     debugPrint("Finished Getting transcripts: $transcriptsStream");
  //   });
  // });
  //     } else if (isStudent == 'teacher') {
  //       print("segment is 2 and is teacher");
  //       // await databaseMethods
  //       //     .getTeacherTranscripts(firebaseAuth.currentUser!.email!)
  //       //     .then((val) {
  //       //   setState(() {
  //       //     transcriptsStream = val;
  //       //   });
  //       // });
  //     }
  //   }
  //   // if (isStudent == 'student') {
  //   //   await databaseMethods
  //   //       .getTranscripts(firebaseAuth.currentUser!.email!)
  //   //       .then((val) {
  //   //     setState(() {
  //   //       transcriptsStream = val;
  //   //       debugPrint("Transcripts: $transcriptsStream");
  //   //     });
  //   //   });
  //   // } else if (isStudent == 'teacher') {
  //   //   await databaseMethods
  //   //       .getTeacherTranscripts(firebaseAuth.currentUser!.email!)
  //   //       .then((val) {
  //   //     setState(() {
  //   //       transcriptsStream = val;
  //   //       debugPrint("Transcripts: $transcriptsStream");
  //   //     });
  //   //   });
  //   // }
  // }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
    }

    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  // Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      floatingActionButton: isStudent == 'student'
          ? FloatingActionButton(
              onPressed: () {
                // Show a popup asking to join a class or record a lecture
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Choose an option'),
                      content: Text(
                          'Would you like to join a class or record a lecture?'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            // Get User Language
                            await databaseMethods
                                .getUserLanguage(
                                    firebaseAuth.currentUser!.email!)
                                .then((value) {
                              if (value == null) {
                                value = 'English (United States)';
                              }
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SpeechRecognitionSheet(
                                    lectureForClass: false,
                                    userLanguage: value,
                                    onComplete: () {
                                      getUserTranscripts(isStudent);
                                    },
                                  );
                                },
                              );
                            });
                          },
                          child: Text('Record a lecture'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Show a popup asking for the class code
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Join a class'),
                                  content: Column(
                                    // minimum sizes for the children
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Enter the class code',
                                        ),
                                        onChanged: (value) {
                                          enteredClassCode = value;
                                        },
                                        // make it accept only numbers
                                        keyboardType: TextInputType.number,
                                      ),
                                      // owner name
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Enter the owner name',
                                        ),
                                        onChanged: (value) {
                                          enteredOwnerName = value;
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        databaseMethods.joinClass(
                                          enteredClassCode,
                                          firebaseAuth.currentUser!.email!,
                                          firebaseAuth
                                              .currentUser!.displayName!,
                                          enteredOwnerName,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Text('Join'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Join a class'),
                        ),
                      ],
                    );
                  },
                );
                // showModalBottomSheet(
                //   context: context,
                //   builder: (context) {
                //     return SpeechRecognitionSheet();
                //   },
                // );
              },
              child: Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: () {
                // create class page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateClassScreen()));
              },
              child: Icon(Icons.add),
            ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Welcome back
                Container(
                  margin: const EdgeInsets.only(left: 30),
                  child: Text(
                    'Welcome back 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: kPrimaryLight,
                    ),
                  ),
                ),

                // User Name
                Container(
                  margin: const EdgeInsets.only(left: 30),
                  child: Text(
                    firebaseAuth.currentUser!.displayName!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryLight,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Segmented Control to Switch between transcripts and classes
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: kPrimaryDark,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: kPrimaryGray,
                    thumbColor: kPrimaryGreen,
                    children: {
                      0: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Transcripts',
                          style: TextStyle(
                            color: _selectedSegment == 0
                                ? kPrimaryDark
                                : kPrimaryLight,
                          ),
                        ),
                      ),
                      1: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Classes',
                          style: TextStyle(
                            color: _selectedSegment == 1
                                ? kPrimaryDark
                                : kPrimaryLight,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        _selectedSegment = value!;
                        transcriptsStream = null;
                        getUserTranscripts(isStudent);
                      });
                    },
                    groupValue: _selectedSegment,
                  ),
                ),

                SizedBox(height: 20),
                transcriptList(),
              ],
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align the row to the right
              children: [
                IconButton(
                  color: kPrimaryLight,
                  icon: Icon(
                    FeatherIcons.settings,
                  ), // Icon for the settings button
                  onPressed: () {
                    // Navigate to the settings screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  color: kPrimaryLight,
                  icon: Icon(FeatherIcons.logOut),
                  onPressed: () {
                    var provider = Provider.of<GoogleSignInProvider>(context,
                        listen: false);
                    provider.logout();

                    HelperFunctions.saveUserLoggedIn(false);
                    HelperFunctions.saveUserEmail('');
                    HelperFunctions.saveUserName('');
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget transcriptList() {
    // This method uses the dmStream
    return StreamBuilder(
      stream: transcriptsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if ((snapshot.data! as QuerySnapshot).docs.length == 0) {
            return _placeholderWidget();
          }
        }

        return snapshot.hasData
            ? Expanded(
                child: ListView.builder(
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot<Object?> data =
                        (snapshot.data! as QuerySnapshot).docs[index];
                    // if (isStudent == 'teacher') {
                    //   return GestureDetector(
                    //     child: ClassCard(
                    //       passedClass: Class(
                    //         name: data['className'],
                    //         description: data['classDescription'],
                    //         studentEmails: data['studentEmails'],
                    //         ID: data['ID'],
                    //         teacherEmail: data['teacherEmail'],
                    //         subject: data['classSubject'],
                    //       ),
                    //     ),
                    //     onTap: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => ClassDetailScreen(
                    //             passedClass: Class(
                    //               name: data['className'],
                    //               description: data['classDescription'],
                    //               studentEmails: data['studentEmails'],
                    //               ID: data['ID'],
                    //               teacherEmail: data['teacherEmail'],
                    //               subject: data['classSubject'],
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   );
                    // }
                    // if (_selectedSegment == 1) {
                    //   // print all keys in data
                    //   (data.data() as Map<String, dynamic>)
                    //       .keys
                    //       .forEach((element) {
                    //     print('keys' + element);
                    //   });
                    // return GestureDetector(
                    //   child: ClassCard(
                    //     passedClass: Class(
                    //       name: data['className'],
                    //       description: data['classDescription'],
                    //       studentEmails: data['studentEmails'],
                    //       ID: data['ID'],
                    //       teacherEmail: data['teacherEmail'],
                    //       subject: data['classSubject'],
                    //     ),
                    //   ),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => ClassDetailScreen(
                    //           passedClass: Class(
                    //             name: data['className'],
                    //             description: data['classDescription'],
                    //             studentEmails: data['studentEmails'],
                    //             ID: data['ID'],
                    //             teacherEmail: data['teacherEmail'],
                    //             subject: data['classSubject'],
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );
                    // }
                    // print keys in data
                    if (_selectedSegment == 0 && transcriptsStream != null) {
                      var dataMap = data.data() as Map<String, dynamic>;
                      if (!dataMap.containsKey('title')) {
                        return _placeholderWidget();
                      }
                      return GestureDetector(
                        child: LectureCard(
                          lecture: Lecture(
                            title: data['title'],
                            duration: data['duration'],
                            transcriptionPreview: data['transcription'],
                            fullTranscription: data['transcription'],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LectureDetailScreen(
                                lecture: Lecture(
                                  title: data['title'],
                                  duration: data['duration'],
                                  transcriptionPreview: data['transcription'],
                                  fullTranscription: data['transcription'],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (_selectedSegment == 1 &&
                        transcriptsStream != null) {
                      var dataMap = data.data() as Map<String, dynamic>;
                      if (!dataMap.containsKey('className')) {
                        return _placeholderWidget();
                      }
                      return GestureDetector(
                        child: ClassCard(
                          passedClass: Class(
                            name: data['className'],
                            description: data['classDescription'],
                            studentEmails: data['studentEmails'],
                            ID: data['ID'],
                            teacherEmail: data['teacherEmail'],
                            subject: data['classSubject'],
                          ),
                        ),
                        onTap: () {
                          print('class ID is ${data['ID']}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassDetailScreen(
                                passedClass: Class(
                                  name: data['className'],
                                  description: data['classDescription'],
                                  studentEmails: data['studentEmails'],
                                  ID: data['ID'],
                                  teacherEmail: data['teacherEmail'],
                                  subject: data['classSubject'],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return _placeholderWidget();
                      // return Container(
                      //   margin: const EdgeInsets.only(left: 30),
                      //   child: Text(
                      //     "Create a new class or record a lecture to get started!",
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // );
                    }
                  },
                ),
              )
            : _placeholderWidget();
        // : Container(
        //     child: Text("No data", style: TextStyle(color: Colors.white)),
        //   );
      },
    );
  }

  Center _placeholderWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        // nodata.svg is a placeholder image
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            SvgPicture.asset(
              'assets/nodata.svg',
              semanticsLabel: 'Recording Icon Logo',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: Text(
                "Create a new class or record a lecture to get started!",
                style: TextStyle(color: kPrimaryPurple, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future toggleRecording() => SpeechAPI.toggleRecording(
        onResult: (text) => setState(() => transcription = text),
      );
}
