import '../models/task_model.dart';
import '../utilis/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  // Firebase implementation (commented out)
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final String _collection = 'tasks';

  // Singleton pattern
  static final TaskService _instance = TaskService._internal();

  factory TaskService() {
    return _instance;
  }

  TaskService._internal();

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      // Firebase implementation (commented out)
      // final snapshot = await _firestore.collection(_collection).get();
      // return snapshot.docs
      //     .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
      //     .toList();

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${rOOT}get_tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Print response for debugging
        print('Response body: ${response.body}');

        // Handle both array and object format responses
        final dynamic decodedJson = json.decode(response.body);
        List<dynamic> tasksJson;

        if (decodedJson is List) {
          // Direct array format
          tasksJson = decodedJson;
        } else if (decodedJson is Map<String, dynamic>) {
          // Object with tasks field
          if (decodedJson['tasks'] == null) {
            print('Tasks field is null in response');
            return [];
          }
          tasksJson = decodedJson['tasks'] as List<dynamic>;
        } else {
          print('Unknown response format: ${decodedJson.runtimeType}');
          return [];
        }

        // Map to Task objects with error handling for each item
        final tasks = <Task>[];
        for (var taskJson in tasksJson) {
          try {
            final task = Task.fromJson(taskJson);
            tasks.add(task);
          } catch (e) {
            print('Error parsing task: $e');
            print('Task JSON: $taskJson');
          }
        }
        return tasks;
      } else {
        print('Failed to load tasks: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load tasks: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  // Get task by ID
  Future<Task> getTaskById(String taskId) async {
    try {
      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${rOOT}get_task/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Print response for debugging
        print('Task response body: ${response.body}');

        final dynamic decodedJson = json.decode(response.body);
        Map<String, dynamic> taskJson;

        if (decodedJson is Map<String, dynamic>) {
          if (decodedJson.containsKey('task')) {
            taskJson = decodedJson['task'];
          } else {
            // The response might be the task object directly
            taskJson = decodedJson;
          }
          return Task.fromJson(taskJson);
        } else {
          throw Exception('Invalid response format for task');
        }
      } else {
        print('Failed to load task: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load task: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load task: $e');
      throw Exception('Failed to load task: $e');
    }
  }

  // Update task status
  Future<bool> updateTaskStatus(String taskId, String status) async {
    try {
      // Firebase implementation (commented out)
      // await _firestore.collection(_collection).doc(taskId).update({
      //   'status': status,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}update_task_status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'task_id': taskId,
          'status': status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating task status: $e');
    }
  }

  // Accept task (for workers)
  Future<bool> acceptTask(String taskId, String workerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}accept_task'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'task_id': taskId,
          'worker_id': workerId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error accepting task: $e');
    }
  }

  // Complete task (for workers)
  Future<bool> completeTask(String taskId, String workerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}complete_task'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'task_id': taskId,
          'worker_id': workerId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error completing task: $e');
    }
  }

  // Update tracking information
  Future<bool> updateTracking(
      String taskId,
      String status,
      String? trackingNumber,
      String? carrier,
      DateTime? estimatedDelivery) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final Map<String, dynamic> body = {
        'task_id': taskId,
        'status': status,
      };

      if (trackingNumber != null) body['tracking_number'] = trackingNumber;
      if (carrier != null) body['carrier'] = carrier;
      if (estimatedDelivery != null)
        body['estimated_delivery'] = estimatedDelivery.toIso8601String();

      final response = await http.post(
        Uri.parse('${rOOT}update_tracking'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating tracking: $e');
    }
  }

  // Assign task to worker
  Future<bool> assignTask(String taskId, String workerId) async {
    try {
      // Firebase implementation (commented out)
      // await _firestore.collection(_collection).doc(taskId).update({
      //   'workerId': workerId,
      //   'status': 'assigned',
      //   'assignedAt': FieldValue.serverTimestamp(),
      // });

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}assign_task'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'task_id': taskId,
          'worker_id': workerId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to assign task: $e');
    }
  }

  // Get tasks by worker ID
  Future<List<Task>> getTasksByWorkerId(String workerId) async {
    try {
      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${rOOT}get_worker_tasks/$workerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Print response for debugging
        print('Worker tasks response body: ${response.body}');

        // Handle both array and object format responses
        final dynamic decodedJson = json.decode(response.body);
        List<dynamic> tasksJson;

        if (decodedJson is List) {
          // Direct array format
          tasksJson = decodedJson;
        } else if (decodedJson is Map<String, dynamic>) {
          // Object with tasks field or data field
          if (decodedJson.containsKey('tasks')) {
            tasksJson = decodedJson['tasks'] as List<dynamic>;
          } else if (decodedJson.containsKey('data')) {
            tasksJson = decodedJson['data'] as List<dynamic>;
          } else {
            print('Could not find tasks in response');
            return [];
          }
        } else {
          print('Unknown response format: ${decodedJson.runtimeType}');
          return [];
        }

        // Map to Task objects with error handling for each item
        final tasks = <Task>[];
        for (var taskJson in tasksJson) {
          try {
            final task = Task.fromJson(taskJson);
            tasks.add(task);
          } catch (e) {
            print('Error parsing worker task: $e');
            print('Task JSON: $taskJson');
          }
        }
        return tasks;
      } else {
        print('Failed to load worker tasks: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load worker tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load worker tasks: $e');
      throw Exception('Failed to load worker tasks: $e');
    }
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus(String status) async {
    try {
      // Firebase implementation (commented out)
      // final snapshot = await _firestore
      //     .collection(_collection)
      //     .where('status', isEqualTo: status)
      //     .get();
      // return snapshot.docs
      //     .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
      //     .toList();

      // HTTP implementation
      final tasks = await getAllTasks();
      return tasks.where((task) => task.status == status).toList();
    } catch (e) {
      throw Exception('Failed to load tasks by status: $e');
    }
  }
}
