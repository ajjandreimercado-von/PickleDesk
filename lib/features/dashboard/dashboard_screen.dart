import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/section_label.dart';
import '../../shared/widgets/pd_card.dart';
import '../../shared/widgets/result_badge.dart';
import '../sessions/session_providers.dart';
import '../expenses/expense_providers.dart';
import '../reservations/reservation_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    final expenses = ref.watch(expenseListProvider);
    final reservations = ref.watch(reservationListProvider);

    final recentSessions = sessions.take(5).toList();

    final wins = sessions.where((s) => s.result == 'W').length;
    final total = sessions.length;
    final winRate = total > 0 ? (wins / total * 100).round() : 0;
    final totalHours = sessions.fold<double>(0, (acc, s) => acc + s.duration.inMinutes / 60);
    final monthlySpend = expenses.fold<double>(0, (acc, e) => acc + e.amount);

    final upcomingRes = reservations
        .where((r) => r.status == 'Upcoming' && r.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList()..sort((a,b) => a.date.compareTo(b.date));
    final nextRes = upcomingRes.isNotEmpty ? upcomingRes.first : null;

    return CustomScrollView(
      slivers: [
        // ── Top bar ───────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: Color(0xE0111410),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border),
                  ),
                  alignment: Alignment.center,
                  child: Text('J',
                      style: GoogleFonts.montserrat(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning,',
                        style: GoogleFonts.inter(
                            color: AppTheme.text2, fontSize: 13)),
                    Text('Player!',
                        style: GoogleFonts.montserrat(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            height: 1.2)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.notifications_outlined,
                    color: AppTheme.text1, size: 22),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Page title
              Text('Dashboard',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),

              // Stats grid
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 600 ? 4 : 2;
                return _StatsGrid(
                    winRate: winRate,
                    totalHours: totalHours,
                    total: total,
                    monthlySpend: monthlySpend,
                    cols: cols);
              }),
              const SizedBox(height: 20),

              // Monthly spending sparkline
              _SpendingChart(monthlySpend: monthlySpend),
              const SizedBox(height: 20),

              // Favorite Court
              SectionLabel('FAVORITE COURT', action: 'View all',
                  onAction: () => context.go('/courts')),
              const SizedBox(height: 12),
              PDCard(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sports_tennis,
                        color: AppTheme.primary),
                  ),
                  title: Text('Central Court',
                      style: GoogleFonts.montserrat(
                          color: AppTheme.text1,
                          fontWeight: FontWeight.w600,
                          fontSize: 18)),
                  subtitle: Text('Indoor • Pro Surface',
                      style: GoogleFonts.inter(
                          color: AppTheme.text2, fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppTheme.text2),
                ),
              ),
              const SizedBox(height: 20),

              // Next Reservation
              if (nextRes != null) ...[
                const SectionLabel('NEXT RESERVATION'),
                const SizedBox(height: 12),
                PDCard(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today,
                          color: Color(0xFFB6B4B7)),
                    ),
                    title: Text('${nextRes.date.month}/${nextRes.date.day}, ${nextRes.startTime.hour}:${nextRes.startTime.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    subtitle: Text(nextRes.courtName,
                        style: GoogleFonts.inter(
                            color: AppTheme.text2, fontSize: 15)),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppTheme.text2),
                    onTap: () => context.go('/reservations'),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/add-session'),
                      child: const Text('+ New Session'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/reservations'),
                      child: const Text('Book Court'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent sessions
              SectionLabel('RECENT SESSIONS',
                  action: 'View all',
                  onAction: () => context.go('/sessions')),
              const SizedBox(height: 12),

              if (recentSessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No sessions yet — log your first!',
                        style: GoogleFonts.inter(
                            color: AppTheme.text3, fontSize: 14)),
                  ),
                )
              else
                PDCard(
                  child: Column(
                    children: recentSessions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final s = entry.value;
                      return Column(
                        children: [
                          if (idx > 0)
                            const Divider(
                                height: 1, color: Color(0xFF1c1c1e)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                ResultBadge(result: s.result ?? 'D'),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${s.date.day}/${s.date.month}/${s.date.year}',
                                        style: GoogleFonts.inter(
                                            color: AppTheme.text1,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      ),
                                      if (s.opponents.isNotEmpty)
                                        Text(
                                          'vs ${s.opponents.join(', ')}',
                                          style: GoogleFonts.inter(
                                              color: AppTheme.text2,
                                              fontSize: 13),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${s.duration.inHours}h ${s.duration.inMinutes.remainder(60)}m',
                                  style: GoogleFonts.inter(
                                      color: AppTheme.text1,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int winRate, total, cols;
  final double totalHours, monthlySpend;
  const _StatsGrid(
      {required this.winRate,
      required this.totalHours,
      required this.total,
      required this.monthlySpend,
      required this.cols});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: 'Sessions This Week', value: '$total', sub: null, pos: true),
      (label: 'Hours Played', value: '${totalHours.toStringAsFixed(1)}h', sub: null, pos: true),
      (label: 'Win Rate', value: '$winRate%', sub: null, pos: true),
      (label: 'Monthly Spend', value: '\$${monthlySpend.toStringAsFixed(0)}', sub: null, pos: false),
    ];

    if (cols == 4) {
      return Row(
        children: stats.map((s) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: s == stats.last ? 0 : 12),
            child: StatCard(label: s.label, value: s.value,
                valueColor: s.label == 'Monthly Spend' ? AppTheme.text1 : null),
          ),
        )).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: stats.map((s) => StatCard(
            label: s.label,
            value: s.value,
            valueColor: s.label == 'Monthly Spend' ? AppTheme.text1 : null,
          )).toList(),
    );
  }
}

// ── Spending sparkline ────────────────────────────────────────────────────────

class _SpendingChart extends StatelessWidget {
  final double monthlySpend;
  const _SpendingChart({required this.monthlySpend});

  final _data = const [85.0, 110.0, 95.0, 140.0, 119.0, 0.0];

  @override
  Widget build(BuildContext context) {
    return PDCard(
      color: AppTheme.surface2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MONTHLY SPENDING',
                    style: GoogleFonts.inter(
                        color: AppTheme.text2,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text('\$${monthlySpend.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                        color: AppTheme.text1,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        letterSpacing: -0.3)),
                Text('+0% vs last month',
                    style: GoogleFonts.inter(
                        color: AppTheme.primaryDeep,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _data.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.3),
                          AppTheme.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
