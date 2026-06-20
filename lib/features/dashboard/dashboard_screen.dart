import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../sessions/session_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    
    // Calculate stats
    final now = DateTime.now();
    final thisWeekSessions = sessions.where((s) => s.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
    
    int totalMinutes = 0;
    for (var session in sessions) {
      totalMinutes += session.duration.inMinutes;
    }
    final totalHoursStr = (totalMinutes / 60.0).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'John!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Top Grid: Sessions & Hours
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final cards = [
                  _buildGreenStatCard(context, 'Sessions This Week', '${thisWeekSessions.length}', '+14% vs last week'),
                  _buildDarkStatCard(context, 'Hours Played', totalHoursStr, '+10% vs last week'),
                ];
                
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            
            // List of other cards
            _buildActionCard(context, 'Favorite Court', 'Central Court\nIndoor', Icons.favorite, Colors.red),
            const SizedBox(height: 12),
            _buildActionCard(context, 'Next Reservation', 'Tomorrow, 7:00 AM\nRiverside Courts', Icons.calendar_today, Colors.orange),
            const SizedBox(height: 12),
            _buildActionCard(context, 'Monthly Spending', '\$128.40\n+8% vs last month', Icons.show_chart, Colors.green),
            const SizedBox(height: 12),
            _buildActionCard(context, 'Tournament Play', '2\nEvents this month', Icons.emoji_events, Colors.amber),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Sessions', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go('/sessions'),
                  child: const Text('View all'),
                ),
              ],
            ),
            
            // Recent Sessions List (Preview)
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No recent sessions')),
              )
            else
              ...sessions.take(3).map((session) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.sports_tennis, color: Colors.white70),
                    title: Text('Session on ${session.date.month}/${session.date.day}'),
                    subtitle: Text('${session.duration.inHours}h ${session.duration.inMinutes.remainder(60)}m'),
                  ),
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-session'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGreenStatCard(BuildContext context, String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDarkStatCard(BuildContext context, String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF253028)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color iconColor) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        trailing: Icon(icon, color: iconColor),
        onTap: () {},
      ),
    );
  }
}
