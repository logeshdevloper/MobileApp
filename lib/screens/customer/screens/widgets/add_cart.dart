import 'package:flutter/material.dart';
import 'package:pops/utilis/constant.dart';
import '../order/order_conform.dart';
import '../../../../common/styles/color.dart';
import '../home.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _controllers = widget.cartItems
        .map((item) => TextEditingController(text: item['quantity'].toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

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

  double getItemTotal(int index) {
    final item = widget.cartItems[index];
    final double price =
        double.tryParse(item['product']['sell_price'].toString()) ?? 0;
    final int quantity = item['quantity'];
    return price * quantity;
  }

  void increaseQuantity(int index) {
    setState(() {
      widget.cartItems[index]['quantity']++;
      _controllers[index].text = widget.cartItems[index]['quantity'].toString();
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (widget.cartItems[index]['quantity'] > 1) {
        widget.cartItems[index]['quantity']--;
        _controllers[index].text =
            widget.cartItems[index]['quantity'].toString();
      } else {
        removeItem(index);
      }
    });
  }

  // Updated removeItem with undo support
  void removeItem(int index) {
    // Keep track of the removed item and its controller
    final removedItem = widget.cartItems[index];
    final removedController = _controllers[index];

    setState(() {
      widget.cartItems.removeAt(index);
      _controllers.removeAt(index);
      cartCountNotifier.value = widget.cartItems.length;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item Removed from the cart'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              widget.cartItems.insert(index, removedItem);
              _controllers.insert(index, removedController);
              cartCountNotifier.value = widget.cartItems.length;
            });
          },
        ),
      ),
    );
  }

  // Shows a dialog with hint message when the info icon is tapped.
  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('How to Remove an Item'),
          content: const Text(
              'Swipe left or right on an item to remove it from your cart.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E45A8),
          title: const Text('My Cart', style: TextStyle(color: Colors.white)),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: _showHintDialog,
            ),
          ],
        ),
        body: widget.cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your cart is feeling lonely!',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add some delicious items to make it happy',
                      style: TextStyle(
                        color: textSecondary.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.shopping_bag_outlined,
                              color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Start Shopping',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        final product = item['product'] as Map<String, dynamic>;
                        final double price =
                            double.tryParse(product['sell_price'].toString()) ??
                                0;
                        final int quantity = item['quantity'];

                        return Dismissible(
                          key: Key(product['id'].toString() + index.toString()),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            removeItem(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              title: Row(
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product['img_url'] ?? '',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          foodBg,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Name, Price, and Quantity controls in one line
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Product Name and Price
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₹${price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color:
                                                    Colors.deepPurple.shade400,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Quantity controls
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.deepPurple),
                                              onPressed: () =>
                                                  decreaseQuantity(index),
                                            ),
                                            SizedBox(
                                              width: 40,
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                controller: _controllers[index],
                                                onChanged: (value) {
                                                  int? newQuantity =
                                                      int.tryParse(value);
                                                  if (newQuantity != null &&
                                                      newQuantity > 0) {
                                                    setState(() {
                                                      widget.cartItems[index]
                                                              ['quantity'] =
                                                          newQuantity;
                                                    });
                                                  }
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 4),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.deepPurple),
                                              onPressed: () =>
                                                  increaseQuantity(index),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Total for the item
                                  Text(
                                    '₹${getItemTotal(index).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade400,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Bottom section for Total and full width Checkout button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E45A8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                '₹${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
                              child: const Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E45A8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
