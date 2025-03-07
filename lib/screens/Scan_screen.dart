import 'dart:convert';
import 'dart:io';
import 'package:demo/widgets/floating_snackbar.dart';
import 'package:demo/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ScanScreen extends StatefulWidget {
  final String token;

  const ScanScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? imageFile;
  bool isUploading = false;
  String? scanResult;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        scanResult = null;
      });
    }
  }

  Future<File?> _fetchMedicalReport() async {
    final response = await http.get(
      Uri.parse('http://192.168.192.154:8000/medical-report'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final reportFile = File('${tempDir.path}/medical_report.pdf');
      await reportFile.writeAsBytes(response.bodyBytes);
      return reportFile;
    } else {
      FloatingSnackbar.show(
        context,
        'Failed to fetch medical report (Status ${response.statusCode})',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        duration: Duration(seconds: 5),
      );
      return null;
    }
  }

  Future<void> _sendToBackend() async {
    if (imageFile == null) {
      FloatingSnackbar.show(context, 'Please select an image first',
      backgroundColor: Colors.yellow.shade200,
      textColor: Colors.black,
      duration: Duration(seconds: 5),
  );
      return;
    }

    setState(() {
      isUploading = true;
      scanResult = null;
    });

    try {
      final medical = await _fetchMedicalReport();
      if (medical == null) {
        setState(() {
          isUploading = false;
        });
        return;
      }

      final uri = Uri.parse('http://192.168.192.154:8000/food-scan');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile!.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('medical', medical.path),
      );
      request.headers['Authorization'] = 'Bearer ${widget.token}';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        setState(() {
          scanResult = jsonEncode(responseData['result']);
        });

        FloatingSnackbar.show(
          context,
          'Image and Medical reports processed Successfully!!',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          duration: Duration(seconds: 5),
        );
      } else {
        FloatingSnackbar.show(
            context,
            "Failed to process files (Status ${response.statusCode})",
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
            duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      FloatingSnackbar.show(
          context,
          'Error Communicating with the server, try again later',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          duration: Duration(seconds: 5),
        );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  String _cleanScanResult(String? result) {
    if (result == null || result.isEmpty) return "No result found.";

    // Clean unwanted characters and make it pretty
    return result
        .replaceAll(r'\n', '\n') // Convert literal \n to actual newlines
        .replaceAll('\\n', '\n') // Handle double escapes
        .replaceAll(r'\t', ' ') // Replace tabs with space
        .replaceAll('\\t', ' ')
        .replaceAll(RegExp(r'[\*\_\-\\]'), '') // Remove *, _, -, \
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n') // Remove excess blank lines
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3EF),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Fixed Header
            const SizedBox(height: 50),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scan",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D244A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Scrollable Area - Wrap rest of content in Expanded + SingleChildScrollView
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFF0D244A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 50),
            const Spacer(),
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

      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFF1AA8F),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            // Add scan action here
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // const SizedBox(height: 50),
        // const Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       "Scan",
        //       style: TextStyle(
        //         fontSize: 22,
        //         fontWeight: FontWeight.bold,
        //         color: Color(0xFF0D244A),
        //       ),
        //     ),
        //   ],
        // ),
        if (imageFile != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture"),
              onPressed: () => _pickImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1AA8F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text("Gallery"),
              onPressed: () => _pickImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1AA8F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon:
              isUploading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.cloud_upload),
          label:
              isUploading
                  ? const Text("Processing...")
                  : const Text("Upload & Process"),
          onPressed: isUploading ? null : _sendToBackend,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D244A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),
        if (scanResult != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Scan Result",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D244A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _cleanScanResult(scanResult),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Bottom App Bar - Same style as MedScreen
}
