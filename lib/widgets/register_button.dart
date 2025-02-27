import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;  // <-- Add this

  const RegisterButton({
    super.key,
    required this.onPressed,
    required this.text,  // <-- Initialize here
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Center(
        child: Text(
          text,  // <-- This was missing
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
