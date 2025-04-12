import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pops/utilis/constant.dart';
import 'package:intl/intl.dart';

class TrackOrderPage extends StatefulWidget {
  final String orderNumber;
  final String status;

  const TrackOrderPage({
    Key? key,
    required this.orderNumber,
    required this.status,
  }) : super(key: key);

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  List<Map<String, dynamic>> trackingHistory = [];
  bool isLoading = true;
  final _cancelReasonController = TextEditingController();
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  final List<String> commonReasons = [
    'Changed my mind',
    'Ordered by mistake',
    'Found better price elsewhere',
    'Delivery time too long',
    'Other reason'
  ];

  Map<String, dynamic> orderDetails = {};

  @override
  void initState() {
    super.initState();
    fetchTrackingDetails();
  }

  @override
  void dispose() {
    _cancelReasonController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (e) {
      return timestamp;
    }
  }

  Future<void> fetchTrackingDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');

      if (customerId == null) {
        throw Exception('Customer ID not found');
      }

      final response = await http.get(
        Uri.parse('$rOOT/track-order/${widget.orderNumber}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          trackingHistory =
              List<Map<String, dynamic>>.from(data['tracking_history']);
          orderDetails = data['order_details'] ?? {};
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tracking details');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load tracking details');
      setState(() => isLoading = false);
    }
  }

  Future<void> cancelOrder(String orderNumber, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');

      if (customerId == null) {
        throw Exception('Customer ID not found');
      }

      final response = await http.post(
        Uri.parse('$rOOT/cancel-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_number': orderNumber,
          'customer_id': customerId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Order cancelled successfully');
        Navigator.pop(context);
        fetchTrackingDetails();
      } else {
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to cancel order');
    }
  }

  Future<void> _showCancelDialog() async {
    String selectedReason = commonReasons[0];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: InputDecoration(
                  labelText: 'Select Reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: commonReasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) => selectedReason = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (selectedReason == 'Other reason')
                TextFormField(
                  controller: _cancelReasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional Details',
                    hintText: 'Please provide more details',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) {
                    if (selectedReason == 'Other reason' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please provide details';
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final reason = selectedReason == 'Other reason'
                    ? _cancelReasonController.text
                    : selectedReason;
                await cancelOrder(widget.orderNumber, reason);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.status.toLowerCase() != 'completed' &&
                    widget.status.toLowerCase() != 'cancelled')
                  TextButton.icon(
                    onPressed: _showCancelDialog,
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Cancel Order',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Status: ${widget.status.toUpperCase()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Product: ${orderDetails['product_name'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Delivery Address:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              orderDetails['delivery_address'] ?? 'Address not available',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trackingHistory.length,
      itemBuilder: (context, index) {
        final track = trackingHistory[index];
        final isLast = index == trackingHistory.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (track['status'] ?? 'UNKNOWN').toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              formatTimestamp(
                                  (track['timestamp'] ?? '').toString()),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          track['location'] ?? 'Location not specified',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          track['description'] ?? 'No description available',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.orderNumber}'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummaryCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Tracking Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTrackingTimeline(),
                  ],
                ),
              ),
            ),
    );
  }
}
