import 'package:flutter/material.dart';
import '../../../../common/styles/color.dart';
import '../../../../utilis/constant.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String productName = product['name']?.toString() ?? 'PRODUCT';
    final String weight = product['stock']?.toString() ?? '48g';
    final String price = product['sell_price']?.toString() ?? '20';
    final String imageUrl = product['img_url']?.toString() ?? '';
    final String deliveryTime =
        product['delivery_time']?.toString() ?? '5 Mins';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFFF2F2F2),
                height: 140,
                width: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit
                                  .cover, // Use BoxFit.cover for better fitting
                              height: 140, // Match the container height
                              width:
                                  double.infinity, // Ensure it fills the width
                            )
                          : Image.asset(
                              'assets/placeholder.png',
                              fit: BoxFit
                                  .cover, // Apply BoxFit.cover for the placeholder
                              height: 140, // Match the container height
                              width:
                                  double.infinity, // Ensure it fills the width
                            ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer,
                                size: 14, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text(
                              '$deliveryTime',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Product info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$weight',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          cartItems.add({
                            'product': product,
                            'quantity': 1,
                          });
                          cartCountNotifier.value = cartItems.length;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product['name']} added to cart'.capitalize(),
                                style: const TextStyle(fontSize: 14),
                              ),
                              backgroundColor: primaryColor,
                              behavior: SnackBarBehavior.floating,
                              elevation: 10,
                              action: SnackBarAction(
                                label: 'Close',
                                textColor: Colors.white,
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: Color(0xFFD92D20), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xFFD92D20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
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
}
