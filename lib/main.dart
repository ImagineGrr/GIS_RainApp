import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rainfall_app/theme/app_theme.dart';
import 'package:rainfall_app/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://tznyfheygwlhzillxdew.supabase.co',
    anonKey: 'sb_publishable_ljuAZQI7EVwJsVK7hxgx_w_YZs98Uqc',
  );

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