// lib/screens/sales_summry_screen.dart

import 'package:flutter/material.dart';
import '../../../../services/sales_service.dart';
import '../../../../models/salesSummary_model.dart';
import '../sales_summary/sales_summary_page.dart'; // Import the main page widget

class SalesSummaryScreen extends StatefulWidget {
  const SalesSummaryScreen({Key? key}) : super(key: key);

  @override
  _SalesSummaryScreenState createState() => _SalesSummaryScreenState();
}

class _SalesSummaryScreenState extends State<SalesSummaryScreen> {
  final SalesSummaryService _salesSummaryService = SalesSummaryService();
  late Future<SalesSummary> _salesSummary;

  @override
  void initState() {
    super.initState();
    // Initialize the future for the sales summary API call
    _salesSummary = _salesSummaryService.fetchSalesSummary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SalesSummary>(
      future: _salesSummary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final salesSummary = snapshot.data!;
          return SalesSummaryPage(salesSummary: salesSummary);
        } else {
          return Center(child: Text('No data available.'));
        }
      },
    );
  }
}
