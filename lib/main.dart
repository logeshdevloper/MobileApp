import 'package:flutter/material.dart';
import 'services/auth_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading indicator with branding
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        } else if (snapshot.hasError) {
          // Error screen
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'An error occurred while loading the app!',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        } else {
          // Navigate to the determined screen
          return MaterialApp(
            home: snapshot.data,
            title: "Pops",
            theme: ThemeData(
              primarySwatch: Colors.orange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      BorderSide(color: Colors.blue.shade300, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }
}
