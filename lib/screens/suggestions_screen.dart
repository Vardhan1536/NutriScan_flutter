import 'package:flutter/material.dart';

class SuggestionScreen extends StatelessWidget {
  final Map<String, dynamic> scanResult;

  const SuggestionScreen({super.key, required this.scanResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Scan Suggestions"),
        backgroundColor: const Color(0xFF0D244A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Scan Result",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ...scanResult.entries.map(
            (entry) => ListTile(
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(entry.value.toString()),
              leading: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
