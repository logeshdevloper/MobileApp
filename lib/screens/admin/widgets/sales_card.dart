// lib/widgets/sales_card.dart

import 'package:flutter/material.dart';

class SalesCard extends StatelessWidget {
  final String title;
  final double value;

  const SalesCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text(title),
        subtitle: Text('\₹${value.toStringAsFixed(2)}'),
      ),
    );
  }
}
