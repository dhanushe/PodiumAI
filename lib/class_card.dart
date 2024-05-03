import 'package:flutter/material.dart';
import 'package:lectifaisubmission/class.dart';
import 'dart:ui' as ui;

import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/lecture.dart';

class ClassCard extends StatelessWidget {
  final Class passedClass;

  const ClassCard({
    Key? key,
    required this.passedClass,
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
            passedClass.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryLight,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, color: kPrimaryLight), // Timer icon
              SizedBox(width: 8),
              Text(
                '${passedClass.studentEmails.length} students',
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
              passedClass.description,
              style: TextStyle(color: kPrimaryLight.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
