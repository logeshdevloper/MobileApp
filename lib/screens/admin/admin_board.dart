import 'package:flutter/material.dart';
import 'widgets/task_list.dart';
import 'widgets/task_details.dart';
import 'widgets/admin_drawer.dart';

class AdmindashBoard extends StatefulWidget {
  const AdmindashBoard({super.key});

  @override
  State<AdmindashBoard> createState() => _AdmindashBoardState();
}

class _AdmindashBoardState extends State<AdmindashBoard> {
  String _selectedTaskId = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onTaskSelected(String taskId) {
    // Navigate to task details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetails(taskId: taskId),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Task Management',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: TaskList(
          onTaskSelected: _onTaskSelected,
          selectedTaskId: _selectedTaskId,
        ),
      ),
    );
  }
}
