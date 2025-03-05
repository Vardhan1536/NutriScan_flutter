import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ScanScreen extends StatefulWidget {
  final String token; // JWT token for authorization

  const ScanScreen({super.key, required this.token});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? imageFile;
  bool isUploading = false;
  String? scanResult;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
          scanResult = null; // Reset previous result
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image.")),
      );
    }
  }

  Future<File?> _fetchMedicalReport() async {
    try {
      final reportUri = Uri.parse('http://192.168.255.154:8000/medical-report');

      final response = await http.get(
        reportUri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch medical report (Status ${response.statusCode})')),
        );
        return null;
      }

      // Save report to temporary file
      final tempDir = await getTemporaryDirectory();
      final reportFile = File('${tempDir.path}/medical_report.pdf');
      await reportFile.writeAsBytes(response.bodyBytes);

      return reportFile;
    } catch (e) {
      print("Error fetching medical report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching medical report.")),
      );
      return null;
    }
  }

  Future<void> _sendToBackend() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    setState(() {
      isUploading = true;
      scanResult = null; // Reset scan result
    });

    try {
      final medical = await _fetchMedicalReport();
      if (medical == null) {
        setState(() {
          isUploading = false;
        });
        return; // If report fetch failed, don't proceed
      }

      final uri = Uri.parse('http://192.168.255.154:8000/food-scan');

      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', imageFile!.path));
      request.files.add(await http.MultipartFile.fromPath('medical', medical.path));

      request.headers['Authorization'] = 'Bearer ${widget.token}';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        setState(() {
          scanResult = jsonEncode(responseData['result']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image and medical report processed successfully!")),
        );
      } else {
        print('Failed response: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to process files (Status ${response.statusCode})")),
        );
      }
    } catch (e) {
      print("Error sending files: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error communicating with the server.")),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Screen")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera),
                label: const Text("Capture Image"),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text("Pick from Gallery"),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
              if (imageFile != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.file(imageFile!, height: 200),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload),
                        label: isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Upload Image & Report"),
                        onPressed: isUploading ? null : _sendToBackend,
                      ),
                    ],
                  ),
                ),
              if (scanResult != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Scan Result: $scanResult",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
