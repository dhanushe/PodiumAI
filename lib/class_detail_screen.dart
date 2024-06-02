import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lectifaisubmission/class.dart';
import 'package:lectifaisubmission/class_lecture_detail_screen.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/database.dart';
import 'package:lectifaisubmission/expandable_panel.dart';
import 'package:lectifaisubmission/flash_cards_screen.dart';
import 'package:lectifaisubmission/keyword.dart';
import 'package:lectifaisubmission/lecture.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lectifaisubmission/lecture_card.dart';
import 'package:lectifaisubmission/lecture_class_card.dart';
import 'package:lectifaisubmission/lecture_detail_screen.dart';
import 'package:lectifaisubmission/notes_screen.dart';
import 'package:lectifaisubmission/quiz_screen.dart';
import 'package:lectifaisubmission/speech_recognition_sheet.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// GeminiAPI Key: AIzaSyDPISavCG_7dSteajrni9M_JedFSWxU6Vk

class ClassDetailScreen extends StatefulWidget {
  final Class passedClass;

  ClassDetailScreen({Key? key, required this.passedClass}) : super(key: key);

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  String keywordsAIOutput = "";
  bool finishedkeywordsAIOutput = false;
  List<Keyword> keywords = [];

  String summary = "";
  bool finishedSummary = false;

  String notes = "";
  bool finishedNotes = false;

  String quizStringOutput = "";
  bool finishedQuizStringOutput = false;

  int _selectedSegment = 0;

  DatabaseMethods databaseMethods = DatabaseMethods();
  FirebaseAuth auth = FirebaseAuth.instance;

  bool isTeacher = false;

  String transcription = 'Press the microphone button to start recording...';
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  Stream? transcriptsStream;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  getClassTranscripts() async {
    await databaseMethods
        .getClassTranscripts(
            firebaseAuth.currentUser!.email!, "${widget.passedClass.ID}")
        .then((val) {
      setState(() {
        transcriptsStream = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getClassTranscripts();
    if (widget.passedClass.teacherEmail == auth.currentUser!.email) {
      isTeacher = true;
    }
    _initSpeech();
  }

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
      floatingActionButton: isTeacher && _selectedSegment == 0
          ? FloatingActionButton(
              // onPressed: () {
              //   showModalBottomSheet(
              //     context: context,
              //     builder: (context) {
              //       return SpeechRecognitionSheet(
              //         lectureForClass: true,
              //         classCode: "${widget.passedClass.ID}",
              //       );
              //     },
              //   );
              // },
              onPressed: () async {
                // Navigator.pop(context);
                // Get User Language
                await databaseMethods
                    .getUserLanguage(firebaseAuth.currentUser!.email!)
                    .then((value) {
                  print('User language is $value');
                  if (value == null) {
                    value = 'English (United States)';
                  }
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SpeechRecognitionSheet(
                        lectureForClass: true,
                        userLanguage: value,
                        classCode: "${widget.passedClass.ID}",
                      );
                    },
                  );
                });
              },
              child: const Icon(Icons.mic),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 35.0, top: 15.0, right: 35.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
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
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          // Handle your popup menu logic here
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Option1',
                            child: ListTile(
                              leading: Icon(Icons.people),
                              title: Text('View Student List'),
                              onTap: () {
                                setState(() {
                                  Navigator.pop(context);
                                  _selectedSegment = 1;
                                });
                              },
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Option2',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete Class'),
                              onTap: () {
                                setState(() {
                                  databaseMethods
                                      .deleteClass("${widget.passedClass.ID}");
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert, color: kPrimaryLight),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  Text(
                    '#${widget.passedClass.ID}',
                    style: TextStyle(
                      color: kPrimaryLight,
                      fontSize: 15,
                    ),
                  ),

                  // Lecture Title, large bold
                  Text(
                    widget.passedClass.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kPrimaryLight,
                    ),
                  ),

                  // Row with Timer icon and duration
                  Row(
                    children: [
                      Icon(Icons.people, color: kPrimaryLight), // Timer icon
                      const SizedBox(width: 8),
                      Text(
                        '${widget.passedClass.studentEmails.length} students',
                        style: TextStyle(color: kPrimaryLight),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Cupertino Segmented Control to switch between Student List and Resources
                  Container(
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
                            'Lectures',
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
                            'Student List',
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
                        });
                      },
                      groupValue: _selectedSegment,
                    ),
                  ),

                  SizedBox(height: 16),

                  if (_selectedSegment == 1)
                    Column(
                      children: [
                        for (var student in widget.passedClass.studentEmails)
                          MemberCardView(
                            title: '${student.split("***")[1]}',
                            centerText: '${student.split("***")[0]}',
                            showOpenButton: false,
                          ),
                      ],
                    ),

                  Visibility(
                    child: transcriptList(),
                    visible: _selectedSegment == 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget transcriptList() {
    // This method uses the dmStream
    return StreamBuilder(
      stream: this.transcriptsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot<Object?> data =
                        (snapshot.data! as QuerySnapshot).docs[index];

                    return GestureDetector(
                      child: LectureClassCard(
                        title: data['title'],
                        duration: data['duration'],
                        transcription: data['transcription'],
                        // convert data['time'] which is in epoch time to a string
                        timeString: DateTime.fromMillisecondsSinceEpoch(
                                data['time'] * 1000)
                            .toString(),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassLectureDetailScreen(
                              title: data['title'],
                              duration: data['duration'],
                              transcription: data['transcription'],
                              keyterms: data['keyterms'],
                              notes: data['notes'],
                              quizJSON: data['quizJSON'],
                              summary: data['summary'],
                              classCode: "${widget.passedClass.ID}",
                              className: widget.passedClass.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            : Container(
                child: Text("No data", style: TextStyle(color: Colors.white)),
              );
      },
    );
  }
}

class MemberCardView extends StatelessWidget {
  const MemberCardView({
    super.key,
    required this.title,
    required this.centerText,
    required this.showOpenButton,
  });

  final String title;
  final String centerText;
  final bool showOpenButton;

  @override
  Widget build(BuildContext context) {
    print(this.showOpenButton);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: kPrimaryGreen,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            this.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kPrimaryLight,
            ),
          ),
          SizedBox(height: 15),
          Text(
            this.centerText,
            style: TextStyle(
              color: kPrimaryLight,
              fontSize: 12,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
