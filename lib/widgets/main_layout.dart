import 'package:flutter/material.dart';

class WidgetLayout extends StatelessWidget {
  final Widget child;

  const WidgetLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3EF), // Background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFF0D244A), // Primary Color
        child: const SizedBox(height: 50), // Space for floating button
      ),
      floatingActionButton: Container(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFF1AA8F), // Soft Orange
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
          onPressed: () {
            // You can optionally navigate to ScanScreen here if needed.
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
