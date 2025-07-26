import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'budget_manager.dart';
import 'reports_screen.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
    // Show budget dialog if not set
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      BudgetManager budgetManager = BudgetManager();
      if (!budgetManager.isBudgetSet()) {
        await budgetManager.promptForBudget(context);
        setState(() {});
      }
    });
  }

  void loadExpenses() {
    final box = Hive.box('expenses');
    expenses = box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    setState(() {});
  }

  double getTotalExpenses() {
    return expenses.fold(0.0, (sum, expense) => sum + expense['amount']);
  }

  // Show context menu on long press
  void showContextMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              editExpense(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              deleteExpense(index);
            },
          ),
        ],
      ),
    );
  }

  // Delete expense
  void deleteExpense(int index) {
    Hive.box('expenses').deleteAt(index);
    loadExpenses();
  }

  // Edit expense
  void editExpense(int index) {
    final expense = expenses[index];
    final titleController = TextEditingController(text: expense['title']);
    final amountController = TextEditingController(text: expense['amount'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Hive.box('expenses').putAt(index, {
                'title': titleController.text,
                'amount': double.parse(amountController.text),
                'category': expense['category'],
                'date': expense['date'],
              });
              loadExpenses();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = getTotalExpenses();
    final budgetManager = BudgetManager();
    final budgetStatus = budgetManager.getBudgetStatus(total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen())),
          ),
        ],
      ),
      body: expenses.isEmpty
          ? const Center(child: Text('No expenses yet', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Column(
        children: [
          // Total and Budget Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Total Expenses: ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(budgetStatus, style: TextStyle(color: budgetStatus.contains('Over') ? Colors.red : Colors.green, fontSize: 16)),
              ],
            ),
          ),
          const Divider(),
          // Expenses List
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return GestureDetector(
                  onLongPress: () => showContextMenu(context, index),
                  child: ListTile(
                    title: Text(expense['title'] ?? 'Expense'),
                    subtitle: Text(expense['category'] ?? ''),
                    trailing: Text('₹${expense['amount'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          loadExpenses();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}