import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import '../../shared/widgets/section_label.dart';
import 'expense_providers.dart';
import '../../core/models/expense.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  static const _categoryColors = {
    'Court Fees': AppTheme.primary,
    'Tournament Fees': Color(0xFFFFB4AB),
    'Equipment': AppTheme.text2,
    'Coaching': AppTheme.primaryDark,
    'Miscellaneous': AppTheme.border,
  };

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseListProvider);
    // Sort expenses by date descending
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final total = expenses.fold<double>(0, (a, e) => a + e.amount);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Spending tracker',
                style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12)),
            Text('Expenses',
                style: GoogleFonts.montserrat(
                    color: AppTheme.text1,
                    fontWeight: FontWeight.w700,
                    fontSize: 22)),
          ],
        ),
        backgroundColor: Color(0xE0111410),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 300, child: _buildSummary(total)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildList(sortedExpenses)),
                  ],
                )
              : Column(children: [
                  _buildSummary(total),
                  const SizedBox(height: 20),
                  _buildList(sortedExpenses),
                ]),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context, ref),
        child: const Icon(Icons.add, color: AppTheme.primaryFg),
      ),
    );
  }

  Widget _buildSummary(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PDCard(
          color: AppTheme.surface2,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('June 2025',
                  style: GoogleFonts.inter(
                      color: AppTheme.text2, fontSize: 12, letterSpacing: 0.8)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                      letterSpacing: -0.5)),
              Text('+8% vs last month',
                  style: GoogleFonts.inter(
                      color: AppTheme.primaryDeep,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categoryColors.keys.map((cat) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(cat,
                    style: GoogleFonts.inter(
                        color: _categoryColors[cat],
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildList(List<Expense> sortedExpenses) {
    if (sortedExpenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text('No expenses recorded',
              style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 14)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('RECENT'),
        const SizedBox(height: 12),
        PDCard(
          child: Column(
            children: sortedExpenses.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final color = _categoryColors[e.category] ?? AppTheme.text2;

              return Column(
                children: [
                  if (i > 0)
                    const Divider(height: 1, color: Color(0xFF1c1c1e)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.13),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.category,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.text1,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                              Text(
                                '${e.date.month}/${e.date.day}/${e.date.year}${e.notes.isNotEmpty ? ' · ${e.notes}' : ''}',
                                style: GoogleFonts.inter(
                                    color: AppTheme.text3, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${e.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.montserrat(
                              color: AppTheme.text1,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            ref.read(expenseListProvider.notifier).deleteExpense(e.id);
                          },
                          child: Icon(Icons.delete_outline, size: 20, color: AppTheme.loseText.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAddExpenseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _AddExpenseSheet(ref: ref),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddExpenseSheet({required this.ref});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = 'Court Fees';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amt = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amt <= 0) return;

    final exp = Expense(
      amount: amt,
      category: _category,
      date: DateTime.now(),
      notes: _notesCtrl.text.trim(),
    );
    widget.ref.read(expenseListProvider.notifier).addExpense(exp);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Expense',
              style: GoogleFonts.montserrat(
                  color: AppTheme.text1,
                  fontWeight: FontWeight.w700,
                  fontSize: 20)),
          const SizedBox(height: 20),
          TextField(
            controller: _amountCtrl,
            decoration: const InputDecoration(labelText: 'Amount (\$)'),
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: AppTheme.text1, fontSize: 15),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            dropdownColor: AppTheme.surface2,
            items: ['Court Fees', 'Tournament Fees', 'Equipment', 'Coaching', 'Miscellaneous']
                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(color: AppTheme.text1))))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            style: GoogleFonts.inter(color: AppTheme.text1, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Save Expense'),
            ),
          ),
        ],
      ),
    );
  }
}
