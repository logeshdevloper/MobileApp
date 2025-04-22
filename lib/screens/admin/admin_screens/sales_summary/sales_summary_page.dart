// lib/screens/sales_summary_page.dart

import 'package:flutter/material.dart';
import '../../../../models/salesSummary_model.dart';
import '../../widgets/sales_chart.dart'; // Import the chart widget
import '../../widgets/sales_card.dart'; // Import sales card widget

class SalesSummaryPage extends StatelessWidget {
  final SalesSummary salesSummary;

  const SalesSummaryPage({required this.salesSummary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Summary Cards
            SalesCard(title: 'Total Sales', value: salesSummary.totalSales),
            SalesCard(title: 'Today\'s Sales', value: salesSummary.todaySales),
            SalesCard(title: 'Weekly Sales', value: salesSummary.weeklySales),
            SalesCard(title: 'Monthly Sales', value: salesSummary.monthlySales),
            SalesCard(
                title: 'Average Order Value',
                value: salesSummary.averageOrderValue),

            SizedBox(height: 20),

            // Sales by Date Chart (line/bar chart)
            SalesChart(salesByDate: salesSummary.salesByDate),

            SizedBox(height: 20),

            // Top Products List
            Text('Top Selling Products',
                style: Theme.of(context).textTheme.titleLarge),
            ListView.builder(
              shrinkWrap:
                  true, // Makes the ListView behave like it’s inside a scrollable area
              itemCount: salesSummary.topProducts.length,
              itemBuilder: (context, index) {
                final product = salesSummary.topProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      'Total Sales: \$${product.totalSales.toStringAsFixed(2)}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
