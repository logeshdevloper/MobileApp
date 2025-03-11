import 'package:flutter/material.dart';
import 'package:pops/common/side-nav-bars/navbar_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/auth/login.dart';
import '../../common/styles/color.dart';
import 'admin_screens/adminSettings.dart';
import 'admin_screens/admin_overview.dart';
import 'admin_screens/product_section/product_manage_screen.dart';

class AdmindashBoard extends StatefulWidget {
  const AdmindashBoard({super.key});

  @override
  State<AdmindashBoard> createState() => _AdmindashBoardState();
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}

class _AdmindashBoardState extends State<AdmindashBoard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminOverview(),
    const ProductManagementScreen(),
    const AdminSettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar:
          AdminNavbar(currentIndex: _currentIndex, onTap: _onTabTapped),
    );
  }
}
