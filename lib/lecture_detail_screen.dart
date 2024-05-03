import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/database.dart';
import 'package:lectifaisubmission/expandable_panel.dart';
import 'package:lectifaisubmission/flash_cards_screen.dart';
import 'package:lectifaisubmission/keyword.dart';
import 'package:lectifaisubmission/lecture.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lectifaisubmission/notes_screen.dart';
import 'package:lectifaisubmission/quiz_screen.dart';

// GeminiAPI Key: AIzaSyDPISavCG_7dSteajrni9M_JedFSWxU6Vk

class LectureDetailScreen extends StatefulWidget {
  final Lecture lecture;

  LectureDetailScreen({Key? key, required this.lecture}) : super(key: key);

  @override
  State<LectureDetailScreen> createState() => _LectureDetailScreenState();
}

class _LectureDetailScreenState extends State<LectureDetailScreen> {
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

  // Generate Summary from Text
  generateSummary() async {
    print("generating summary");
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [
      Content.text(
          'Provider a consise summary of the lecture. Don\'t use Markdown format, just regular english: ${this.widget.lecture.fullTranscription}')
    ];
    // final response = await model.generateContent(content);
    final response = model.generateContentStream(content).listen(
      (event) {
        setState(() {
          if (event.text != null) {
            summary += event.text!;
          }
        });
      },
      onDone: () {
        setState(() {
          finishedSummary = true;
          // print(summary);
          databaseMethods.uploadLectureSummary(
            auth.currentUser!.email!,
            widget.lecture.title,
            widget.lecture.duration,
            summary,
          );
        });
      },
    );
  }

