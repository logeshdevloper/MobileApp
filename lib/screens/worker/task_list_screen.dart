import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import 'task_detail_screen.dart';
import '../../common/styles/color.dart';
import '../../common/widgets/empty_state.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskService _taskService = TaskService();
  bool _isLoading = true;
  List<Task> _allTasks = [];
  String? _errorMessage;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  String _sortOption = 'newest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // Clear search when tab changes
      if (_searchQuery.isNotEmpty) {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final tasks = await _taskService.getAllTasks();

      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tasks: $e';
        _isLoading = false;
      });
    }
  }

  List<Task> _getFilteredTasks(String status) {
    var filteredTasks =
        _allTasks.where((task) => task.status == status).toList();

    // Apply search filter if query exists
    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return task.orderNumber
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            task.deliveryAddress
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            task.customerId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'newest':
        filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filteredTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest_amount':
        filteredTasks.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'lowest_amount':
        filteredTasks.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
    }

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Task Manager'),
              elevation: 0,
              floating: true,
              pinned: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(104),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search by order #, address, or customer ID',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Available'),
                        Tab(text: 'Accepted'),
                        Tab(text: 'Completed'),
                      ],
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    _showSortOptions();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadTasks,
                ),
              ],
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskList(_getFilteredTasks('pending')),
                      _buildTaskList(_getFilteredTasks('accepted')),
                      _buildTaskList(_getFilteredTasks('completed')),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTasks,
        tooltip: 'Refresh tasks',
        backgroundColor: primaryColor,
        child: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTasks,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'No tasks found',
        message: 'There are no tasks available in this category.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          ).then((_) => _loadTasks());
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(task.status),
                    color: _getStatusColor(task.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Order #${task.orderNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      _getStatusLabel(task.status),
                      style: TextStyle(
                        color: _getStatusColor(task.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor:
                        _getStatusColor(task.status).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _getStatusColor(task.status).withOpacity(0.5),
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy – h:mm a')
                            .format(task.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Customer ID: ${task.customerId}',
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.deliveryAddress,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${task.orderItems.length} item(s)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        '\$${task.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(task),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(Task task) {
    switch (task.status.toLowerCase()) {
      case 'pending':
        return ElevatedButton.icon(
          onPressed: () {
            // Navigate to task details to accept
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            ).then((_) => _loadTasks());
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('View Details'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      case 'accepted':
        return ElevatedButton.icon(
          onPressed: () {
            // Navigate to task details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            ).then((_) => _loadTasks());
          },
          icon: const Icon(Icons.delivery_dining),
          label: const Text('Start Delivery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      case 'completed':
        return OutlinedButton.icon(
          onPressed: () {
            // Navigate to task details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            ).then((_) => _loadTasks());
          },
          icon: Icon(Icons.remove_red_eye, color: primaryColor),
          label: Text('View Details', style: TextStyle(color: primaryColor)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      default:
        return ElevatedButton(
          onPressed: () {
            // Navigate to task details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            ).then((_) => _loadTasks());
          },
          child: const Text('View Task'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'accepted':
        return Icons.thumb_up;
      case 'in_progress':
        return Icons.delivery_dining;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'accepted':
        return 'ACCEPTED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('newest', 'Newest First'),
              _buildSortOption('oldest', 'Oldest First'),
              _buildSortOption('highest_amount', 'Highest Amount'),
              _buildSortOption('lowest_amount', 'Lowest Amount'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _sortOption = value;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              _sortOption == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _sortOption == value ? primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    _sortOption == value ? FontWeight.bold : FontWeight.normal,
                color: _sortOption == value ? primaryColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
