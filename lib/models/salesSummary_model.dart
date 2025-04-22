class SalesSummary {
  final double totalSales;
  final double todaySales;
  final double weeklySales;
  final double monthlySales;
  final int totalOrders;
  final double averageOrderValue;
  final List<SalesByDate> salesByDate;
  final List<TopProduct> topProducts;

  SalesSummary({
    required this.totalSales,
    required this.todaySales,
    required this.weeklySales,
    required this.monthlySales,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.salesByDate,
    required this.topProducts,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    var salesByDateList = json['sales_by_date'] as List;
    var topProductsList = json['top_products'] as List;

    return SalesSummary(
      totalSales: (json['total_sales'] as num).toDouble(),
      todaySales: (json['today_sales'] as num).toDouble(),
      weeklySales: (json['weekly_sales'] as num).toDouble(),
      monthlySales: (json['monthly_sales'] as num).toDouble(),
      totalOrders: json['total_orders'],
      averageOrderValue: (json['average_order_value'] as num).toDouble(),
      salesByDate: salesByDateList.map((i) => SalesByDate.fromJson(i)).toList(),
      topProducts: topProductsList.map((i) => TopProduct.fromJson(i)).toList(),
    );
  }
}

class SalesByDate {
  final String date;
  final double sales;

  SalesByDate({required this.date, required this.sales});

  factory SalesByDate.fromJson(Map<String, dynamic> json) {
    return SalesByDate(
      date: json['date'],
      sales: (json['sales'] as num).toDouble(),
    );
  }
}

class TopProduct {
  final String name;
  final double totalSales;

  TopProduct({required this.name, required this.totalSales});

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
        name: json['name'] as String,
        totalSales: (json['total_sales'] as num).toDouble());
  }
}
