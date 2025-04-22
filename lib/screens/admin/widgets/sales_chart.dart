import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/salesSummary_model.dart';

class SalesChart extends StatelessWidget {
  final List<SalesByDate> salesByDate;

  const SalesChart({Key? key, required this.salesByDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: getMaxY(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '₹${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          gridData: FlGridData(show: true, horizontalInterval: 50),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.black26),
              bottom: BorderSide(color: Colors.black26),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < salesByDate.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        salesByDate[index].date.substring(5), // "MM-DD"
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, _) => Text(
                  '₹${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          barGroups: salesByDate
              .asMap()
              .entries
              .map(
                (entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.sales.toDouble(),
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2EC4B6), Color(0xFFCBF3F0)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600), // Animation
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  double getMaxY() {
    double max = 0;
    for (var item in salesByDate) {
      if (item.sales > max) {
        max = item.sales;
      }
    }
    return (max * 1.3).ceilToDouble(); // add headroom
  }
}
