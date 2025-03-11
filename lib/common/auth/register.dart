import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../styles/color.dart';
import '../../utilis/constant.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();

  String responseMessage = "Press the button to fetch data";
  String? _selectedRole;

  Future<void> registerUser() async {
    final url = Uri.parse('${rOOT}add_user');

    if (_selectedRole == null) {
      // Show error if no role is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'phone': _phone,
          'password': _password,
          'username': _name,
          'role': _selectedRole
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          responseMessage = data['message'];
        });

        // Navigate to home screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          responseMessage = error['error'] ?? 'Registration failed!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseMessage)),
        );
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Failed to connect to Flask server';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
    }
  }

  bool _isValidEmail(String email) => RegExp(emailPattern).hasMatch(email);

  bool _isValidPhone(String phone) => RegExp(phonePattern).hasMatch(phone);

  String? _email, _password, _phone, _name;

  @override
  Widget build(BuildContext context) {
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Background
                  Stack(
                    children: [
                      Image.asset(
                        foodregBg,
                        height: 250,
                        width: width,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 250,
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

                  // Signup Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      sigUp,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Email Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      onSaved: (val) => _email = val,
                      validator: (email) {
                        if (email == null || email.trim().isEmpty) {
                          return 'Please enter Email ID';
                        } else if (!_isValidEmail(email)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        prefixIcon: Icon(Icons.email, color: secondaryColor),
                        labelText: "Email ID",
                        labelStyle: TextStyle(color: secondaryColor),
                      ),
                    ),
                  ),

                  // Username Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      onSaved: (val) => _name = val,
                      validator: (user) {
                        if (user == null || user.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        prefixIcon: Icon(Icons.supervised_user_circle,
                            color: secondaryColor),
                        labelText: "Username",
                        labelStyle: TextStyle(color: secondaryColor),
                      ),
                    ),
                  ),

                  // Phone Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      onSaved: (val) => _phone = val,
                      validator: (phone) {
                        if (phone == null || phone.trim().isEmpty) {
                          return 'Please enter Phone Number';
                        } else if (!_isValidPhone(phone)) {
                          return 'Please enter a valid Phone Number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        prefixIcon: Icon(Icons.phone, color: secondaryColor),
                        labelText: "Phone Number",
                        labelStyle: TextStyle(color: secondaryColor),
                      ),
                    ),
                  ),

                  // Password Input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextFormField(
                      obscureText: true,
                      onSaved: (val) => _password = val,
                      validator: (password) {
                        if (password == null || password.isEmpty) {
                          return 'Please enter Password';
                        } else if (password.length < 6 ||
                            password.length > 15) {
                          return 'Password must be 6-15 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        prefixIcon:
                            Icon(Icons.lock_open, color: secondaryColor),
                        labelText: "Password",
                        labelStyle: TextStyle(color: secondaryColor),
                      ),
                    ),
                  ),

                  //Select role
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Select role",
                          style: TextStyle(color: secondaryColor),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = '1';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedRole == '1'
                                    ? secondaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: _selectedRole == '1'
                                        ? Colors.white
                                        : secondaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20), // Add gap here
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = '2';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedRole == '2'
                                    ? secondaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: _selectedRole == '2'
                                        ? Colors.white
                                        : secondaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20), // Add another gap here
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = '3';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedRole == '3'
                                    ? secondaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.delivery_dining,
                                    color: _selectedRole == '3'
                                        ? Colors.white
                                        : secondaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Signup Button
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: SizedBox(
                        width: width * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              registerUser();
                            }
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Login Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text("Login"),
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
