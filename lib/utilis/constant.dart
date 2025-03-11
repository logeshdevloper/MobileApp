import 'package:flutter/material.dart';

const String appName = "POPS";
const String appSolgan = "Local snacks develeriy app";
const String foodBg = "assests/pops.png";
const String foodregBg = "assests/pops_register.png";
const String profilePlaceholder = "assets/profile_image.png";
const String login = "LOGIN";
const String sigUp = "Register";
const String fpassword = "Forget Password";
const String rOOT = 'http://192.168.192.81:39792/';
const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
const String phonePattern = r'^[0-9]{10}$';
List<Map<String, dynamic>> cartItems = [];
ValueNotifier<int> cartCountNotifier = ValueNotifier(cartItems.length);

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