  generateKeyWords() async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [
      Content.text(
          'Give me all of the important keywords/concept, along with a concise definition for each keyword/concept in the transcript below. Your response should be in this format so it is easy for me to parse it: keyword/phrase***definition***keyword/phrase***definition. Do not use any markdown! The only time you should use "*" is when you are seperating definition from phrase.Your response needs to be one 1 line and use *** to seperate everything. \nPerform this analysis on the following transcription:\n${this.widget.lecture.fullTranscription}')
    ];
    final response = model.generateContentStream(content).listen(
      (event) {
        setState(() {
          if (event.text != null) {
            keywordsAIOutput += event.text!;
          }
        });
      },
      onDone: () {
        setState(() {
          parseKeywords(keywordsAIOutput);
        });
      },
    );
  }

  void parseKeywords(String keywordsAIOutput) {
    List<String> keywordsList = keywordsAIOutput.split('***');
    // print(keywordsAIOutput);
    // print(keywordsList);

    keywordsList.removeWhere((element) => element.length <= 2);

    for (int i = 0; i < keywordsList.length; i += 2) {
      if (i + 1 < keywordsList.length) {
        keywords.add(Keyword(
          title: keywordsList[i].trim(),
          definition: keywordsList[i + 1].trim(),
        ));
      }
    }

    // Correct iteration over 'keywords' for printing
    for (var keyword in keywords) {
      print(keyword.title);
      print(keyword.definition);
    }

    databaseMethods.uploadLectureKeyWords(
      auth.currentUser!.email!,
      widget.lecture.title,
      widget.lecture.duration,
      keywordsAIOutput,
    );

    // Assuming this is a boolean flag indicating completion
    finishedkeywordsAIOutput = true;
  }

  void generateQuiz() async {
    if (finishedQuizStringOutput) {
      var decodedJson = jsonDecode(
          quizStringOutput.replaceAll("```json", "").replaceAll("```", ""));

      await databaseMethods.uploadLectureQuiz(
        auth.currentUser!.email!,
        widget.lecture.title,
        widget.lecture.duration,
        quizStringOutput,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(data: decodedJson),
        ),
      );
      return;
    }

    print("generating quiz");
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    // Disable Unhandled Exception: GenerativeAIException: Candidate was blocked due to safety
    final content = [
      Content.text(createQuizPrompt.replaceAll(
          "LECTURETRANSCRIPTINSERT", this.widget.lecture.fullTranscription)),
    ];
    final response = model.generateContentStream(content).listen(
      (event) {
        setState(() {
          if (event.text != null) {
            quizStringOutput += event.text!;
          }
        });
      },
      onDone: () {
        setState(() {
          finishedQuizStringOutput = true;
          // print(quizStringOutput);
          void printWrapped(String text) {
            final pattern =
                new RegExp('.{1,800}'); // 800 is the size of each chunk
            pattern.allMatches(text).forEach((match) => print(match.group(0)));
          }

          printWrapped(quizStringOutput);

          var decodedJson = jsonDecode(
              quizStringOutput.replaceAll("```json", "").replaceAll("```", ""));

          databaseMethods
              .uploadLectureQuiz(
            auth.currentUser!.email!,
            widget.lecture.title,
            widget.lecture.duration,
            quizStringOutput,
          )
              .then((value) {
            print("Quiz uploaded");
          });

          Navigator.pop(context);

          // Navigate to Quiz Screen (no named route)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(data: decodedJson),
            ),
          );
        });
      },
    );
  }

  void generateNotes() async {
    if (finishedNotes) {
      await databaseMethods.uploadLectureNotes(
        auth.currentUser!.email!,
        widget.lecture.title,
        widget.lecture.duration,
        notes,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotesScreen(markdownData: notes),
        ),
      );
      return;
    }

    // kCreateNoteSheetPrompt
    print("generating quiz");
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [
      Content.text(kCreateNoteSheetPrompt.replaceAll(
          "LECTURETRANSCRIPTINSERT", this.widget.lecture.fullTranscription)),
    ];
    final response = model.generateContentStream(content).listen(
      (event) {
        setState(() {
          if (event.text != null) {
            notes += event.text!;
          }
        });
      },
      onDone: () {
        setState(() {
          finishedNotes = true;
          void printWrapped(String text) {
            final pattern =
                new RegExp('.{1,800}'); // 800 is the size of each chunk
            pattern.allMatches(text).forEach((match) => print(match.group(0)));
          }

          printWrapped(notes);

          databaseMethods
              .uploadLectureNotes(
            auth.currentUser!.email!,
            widget.lecture.title,
            widget.lecture.duration,
            notes,
          )
              .then((value) {
            print("Notes uploaded");
          });

          Navigator.pop(context);

          // Navigate to Quiz Screen (no named route)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotesScreen(markdownData: notes),
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Check if a summary has been generated and it is not ""
    databaseMethods
        .getLectureSummary(auth.currentUser!.email!, widget.lecture.title,
            widget.lecture.duration)
        .then((value) {
      print("Summary: $value");
      if (value == "") {
        generateSummary();
      } else {
        setState(() {
          summary = value;
          finishedSummary = true;
        });
      }
    });
    databaseMethods
        .getLectureKeyWords(auth.currentUser!.email!, widget.lecture.title,
            widget.lecture.duration)
        .then((value) {
      print("Keywords: $value");
      if (value == "") {
        generateKeyWords();
      } else {
        setState(() {
          keywordsAIOutput = value;
          parseKeywords(keywordsAIOutput);
        });
      }
    });
    databaseMethods
        .getLectureQuiz(auth.currentUser!.email!, widget.lecture.title,
            widget.lecture.duration)
        .then((value) {
      print("Quiz: $value");
      if (value == "") {
        // generateQuiz();
      } else {
        setState(() {
          quizStringOutput = value;
          finishedQuizStringOutput = true;
        });
      }
    });

    databaseMethods
        .getLectureNotes(auth.currentUser!.email!, widget.lecture.title,
            widget.lecture.duration)
        .then((value) {
      print("Notes: $value");
      if (value == "") {
        // generateNotes();
      } else {
        setState(() {
          notes = value;
          finishedNotes = true;
        });
      }
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
                    PopupMenuButton<String>(
                      onSelected: (String result) {
                        // Handle your popup menu logic here
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'Option1',
                          child: ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Create Quiz'),
                            onTap: () {
                              // Create Quiz
                              generateQuiz();
                              if (!finishedQuizStringOutput) {
                                showLoaderDialog(BuildContext context) {
                                  AlertDialog alert = AlertDialog(
                                    content: new Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text("Loading...")),
                                      ],
                                    ),
                                  );
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                }

                                showLoaderDialog(context);
                              }
                              // generateQuiz();
                            },
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Option2',
                          child: ListTile(
                            leading: Icon(Icons.note_add),
                            title: Text('Create Notes'),
                            onTap: () {
                              generateNotes();
                              if (!finishedNotes) {
                                showLoaderDialog(BuildContext context) {
                                  AlertDialog alert = AlertDialog(
                                    content: new Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text("Making Notes...")),
                                      ],
                                    ),
                                  );
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                }

                                showLoaderDialog(context);
                              }
                            },
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Option3',
                          child: ListTile(
                            leading: Icon(Icons.refresh),
                            title: Text('Recreate AI Content'),
                            onTap: () {
                              // Recreate AI Content
                              setState(() {
                                finishedkeywordsAIOutput = false;
                                finishedQuizStringOutput = false;
                                finishedSummary = false;
                                keywordsAIOutput = "";
                                summary = "";
                                quizStringOutput = "";
                                keywords = [];
                                generateSummary();
                                generateKeyWords();
                              });
                            },
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Option4',
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete Lecture'),
                            onTap: () {
                              // Delete Lecture
                              databaseMethods.deleteLecture(
                                auth.currentUser!.email!,
                                widget.lecture.title,
                                widget.lecture.duration,
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: kPrimaryLight),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                // Lecture Title, large bold
                Text(
                  widget.lecture.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: kPrimaryLight,
                  ),
                ),

                // Row with Timer icon and duration
                Row(
                  children: [
                    Icon(Icons.timer, color: kPrimaryLight), // Timer icon
                    const SizedBox(width: 8),
                    Text(
                      '${widget.lecture.duration.toStringAsFixed(1)} seconds',
                      style: TextStyle(color: kPrimaryLight),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Cupertino Segmented Control to switch between Transcription and Summary
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
                          'Transcription',
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
                          'Summary (AI)',
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

                const SizedBox(height: 16),

                // Full transcription text. Trimmed at 5 lines for preview.
                Visibility(
                  child: ShortenCardView(
                    title: "Transcription",
                    centerText: widget.lecture.fullTranscription,
                    showOpenButton: true,
                  ),
                  visible: _selectedSegment == 0,
                ),

                // Summary of the lecture
                const SizedBox(height: 16),
                Visibility(
                  child: ShortenCardView(
                    title: "Summary",
                    centerText: this.summary,
                    showOpenButton: this.finishedSummary,
                  ),
                  visible: _selectedSegment == 1,
                ),

                SizedBox(height: 16),

                Visibility(
                  visible: finishedkeywordsAIOutput,
                  child: Column(
                    children: [
                      Text(
                        "Keywords",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryLight,
                        ),
                      ),

                      // Open Flashcards Button
                      Visibility(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.flash_on, color: kPrimaryGreen),
                          label: Text(
                            'Open Flashcards',
                            style: TextStyle(
                              color: kPrimaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            // Open Flashcards, go to new screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlashcardsScreen(
                                  keywords: keywords,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen.withOpacity(0.1),
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(
                            //     20.0,
                            //   ),
                            // ),
                          ),
                        ),
                        visible: finishedkeywordsAIOutput,
                      ),

                      SizedBox(height: 16),
                      for (Keyword keyword in keywords)
                        ExpandableCard(
                          header: keyword.title,
                          collapsedContent: keyword.definition,
                        ),
                    ],
                  ),
                ),
                // Keyword Collapsable Cards
                // ExpandableCard(
                //   header: "Artificial Intelligence",
                //   collapsedContent: "This is the definition of AI",
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShortenCardView extends StatelessWidget {
  const ShortenCardView({
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
            this.centerText,
            style: TextStyle(
              color: kPrimaryLight,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 15),
          Visibility(
            visible: this.showOpenButton,
            child: GestureDetector(
              child: Text(
                'See Full $title',
                style: TextStyle(
                  color: kPrimaryGreen,
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return DraggableScrollableSheet(
                      expand: false,
                      builder: (_, controller) => Container(
                        padding: EdgeInsets.all(35.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35.0),
                            topRight: Radius.circular(35.0),
                          ),
                        ),
                        child: ListView(
                          controller: controller,
                          children: <Widget>[
                            Text(
                              "Full $title",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              this.centerText,
                              style: TextStyle(
                                color: kPrimaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
