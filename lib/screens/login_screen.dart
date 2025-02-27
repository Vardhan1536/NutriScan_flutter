import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/custom_textfield.dart';
import '../widgets/register_button.dart';
import '/screens/med_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
  final String username = usernameController.text;
  final String password = passwordController.text;

  final Uri url = Uri.parse('http://192.168.223.154:8000/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "username": username,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final token = responseData['access_token'];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login Successful!')),
    );

    // Navigate to MedScreen and pass the token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MedScreen(token: token)),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid credentials')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(controller: usernameController, labelText: 'Username'),
            const SizedBox(height: 16),
            CustomTextField(controller: passwordController, labelText: 'Password', obscureText: true),
            const SizedBox(height: 24),
            RegisterButton(
              onPressed: _login,
              text: 'Login',
            ),
          ],
        ),
      ),
    );
  }
}
