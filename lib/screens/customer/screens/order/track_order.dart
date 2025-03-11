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
  final TextEditingController _cancelReasonController = TextEditingController();
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
      print('Error fetching tracking details: $e');
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

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  Future<void> _showCancelDialog() async {
    String selectedReason = commonReasons[0];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReason,
              items: commonReasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) => selectedReason = value!,
              decoration: const InputDecoration(
                labelText: 'Select Reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cancelReasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Details (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final reason = selectedReason == 'Other reason'
                    ? _cancelReasonController.text
                    : selectedReason;

                await cancelOrder(widget.orderNumber, reason);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );

                await fetchTrackingDetails();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to cancel order: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Confirm Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.orderNumber}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Order Summary Card
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order Status: ${widget.status.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.status.toLowerCase() != 'completed' &&
                                  widget.status.toLowerCase() != 'cancelled')
                                TextButton.icon(
                                  onPressed: _showCancelDialog,
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  label: const Text(
                                    'Cancel Order',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            'Product: ${orderDetails['product_name'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Delivery Address:',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            orderDetails['delivery_address'] ??
                                'Address not available',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tracking Timeline
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
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
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: Colors.blue.shade200,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              (track['status'] ?? 'UNKNOWN')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formatTimestamp(
                                                (track['timestamp'] ?? '')
                                                    .toString()),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        track['location'] ??
                                            'Location not specified',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        track['description'] ??
                                            'No description available',
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
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _cancelReasonController.dispose();
    super.dispose();
  }
}
