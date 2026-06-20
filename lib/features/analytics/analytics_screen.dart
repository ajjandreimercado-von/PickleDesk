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

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _tab = 'Overview';

  final _hoursData = const [8.0, 10.0, 14.0, 11.0, 18.6, 12.5];
  final _spendData = const [85.0, 110.0, 95.0, 140.0, 119.0, 337.40];
  final _freqData = const [2.0, 0.0, 3.0, 1.0, 2.0, 4.0, 1.0];
  final _months = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  final _days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final _courtData = [
    (name: 'Central Court', value: 55.0, color: AppTheme.primary),
    (name: 'Riverside', value: 27.0, color: AppTheme.primaryDark),
    (name: 'Park Side', value: 18.0, color: AppTheme.border),
  ];

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionListProvider);
    final expenses = ref.watch(expenseListProvider);

    final totalHours = sessions.fold<double>(0, (acc, s) => acc + s.duration.inMinutes / 60);
    final totalSessions = sessions.length;
    final longestSession = sessions.isEmpty ? 0.0 : sessions.map((s) => s.duration.inMinutes.toDouble()).reduce(math.max) / 60;
    final avgSession = totalSessions > 0 ? (totalHours * 60 / totalSessions).round() : 0;
    
    final wins = sessions.where((s) => s.result == 'W').length;
    final winRate = totalSessions > 0 ? (wins / totalSessions * 100).round() : 0;
    
    final monthlySpend = expenses.fold<double>(0, (acc, e) => acc + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics',
            style: GoogleFonts.montserrat(
                color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
        backgroundColor: Color(0xE0111410),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border))),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Overview', 'Activity', 'Courts', 'Spending']
                    .map((t) => _AnalyticsTab(t, _tab == t, () => setState(() => _tab = t)))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: _buildContent(totalHours, totalSessions, avgSession, longestSession, winRate, monthlySpend),
      ),
    );
  }

  Widget _buildContent(double totalHours, int totalSessions, int avgSessionMin, double longestSessionHrs, int winRate, double monthlySpend) {
    switch (_tab) {
      case 'Overview':
        return _buildOverview(totalHours, totalSessions, avgSessionMin, longestSessionHrs);
      case 'Activity':
        return _buildActivity(totalSessions, totalHours, winRate);
      case 'Courts':
        return _buildCourts();
      case 'Spending':
        return _buildSpending(monthlySpend);
      default:
        return _buildOverview(totalHours, totalSessions, avgSessionMin, longestSessionHrs);
    }
  }

  Widget _buildOverview(double totalHours, int totalSessions, int avgSessionMin, double longestSessionHrs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main metric with area chart
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
                              text: '+0% ',
                              style: GoogleFonts.inter(
                                  color: AppTheme.text2,
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
                child: LineChart(_buildLineChart(_hoursData, _months)),
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
                    Expanded(child: _buildMiniStats(totalSessions, avgSessionMin, longestSessionHrs)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildFrequency()),
                  ],
                )
              : Column(children: [_buildMiniStats(totalSessions, avgSessionMin, longestSessionHrs), const SizedBox(height: 20), _buildFrequency()]);
        }),
      ],
    );
  }

  Widget _buildMiniStats(int total, int avgMin, double longestHrs) {
    final stats = [
      (label: 'SESSIONS', value: '$total'),
      (label: 'AVG. SESSION', value: '${avgMin ~/ 60}h ${avgMin % 60}m'),
      (label: 'LONGEST', value: '${longestHrs.toInt()}h ${((longestHrs - longestHrs.toInt()) * 60).toInt()}m'),
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
                    border: Border.all(color: AppTheme.border.withValues(alpha: 0.8))),
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

  Widget _buildFrequency() {
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
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                          _days[v.toInt()],
                          style: GoogleFonts.inter(
                              color: AppTheme.text2, fontSize: 10)),
                    ),
                  ),
                ),
                barGroups: _freqData.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value,
                          color: e.value >= 3 ? AppTheme.primary : AppTheme.border,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivity(int totalSessions, double totalHours, int winRate) {
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
                child: LineChart(_buildLineChart(_hoursData, _months, showGrid: true)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (ctx, c) {
          final w = c.maxWidth > 600;
          final cards = [
            StatCard(label: 'Total Sessions', value: '$totalSessions'),
            StatCard(label: 'Total Hours', value: '${totalHours.toStringAsFixed(1)}h'),
            StatCard(label: 'Win Rate', value: '$winRate%', sub: null, subPositive: true),
            StatCard(label: 'Streak', value: '-', sub: null, subPositive: true),
          ];
          if (w) {
            return Row(children: cards.asMap().entries.map((e) =>
                Expanded(child: Padding(padding: EdgeInsets.only(left: e.key > 0 ? 12 : 0), child: e.value))).toList());
          }
          return Column(children: [
            Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
          ]);
        }),
      ],
    );
  }

  Widget _buildCourts() {
    return Column(
      children: [
        PDCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Court Usage',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.text1, fontWeight: FontWeight.w600, fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sections: _courtData.map((c) => PieChartSectionData(
                              value: c.value,
                              color: c.color,
                              showTitle: false,
                              radius: 50,
                            )).toList(),
                        centerSpaceRadius: 35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: _courtData.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        color: c.color, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(c.name,
                                        style: GoogleFonts.inter(
                                            color: AppTheme.text2,
                                            fontSize: 13))),
                                Text('${c.value.toInt()}%',
                                    style: GoogleFonts.montserrat(
                                        color: AppTheme.text1,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ],
                            ),
                          )).toList(),
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

  Widget _buildSpending(double monthlySpend) {
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
              Text('\$${monthlySpend.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: LineChart(_buildLineChart(_spendData, _months)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChart(List<double> data, List<String> labels,
      {bool showGrid = false}) {
    return LineChartData(
      gridData: FlGridData(show: showGrid, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppTheme.border, strokeWidth: 0.5)),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: showGrid,
              reservedSize: 30,
              getTitlesWidget: (v, _) => Text('${v.toInt()}',
                  style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 10))),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Text(labels[i],
                  style: GoogleFonts.inter(
                      color: AppTheme.text2, fontSize: 11));
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
                radius: 4,
                color: AppTheme.primary,
                strokeWidth: 0),
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
