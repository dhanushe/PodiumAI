import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lectifaisubmission/constants.dart';
import 'package:lectifaisubmission/database.dart';

class CreateClassScreen extends StatefulWidget {
  @override
  _CreateClassScreenState createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String _className = '';
  String _classDescription = '';

  DatabaseMethods databaseMethods = DatabaseMethods();

  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kPrimaryDark,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
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
                      "Create Class",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kPrimaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Class Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: kPrimaryGreen,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _className = value;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: kPrimaryGreen,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _classDescription = value;
                  },
                ),
                SizedBox(height: 16.0),
                // Drop down with different subjects
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    label: null,
                  ),
                  value: _selectedSubject,
                  items: <String>[
                    'Mathematics',
                    'Science',
                    'History',
                    'English',
                    'Art',
                    'Music',
                    'Physical Education',
                    'Computer Science',
                    'Foreign Language',
                    'Other',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child:
                          Text(value, style: TextStyle(color: kPrimaryPurple)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSubject = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a subject';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    print('Class Name: $_className');
                    print('Class Description: $_classDescription');
                    print('Subject: $_selectedSubject');
                    databaseMethods.uploadClassInfo({
                      'className': _className,
                      'classDescription': _classDescription,
                      'classSubject': _selectedSubject,
                      'teacherEmail': _firebaseAuth.currentUser!.email,
                      'studentEmails': [],
                      // random 6 digit ID
                      'ID': (100000 + Random().nextInt(900000)),
                    }).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Create Class'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
