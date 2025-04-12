import '../models/worker_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utilis/constant.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerService {
  // Firebase implementation (commented out)
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final String _collection = 'workers';

  // Get all workers
  Future<List<Worker>> getAllWorkers() async {
    try {
      // Firebase implementation (commented out)
      // final snapshot = await _firestore.collection(_collection).get();
      // return snapshot.docs
      //    .map((doc) => Worker.fromJson({...doc.data(), 'id': doc.id}))
      //    .toList();

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${rOOT}get_workers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> workersJson = data['workers'];
        return workersJson.map((json) => Worker.fromJson(json)).toList();
      } else {
        print(response.statusCode);
        throw Exception('Failed to load workers: ${response.statusCode}');
      }
    } catch (e) {
      print('error: $e');
      throw Exception('Failed to load workers: $e');
    }
  }

  // Get worker by ID
  Future<Worker> getWorkerById(String workerId) async {
    try {
      // Firebase implementation (commented out)
      // final doc = await _firestore.collection(_collection).doc(workerId).get();
      // if (!doc.exists) {
      //   throw Exception('Worker not found');
      // }
      // return Worker.fromJson({...doc.data()!, 'id': doc.id});

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${rOOT}get_worker/$workerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Worker.fromJson(data['worker']);
      } else {
        throw Exception('Failed to load worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load worker: $e');
    }
  }

  // Add new worker
  Future<String> addWorker(Worker worker) async {
    try {
      // Firebase implementation (commented out)
      // final docRef = await _firestore.collection(_collection).add(worker.toJson());
      // return docRef.id;

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}add_worker'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(worker.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['worker_id'];
      } else {
        throw Exception('Failed to add worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add worker: $e');
    }
  }

  // Update worker
  Future<void> updateWorker(String workerId, Worker worker) async {
    try {
      // Firebase implementation (commented out)
      // await _firestore
      //     .collection(_collection)
      //     .doc(workerId)
      //     .update(worker.toJson());

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${rOOT}update_worker/$workerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(worker.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update worker: $e');
    }
  }

  // Toggle worker status
  Future<void> toggleWorkerStatus(String workerId, bool isActive) async {
    try {
      // Firebase implementation (commented out)
      // await _firestore
      //     .collection(_collection)
      //     .doc(workerId)
      //     .update({'isActive': isActive});

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}toggle_worker_status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'worker_id': workerId,
          'is_active': isActive,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update worker status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update worker status: $e');
    }
  }

  // Get worker's assigned tasks
  Future<List<String>> getWorkerTasks(String workerId) async {
    try {
      // Firebase implementation (commented out)
      // final doc = await _firestore.collection(_collection).doc(workerId).get();
      // if (!doc.exists) {
      //   throw Exception('Worker not found');
      // }
      // final data = doc.data()!;
      // return (data['assignedTaskIds'] as List<dynamic>?)
      //        ?.map((e) => e as String)
      //        .toList() ??
      //    [];

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
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> taskIds = data['task_ids'];
        return taskIds.map((id) => id.toString()).toList();
      } else {
        throw Exception('Failed to load worker tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load worker tasks: $e');
    }
  }

  // Assign task to worker
  Future<void> assignTaskToWorker(String workerId, String taskId) async {
    try {
      // Firebase implementation (commented out)
      // await _firestore.collection(_collection).doc(workerId).update({
      //   'assignedTaskIds': FieldValue.arrayUnion([taskId])
      // });

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}assign_task_to_worker'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'worker_id': workerId,
          'task_id': taskId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to assign task to worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to assign task to worker: $e');
    }
  }

  // Remove task from worker
  Future<void> removeTaskFromWorker(String workerId, String taskId) async {
    try {
      // Firebase implementation (commented out)
      // await _firestore.collection(_collection).doc(workerId).update({
      //   'assignedTaskIds': FieldValue.arrayRemove([taskId])
      // });

      // HTTP implementation
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${rOOT}remove_task_from_worker'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'worker_id': workerId,
          'task_id': taskId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to remove task from worker: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove task from worker: $e');
    }
  }
}
