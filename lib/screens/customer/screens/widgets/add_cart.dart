import 'package:flutter/material.dart';
import '../../../../common/styles/color.dart';
import '../order/order_conform.dart';
import '../home.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
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

  double getItemTotal(int index) {
    final item = widget.cartItems[index];
    final double price =
        double.tryParse(item['product']['sell_price'].toString()) ?? 0;
    final int quantity = item['quantity'];
    return price * quantity;
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

  void removeItem(int index) {
    final removedItem = widget.cartItems[index];
    final removedController = _controllers[index];

    setState(() {
      widget.cartItems.removeAt(index);
      _controllers.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed'),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              widget.cartItems.insert(index, removedItem);
              _controllers.insert(index, removedController);
            });
          },
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              infoTile(
                  Icons.swipe, 'Swipe left or right to remove items from cart'),
              const SizedBox(height: 16),
              infoTile(Icons.remove_circle_outline,
                  'Tap - button to decrease quantity or remove item'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget infoTile(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          orderItems: widget.cartItems,
          totalAmount: totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) => buildCartItem(index),
                  ),
                ),
                buildTotalBar(),
              ],
            ),
    );
  }

  Widget buildEmptyCart() {
    return Center(
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child:
                const Icon(Icons.shopping_cart, size: 80, color: primaryColor),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is feeling lonely!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          const Text('Add some delicious items to make it happy',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage())),
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartItem(int index) {
    final item = widget.cartItems[index];
    final product = item['product'];
    final double price = double.tryParse(product['sell_price'].toString()) ?? 0;

    return Dismissible(
      key: Key(product['id'].toString() + index.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => removeItem(index),
      background:
          buildSwipeBackground(Alignment.centerLeft, EdgeInsets.only(left: 20)),
      secondaryBackground: buildSwipeBackground(
          Alignment.centerRight, EdgeInsets.only(right: 20)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['img_url'] ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(product['description'] ?? 'No description available',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      quantityButton(
                          Icons.remove, () => decreaseQuantity(index)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(item['quantity'].toString(),
                            style: const TextStyle(fontSize: 16)),
                      ),
                      quantityButton(Icons.add, () => increaseQuantity(index)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('₹${getItemTotal(index).toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget quantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: const Color(0xFFFFA726)),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget buildSwipeBackground(
      AlignmentGeometry alignment, EdgeInsetsGeometry padding) {
    return Container(
      color: const Color(0xFFE53935),
      alignment: alignment,
      padding: padding,
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget buildTotalBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _checkout,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Checkout',
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
