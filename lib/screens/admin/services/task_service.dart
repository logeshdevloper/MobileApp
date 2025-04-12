import '../models/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../utilis/constant.dart';

class TaskService {
  Future<List<Task>> getTasks(String status) async {
    try {
      // API call to get all tasks
      final response = await http.get(
        Uri.parse('${rOOT}get_tasks'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allTasks = List<Task>.from(
          data['tasks'].map((task) => Task.fromJson(task)),
        );

        // Filter tasks by status on the client side
        // Only return tasks with the requested status
        if (status.isNotEmpty) {
          return allTasks.where((task) => task.status == status).toList();
        }

        return allTasks;
      } else {
        throw Exception(
            'Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task?> getTaskById(String taskId) async {
    try {
      // First get all tasks
      final allTasks = await getTasks('');

      // Find the task with the matching ID
      for (var task in allTasks) {
        if (task.id == taskId) {
          return task;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to load task details: $e');
    }
  }

  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    try {
      // API call to update task status
      final response = await http.put(
        Uri.parse('${rOOT}update_task_status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'task_id': taskId,
          'status': newStatus,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }
}
