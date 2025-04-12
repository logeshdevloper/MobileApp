import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../common/styles/color.dart';

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
    if (widget.task != null) {
      setState(() {
        _task = widget.task;
        _isLoading = false;
      });
    } else if (widget.taskId != null) {
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

  Future<void> _updateTaskStatus(String newStatus) async {
    if (_task == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final success = await _taskService.updateTaskStatus(_task!.id, newStatus);

      if (success) {
        await _loadTask();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task status updated to $newStatus'),
              backgroundColor: _getStatusColor(newStatus),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update task status';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task #${_task?.orderNumber ?? ''}'),
        elevation: 0,
        actions: [
          if (_task != null)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHelpDialog(),
            ),
        ],
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
              : _task == null
                  ? const Center(
                      child: Text('Task not found'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTask,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusSection(),
                            const SizedBox(height: 16),
                            _buildTimelineSection(),
                            const SizedBox(height: 16),
                            _buildInfoSection(),
                            const SizedBox(height: 16),
                            _buildItemsSection(),
                            const SizedBox(height: 24),
                            if (_task!.trackingInfo != null) ...[
                              _buildTrackingSection(),
                              const SizedBox(height: 24),
                            ],
                            _buildActionsSection(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(_task!.status).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(_task!.status),
                color: _getStatusColor(_task!.status),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusLabel(_task!.status),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: ${DateFormat('MMM d, yyyy – h:mm a').format(_task!.updatedAt ?? _task!.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_task!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _task!.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(_task!.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    final List<Map<String, dynamic>> timelineSteps = [
      {
        'title': 'Order Placed',
        'description': 'Customer placed the order',
        'time': _task!.createdAt,
        'isCompleted': true,
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'title': 'Accepted',
        'description': 'Order accepted by worker',
        'time': _task!.status == 'accepted' ||
                _task!.status == 'in_progress' ||
                _task!.status == 'completed'
            ? _task!.updatedAt
            : null,
        'isCompleted': _task!.status == 'accepted' ||
            _task!.status == 'in_progress' ||
            _task!.status == 'completed',
        'icon': Icons.thumb_up_outlined,
      },
      {
        'title': 'In Progress',
        'description': 'Order is being delivered',
        'time': _task!.status == 'in_progress' || _task!.status == 'completed'
            ? _task!.updatedAt
            : null,
        'isCompleted':
            _task!.status == 'in_progress' || _task!.status == 'completed',
        'icon': Icons.delivery_dining,
      },
      {
        'title': 'Completed',
        'description': 'Order has been delivered',
        'time': _task!.status == 'completed' ? _task!.updatedAt : null,
        'isCompleted': _task!.status == 'completed',
        'icon': Icons.check_circle_outline,
      },
    ];

    // If order is cancelled, show a different timeline
    if (_task!.status == 'cancelled') {
      return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Cancelled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cancelled on: ${DateFormat('MMM d, yyyy – h:mm a').format(_task!.updatedAt ?? _task!.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < timelineSteps.length; i++) ...[
              _buildTimelineItem(
                timelineSteps[i]['title'],
                timelineSteps[i]['description'],
                timelineSteps[i]['time'],
                timelineSteps[i]['isCompleted'],
                timelineSteps[i]['icon'],
                i < timelineSteps.length - 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    DateTime? time,
    bool isCompleted,
    IconData icon,
    bool showConnector,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color:
                    isCompleted ? primaryColor : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : Colors.grey,
                size: 18,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 40,
                color:
                    isCompleted ? primaryColor : Colors.grey.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? darkBlue : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (time != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('MMM d, yyyy – h:mm a').format(time),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              SizedBox(height: showConnector ? 20 : 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Order Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Order Number', _task!.orderNumber),
            _buildInfoRow('Created',
                DateFormat('MMM d, yyyy – h:mm a').format(_task!.createdAt)),
            _buildInfoRow('Customer ID', _task!.customerId),
            _buildInfoRow('Delivery Address', _task!.deliveryAddress),
            _buildInfoRow('Delivery Time', _task!.deliveryTime),
            _buildInfoRow('Payment Method', _task!.paymentMethod),
            _buildInfoRow(
                'Total Amount', '\$${_task!.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  '${_task!.orderItems.length} item(s)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _task!.orderItems.length,
              itemBuilder: (context, index) {
                final item = _task!.orderItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              spreadRadius: 1,
                            ),
                          ],
                          image: item.productImage != null
                              ? DecorationImage(
                                  image: NetworkImage(item.productImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.productImage == null
                            ? const Icon(Icons.image_not_supported_outlined,
                                color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Text(
                                item.notes!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${_task!.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingSection() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  'Tracking Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildInfoRow('Status', _task!.trackingInfo!.status),
            if (_task!.trackingInfo!.trackingNumber != null)
              _buildInfoRow(
                  'Tracking Number', _task!.trackingInfo!.trackingNumber!),
            if (_task!.trackingInfo!.carrier != null)
              _buildInfoRow('Carrier', _task!.trackingInfo!.carrier!),
            if (_task!.trackingInfo!.estimatedDelivery != null)
              _buildInfoRow(
                  'Estimated Delivery',
                  DateFormat('MMM d, yyyy')
                      .format(_task!.trackingInfo!.estimatedDelivery!)),
            _buildInfoRow(
                'Last Updated',
                DateFormat('MMM d, yyyy – h:mm a')
                    .format(_task!.trackingInfo!.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    if (_task!.status == 'completed' || _task!.status == 'cancelled') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.check_circle),
          label: const Text('Done'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_task!.status == 'pending')
          ElevatedButton.icon(
            onPressed: () => _updateTaskStatus('accepted'),
            icon: const Icon(Icons.check_circle),
            label: const Text('Accept Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (_task!.status == 'accepted')
          ElevatedButton.icon(
            onPressed: () => _updateTaskStatus('in_progress'),
            icon: const Icon(Icons.delivery_dining),
            label: const Text('Start Delivery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (_task!.status == 'in_progress')
          ElevatedButton.icon(
            onPressed: () => _updateTaskStatus('completed'),
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (_task!.status != 'completed' && _task!.status != 'cancelled')
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () => _showCancelConfirmation(),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel Task'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
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
        return 'Waiting for acceptance';
      case 'accepted':
        return 'Task accepted';
      case 'in_progress':
        return 'Delivery in progress';
      case 'completed':
        return 'Task completed';
      case 'cancelled':
        return 'Task cancelled';
      default:
        return 'Unknown status';
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Task'),
        content: const Text(
            'Are you sure you want to cancel this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Task'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTaskStatus('cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel Task'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Status Guide'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• Pending: New task waiting for acceptance'),
            SizedBox(height: 8),
            Text('• Accepted: Task has been accepted'),
            SizedBox(height: 8),
            Text('• In Progress: Task is being worked on'),
            SizedBox(height: 8),
            Text('• Completed: Task has been completed successfully'),
            SizedBox(height: 8),
            Text('• Cancelled: Task was cancelled'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}
