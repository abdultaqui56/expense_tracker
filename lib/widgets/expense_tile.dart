import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat.jm().format(expense.date);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // category circle
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getCategoryColor(expense.category).withOpacity(0.9), _getCategoryColor(expense.category)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _getCategoryColor(expense.category).withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(expense.category),
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      expense.category,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    Text("•", style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 8),
                    Text(
                      dt,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                )
              ],
            ),
          ),

          // amount & actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${expense.amount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.edit, size: 16, color: Colors.blue.shade400),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case "Food":
        return Icons.restaurant;
      case "Travel":
        return Icons.directions_car;
      case "Shopping":
        return Icons.shopping_bag;
      case "Bills":
        return Icons.receipt_long;
      case "Salary":
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case "Food":
        return const Color(0xFF7B61FF);
      case "Travel":
        return const Color(0xFF00C853);
      case "Shopping":
        return const Color(0xFF4FC3F7);
      case "Bills":
        return const Color(0xFFFF7043);
      case "Salary":
        return const Color(0xFF8E24AA);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
