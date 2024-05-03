import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/lecture.dart'; // Importing ui library for the ImageFilter

class LectureClassCard extends StatelessWidget {
  // final Lecture lecture;
  // title: data['title'],
  //                         duration: data['duration'],
  //                         transcriptionPreview: data['transcription'],
  //                         fullTranscription: data['transcription'],

  String title;
  double duration;
  String transcription;
  String timeString;

  LectureClassCard({
    Key? key,
    required this.title,
    required this.duration,
    required this.transcription,
    required this.timeString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF1d1c23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF333239),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryLight,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timer, color: kPrimaryLight), // Timer icon
              SizedBox(width: 8),
              Text(
                '${duration.toStringAsFixed(1)}',
                style: TextStyle(
                  color: kPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: kPrimaryLight), // Timer icon
              SizedBox(width: 8),
              Text(
                timeString,
                style: TextStyle(
                  color: kPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              transcription.length > 150
                  ? '${transcription.substring(0, 150)}...'
                  : transcription,
              style: TextStyle(color: kPrimaryLight.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
