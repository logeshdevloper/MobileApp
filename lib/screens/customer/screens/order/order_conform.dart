import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pops/utilis/constant.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';

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

  Future<void> placeOrder(BuildContext context, String address) async {
    // Implement your order placement logic here
    try {
      if (address.length < 10) {
        throw Exception('Address must be at least 10 characters long');
      }
      if (!address.contains(',')) {
        throw Exception('Please include street, city, and state.');
      }

      // Assuming you have a customer ID stored in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');

      if (customerId == null) {
        throw Exception('Customer ID not found');
      }

      final response = await http.post(
        Uri.parse('${rOOT}place-order'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'items': widget.orderItems.map((item) {
            return {
              'product_id': item['product']['id'],
              'quantity': item['quantity'],
              'price': double.parse(item['product']['price'].toString()),
            };
          }).toList(),
          'total_amount': widget.totalAmount,
          'delivery_address': address,
          'delivery_time': widget.orderItems.isNotEmpty
              ? widget.orderItems[0]['product']['delivery_time']
              : null, // Ensure it doesn't crash if empty
          'payment_method': 'COD',
          'status': 'pending',
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final orderNumber = responseData['order_number'];

        // Notify that the order was successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Order placed successfully! Order #$orderNumber')),
        );

        // Navigate to Home Page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } else {
        throw Exception('Failed to place order.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
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
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Enter street, city, state (separated by commas)',
                          border: OutlineInputBorder(),
                          helperText:
                              'Address must be at least 10 characters long',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Method: Cash on Delivery',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
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
                              double.tryParse(product['price'].toString()) ?? 0;

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
