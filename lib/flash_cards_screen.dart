import 'package:flutter/material.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/keyword.dart';

class FlashcardsScreen extends StatefulWidget {
  final List<dynamic> keywords;

  const FlashcardsScreen({Key? key, required this.keywords}) : super(key: key);

  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int _currentIndex = 0;
  bool _isFront = true; // Tracks if the front of the card is shown

  void _nextCard() {
    if (_currentIndex < widget.keywords.length - 1) {
      setState(() {
        _currentIndex++;
        _isFront = true; // Reset to front side when moving to the next card
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFront = true; // Reset to front side when moving to the previous card
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current keyword object
    Keyword currentKeyword = widget.keywords[_currentIndex];

    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
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
                "Flashcards",
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
                child: ElevatedButton.icon(
                  icon: Icon(Icons.flip, color: kPrimaryDark),
                  onPressed: () {
                    _flipCard();
                  },
                  label: const Text(
                    'Flip',
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
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              transform: Matrix4.rotationY(_isFront ? 0 : 3.1416),
              transformAlignment: Alignment.center,
              child: _isFront
                  ? Card(
                      color: Colors.white,
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Text(
                            currentKeyword.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Transform(
                      // This will counteract the Y-axis rotation to ensure the back of the card is facing the correct way
                      transform: Matrix4.rotationY(3.1416),
                      alignment: Alignment.center,
                      child: Card(
                        color: Colors.white,
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                currentKeyword.definition,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: kPrimaryLight),
                onPressed: _prevCard,
                tooltip: 'Previous',
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, color: kPrimaryLight),
                onPressed: _nextCard,
                tooltip: 'Next',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
