import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class BudgetManager {
  static final Box _budgetBox = Hive.box('budget');

  // Check if budget is set
  bool isBudgetSet() {
    return _budgetBox.get('amount', defaultValue: 0) > 0;
  }

  // Show budget dialog
  Future<void> promptForBudget(BuildContext context) async {
    final controller = TextEditingController();
    String period = 'Weekly';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Set Your Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Period dropdown
                  DropdownButton<String>(
                    value: period,
                    items: ['Weekly', 'Monthly']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (value) => setState(() => period = value!),
                  ),
                  const SizedBox(height: 16),
                  // Amount field
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget Amount',
                      prefixText: '₹',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text);
                    if (amount != null && amount > 0) {
                      _budgetBox.put('amount', amount);
                      _budgetBox.put('period', period);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Get budget amount
  double getBudgetAmount() {
    return _budgetBox.get('amount', defaultValue: 0.0);
  }

  // Get budget status message
  String getBudgetStatus(double totalExpenses) {
    double budget = getBudgetAmount();
    if (totalExpenses > budget) {
      return '⚠️ Over budget by ₹${(totalExpenses - budget).toStringAsFixed(2)}';
    } else if (totalExpenses == budget) {
      return '⚖️ Budget reached exactly';
    } else {
      return '✅ ₹${(budget - totalExpenses).toStringAsFixed(2)} remaining';
    }
  }

  // NEW: Edit budget dialog
  Future<void> editBudget(BuildContext context) async {
    final controller = TextEditingController(
      text: getBudgetAmount().toString(),
    );
    String period = _budgetBox.get('period', defaultValue: 'Weekly');

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Your Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Period dropdown
                  DropdownButton<String>(
                    value: period,
                    items: ['Weekly', 'Monthly']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (value) => setState(() => period = value!),
                  ),
                  const SizedBox(height: 16),
                  // Amount field
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget Amount',
                      prefixText: '₹',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text);
                    if (amount != null && amount > 0) {
                      _budgetBox.put('amount', amount);
                      _budgetBox.put('period', period);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // NEW: Get status color
  Color getBudgetStatusColor(double totalExpenses) {
    double budget = getBudgetAmount();
    if (totalExpenses > budget) {
      return Colors.red;
    } else if (totalExpenses == budget) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // NEW: Budget edit widget
  Widget buildBudgetEditWidget(BuildContext context, VoidCallback onBudgetChanged) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
        title: Text('Budget: ₹${getBudgetAmount().toStringAsFixed(2)}'),
        subtitle: Text(_budgetBox.get('period', defaultValue: 'Weekly')),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () async {
            await editBudget(context);
            onBudgetChanged();
          },
        ),
      ),
    );
  }
}