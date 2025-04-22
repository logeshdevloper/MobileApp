import 'package:flutter/material.dart';
import '../../../../models/worker_model.dart';
import '../../../../services/worker_service.dart';
import '../../../../common/styles/color.dart';

class WorkerManagementScreen extends StatefulWidget {
  const WorkerManagementScreen({Key? key}) : super(key: key);

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen> {
  final WorkerService _workerService = WorkerService();
  bool _isLoading = true;
  List<Worker> _workers = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final workers = await _workerService.getAllWorkers();
      setState(() {
        _workers = workers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load workers: $e';
        _isLoading = false;
      });
    }
  }

  List<Worker> _getFilteredWorkers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _workers;

    return _workers.where((worker) {
      return worker.name.toLowerCase().contains(query) ||
          worker.id.toLowerCase().contains(query) ||
          worker.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWorkerDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search workers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: _isLoading
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
                              onPressed: _loadWorkers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildWorkerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerList() {
    final filteredWorkers = _getFilteredWorkers();

    if (filteredWorkers.isEmpty) {
      return const Center(
        child: Text('No workers found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredWorkers.length,
        itemBuilder: (context, index) {
          final worker = filteredWorkers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () => _showWorkerDetails(worker),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        worker.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatusChip(
                                'Tasks: ${worker.completedTasks}',
                                Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              _buildStatusChip(
                                worker.isActive ? 'Active' : 'Inactive',
                                worker.isActive ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showWorkerActions(worker),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showWorkerDetails(Worker worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(worker.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', worker.id),
            _buildDetailRow('Email', worker.email),
            _buildDetailRow('Phone', worker.phone),
            _buildDetailRow('Joined', worker.joinDate.toString()),
            _buildDetailRow('Status', worker.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow(
                'Completed Tasks', worker.completedTasks.toString()),
            _buildDetailRow(
                'Rating', '${worker.rating.toStringAsFixed(1)}/5.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  void _showWorkerActions(Worker worker) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Worker'),
              onTap: () {
                Navigator.pop(context);
                _showEditWorkerDialog(worker);
              },
            ),
            ListTile(
              leading: Icon(
                worker.isActive ? Icons.block : Icons.check_circle,
                color: worker.isActive ? Colors.red : Colors.green,
              ),
              title: Text(
                worker.isActive ? 'Deactivate Worker' : 'Activate Worker',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleWorkerStatus(worker);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('View Assigned Tasks'),
              onTap: () {
                Navigator.pop(context);
                _viewWorkerTasks(worker);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkerDialog() {
    // Implement add worker dialog
  }

  void _showEditWorkerDialog(Worker worker) {
    // Implement edit worker dialog
  }

  void _toggleWorkerStatus(Worker worker) {
    // Implement toggle worker status
  }

  void _viewWorkerTasks(Worker worker) {
    // Implement view worker tasks
  }
}
