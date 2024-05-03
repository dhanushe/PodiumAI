import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:lectifaisubmission/constants.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.data,
  });

  final dynamic data;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // A map to keep track of the selected option for each question
  Map<String, String> _selectedOptions = {};
  Map<String, List<String>> _sequenceOptions = {};
  Map<String, String> _fitbAnswers = {};

  bool _isSubmitted = false;

  // Helper function to shuffle options for sequence questions
  List<String> _shuffleOptions(List<String> options) {
    var random = Random();
    List<String> shuffledOptions = List<String>.from(options);
    shuffledOptions.shuffle(random);
    return shuffledOptions;
  }

  @override
  void initState() {
    super.initState();
    // Initialize the sequence options with shuffled options when the widget is first created
    // for (var question in widget.data['quiz']) {
    for (var question in widget.data['quiz']) {
      if (question['type'] == 'Sequence') {
        _sequenceOptions[question['id']] =
            _shuffleOptions(List<String>.from(question['options']));
      } else if (question['type'] == 'Fill in the Blank') {
        _fitbAnswers[question['id']] = ''; // Initialize FITB answers as empty
      } else {
        _selectedOptions[question['id']] =
            ''; // Initialize selected options for MCQ and True/False questions
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtering to include MCQ, True/False, and now Sequence questions
    List<dynamic> questions = widget.data['quiz']
        .where((question) =>
            question['type'] == 'MCQ' ||
            question['type'] == 'True/False' ||
            question['type'] == 'Sequence' ||
            question['type'] == 'Fill in the Blank')
        .toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kPrimaryDark,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: kPrimaryLight,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Quiz",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kPrimaryLight,
                    ),
                  ),
                  Spacer(),

                  // Modern Rounded Submit
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isSubmitted = true;
                        });
                      },
                      child: const Text(
                        'Submit',
                        style: const TextStyle(
                          color: kPrimaryDark,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var question = questions[index];
                    if (question['type'] == 'Sequence') {
                      return _buildSequenceCard(question);
                    } else if (question['type'] == 'Fill in the Blank') {
                      return _buildFITBCard(question);
                    } else {
                      // Handling for MCQ and True/False remains the same
                      List<dynamic> options = question['type'] == 'MCQ'
                          ? question['options']
                          : [
                              'True',
                              'False'
                            ]; // For True/False questions, set options manually
                      return _buildOptionCard(question, options);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildOptionCard(dynamic question, List<dynamic> options) {
  //   return Card(
  //     margin: const EdgeInsets.all(10.0),
  //     color: kPrimaryLight,
  //     child: Column(
  //       children: <Widget>[
  //         ListTile(
  //           title: Text(
  //             question['question'],
  //             style: const TextStyle(
  //               color: kPrimaryDark,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           subtitle: const Text('Select an answer:'),
  //         ),
  // ...options.map((option) {
  //   return ListTile(
  //     title: Text(option),
  //     leading: Radio<String>(
  //       value: option,
  //       groupValue: _selectedOptions[question['id']],
  //       onChanged: (String? value) {
  //         setState(() {
  //           _selectedOptions[question['id']] = value!;
  //         });
  //       },
  //     ),
  //   );
  // }).toList(),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildOptionCard(dynamic question, List<dynamic> options) {
    bool isCorrect = _isSubmitted &&
        (_selectedOptions[question['id']] == question['correct_answer']);
    Color cardColor = Colors.white; // Default color
    String subtitleText = 'Select an answer:';

    if (_isSubmitted) {
      cardColor = isCorrect ? Colors.lightGreen[100]! : Colors.red[100]!;
      subtitleText = 'Correct answer: ${question['correct_answer']}';
    }

    return Card(
      margin: const EdgeInsets.all(10.0),
      color: cardColor, // Updated to reflect correctness
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              question['question'],
              style:
                  TextStyle(color: kPrimaryDark, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitleText), // Updated based on submission status
          ),
          ...options.map((option) {
            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: _selectedOptions[question['id']],
                onChanged: (String? value) {
                  setState(() {
                    _selectedOptions[question['id']] = value!;
                  });
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Widget _buildSequenceCard(dynamic question) {
  //   return Card(
  //     margin: const EdgeInsets.all(8.0),
  //     color: kPrimaryLight,
  //     child: Column(
  //       children: <Widget>[
  //         ListTile(
  //           title: Text(
  //             question['question'],
  //             style: const TextStyle(
  //               color: kPrimaryDark,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           subtitle: const Text('Arrange in correct order:'),
  //         ),
  //         ReorderableListView(
  //           shrinkWrap: true,
  //           physics:
  //               NeverScrollableScrollPhysics(), // to disable scrolling inside the card
  //           children: _sequenceOptions[question['id']]!.map((option) {
  //             return ListTile(
  //               key: ValueKey(option),
  //               title: Text(option),
  //               trailing: const Icon(Icons.reorder),
  //             );
  //           }).toList(),
  //           onReorder: (int oldIndex, int newIndex) {
  //             setState(() {
  //               // Update the state of the options to reflect the reorder
  //               if (newIndex > oldIndex) {
  //                 newIndex -= 1;
  //               }
  //               final options = _sequenceOptions[question['id']]!;
  //               final item = options.removeAt(oldIndex);
  //               options.insert(newIndex, item);
  //             });
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSequenceCard(dynamic question) {
    bool isCorrect = false;
    if (_isSubmitted) {
      isCorrect = ListEquality().equals(
        _sequenceOptions[question['id']],
        question['correct_order'],
      );
    }

    Color cardColor = _isSubmitted
        ? (isCorrect ? Colors.lightGreen[100]! : Colors.red[100]!)
        : kPrimaryLight;
    String subtitleText =
        _isSubmitted ? 'Correct sequence shown' : 'Arrange in correct order:';

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: cardColor,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              question['question'],
              style: TextStyle(
                color: kPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(subtitleText),
          ),
          ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            onReorder: _isSubmitted
                ? (int oldIndex, int newIndex) {}
                : (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final options = _sequenceOptions[question['id']]!;
                      final item = options.removeAt(oldIndex);
                      options.insert(newIndex, item);
                    });
                  },
            children: _sequenceOptions[question['id']]!
                .asMap()
                .map((index, option) => MapEntry(
                      index,
                      ListTile(
                        key: ValueKey(option),
                        title: Text(option),
                        trailing:
                            _isSubmitted ? null : const Icon(Icons.reorder),
                      ),
                    ))
                .values
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFITBCard(dynamic question) {
    bool isCorrect = false;
    if (_isSubmitted) {
      isCorrect = question['correct_answer'].toString().toLowerCase() ==
          (_fitbAnswers[question['id']] ?? "").toLowerCase();
    }

    Color cardColor = _isSubmitted
        ? (isCorrect ? Colors.lightGreen[100]! : Colors.red[100]!)
        : kPrimaryLight;
    String subtitleText = _isSubmitted
        ? 'Correct answer: ${question['correct_answer']}'
        : 'Enter your answer:';

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: cardColor,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              question['question'].replaceFirst('______', '________'),
              style: const TextStyle(
                color: kPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(subtitleText),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
                enabled: !_isSubmitted, // Disable TextField after submission
                style: TextStyle(color: kPrimaryLight),
                autocorrect: true,
                enableSuggestions: false,
                cursorColor: kPrimaryLight,
                cursorWidth: 2.0,
                cursorHeight: 25.0,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kPrimaryDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Type your answer here',
                  hintStyle: const TextStyle(color: kPrimaryLight),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15.0),
                ),
                onChanged: (value) {
                  if (!_isSubmitted) {
                    setState(() {
                      _fitbAnswers[question['id']] = value;
                    });
                  }
                }),
          ),
        ],
      ),
    );
  }

  // Widget _buildFITBCard(dynamic question) {
  //   return Card(
  //     margin: const EdgeInsets.all(8.0),
  //     color: kPrimaryLight,
  //     child: Column(
  //       children: <Widget>[
  //         ListTile(
  //           title: Text(
  //             question['question'].replaceFirst('______', '________'),
  //             style: const TextStyle(
  //               color: kPrimaryDark,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           subtitle: const Text('Enter your answer:'),
  //         ),
  //         Padding(
  //           padding:
  //               const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //           child: TextField(
  //             style: TextStyle(color: kPrimaryLight),
  //             // Disable Auto-Correct and Auto-Complete
  //             autocorrect: false,
  //             enableSuggestions: false,
  //             cursorColor: kPrimaryLight,
  //             cursorWidth: 2.0,
  //             cursorHeight: 25.0,
  //             decoration: InputDecoration(
  //               filled: true, // Add fill color to the text field
  //               fillColor: kPrimaryDark, // Choose a light grey fill color
  //               // Input letters color
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(15.0), // Rounded corners
  //                 borderSide: BorderSide.none, // No border
  //               ),
  //               hintText: 'Type your answer here',
  //               hintStyle: const TextStyle(
  //                 color: kPrimaryLight,
  //               ),

  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 20.0,
  //                 vertical: 15.0,
  //               ), // Padding inside the text field
  //             ),
  //             onChanged: (value) {
  //               // Update the FITB answer in the state
  //               setState(() {
  //                 _fitbAnswers[question['id']] = value;
  //               });
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
