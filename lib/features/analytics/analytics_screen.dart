import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/sales_provider.dart';
import '../../providers/session_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final currentUser = sessionProvider.loggedInUser?.username ?? '';

    // Map product names (lowercase) to category names
    final Map<String, String> itemCategoryMap = {
      'basmati rice': 'Grocery',
      'atta': 'Grocery',
      'toor dal': 'Grocery',
      'maggi': 'Snacks',
      'chocolate': 'Snacks',
      // Add other mappings per your catalog
    };

    // Get category-wise sales from provider (method implemented in SalesProvider)
    final categorySales = salesProvider.getCategorySalesData(
      currentUser,
      itemCategoryMap: itemCategoryMap,
    );

    final totalSales = categorySales.values.fold(0.0, (a, b) => a + b);

    if (totalSales == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics Dashboard')),
        body: const Center(child: Text('No sales data available')),
      );
    }

    List<PieChartSectionData> sections = categorySales.entries.map((entry) {
      final percentage = (entry.value / totalSales) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
        color: getCategoryColor(entry.key),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            const Text(
              "Category-wise Sales",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 22,
                ),
              ),
            ),
            // Add more charts here with salesProvider data as needed
          ],
        ),
      ),
    );
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
        return Colors.blue;
      case 'snacks':
        return Colors.orange;
      case 'dairy':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
