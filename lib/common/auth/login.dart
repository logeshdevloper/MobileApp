import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/admin/admin_board.dart';
import '../../screens/customer/cus_board.dart';
import '../../screens/worker/worker_board.dart';
import '../styles/color.dart';
import '../../utilis/constant.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  bool _isValidEmail(String email) {
    return RegExp(phonePattern).hasMatch(email);
  }

  String? _email, _password;

  //for login function
  String responseMessage = "Press the button to fetch data";

  Future<void> saveLoginSession(String role, String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userRole', role);
    await prefs.setString('customer_id', customerId);
  }

  Future<void> loginUser() async {
    final url = Uri.parse('${rOOT}login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _email,
          'password': _password,
        }),
      );

      if (response.statusCode == 200) {
        final navigate = jsonDecode(response.body);
        final role = navigate['user']['role'];
        final customerId =
            navigate['user']['id'].toString(); // Convert int to String
        saveLoginSession(role, customerId);

        if (role == 'admin') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AdmindashBoard()));
        } else if (role == 'worker') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => WorkedDashboard()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CustomerScreen()));
        }
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          responseMessage = error['message'] ?? 'Login failed!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseMessage)),
        );
      }
    } catch (e) {
      setState(() {
        responseMessage = "error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.amber.shade50,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image and Gradient Header
                  Stack(
                    children: [
                      Image.asset(
                        foodBg,
                        height: height * 0.40,
                        width: width,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: height * 0.40,
                        width: width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.amber.shade50,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // App Name and Slogan
                  Center(
                    child: Column(
                      children: [
                        Text(
                          appName,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          appSolgan,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Login Heading
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.3),
                            primaryColor.withOpacity(0.1),
                          ],
                        ),
                        border: Border(
                          left: BorderSide(color: primaryColor, width: 4),
                        ),
                      ),
                      child: Text(
                        "  $login  ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),

                  // Email Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      onSaved: (val) {
                        _email = val;
                      },
                      validator: (phone) {
                        if (phone == null || phone.trim().isEmpty) {
                          return 'Please enter phonenumber';
                        } else if (!_isValidEmail(phone)) {
                          return 'Please enter a valid phonenumber';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        prefixIcon:
                            Icon(Icons.phone_android, color: primaryColor),
                        labelText: "Phone number",
                        labelStyle:
                            TextStyle(color: primaryColor, fontSize: 18),
                      ),
                    ),
                  ),

                  // Password Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      obscureText: true,
                      onSaved: (val) {
                        _password = val;
                      },
                      validator: (password) {
                        if (password == null || password.isEmpty) {
                          return 'Please enter Password';
                        } else if (password.length < 6 ||
                            password.length > 15) {
                          return 'Password length Incorrect';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        prefixIcon: Icon(Icons.lock_open, color: primaryColor),
                        labelText: "Password",
                        labelStyle:
                            TextStyle(color: primaryColor, fontSize: 18),
                      ),
                    ),
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Add forgot password navigation logic
                      },
                      child: Text(fpassword,
                          style: TextStyle(color: primaryColor)),
                    ),
                  ),

                  // Login Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Center(
                      child: SizedBox(
                        width: width * 0.8,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              loginUser();
                            }
                          },
                          child: Text(
                            "Login to account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Create Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account ?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Register(),
                            ),
                          );
                        },
                        child: Text("Create account"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
