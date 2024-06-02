import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<String?> uploadUserInfo(Map<String, dynamic> userMap) async {
    try {
      var usersCollection = FirebaseFirestore.instance.collection('users');

      // Get all users and print their emails
      var allUsers = await usersCollection.get();
      for (var element in allUsers.docs) {
        print(element.data()['email']);
      }
      print('finished printing the emails');

      // Check if user already exists
      var existingUser = await usersCollection
          .where('email', isEqualTo: userMap['email'])
          .get();

      if (existingUser.docs.isEmpty) {
        // Add new user
        await usersCollection.doc(userMap['email']).set(userMap);
        print('User added');
      } else {
        print('User already exists');
      }

      // Whether new or existing user, get and return status
      var status =
          await getStudentTeacherStatus(userMap['email'], userMap['name']);
      print("Value being returned: $status");
      return status;
    } catch (e) {
      print('An error occurred: $e');
      return null;
    }
  }

  updateUserLanguage(String email, String language) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .set({'language': language}, SetOptions(merge: true));
  }

  getUserLanguage(String email) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .get()
        .then((value) {
      return value.data()!['language'];
    });
  }

  // uploadUserInfo(userMap) async {
  //   await FirebaseFirestore.instance.collection('users').get().then((value) {
  //     value.docs.forEach((element) {
  //       try {
  //         print(element.data()['email']);
  //       } catch (e) {
  //         print('error: $e');
  //       }
  //     });
  //   });

  //   print('finished printing the emails');

  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('email', isEqualTo: userMap['email'])
  //       .get()
  //       .catchError((error) {
  //     print('the error is: $error');
  //   }).then((data) async {
  //     // print('the data.docs[0] is ${data.docs[0].data()}');
  //     if (data.docs.isEmpty) {
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userMap['email'])
  //           .set(userMap)
  //           .then((value) {
  //         print('User added');

  //         return getStudentTeacherStatus(userMap['email'], userMap['name'])
  //             .then((value) {
  //           return value;
  //         });
  //       }).catchError((error) {
  //         print(error);
  //       });
  //     } else {
  //       print('User already exists');
  //       // return 'user already exists';
  //       return getStudentTeacherStatus(userMap['email'], userMap['name'])
  //           .then((value) {
  //         print("Value being returned when user already exists: $value");
  //         return value;
  //       });
  //     }
  //   }).catchError((error) {
  //     print('the error after: $error');
  //   });
  // }

  Future<void> uploadTranscription(String transcription, String username,
      String email, String title, double duration) async {
    // Go into the collection 'email' and create a new collection 'transcriptions' and add a map with the transcription
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('transcriptions')
        .add({
      'transcription': transcription,
      'quizJSON': '',
      'keyterms': '',
      'summary': '',
      'notes': '',
      'title': title,
      'duration': duration,
    }).then((value) {
      print('Transcription added');
    }).catchError((error) {
      print('Error adding transcription: $error');
    });
  }

  // uploadTranscriptionForClass(
  //     String transcription,
  //     String username,
  //     String email,
  //     String title,
  //     double duration,
  //     String classCode,
  //     int epoch) async {
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(email)
  //       .collection('classes')
  //       .doc(classCode)
  //       .collection('transcriptions')
  //       .add({
  //     'transcription': transcription,
  //     'quizJSON': '',
  //     'keyterms': '',
  //     'summary': '',
  //     'notes': '',
  //     'title': title,
  //     'duration': duration,
  //     'time': epoch,
  // }).then((value) {
  //   print('Transcription added');
  // }).catchError((error) {
  //   print('Error adding transcription: $error');
  // });
  // }

  uploadTranscriptionForClass(
      String transcription,
      String username,
      String email,
      String title,
      double duration,
      String classCode,
      int epoch) async {
    await FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .add({
      'transcription': transcription,
      'quizJSON': '',
      'keyterms': '',
      'summary': '',
      'notes': '',
      'title': title,
      'duration': duration,
      'time': epoch,
    }).then((value) {
      print('Transcription added');
    }).catchError((error) {
      print('Error adding transcription: $error');
    });
  }

  deleteClass(String ID) {
    FirebaseFirestore.instance.collection('allClasses').doc(ID).delete();
  }

  // getTranscripts(String email) async {
  getTranscripts(String email) async {
    // Check if the 'transcriptions' collection exists for the user with the email
    var collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('transcriptions');
    var querySnapshot = await collectionRef.get().catchError((error) {
      print('Error checking if transcriptions exist: $error');
    });
    if (querySnapshot != null && querySnapshot.docs.isEmpty) {
      // If the collection does not exist or is empty, return null
      return null;
    } else {
      // If the collection exists, return the snapshots
      return collectionRef.snapshots().handleError((error) {
        print('Error getting transcriptions: $error');
      });
    }
  }

  getClassTranscripts(String email, String classCode) async {
    // return FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(email)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .orderBy('time', descending: true)
    //     .snapshots()
    //     .handleError((error) {
    //   print('Error getting transcriptions: $error');
    // });
    return FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .orderBy('time', descending: true)
        .snapshots()
        .handleError((error) {
      print('Error getting transcriptions for class $classCode: $error');
    });
  }

  getTeacherTranscripts(String email) async {
    // Get all the transcriptions from the user with the email
    return FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('classes')
        .snapshots()
        .handleError((error) {
      print('Error getting transcriptions: $error');
    });
  }

  // getClassesThatIAmEnrolledIn(String email, String userName) async {
  //   final userEmailWithName = '$email***$userName';
  //   final transcriptionsStreams =
  //       <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

  //   // Get a stream of all users
  //   final usersStream =
  //       FirebaseFirestore.instance.collection('users').snapshots();

  //   // For each user, check their classes collection
  //   await for (var userSnapshot in usersStream) {
  //     for (var userDoc in userSnapshot.docs) {
  //       // Get a stream of classes for this user
  //       final classesStream =
  //           userDoc.reference.collection('classes').snapshots();

  //       // For each class, check if the user is enrolled
  //       await for (var classSnapshot in classesStream) {
  //         for (var classDoc in classSnapshot.docs) {
  //           final studentEmails =
  //               classDoc.data()['studentEmails'] as List<dynamic>;
  //           if (studentEmails.contains(userEmailWithName)) {
  //             // If the user is enrolled, add the transcriptions stream to the list
  //             transcriptionsStreams.add(
  //                 classDoc.reference.collection('transcriptions').snapshots());
  //           }
  //         }
  //       }
  //     }
  //   }

  //   // Combine all transcriptions streams into a single stream
  //   final combinedStream = StreamGroup.merge(transcriptionsStreams).asBroadcastStream();

  //   return combinedStream;
  // }

  // getClassesThatIAmEnrolledIn(String email, String userName) async {
  //   final userEmailWithName = '$email***$userName';
  //   final classesStreams = <Stream<QuerySnapshot<Map<String, dynamic>>>>[];

  //   // Get a stream of all users
  //   final usersStream =
  //       FirebaseFirestore.instance.collection('users').snapshots();

  //   // print out the names of the users in the strea
  //   // await for (var userSnapshot in usersStream) {
  //   //   for (var userDoc in userSnapshot.docs) {
  //   //     print(userDoc.data()['name']);
  //   //   }
  //   // }

  //   // For each user, check their classes collection
  //   await for (var userSnapshot in usersStream) {
  //     for (var userDoc in userSnapshot.docs) {
  //       // print name of user
  //       print(userDoc.data()['name']);
  //       // Get a stream of classes for this user
  //       final classesStream =
  //           userDoc.reference.collection('classes').snapshots();

  //       // For each class, check if the user is enrolled
  //       await for (var classSnapshot in classesStream) {
  //         for (var classDoc in classSnapshot.docs) {
  //           final studentEmails =
  //               classDoc.data()['studentEmails'] as List<dynamic>;
  //           print(studentEmails);
  //           if (studentEmails.contains(userEmailWithName)) {
  //             // If the user is enrolled, add the class snapshots to the list
  //             // don't add the transcript stream, but just add the class in which the transcript is
  //             classesStreams.add(classesStream);
  //           } else {
  //             print('User not enrolled in this class');
  //           }
  //         }
  //       }
  //     }
  //   }

  //   // Combine all class streams into a single stream
  //   final combinedStream =
  //       StreamGroup.merge(classesStreams).asBroadcastStream();

  //   return combinedStream;
  // }

  // Future<Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>>
  //     getClassesThatIAmEnrolledIn(String email, String userName) async {
  //   final userEmailWithName = '$email***$userName';
  //   List<QueryDocumentSnapshot<Map<String, dynamic>>> classesList = [];

  //   // Get a snapshot of all users
  //   var usersSnapshot =
  //       await FirebaseFirestore.instance.collection('users').get();

  //   // Iterate over each user document
  //   for (var userDoc in usersSnapshot.docs) {
  //     print(userDoc.data()['name']); // Print name of user for debugging

  //     // Get a snapshot of classes for this user
  //     var classSnapshot = await userDoc.reference.collection('classes').get();
  //     for (var classDoc in classSnapshot.docs) {
  //       final studentEmails = classDoc.data()['studentEmails'] as List<dynamic>;
  //       if (studentEmails.contains(userEmailWithName)) {
  //         // Add the class document snapshot if the user is enrolled
  //         classesList.add(classDoc);
  //       } else {
  //         print('User not enrolled in this class');
  //       }
  //     }
  //   }

  //   // Create a stream from the list using a StreamController
  //   var controller =
  //       StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();
  //   controller.add(classesList); // Emit the list of classes
  //   controller.close(); // Close the stream after adding data

  //   return controller.stream;
  // }

  getClassesThatIAmEnrolledIn(
      String email, String userName, String studentStatus) async {
    if (studentStatus == 'teacher') {
      return FirebaseFirestore.instance
          .collection('allClasses')
          .where('teacherEmail', isEqualTo: email)
          .snapshots();
    }

    final userEmailWithName = '$email***$userName';

    // Assuming a simpler structure where all classes can be queried at once
    // This is a placeholder path and should be replaced by your actual path or query logic
    return FirebaseFirestore.instance
        .collection('allClasses')
        .where('studentEmails', arrayContains: userEmailWithName)
        .snapshots()
        .handleError((error) => print('Error fetching classes: $error'))
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      } else {
        print('returning snapshot for $email');
      }
      bool containsUserEmailWithName = snapshot.docs.any((doc) =>
          (doc.data()['studentEmails'] as List<dynamic>)
              .contains(userEmailWithName));
      if (!containsUserEmailWithName) {
        print("return null for $email");
        return null;
      }
      return snapshot;
    });
  }

  getLectureSummary(String email, String title, double duration) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        // get the summary field of the document
        .get()
        .then((value) {
      return value.docs[0].data()['summary'];
    });
  }

  getLectureKeyWords(
      String userEmail, String lectureTitle, double lectureDuration) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      return value.docs[0].data()['keyterms'];
    });
  }

  getLectureQuiz(
      String userEmail, String lectureTitle, double lectureDuration) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      return value.docs[0].data()['quizJSON'];
    });
  }

  getLectureNotes(
      String userEmail, String lectureTitle, double lectureDuration) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      return value.docs[0].data()['notes'];
    });
  }

  // getClassLectureSummary(
  //     String email, String title, double duration, String classCode) async {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(email)
  //       .collection('classes')
  //       .doc(classCode)
  //       .collection('transcriptions')
  //       .where('title', isEqualTo: title)
  //       .where('duration', isEqualTo: duration)
  //       .get()
  //       .then((value) {
  //     return value.docs[0].data()['summary'];
  //   });
  // }

  getClassLectureSummary(
      String email, String title, double duration, String classCode) async {
    return FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      return value.docs[0].data()['summary'];
    });
  }

  // getClassLectureKeyWords(
  //     String email, String title, double duration, String classCode) async {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(email)
  //       .collection('classes')
  //       .doc(classCode)
  //       .collection('transcriptions')
  //       .where('title', isEqualTo: title)
  //       .where('duration', isEqualTo: duration)
  //       .get()
  //       .then((value) {
  //     return value.docs[0].data()['keyterms'];
  //   });
  // }

  getClassLectureKeyWords(
      String email, String title, double duration, String classCode) async {
    return FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      return value.docs[0].data()['keyterms'];
    });
  }

  // getClassLectureQuiz(
  //     String email, String title, double duration, String classCode) async {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(email)
  //       .collection('classes')
  //       .doc(classCode)
  //       .collection('transcriptions')
  //       .where('title', isEqualTo: title)
  //       .where('duration', isEqualTo: duration)
  //       .get()
  //       .then((value) {
  //     return value.docs[0].data()['quizJSON'];
  //   });
  // }

  getClassLectureQuiz(
      String email, String title, double duration, String classCode) async {
    return FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      return value.docs[0].data()['quizJSON'];
    });
  }

  // getClassLectureNotes(
  //     String email, String title, double duration, String classCode) async {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(email)
  //       .collection('classes')
  //       .doc(classCode)
  //       .collection('transcriptions')
  //       .where('title', isEqualTo: title)
  //       .where('duration', isEqualTo: duration)
  //       .get()
  //       .then((value) {
  //     return value.docs[0].data()['notes'];
  //   });
  // }

  getClassLectureNotes(
      String email, String title, double duration, String classCode) async {
    return FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      return value.docs[0].data()['notes'];
    });
  }

  getStudentTeacherStatus(String userEmail, String userName) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: userName)
        .get()
        .then((value) {
      return value.docs[0].data()['isStudent'];
    });
  }

  uploadLectureSummary(String userEmail, String lectureTitle,
      double lectureDuration, String summary) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'summary': summary});
    });
  }

  uploadLectureKeyWords(String userEmail, String lectureTitle,
      double lectureDuration, String keyWords) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'keyterms': keyWords});
    });
  }

  uploadLectureQuiz(String userEmail, String lectureTitle,
      double lectureDuration, String quizJSON) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'quizJSON': quizJSON});
    });
  }

  uploadLectureNotes(String userEmail, String lectureTitle,
      double lectureDuration, String notes) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'notes': notes});
    });
  }

  deleteLecture(String email, String title, double duration) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      value.docs[0].reference.delete();
    });
  }

  uploadClassLectureNotes(String userEmail, String lectureTitle,
      double lectureDuration, String classCode, String notes) async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userEmail)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .where('title', isEqualTo: lectureTitle)
    //     .where('duration', isEqualTo: lectureDuration)
    //     .get()
    //     .then((value) {
    //   value.docs[0].reference.update({'notes': notes});
    // });
    // Find this class in the allClasses collection
    await FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'notes': notes});
    });
  }

  uploadClassLectureQuiz(String userEmail, String lectureTitle,
      double lectureDuration, String classCode, String quizJSON) async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userEmail)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .where('title', isEqualTo: lectureTitle)
    //     .where('duration', isEqualTo: lectureDuration)
    //     .get()
    //     .then((value) {
    //   value.docs[0].reference.update({'quizJSON': quizJSON});
    // });
    // Find this class in the allClasses collection
    await FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'quizJSON': quizJSON});
    });
  }

  uploadClassLectureKeyWords(String userEmail, String lectureTitle,
      double lectureDuration, String classCode, String keyWords) async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userEmail)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .where('title', isEqualTo: lectureTitle)
    //     .where('duration', isEqualTo: lectureDuration)
    //     .get()
    //     .then((value) {
    //   value.docs[0].reference.update({'keyterms': keyWords});
    // });
    // Find this class in the allClasses collection
    await FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'keyterms': keyWords});
    });
  }

  uploadClassLectureSummary(String userEmail, String lectureTitle,
      double lectureDuration, String classCode, String summary) async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userEmail)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .where('title', isEqualTo: lectureTitle)
    //     .where('duration', isEqualTo: lectureDuration)
    //     .get()
    //     .then((value) {
    //   value.docs[0].reference.update({'summary': summary});
    // });
    // Find this class in the allClasses collection
    await FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: lectureTitle)
        .where('duration', isEqualTo: lectureDuration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'summary': summary});
    });
  }

  deleteClassLecture(
      String email, String title, double duration, String classCode) async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(email)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .where('title', isEqualTo: title)
    //     .where('duration', isEqualTo: duration)
    //     .get()
    //     .then((value) {
    //   value.docs[0].reference.delete();
    // });
    // Find this class in the allClasses collection
    await FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      value.docs[0].reference.delete();
    });
  }

  saveObjectives(String email, String title, double duration, String classCode,
      List<String> objectives) async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(email)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .where('title', isEqualTo: title)
    //     .where('duration', isEqualTo: duration)
    //     .get()
    //     .then((value) {
    //   value.docs[0].reference.update({'objectives': objectives});
    //   // Set the notes to "" and the quizJSON to "" when the objectives are set
    //   value.docs[0].reference.update({'notes': ''});
    //   value.docs[0].reference.update({'quizJSON': ''});
    // });
    // Find this class in the allClasses collection
    await FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      value.docs[0].reference.update({'objectives': objectives});
      // Set the notes to "" and the quizJSON to "" when the objectives are set
      value.docs[0].reference.update({'notes': ''});
      value.docs[0].reference.update({'quizJSON': ''});
    });
  }

  getObjectives(String email, String title, double duration, String classCode) {
    // return FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(email)
    //     .collection('classes')
    //     .doc(classCode)
    //     .collection('transcriptions')
    //     .where('title', isEqualTo: title)
    //     .where('duration', isEqualTo: duration)
    //     .get()
    //     .then((value) {
    //   return value.docs[0].data()['objectives'];
    // });
    // Find this class in the allClasses collection
    return FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classCode)
        .collection('transcriptions')
        .where('title', isEqualTo: title)
        .where('duration', isEqualTo: duration)
        .get()
        .then((value) {
      return value.docs[0].data()['objectives'];
    });
  }

  updateStudentTeacherStatus(String email, String displayName, String role) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .set({'isStudent': role}, SetOptions(merge: true));
  }

  uploadClassInfo(Map<String, dynamic> classInfo) async {
    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(classInfo['teacherEmail'])
    //     .collection('classes')
    //     .doc(classInfo['ID'].toString())
    //     .set(classInfo)
    //     .then((value) {
    //   print('Class added');
    //   // Create a collection called allClasses and add the class to it
    //   FirebaseFirestore.instance
    //       .collection('allClasses')
    //       .doc(classInfo['ID'].toString())
    //       .set(classInfo);
    // }).catchError((error) {
    //   print('Error adding class: $error');
    // });
    // Create a collection called allClasses and add the class to it
    FirebaseFirestore.instance
        .collection('allClasses')
        .doc(classInfo['ID'].toString())
        .set(classInfo);
  }

  // Future<void> joinClass(
  //     String code, String email, String displayName, String ownerName) async {
  //   print(
  //       "Joining class with code: $code. With email $email. With name $displayName");

  //   try {
  //     // Get the document reference for the user with the given ownerName
  //     final userRef = FirebaseFirestore.instance
  //         .collection('users')
  //         .where('name', isEqualTo: ownerName)
  //         .limit(1)
  //         .get();

  //     // Get the document snapshot of the user
  //     final userSnapshot = await userRef.then((querySnapshot) =>
  //         querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null);

  //     if (userSnapshot != null) {
  //       // Get the document reference for the class with the given code
  //       final classRef = userSnapshot.reference.collection('classes').doc(code);

  //       // Update the 'studentEmails' field of the class document
  //       await classRef.update({
  //         'studentEmails': FieldValue.arrayUnion(['${email}***${displayName}'])
  //       });
  //     } else {
  //       print('User with name $ownerName not found');
  //     }
  //   } catch (e) {
  //     print('Error joining class: $e');
  //   }
  // }

  Future<void> joinClass(
      String code, String email, String displayName, String ownerName) async {
    try {
      // Find the class in allClasses collection
      final classRef =
          FirebaseFirestore.instance.collection('allClasses').doc(code);
      // Update the 'studentEmails' field of the class document
      await classRef.update({
        'studentEmails': FieldValue.arrayUnion(['${email}***${displayName}'])
      });
    } catch (e) {
      print('Error joining class: $e');
      throw e; // Rethrow the error to be handled by the caller if necessary
    }
  }
}
