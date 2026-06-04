import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_theme.dart';
import 'package:rainfall_app/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const RainfallApp());
}

class RainfallApp extends StatelessWidget {
  const RainfallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rainfall Monitor',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}