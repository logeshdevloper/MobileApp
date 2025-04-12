import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../services/task_service.dart';
import 'task_assignment_screen.dart';
import '../../../common/styles/color.dart';

class TaskDetailScreen extends StatefulWidget {
  final String? taskId;
  final Task? task;

  const TaskDetailScreen({Key? key, this.taskId, this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  bool _isLoading = true;
  Task? _task;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // If task is directly provided, use it without API call
    if (widget.task != null) {
      setState(() {
        _task = widget.task;
        _isLoading = false;
      });
    } else if (widget.taskId != null) {
      // Otherwise load task from API using ID
      _loadTask();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No task or task ID provided';
      });
    }
  }

  Future<void> _loadTask() async {
    if (widget.taskId == null) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final task = await _taskService.getTaskById(widget.taskId!);
      setState(() {
        _task = task;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load task: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task #${_task?.orderNumber ?? ''}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadTask,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTaskInfo(),
                      const SizedBox(height: 16),
                      _buildActionsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTaskInfo() {
    if (_task == null) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Order Number', _task!.orderNumber),
            _buildInfoRow('Status', _task!.status),
            _buildInfoRow('Customer', _task!.customerId),
            _buildInfoRow('Address', _task!.deliveryAddress),
            _buildInfoRow('Items', '${_task!.orderItems.length}'),
            _buildInfoRow(
                'Total Amount', '\$${_task!.totalAmount.toStringAsFixed(2)}'),
            if (_task!.workerId != null)
              _buildInfoRow('Assigned To', _task!.workerId!),
            _buildInfoRow('Created',
                '${_task!.createdAt.day}/${_task!.createdAt.month}/${_task!.createdAt.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    if (_task == null) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_task!.status == 'pending')
              ElevatedButton.icon(
                onPressed: () => _navigateToAssignWorker(),
                icon: const Icon(Icons.person_add),
                label: const Text('Assign Worker'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (_task!.status == 'assigned' || _task!.status == 'in_progress')
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _reassignWorker(),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Reassign Worker'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_task!.status == 'assigned')
                    ElevatedButton.icon(
                      onPressed: () => _updateTaskStatus('cancelled'),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToAssignWorker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskAssignmentScreen(taskId: _task!.id),
      ),
    ).then((assigned) {
      if (assigned == true) {
        _loadTask();
      }
    });
  }

  void _reassignWorker() {
    _navigateToAssignWorker();
  }

  Future<void> _updateTaskStatus(String status) async {
    try {
      setState(() => _isLoading = true);

      await _taskService.updateTaskStatus(_task!.id, status);
      await _loadTask();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update task status: $e';
      });
    }
  }
}
