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

  SpeechRecognitionSheet({
    Key? key,
    required this.lectureForClass,
    this.classCode,
    this.onComplete,
  }) : super(key: key);

  @override
  _SpeechRecognitionSheetState createState() => _SpeechRecognitionSheetState();
}

class _SpeechRecognitionSheetState extends State<SpeechRecognitionSheet> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = ''; // Initialize as empty string
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
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    _lastWords = '';
    _speechEnabled = false;
    _isListening = false;
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
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
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  // Generate Summary from Text
  generateTranscriptionTitle() async {
    print("generating summary");
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [
      Content.text(
          'Give me a title based on the contents of this transcription. Try to keep it short and sweet.\n\nTranscription:\n$_lastWords\n\nTitle (respond with only the title): '),
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
      await databaseMethods
          .uploadTranscriptionForClass(
        _lastWords,
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
        _lastWords,
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
            // Close button
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close, color: kPrimaryLight),
                onPressed: () {
                  _stopListening();
                  resetValues();
                  Navigator.pop(context);
                },
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
                  _lastWords, // Display the last recognized words
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
              label: Text(
                _isListening ? 'Pause Transcription' : 'Start Recording',
                style: TextStyle(
                  color: kPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _isListening ? _stopListening : _startListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGray,
              ),
            ),

            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
