import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pops/utilis/constant.dart';
import '../home.dart';
import '../order/order_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirmationPage extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final double totalAmount;

  const OrderConfirmationPage({
    Key? key,
    required this.orderItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final addressController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Hide keyboard when focus is lost
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> placeOrder(BuildContext context, String address) async {
    try {
      // Validate address length
      if (address.length < 10) {
        throw Exception('Address must be at least 10 characters long');
      }

      // Validate address format - should contain street, city, state
      if (!address.contains(',')) {
        throw Exception(
            'Please include street, city and state separated by commas');
      }

      // Retrieve customer_id from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');

      print('customerId: $customerId');

      if (customerId == null) {
        throw Exception('Customer ID not found');
      }

      final response = await http.post(
        Uri.parse('${rOOT}/place-order'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'items': widget.orderItems
              .map((item) => {
                    'product_id': item['product']['id'],
                    'quantity': item['quantity'],
                    'price': double.parse(item['product']['price'].toString()),
                  })
              .toList(),
          'total_amount': widget.totalAmount,
          'delivery_address': address,
          'delivery_time': widget.orderItems.isNotEmpty
              ? widget.orderItems[0]['product']['delivery_time']
              : null, // Ensure it doesn't crash if empty
          'payment_method': 'COD',
          'status': 'pending'
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final orderNumber = responseData['order_number'];

        // Clear the cart after successful order
        cartItems.clear();
        cartCountNotifier.value = 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed successfully! Order #$orderNumber'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to HomePage and clear the navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
          (route) => false, // This will clear all previous routes
        );
      } else {
        // Check if the response is JSON
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to place order');
        } else {
          throw Exception('Unexpected response format');
        }
      }
    } catch (e) {
      print(widget.orderItems);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Confirmation'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Address
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: addressController,
                        focusNode: _focusNode,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Enter street, city, state (separated by commas)',
                          border: OutlineInputBorder(),
                          helperText:
                              'Address must be at least 10 characters long',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          if (value.length < 10) {
                            return 'Address must be at least 10 characters long';
                          }
                          if (!value.contains(',')) {
                            return 'Please include street, city and state separated by commas';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Method
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.money),
                        title: const Text('Cash on Delivery'),
                        trailing:
                            const Icon(Icons.check_circle, color: Colors.green),
                        tileColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Order Items
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.orderItems.length,
                        itemBuilder: (context, index) {
                          final item = widget.orderItems[index];
                          final product =
                              item['product'] as Map<String, dynamic>;
                          final quantity = item['quantity'] as int;
                          final price =
                              double.tryParse(product['price'].toString()) ??
                                  0.0;

                          return ListTile(
                            title: Text(product['name'] ?? ''),
                            subtitle: Text('Quantity: $quantity'),
                            trailing: Text(
                              '₹${(price * quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final address = addressController.text.trim();
                if (address.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter delivery address'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (address.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Address must be at least 10 characters long'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (!address.contains(',')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please include street, city and state separated by commas'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                placeOrder(context, address);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
