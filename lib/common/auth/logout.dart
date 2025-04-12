import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // Clear session data
  await prefs.clear();

  // Navigate to LoginScreen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}
