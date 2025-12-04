import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/expense_model.dart';
import 'add_expense_page.dart';
import '../widgets/expense_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Expense> expenses = [];
  String filter = "All";
  DateTime? selectedDate;

  final Map<String, Color> categoryColors = {
    "Food": Colors.red,
    "Shopping": Colors.blue,
    "Travel": Colors.green,
    "Bills": Colors.orange,
    "Salary": Colors.purple,
    "Other": Colors.brown,
  };

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final data = await DBHelper().getAllExpenses();
    data.sort((a, b) => b.date.compareTo(a.date)); // latest first
    setState(() {
      expenses = data;
    });
  }

  // ---------------- POP-UP CONFIRM DELETE ----------------
  Future<bool> confirmDelete() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Delete this expense permanently?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ??
        false;
  }

  // ---------------- FILTER ----------------
  List<Expense> getFilteredExpenses() {
    if (selectedDate != null) {
      return expenses
          .where((e) =>
      e.date.year == selectedDate!.year &&
          e.date.month == selectedDate!.month &&
          e.date.day == selectedDate!.day)
          .toList();
    }

    final now = DateTime.now();
    switch (filter) {
      case "Today":
        return expenses
            .where((e) =>
        e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
            .toList();

      case "This Week":
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return expenses
            .where((e) => e.date.isAfter(weekStart) && e.date.isBefore(weekEnd))
            .toList();

      case "This Month":
        return expenses
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();

      default:
        return expenses;
    }
  }

  // ---------------- LIST WITHOUT DATE HEADERS ----------------
  List<Widget> buildExpenseList(List<Expense> list) {
    return list.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (d) async => await confirmDelete(),
          onDismissed: (d) async {
            await DBHelper().deleteExpense(e.id!);
            fetchExpenses();
          },
          child: ExpenseTile(
            expense: e,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpensePage(existing: e),
                ),
              ).then((_) => fetchExpenses());
            },
            onDelete: () async {
              if (await confirmDelete()) {
                await DBHelper().deleteExpense(e.id!);
                fetchExpenses();
              }
            },
          ),
        ),
      );
    }).toList();
  }

  // ---------------- PIE CHART ----------------
  Map<String, double> calculateTotals(List<Expense> list) {
    Map<String, double> totals = {};
    for (var e in list) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Widget buildPieChart() {
    final totals = calculateTotals(getFilteredExpenses());
    if (totals.isEmpty) return const Center(child: Text("No Data"));

    final List<PieChartSectionData> sections = [];
    final List<Widget> labels = [];

    totals.forEach((category, amount) {
      final color = categoryColors[category] ?? Colors.grey;

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          radius: 50,
          title: "",
        ),
      );

      labels.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "$category: ₹${amount.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 3,
                  centerSpaceRadius: 35,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: labels,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final list = getFilteredExpenses();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final dt = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (dt != null) {
                setState(() {
                  selectedDate = dt;
                  filter = "All";
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                selectedDate = null;
              });
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpensePage()),
        ).then((_) => fetchExpenses()),
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // filter dropdown
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButton<String>(
              value: filter,
              items: ["All", "Today", "This Week", "This Month"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  filter = v!;
                  selectedDate = null;
                });
              },
            ),
          ),

          // pie chart
          SizedBox(height: 180, child: buildPieChart()),

          const Divider(),

          // FIXED DATE HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey.shade200,
            child: Text(
              selectedDate != null
                  ? DateFormat("EEE, dd MMM yyyy").format(selectedDate!)
                  : list.isNotEmpty
                  ? DateFormat("EEE, dd MMM yyyy").format(list.first.date)
                  : "No expenses",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // LIST VIEW
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("No expenses"))
                : ListView(
              padding: EdgeInsets.zero,
              children: buildExpenseList(list),
            ),
          ),
        ],
      ),
    );
  }
}
