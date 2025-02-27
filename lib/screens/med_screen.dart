import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class MedScreen extends StatefulWidget {
  const MedScreen({super.key});

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
    final response = await http.get(Uri.parse('http://192.168.223.154:8000/files/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        files = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Failed to fetch files: ${response.reasonPhrase}");
    }
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final uri = Uri.parse('http://192.168.223.154:8000/upload/');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      print('File uploaded successfully');
      fetchFiles();
    } else {
      print('Failed to upload file');
    }
  }

  Future<void> downloadFile(String fileId, String filename) async {
    final response = await http.get(Uri.parse('http://192.168.223.154:8000/download/$fileId'));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      // Save to device
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/$filename');
      await file.writeAsBytes(bytes);

      print("File saved to: ${file.path}");
      OpenFilex.open(file.path);
    } else {
      print('Failed to download file');
    }
  }

  Future<void> deleteFile(String fileId) async {
    final response = await http.delete(Uri.parse('http://192.168.223.154:8000/delete/$fileId'));

    if (response.statusCode == 200) {
      print('File deleted successfully');
      fetchFiles();
    } else {
      print('Failed to delete file');
    }
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
                  final isPdf = file['name'].toString().toLowerCase().endsWith('.pdf');

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isPdf ? Icons.picture_as_pdf : Icons.image,
                        color: isPdf ? Colors.red : Colors.blue,
                      ),
                      title: Text(file['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => downloadFile(file['id'], file['name']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteFile(file['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
