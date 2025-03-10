import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onScanPressed;
  final VoidCallback onHomePressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onLogoutPressed;

  const BottomNavBar({
    Key? key,
    required this.onScanPressed,
    required this.onHomePressed,
    required this.onProfilePressed,
    required this.onLogoutPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color(0xFF0D244A), // Primary Color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: onHomePressed, // Navigate to Home
          ),

          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            onPressed: onProfilePressed, // Navigate to Profile
          ),

          const SizedBox(width: 110), // Space for Floating Action Button

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogoutPressed, // Handle logout
          ),
        ],
      ),
    );
  }
}
