import 'package:flutter/material.dart';

class SuggestionsScreen extends StatelessWidget {
  final String result;

  SuggestionsScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suggestions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            result,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
