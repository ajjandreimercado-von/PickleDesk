import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text('Session History (PDF)'),
            subtitle: const Text('Export all sessions into a printable PDF report'),
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Expenses (CSV)'),
            subtitle: const Text('Export all payments into a spreadsheet'),
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
