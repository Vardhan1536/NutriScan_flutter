import 'package:demo/widgets/floating_snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    final Uri url = Uri.parse('http://192.168.232.154:8000/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      FloatingSnackbar.show(
          context,
          'Login Successfull',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          duration: Duration(seconds: 5),
        );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MedScreen(token: token)),
      );
    } else {
      FloatingSnackbar.show(
          context,
          'Invalid Credentials',
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          duration: Duration(seconds: 5),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0D244A),
        width: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            // Ensures content fits smaller screens
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Welcome Box (Logo/Welcome Message)
                Container(
                  padding: const EdgeInsets.all(35),
                  height: 400,
                  decoration: BoxDecoration(
                    color: Color(0xFF0D244A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Lottie.asset(
                    'assets/animations/animation_welcome.json',
                    width: 350,
                    height: 350,
                  ),
                ),
                // Bottom Form Box
                Container(
                  padding: const EdgeInsets.all(30),
                  height: 450,
                  decoration: BoxDecoration(
                    color: Color(0xFFFDF3EF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username Field
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: TextField(
                          controller: usernameController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.black),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF0D244A),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.black),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF0D244A),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Remember Me and Forgot Password Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Remember Me',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0D244A),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Forgot Password clicked'),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0D244A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Login Button and Sign Up Link
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                onPressed: _login,
                                // onPressed: () {
                                //   Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => MedScreen(token: '',),
                                //     ),
                                //   );
                                // },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCEE8F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF0D244A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontFamily: 'Poppins'),
                                children: [
                                  const TextSpan(
                                    text: 'Don’t Have an Account? ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'SIGN UP',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D244A),
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            print('Redirect to Sign Up Page');
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
