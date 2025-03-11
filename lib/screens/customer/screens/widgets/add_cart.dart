import 'package:flutter/material.dart';
import 'package:pops/utilis/constant.dart';
import '../order/order_conform.dart';

import '../../../../common/styles/color.dart'; // Ensure that foodBg is defined here

class CartScreen extends StatefulWidget {
  // Each cart item is expected to have a 'product' (Map) and a 'quantity' (int)
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // List of controllers for each cart item
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each cart item
    _controllers = widget.cartItems
        .map((item) => TextEditingController(text: item['quantity'].toString()))
        .toList();
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Calculate the total price for all items in the cart.
  double get totalPrice {
    double total = 0;
    for (var item in widget.cartItems) {
      double price =
          double.tryParse(item['product']['sell_price'].toString()) ?? 0;
      int quantity = item['quantity'] as int;
      total += price * quantity;
    }
    return total;
  }

  // Increase the quantity of a specific cart item.
  void increaseQuantity(int index) {
    setState(() {
      widget.cartItems[index]['quantity']++;
      _controllers[index].text = widget.cartItems[index]['quantity'].toString();
    });
  }

  // Decrease the quantity of a specific cart item.
  // If quantity becomes less than 1, remove the item.
  void decreaseQuantity(int index) {
    setState(() {
      if (widget.cartItems[index]['quantity'] > 1) {
        widget.cartItems[index]['quantity']--;
        _controllers[index].text =
            widget.cartItems[index]['quantity'].toString();
      } else {
        widget.cartItems.removeAt(index);
        _controllers.removeAt(index);
      }
    });
  }

  // Remove the cart item completely.
  void removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
      cartCountNotifier.value = widget.cartItems.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item Removed from the cart'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          elevation: 10,
          action: SnackBarAction(
            label: 'Close',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    });
  }

  // Method to increase the total count
  void increaseTotalCount() {
    setState(() {
      for (var item in widget.cartItems) {
        item['quantity']++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200], // Set a custom background color
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: widget.cartItems.isEmpty
            ? const Center(child: Text('Your cart is empty!'))
            : Column(
                children: [
                  // List of Cart Items.
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        final product = item['product'] as Map<String, dynamic>;
                        final double price =
                            double.tryParse(product['sell_price'].toString()) ??
                                0;

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Image.network(
                              product['img_url'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  foodBg,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            title: Text(product['name'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Price: ₹${double.tryParse(product['sell_price'].toString())?.toStringAsFixed(2) ?? '0.00'}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    // Decrease quantity button.
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () => decreaseQuantity(index),
                                    ),
                                    // Typeable quantity field.
                                    SizedBox(
                                      width: 50,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        controller: _controllers[index],
                                        onChanged: (value) {
                                          int? newQuantity =
                                              int.tryParse(value);
                                          if (newQuantity != null &&
                                              newQuantity > 0) {
                                            setState(() {
                                              widget.cartItems[index]
                                                  ['quantity'] = newQuantity;
                                            });
                                          }
                                        },
                                        onSubmitted: (value) {
                                          int? newQuantity =
                                              int.tryParse(value);
                                          if (newQuantity != null &&
                                              newQuantity > 0) {
                                            setState(() {
                                              widget.cartItems[index]
                                                  ['quantity'] = newQuantity;
                                            });
                                          } else {
                                            // Reset to previous valid quantity
                                            _controllers[index].text = widget
                                                .cartItems[index]['quantity']
                                                .toString();
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                        ),
                                      ),
                                    ),
                                    // Increase quantity button.
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () => increaseQuantity(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Remove item button.
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => removeItem(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Bottom Bar with Total Price and Checkout Button.
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total price display.
                        Text(
                          'Total: ₹${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // Checkout button.
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderConfirmationPage(
                                  orderItems: widget.cartItems,
                                  totalAmount: totalPrice,
                                ),
                              ),
                            );
                          },
                          child: const Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
