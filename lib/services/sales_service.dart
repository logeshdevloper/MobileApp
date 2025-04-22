// lib/services/sales_summary_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/salesSummary_model.dart';
import '../utilis/constant.dart';

class SalesSummaryService {
  Future<SalesSummary> fetchSalesSummary() async {
    final response = await http.get(Uri.parse('${rOOT}sales_summary'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return SalesSummary.fromJson(decoded);
    } else {
      throw Exception('Failed to load sales summary');
    }
  }
}
