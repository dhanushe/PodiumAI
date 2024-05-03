import 'package:flutter/material.dart';

class ErrorAuth extends StatelessWidget {
  const ErrorAuth({Key? key, required this.title, required this.centerText})
      : super(key: key);

  final String title;
  final String centerText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(centerText),
      ),
    );
  }
}
