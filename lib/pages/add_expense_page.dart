import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/expense_model.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? existing;
  const AddExpensePage({super.key, this.existing});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final db = DBHelper();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';

  final List<String> _categories = ['Food', 'Travel', 'Shopping', 'Bills', 'Salary', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _titleCtrl.text = e.title;
      _amountCtrl.text = e.amount.toString();
      _selectedDate = e.date;
      _selectedCategory = e.category;
    }
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dt != null) setState(() => _selectedDate = dt);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      id: widget.existing?.id,
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      date: _selectedDate,
      category: _selectedCategory,
    );

    if (widget.existing == null) {
      await db.insertExpense(expense);
    } else {
      await db.updateExpense(expense);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd();
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Expense' : 'Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Date'),
                      child: InkWell(
                        onTap: _pickDate,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(df.format(_selectedDate)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v ?? 'Other'),
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Category'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
