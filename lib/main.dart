import 'package:demo/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/med_screen.dart';
// import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'themes/app_theme.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async in main()

  final String? token = await getSavedToken();

  runApp(MyApp(initialRoute: token == null ? '/login' : '/home', token: token));
}

Future<String?> getSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? token;

  const MyApp({super.key, required this.initialRoute, required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Reports App',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute, // Start with login or med screen

      routes: {
        '/login': (context) => const LoginScreen(),
        '/med':(context) => MedScreen(token: token ?? ''), 
        '/home': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen(),
        '/scan': (context) => ScanScreen(token: token ?? ''), // ✅ Removed `const`
      },
    );
  }
}
