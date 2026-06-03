import 'package:flutter/material.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/screens/field/home_screen.dart';
import 'package:rainfall_app/screens/field/gis_screen.dart';
import 'package:rainfall_app/screens/field/queue_screen.dart';
import 'package:rainfall_app/screens/field/profile_screen.dart';

class FieldNavigationScreen extends StatefulWidget {
  final UserModel user;

  const FieldNavigationScreen({super.key, required this.user});

  @override
  State<FieldNavigationScreen> createState() => _FieldNavigationScreenState();
}

class _FieldNavigationScreenState extends State<FieldNavigationScreen> {
  int currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      FieldHomeScreen(user: widget.user),
      GisScreen(user: widget.user),
      QueueScreen(user: widget.user),
      FieldProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'GPS'),
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}