import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lectifaisubmission/database.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'constants.dart';
import 'dart:async';

class SpeechRecognitionSheet extends StatefulWidget {
  final bool lectureForClass;
  String? classCode;
  final VoidCallback? onComplete;
  final String userLanguage;

  SpeechRecognitionSheet({
    Key? key,
    required this.lectureForClass,
    this.classCode,
    this.onComplete,
    required this.userLanguage,
  }) : super(key: key);

  @override
  _SpeechRecognitionSheetState createState() => _SpeechRecognitionSheetState();
}

class _SpeechRecognitionSheetState extends State<SpeechRecognitionSheet> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = ''; // Initialize as empty string
  String words = '';
  bool _isListening = false; // Track listening state
  DatabaseMethods databaseMethods = new DatabaseMethods();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String transcriptionTitle = "";

  Timer? _timer;
  double _duration = 0.0; // Duration in seconds

  @override
  void initState() {
    super.initState();
    _initSpeech();
    print("User Language: ${widget.userLanguage}");
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      finalTimeout: Duration(seconds: 3),
    );
    _lastWords = '';
    words = '';
    _speechEnabled = false;
    _isListening = false;
    setState(() {});
  }

  void _startListening() async {
    var locales = await _speechToText.locales();

    String localeID = '';

    print(widget.userLanguage + " is the user language");

    // print the list of available locales
    for (var locale in locales) {
      if (locale.name == widget.userLanguage) {
        localeID = locale.localeId;
        print(localeID);
        break;
      }
    }

    // Some UI or other code to select a locale from the list
    // resulting in an index, selectedLocale

    // var selectedLocale = locales[selectedLocale];
    // _speechToText.listen(
    //   onResult: resultListener,
    //   localeId: selectedLocale.localeId,
    // );
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: localeID,
      listenOptions: SpeechListenOptions(listenMode: ListenMode.dictation),
    );
    setState(() {
      _isListening = true;
    });
    _startTimer(); // Start the timer when recording starts
  }

  void _stopListening() async {
    await _speechToText.stop();
    _stopTimer(); // Stop the timer when recording stops
    setState(() {
      _isListening = false;
      words = words + _lastWords;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      print("Is Final Result ${result.finalResult}");
      if (result.finalResult) {
        words = '$words $_lastWords';
        _lastWords = '';
      }
    });
  }

  // Generate Summary from Text
  generateTranscriptionTitle() async {
    print("generating summary");
    String totalText = words + _lastWords;
    print("Total Text: $totalText");
    // return;
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [
      Content.text(
          'Give me a title based on the contents of this transcription. Try to keep it short and sweet.\n\nTranscription:\n$totalText\n\nTitle (respond with only the title): '),
    ];
    // final response = await model.generateContent(content);
    final response = model.generateContentStream(content).listen(
      (event) {
        setState(() {
          if (event.text != null) {
            transcriptionTitle = event.text!;
            print("Transcription Title: $transcriptionTitle");
          }
        });
      },
      onDone: () {
        print("Done");
        uploadTranscriptionToFirebase();
      },
    );
  }

  void uploadTranscriptionToFirebase() async {
    print("Uploading transcription to Firebase");
    String userName = firebaseAuth.currentUser!.displayName!;
    String userEmail = firebaseAuth.currentUser!.email!;
    if (widget.lectureForClass) {
      print("Uploading transcription to Firebase within Class");
      await databaseMethods
          .uploadTranscriptionForClass(
        words + _lastWords,
        userName,
        userEmail,
        this.transcriptionTitle,
        _duration,
        widget.classCode!,
        // Get seconds epoch time
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      )
          .then((value) {
        _stopListening();
        resetValues();
        Navigator.pop(context);
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    } else {
      await databaseMethods
          .uploadTranscription(
        words + _lastWords,
        userName,
        userEmail,
        this.transcriptionTitle,
        // Duration
        _duration,
      )
          .then((value) {
        _stopListening();
        resetValues();
        Navigator.pop(context);
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    }
  }

  void resetValues() {
    _lastWords = '';
    words = '';
    _speechEnabled = false;
    _isListening = false;
    _duration = 0.0;
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _duration += 0.1;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      color: kPrimaryDark,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Text(
                "${_duration.toStringAsFixed(1)}s", // Display the duration with one decimal place
                style: TextStyle(color: kPrimaryLight, fontSize: 16),
              ),
            ),

            // Add lecture button
            ElevatedButton.icon(
              icon: Icon(Icons.add, color: kPrimaryLight),
              label: Text(
                'Add Lecture',
                style: TextStyle(
                  color: kPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _stopListening();
                final recordedDuration = _duration;
                generateTranscriptionTitle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGray,
              ),
            ),

            // Transcription Text
            Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.2,
              child: SingleChildScrollView(
                // Always scroll to the bottom
                reverse: true,
                child: Text(
                  // _lastWords, // Display the last recognized words
                  words + _lastWords,
                  style: TextStyle(
                    color: kPrimaryLight,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Start/Stop Recording Button
            ElevatedButton.icon(
              icon: Icon(
                _isListening ? Icons.pause : Icons.mic,
                color: kPrimaryLight,
              ),
              label: Column(
                children: [
                  Text(
                    _isListening ? 'Pause Transcription' : 'Start Recording',
                    style: TextStyle(
                      color: kPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // language
                  Text(
                    widget.userLanguage,
                    style: TextStyle(
                      fontSize: 10,
                      color: kPrimaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onPressed: _isListening ? _stopListening : _startListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGray,
              ),
            ),

            // Close button
            ElevatedButton(
              onPressed: () {
                _stopListening();
                resetValues();
                Navigator.pop(context);
              },
              child: Text("Cancel Recording",
                  style: TextStyle(color: kPrimaryGray)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                // border radius
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
