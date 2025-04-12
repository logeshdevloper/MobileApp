import 'package:flutter/material.dart';

const String appName = "POPS";
const String appSolgan = "Local snacks develeriy app";
const String foodBg = "assets/pops.png";
const String foodregBg = "assets/pops_register.png";
const String welcomeBg = "assets/welcome_png_3.jpg";
const String welcome1 = "assets/wimage_1.jpg";
const String welcome2 = "assets/wimage_2.jpg";
const String welcome3 = "assets/wimage_3.jpg";
const String profilePlaceholder = "assets/profile_image.png";

// Authentication Labels
const String login = "LOGIN";
const String sigUp = "Register";
const String fpassword = "Forget Password";
const String rOOT = 'http://192.168.59.81:39792/';
const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
const String phonePattern = r'^[0-9]{10}$';
List<Map<String, dynamic>> cartItems = [];
ValueNotifier<int> cartCountNotifier = ValueNotifier(cartItems.length);

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
