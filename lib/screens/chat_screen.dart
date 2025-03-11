import 'dart:convert';
import 'package:demo/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> chatHistory = [];
  TextEditingController _messageController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      chatHistory = prefs.getStringList('chat_history') ?? [];
    });
  }

  Future<void> _clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      chatHistory.clear();
    });
  }

  Future<void> _sendMessage(String userInput) async {
  if (userInput.isEmpty) return;

  setState(() {
    chatHistory.add("You: $userInput");
    isLoading = true;
  });

  final prefs = await SharedPreferences.getInstance();
  
  try {
    // Retrieve scan result (hist)
    String? scanResult = prefs.getString('scan_result');
    List<String> hist = scanResult != null ? [scanResult] : []; // Ensure hist is a list

    final response = await http.post(
      Uri.parse("http://192.168.50.154:8000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "hist": hist,  // Sending scan result as history
        "user_input": userInput
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        chatHistory.add("Bot: ${responseData['response']}");
      });
    } else {
      setState(() {
        chatHistory.add("Error: Failed to get response");
      });
    }

    await prefs.setStringList('chat_history', chatHistory);
  } catch (e) {
    setState(() {
      chatHistory.add("Error: Unable to connect to server");
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/logo.png', 
                      height: 40,
                    ),
                    SizedBox(width: 10),
                    const Text(
                      "Chat",
                      style: TextStyle(
                        color: Color(0xFF0D244A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF0D244A)),
                  onPressed: _clearChatHistory,
                ),
              ],
            ),
          ),

          // Chat History
          Expanded(
            child: chatHistory.isEmpty
                ? const Center(
                    child: Text(
                      "No chat history available.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            chatHistory[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                          leading: const Icon(Icons.history, color: Color(0xFF0D244A)),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                isLoading
                    ? CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(Icons.send, color: Color(0xFF0D244A)),
                        onPressed: () {
                          _sendMessage(_messageController.text);
                          _messageController.clear();
                        },
                      ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        onScanPressed: () => Navigator.pushNamed(context, '/scan'),
        onHomePressed: () => Navigator.pushNamed(context, '/home'),
        onMedPressed: () => Navigator.pushNamed(context, '/med'),
        onChatPressed: () => Navigator.pushNamed(context, '/chat'),
        onLogoutPressed: () => Navigator.pushNamed(context, '/login'),
      ),

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFF1AA8F), 
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
        onPressed: () => Navigator.pushNamed(context, '/scan'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
