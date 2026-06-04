import 'package:flutter/material.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/screens/district/district_dashboard_screen.dart';
import 'package:rainfall_app/screens/district/district_map_screen.dart';
import 'package:rainfall_app/screens/shared/role_profile_screen.dart';

class DistrictNavigationScreen extends StatefulWidget {
  final UserModel user;

  const DistrictNavigationScreen({super.key, required this.user});

  @override
  State<DistrictNavigationScreen> createState() => _DistrictNavigationScreenState();
}

class _DistrictNavigationScreenState extends State<DistrictNavigationScreen> {
  int currentIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      DistrictDashboardScreen(user: widget.user),
      DistrictMapScreen(user: widget.user),
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
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'GIS Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
