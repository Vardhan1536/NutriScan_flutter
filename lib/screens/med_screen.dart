import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'scan_screen.dart';  // Import the ScanScreen here

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
      Uri.parse('http://192.168.255.154:8000/get-user-files'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
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
    final uri = Uri.parse('http://192.168.255.154:8000/upload-medical-report');
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
      Uri.parse('http://192.168.255.154:8000/download-medical-report/$fileId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
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
      Uri.parse('http://192.168.255.154:8000/delete-medical-report/$fileId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('File deleted successfully');
      fetchFiles();
    } else {
      print('Failed to delete file');
    }
  }

  void navigateToScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanScreen(token: widget.token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final isPdf = file['filename'].toString().toLowerCase().endsWith('.pdf');

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                        color: isPdf ? Colors.red : Colors.blue,
                      ),
                      title: Text(file['filename']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => downloadFile(file['file_id'], file['filename']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteFile(file['file_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: navigateToScanScreen,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Go to Scan Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uploadFile,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Report'),
      ),
    );
  }
}
