import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Control Placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('Overview', true),
                _buildTab('Activity', false),
                _buildTab('Courts', false),
                _buildTab('Spending', false),
              ],
            ),
            const SizedBox(height: 24),
            
            // Month Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('This Month', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Hours Played Section
            Text('Hours Played', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('18.6h', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                Text('+12% vs last month', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Line Chart Placeholder
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('May 1', style: TextStyle(color: Colors.white54, fontSize: 10));
                            case 3: return const Text('May 10', style: TextStyle(color: Colors.white54, fontSize: 10));
                            case 6: return const Text('May 20', style: TextStyle(color: Colors.white54, fontSize: 10));
                            case 9: return const Text('May 31', style: TextStyle(color: Colors.white54, fontSize: 10));
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2),
                        FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 6), FlSpot(7, 4),
                        FlSpot(8, 8), FlSpot(9, 6),
                      ],
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Sessions', '12'),
                _buildStatColumn('Avg. Session', '1h 33m'),
                _buildStatColumn('Longest Session', '2h 15m'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Bar Chart
            Text(
              'Play Frequency',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 30,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white54);
                          String text;
                          switch (value.toInt()) {
                            case 0: text = 'Mon'; break;
                            case 1: text = 'Tue'; break;
                            case 2: text = 'Wed'; break;
                            case 3: text = 'Thu'; break;
                            case 4: text = 'Fri'; break;
                            case 5: text = 'Sat'; break;
                            case 6: text = 'Sun'; break;
                            default: text = ''; break;
                          }
                          return SideTitleWidget(meta: meta, space: 4.0, child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value % 10 == 0) {
                            return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white54, fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBar(0, 10, context),
                    _buildBar(1, 15, context),
                    _buildBar(2, 5, context),
                    _buildBar(3, 20, context),
                    _buildBar(4, 12, context),
                    _buildBar(5, 28, context),
                    _buildBar(6, 18, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 4),
        if (isSelected) Container(height: 2, width: 24, color: const Color(0xFF2E7D32)),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  BarChartGroupData _buildBar(int x, double y, BuildContext context) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Theme.of(context).colorScheme.primary,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
