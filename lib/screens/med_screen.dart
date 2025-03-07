import 'package:demo/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scan_screen.dart';

class MedScreen extends StatefulWidget {
  final String token;

  const MedScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<MedScreen> createState() => _MedScreenState();
}

class _MedScreenState extends State<MedScreen> {
  List<Map<String, dynamic>> files = [];

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final response = await http.get(
      Uri.parse('http://192.168.192.154:8000/get-user-files'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        files = List<Map<String, dynamic>>.from(responseData['files']);
      });
    } else {
      print("Failed to fetch files: ${response.reasonPhrase}");
    }
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final uri = Uri.parse('http://192.168.192.154:8000/upload-medical-report');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    final response = await request.send();
    if (response.statusCode == 200) {
      print('File uploaded successfully');
      fetchFiles();
    } else {
      print('Failed to upload file');
    }
  }

  Future<void> downloadFile(String fileId, String filename) async {
    final response = await http.get(
      Uri.parse('http://192.168.192.154:8000/download-medical-report/$fileId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/$filename');
      await file.writeAsBytes(bytes);
      print("File saved to: ${file.path}");
    } else {
      print('Failed to download file');
    }
  }

  Future<void> deleteFile(String fileId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.192.154:8000/delete-medical-report/$fileId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      print('File deleted successfully');
      fetchFiles();
    } else {
      print('Failed to delete file');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Clear the saved token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void navigateToScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanScreen(token: widget.token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3EF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Medical Reports",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D244A), // Primary Color
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: uploadFile,
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1AA8F), // Soft Orange
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // List of Files
            Expanded(
              child:
                  files.isEmpty
                      ? const Center(child: Text('No reports uploaded yet.'))
                      : ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          final isPdf = file['filename']
                              .toString()
                              .toLowerCase()
                              .endsWith('.pdf');

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isPdf
                                            ? Colors.red.shade100
                                            : Colors.blue.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPdf
                                        ? Icons.picture_as_pdf
                                        : Icons.insert_drive_file,
                                    color: isPdf ? Colors.red : Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file['filename'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF0D244A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Uploaded: ${file['uploaded_at'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.download,
                                    color: Color(0xFF0D244A),
                                  ),
                                  onPressed:
                                      () => downloadFile(
                                        file['file_id'],
                                        file['filename'],
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFFD32F2F),
                                  ),
                                  onPressed: () => deleteFile(file['file_id']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFF0D244A), // Primary Color
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 50,
            ), // Space to balance floating button on the left

            const Spacer(), // Pushes logout icon to the far right

            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: Container(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFF1AA8F), // Soft Orange
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 30,
          ),
          onPressed: navigateToScanScreen, // This triggers the ScanPopup
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
