import 'package:flutter/material.dart';

class WorkedDashboard extends StatefulWidget {
  const WorkedDashboard({super.key});

  @override
  State<WorkedDashboard> createState() => _WorkedDashboardState();
}

class _WorkedDashboardState extends State<WorkedDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Worker screen'),
      ),
    );
  }
}
