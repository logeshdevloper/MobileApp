import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/auth/welcome_screen.dart';
import '../screens/admin/admin_board.dart';
import '../screens/customer/cus_board.dart';
import '../screens/worker/worker_screen.dart';

Future<Widget> getInitialScreen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('userRole') ?? '';

    if (isLoggedIn) {
      if (role == 'admin') {
        return const AdmindashBoard();
      } else if (role == 'worker') {
        return const WorkerScreen();
      } else {
        return const CustomerScreen();
      }
    } else {
      return const WelcomeScreen();
    }
  } catch (e) {
    // Return a fallback screen if error occurs
    return Scaffold(
      body: Center(
        child: Text('Error: $e', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
