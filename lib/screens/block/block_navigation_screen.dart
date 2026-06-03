import 'package:flutter/material.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/screens/block/block_dashboard_screen.dart';
import 'package:rainfall_app/screens/block/block_map_screen.dart';
import 'package:rainfall_app/screens/block/block_stations_screen.dart';
import 'package:rainfall_app/screens/shared/role_profile_screen.dart';

class BlockNavigationScreen extends StatefulWidget {
  final UserModel user;

  const BlockNavigationScreen({super.key, required this.user});

  @override
  State<BlockNavigationScreen> createState() => _BlockNavigationScreenState();
}

class _BlockNavigationScreenState extends State<BlockNavigationScreen> {
  int currentIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      BlockDashboardScreen(user: widget.user),
      BlockMapScreen(user: widget.user),
      BlockStationsScreen(user: widget.user),
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
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Stations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
