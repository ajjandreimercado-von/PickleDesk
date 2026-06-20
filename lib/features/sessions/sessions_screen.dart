import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'session_providers.dart';
import '../courts/court_providers.dart';
import 'package:intl/intl.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    final courts = ref.watch(courtListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: sessions.isEmpty
                ? const Center(child: Text('No sessions recorded', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final court = courts.where((c) => c.id == session.courtId).firstOrNull;
                      final courtName = court?.name ?? 'Unknown Court';
                      final DateFormat formatter = DateFormat('MMM d, yyyy');
                      final timeFormatter = DateFormat('h:mm a');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF253028)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.sports_tennis, color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(courtName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('${formatter.format(session.date)} • ${timeFormatter.format(session.startTime)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  if (session.opponents.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('vs: ${session.opponents.join(', ')}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${session.duration.inHours}h ${session.duration.inMinutes.remainder(60)}m',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                                  onPressed: () {
                                    ref.read(sessionListProvider.notifier).deleteSession(session.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/add-session'),
                icon: const Icon(Icons.add),
                label: const Text('Log Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
