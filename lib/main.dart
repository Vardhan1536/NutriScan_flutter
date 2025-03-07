import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/med_screen.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required to use async in main()

  final String? token = await getSavedToken();

  runApp(MyApp(initialScreen: token == null ? const LoginScreen() : MedScreen(token: token)));
}

Future<String?> getSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');  
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Reports App',
      theme: AppTheme.lightTheme,
      home: initialScreen,  // Start with either LoginScreen or MedScreen based on token
    );
  }
}
