import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'budget_manager.dart'; // ✅ ADDED

class ReportsScreen extends StatelessWidget {
  ReportsScreen({Key? key}) : super(key: key);

  final Box expenseBox = Hive.box('expenses');

  List<Map<String, dynamic>> get sectionsData {
    double food = 0, travel = 0, bills = 0, other = 0;

    for (var e in expenseBox.values) {
      switch (e['category']) {
        case 'Food':
          food += e['amount'];
          break;
        case 'Travel':
          travel += e['amount'];
          break;
        case 'Bills':
          bills += e['amount'];
          break;
        default:
          other += e['amount'];
      }
    }

    return [
      if (food > 0) {'label': 'Food', 'value': food, 'color': Colors.green},
      if (travel > 0) {'label': 'Travel', 'value': travel, 'color': Colors.orange},
      if (bills > 0) {'label': 'Bills', 'value': bills, 'color': Colors.blue},
      if (other > 0) {'label': 'Other', 'value': other, 'color': Colors.purple},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double total = sectionsData.fold(0.0, (sum, item) => sum + item['value']);
    final budgetManager = BudgetManager();
    final budgetStatus = budgetManager.getBudgetStatus(total);

    if (sectionsData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expense Report')),
        body: const Center(child: Text('No expenses yet')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Report')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
            const SizedBox(height: 50), // space between chart and legend
            Column(
              children: sectionsData.map((section) {
                final percent = total > 0
                    ? (section['value'] / total * 100).toStringAsFixed(1)
                    : '0';
                return Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 14, height: 14, color: section['color']),
                      const SizedBox(width: 8),
                      Text('${section['label']} — ₹${section['value']} — $percent%'),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Expense: ₹${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              budgetStatus, // ✅ ADDED
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: budgetStatus.contains('Over') ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return sectionsData.map((section) {
      return PieChartSectionData(
        color: section['color'],
        value: section['value'],
        title: '',
        radius: 100,
      );
    }).toList();
  }
}
