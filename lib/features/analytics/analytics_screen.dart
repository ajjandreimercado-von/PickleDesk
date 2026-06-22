import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import '../../shared/widgets/stat_card.dart';
import '../sessions/session_providers.dart';
import '../expenses/expense_providers.dart';
import '../courts/court_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _tab = 'Overview';

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the last [count] months as 'MMM' strings (oldest → newest).
  List<String> _lastMonthLabels(int count) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final m = DateTime(now.year, now.month - (count - 1 - i));
      return _monthShort(m.month);
    });
  }

  /// Sums session hours per month for the last [count] months.
  List<double> _hoursPerMonth(List sessions, int count) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final target = DateTime(now.year, now.month - (count - 1 - i));
      return sessions
          .where((s) =>
              s.date.year == target.year && s.date.month == target.month)
          .fold<double>(0, (acc, s) => acc + s.duration.inMinutes / 60.0);
    });
  }

  /// Sums expense amounts per month for the last [count] months.
  List<double> _spendPerMonth(List expenses, int count) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final target = DateTime(now.year, now.month - (count - 1 - i));
      return expenses
          .where((e) =>
              e.date.year == target.year && e.date.month == target.month)
          .fold<double>(0, (acc, e) => acc + e.amount);
    });
  }

  /// Returns session counts per day-of-week (Mon=0 … Sun=6).
  List<double> _freqByWeekday(List sessions) {
    final counts = List<double>.filled(7, 0);
    for (final s in sessions) {
      // DateTime.weekday: Mon=1 … Sun=7
      counts[s.date.weekday - 1] += 1;
    }
    return counts;
  }

  /// Court usage as a list of (name, pct, color).
  List<({String name, double value, Color color})> _courtUsage(
      List sessions, List courts) {
    if (sessions.isEmpty) return [];
    final Map<String, int> counts = {};
    for (final s in sessions) {
      counts[s.courtId] = (counts[s.courtId] ?? 0) + 1;
    }
    final total = sessions.length;
    final palette = [
      AppTheme.primary,
      AppTheme.primaryDark,
      AppTheme.border,
      const Color(0xFF8ecae6),
      const Color(0xFFe9c46a),
    ];
    int idx = 0;
    return counts.entries.map((e) {
      final court = courts.where((c) => c.id == e.key).firstOrNull;
      final name = (court?.name as String?) ?? 'Unknown';
      final pct = e.value / total * 100;
      return (name: name, value: pct, color: palette[idx++ % palette.length]);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Compute current-month vs previous-month % change for hours.
  String _monthOverMonth(List<double> data) {
    if (data.length < 2) return '+0%';
    final prev = data[data.length - 2];
    final curr = data.last;
    if (prev == 0) return curr > 0 ? '+∞%' : '+0%';
    final pct = ((curr - prev) / prev * 100).round();
    return pct >= 0 ? '+$pct%' : '$pct%';
  }

  String _monthShort(int m) =>
      const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionListProvider);
    final expenses = ref.watch(expenseListProvider);
    final courts   = ref.watch(courtListProvider);

    final totalHours = sessions.fold<double>(
        0, (acc, s) => acc + s.duration.inMinutes / 60.0);
    final totalSessions = sessions.length;
    final longestSession = sessions.isEmpty
        ? 0.0
        : sessions
                .map((s) => s.duration.inMinutes.toDouble())
                .reduce(math.max) /
            60;
    final avgSessionMin =
        totalSessions > 0 ? (totalHours * 60 / totalSessions).round() : 0;
    final wins = sessions.where((s) => s.result == 'W').length;
    final winRate =
        totalSessions > 0 ? (wins / totalSessions * 100).round() : 0;
    final totalSpend =
        expenses.fold<double>(0, (acc, e) => acc + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics',
            style: GoogleFonts.montserrat(
                color: AppTheme.text1,
                fontWeight: FontWeight.w700,
                fontSize: 22)),
        backgroundColor: const Color(0xE0111410),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppTheme.border))),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Overview', 'Activity', 'Courts', 'Spending']
                    .map((t) => _AnalyticsTab(
                        t, _tab == t, () => setState(() => _tab = t)))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: _buildContent(sessions, expenses, courts, totalHours,
            totalSessions, avgSessionMin, longestSession, winRate, totalSpend),
      ),
    );
  }

  Widget _buildContent(
    List sessions,
    List expenses,
    List courts,
    double totalHours,
    int totalSessions,
    int avgSessionMin,
    double longestSessionHrs,
    int winRate,
    double totalSpend,
  ) {
    switch (_tab) {
      case 'Overview':
        return _buildOverview(
            sessions, totalHours, totalSessions, avgSessionMin, longestSessionHrs);
      case 'Activity':
        return _buildActivity(sessions, totalSessions, totalHours, winRate);
      case 'Courts':
        return _buildCourts(sessions, courts);
      case 'Spending':
        return _buildSpending(expenses, totalSpend);
      default:
        return _buildOverview(
            sessions, totalHours, totalSessions, avgSessionMin, longestSessionHrs);
    }
  }

  // ── Overview ───────────────────────────────────────────────────────────────

  Widget _buildOverview(List sessions, double totalHours, int totalSessions,
      int avgSessionMin, double longestSessionHrs) {
    final months = _lastMonthLabels(6);
    final hoursData = _hoursPerMonth(sessions, 6);
    final mom = _monthOverMonth(hoursData);
    final momPositive = !mom.startsWith('-');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PDCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hours Played',
                  style: GoogleFonts.inter(
                      color: AppTheme.text2, fontSize: 13, letterSpacing: 0.4)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${totalHours.toStringAsFixed(1)}h',
                      style: GoogleFonts.montserrat(
                          color: AppTheme.text1,
                          fontWeight: FontWeight.w700,
                          fontSize: 48,
                          letterSpacing: -1)),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: '$mom ',
                              style: GoogleFonts.inter(
                                  color: momPositive
                                      ? AppTheme.primary
                                      : AppTheme.loseText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          TextSpan(
                              text: 'vs last month',
                              style: GoogleFonts.inter(
                                  color: AppTheme.text2, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: hoursData.every((v) => v == 0)
                    ? _emptyChart()
                    : LineChart(_buildLineChart(hoursData, months)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (ctx, c) {
          final isWide = c.maxWidth > 600;
          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _buildMiniStats(
                            totalSessions, avgSessionMin, longestSessionHrs)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildFrequency(sessions)),
                  ],
                )
              : Column(children: [
                  _buildMiniStats(totalSessions, avgSessionMin, longestSessionHrs),
                  const SizedBox(height: 20),
                  _buildFrequency(sessions),
                ]);
        }),
      ],
    );
  }

  Widget _buildMiniStats(int total, int avgMin, double longestHrs) {
    final stats = [
      (label: 'SESSIONS', value: '$total'),
      (label: 'AVG. SESSION',
          value:
              '${avgMin ~/ 60}h ${avgMin % 60}m'),
      (label: 'LONGEST',
          value:
              '${longestHrs.toInt()}h ${((longestHrs - longestHrs.toInt()) * 60).toInt()}m'),
    ];
    return Row(
      children: stats.asMap().entries.map((e) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.border.withValues(alpha: 0.8))),
                child: Column(
                  children: [
                    Text(e.value.label,
                        style: GoogleFonts.inter(
                            color: AppTheme.text2,
                            fontSize: 10,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 8),
                    Text(e.value.value,
                        style: GoogleFonts.montserrat(
                            color: AppTheme.text1,
                            fontWeight: FontWeight.w700,
                            fontSize: 20)),
                  ],
                ),
              ),
            ),
          )).toList(),
    );
  }

  Widget _buildFrequency(List sessions) {
    final freqData = _freqByWeekday(sessions);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = freqData.reduce(math.max);

    return PDCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Play Frequency',
              style: GoogleFonts.montserrat(
                  color: AppTheme.text1,
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: sessions.isEmpty
                ? _emptyChart()
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(
                                days[v.toInt()],
                                style: GoogleFonts.inter(
                                    color: AppTheme.text2, fontSize: 10)),
                          ),
                        ),
                      ),
                      barGroups: freqData.asMap().entries
                          .map((e) => BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value,
                                    color: e.value == maxVal && maxVal > 0
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                    width: 18,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Activity ───────────────────────────────────────────────────────────────

  Widget _buildActivity(
      List sessions, int totalSessions, double totalHours, int winRate) {
    final months = _lastMonthLabels(6);
    final hoursData = _hoursPerMonth(sessions, 6);

    // Compute win streak
    int streak = 0;
    for (final s in sessions) {
      if (s.result == 'W') streak++;
      else break;
    }

    return Column(
      children: [
        PDCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monthly Hours Trend',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.w600,
                      fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: hoursData.every((v) => v == 0)
                    ? _emptyChart()
                    : LineChart(
                        _buildLineChart(hoursData, months, showGrid: true)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (ctx, c) {
          final w = c.maxWidth > 600;
          final cards = [
            StatCard(label: 'Total Sessions', value: '$totalSessions'),
            StatCard(
                label: 'Total Hours',
                value: '${totalHours.toStringAsFixed(1)}h'),
            StatCard(
                label: 'Win Rate',
                value: '$winRate%',
                sub: null,
                subPositive: true),
            StatCard(
                label: 'Win Streak',
                value: streak > 0 ? '${streak}W' : '-',
                sub: null,
                subPositive: true),
          ];
          if (w) {
            return Row(
                children: cards.asMap().entries
                    .map((e) => Expanded(
                          child: Padding(
                              padding:
                                  EdgeInsets.only(left: e.key > 0 ? 12 : 0),
                              child: e.value),
                        ))
                    .toList());
          }
          return Column(children: [
            Row(children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1])
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3])
            ]),
          ]);
        }),
      ],
    );
  }

  // ── Courts ─────────────────────────────────────────────────────────────────

  Widget _buildCourts(List sessions, List courts) {
    final courtUsage = _courtUsage(sessions, courts);

    return Column(
      children: [
        PDCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Court Usage',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.w600,
                      fontSize: 18)),
              const SizedBox(height: 16),
              courtUsage.isEmpty
                  ? _emptyChart()
                  : Row(
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: PieChart(
                            PieChartData(
                              sections: courtUsage
                                  .map((c) => PieChartSectionData(
                                        value: c.value,
                                        color: c.color,
                                        showTitle: false,
                                        radius: 50,
                                      ))
                                  .toList(),
                              centerSpaceRadius: 35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: courtUsage
                                .map((c) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: c.color,
                                                  shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(c.name,
                                                  style: GoogleFonts.inter(
                                                      color: AppTheme.text2,
                                                      fontSize: 13))),
                                          Text(
                                              '${c.value.toStringAsFixed(1)}%',
                                              style: GoogleFonts.montserrat(
                                                  color: AppTheme.text1,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Spending ───────────────────────────────────────────────────────────────

  Widget _buildSpending(List expenses, double totalSpend) {
    final months = _lastMonthLabels(6);
    final spendData = _spendPerMonth(expenses, 6);

    return Column(
      children: [
        PDCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL SPENT',
                  style: GoogleFonts.inter(
                      color: AppTheme.text2,
                      fontSize: 11,
                      letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text('\$${totalSpend.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: spendData.every((v) => v == 0)
                    ? _emptyChart()
                    : LineChart(_buildLineChart(spendData, months)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Chart builders ─────────────────────────────────────────────────────────

  Widget _emptyChart() {
    return Center(
      child: Text('No data yet',
          style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 13)),
    );
  }

  LineChartData _buildLineChart(List<double> data, List<String> labels,
      {bool showGrid = false}) {
    final maxY = data.isEmpty ? 1.0 : (data.reduce(math.max) * 1.2).ceilToDouble();
    return LineChartData(
      minY: 0,
      maxY: maxY == 0 ? 1 : maxY,
      gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppTheme.border, strokeWidth: 0.5)),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: showGrid,
              reservedSize: 30,
              getTitlesWidget: (v, _) => Text('${v.toInt()}',
                  style: GoogleFonts.inter(
                      color: AppTheme.text2, fontSize: 10))),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Text(labels[i],
                  style:
                      GoogleFonts.inter(color: AppTheme.text2, fontSize: 11));
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList(),
          isCurved: true,
          color: AppTheme.primary,
          barWidth: 2,
          dotData: FlDotData(
            show: showGrid,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4, color: AppTheme.primary, strokeWidth: 0),
          ),
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
    );
  }
}

// ── Tab widget ─────────────────────────────────────────────────────────────────

class _AnalyticsTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _AnalyticsTab(this.label, this.isActive, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(label,
                style: GoogleFonts.inter(
                    color: isActive ? AppTheme.primary : AppTheme.text2,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.4)),
          ),
          if (isActive)
            Container(height: 2, width: 60, color: AppTheme.primary),
        ],
      ),
    );
  }
}
