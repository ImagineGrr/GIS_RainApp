import 'package:flutter/material.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/screens/state/state_dashboard_screen.dart';
import 'package:rainfall_app/screens/state/state_map_screen.dart';
import 'package:rainfall_app/screens/shared/role_profile_screen.dart';

class StateNavigationScreen extends StatefulWidget {
  final UserModel user;

  const StateNavigationScreen({super.key, required this.user});

  @override
  State<StateNavigationScreen> createState() => _StateNavigationScreenState();
}

class _StateNavigationScreenState extends State<StateNavigationScreen> {
  int currentIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      StateDashboardScreen(user: widget.user),
      StateMapScreen(user: widget.user),
      RoleProfileScreen(user: widget.user),
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
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'State Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
