import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onScanPressed;
  final VoidCallback onHomePressed;
  final VoidCallback onMedPressed;
  final VoidCallback onLogoutPressed;
  final VoidCallback onChatPressed;


  const BottomNavBar({
    Key? key,
    required this.onScanPressed,
    required this.onHomePressed,
    required this.onMedPressed,
    required this.onLogoutPressed,
    required this.onChatPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color(0xFF0D244A), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: onHomePressed, 
          ),

          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            onPressed: onMedPressed, 
          ),

          const SizedBox(width: 110), 

           IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: onChatPressed, 
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogoutPressed, 
          ),
        ],
      ),
    );
  }
}
