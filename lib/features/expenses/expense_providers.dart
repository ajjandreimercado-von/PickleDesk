import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/expense.dart';
import '../../services/local_storage_service.dart';

class ExpenseListNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    final box = Hive.box<Expense>(LocalStorageService.expensesBoxName);
    return box.values.toList().cast<Expense>();
  }

  Future<void> addExpense(Expense expense) async {
    final box = Hive.box<Expense>(LocalStorageService.expensesBoxName);
    await box.put(expense.id, expense);
    state = box.values.toList().cast<Expense>();
  }

  Future<void> deleteExpense(String id) async {
    final box = Hive.box<Expense>(LocalStorageService.expensesBoxName);
    await box.delete(id);
    state = box.values.toList().cast<Expense>();
  }
}

final expenseListProvider = NotifierProvider<ExpenseListNotifier, List<Expense>>(
  ExpenseListNotifier.new,
);
