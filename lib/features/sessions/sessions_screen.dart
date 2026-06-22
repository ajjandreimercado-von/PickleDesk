import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import '../../shared/widgets/result_badge.dart';
import 'session_providers.dart';
import '../courts/court_providers.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionListProvider);
    final courts = ref.watch(courtListProvider);

    final filtered = _filter == 'All'
        ? sessions
        : sessions.where((s) => s.sessionType == _filter).toList();

    final wins = sessions.where((s) => s.result == 'W').length;
    final total = sessions.length;
    final winRate = total > 0 ? (wins / total * 100).round() : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xE0111410),
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$total total',
                        style: GoogleFonts.inter(
                            color: AppTheme.text2, fontSize: 11)),
                    Text('Sessions',
                        style: GoogleFonts.montserrat(
                            color: AppTheme.text1,
                            fontWeight: FontWeight.w700,
                            fontSize: 20)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.filter_list, color: AppTheme.text2, size: 22),
              ],
            ),
          ),


          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                LayoutBuilder(builder: (ctx, c) {
                  final cols = c.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _MiniStat('Win Rate', '$winRate%', primary: true),
                      _MiniStat('Avg Duration', '1h 28m'),
                      _MiniStat('Total Sessions', '$total'),
                      _MiniStat('Best Streak', '4W', primary: true),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // Filter pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Competitive', 'Casual', 'Practice']
                        .map((f) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _filter = f),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _filter == f
                                        ? AppTheme.primary
                                        : AppTheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: _filter == f ? AppTheme.primary : AppTheme.border),
                                  ),
                                  child: Text(
                                    f,
                                    style: GoogleFonts.inter(
                                      color: _filter == f
                                          ? AppTheme.primaryFg
                                          : AppTheme.text2,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Session list
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text('No sessions found',
                          style: GoogleFonts.inter(
                              color: AppTheme.text3, fontSize: 14)),
                    ),
                  )
                else
                  ...filtered.map((s) {
                    final court = courts
                        .where((c) => c.id == s.courtId)
                        .firstOrNull;
                    final courtName = court?.name ?? 'Unknown Court';
                    final dateStr = DateFormat('MMM d, yyyy').format(s.date);
                    final timeStr = DateFormat('h:mm a').format(s.startTime);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PDCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResultBadge(result: s.result ?? 'D'),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$dateStr · $timeStr',
                                      style: GoogleFonts.montserrat(
                                          color: AppTheme.text1,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                  Text(courtName,
                                      style: GoogleFonts.inter(
                                          color: AppTheme.text2,
                                          fontSize: 13)),
                                  if (s.opponents.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'vs ${s.opponents.join(', ')} · ${s.duration.inHours}h ${s.duration.inMinutes.remainder(60)}m',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.text3,
                                          fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _TypeBadge(s.sessionType ?? 'Casual'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-session'),
        child: const Icon(Icons.add, color: AppTheme.primaryFg),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final bool primary;
  const _MiniStat(this.label, this.value, {this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  color: AppTheme.text2,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.montserrat(
                  color: primary ? AppTheme.primary : AppTheme.text1,
                  fontWeight: FontWeight.w700,
                  fontSize: 24)),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Competitive': AppTheme.primary,
      'Casual': AppTheme.loseText,
      'Practice': AppTheme.text2,
    };
    return Text(
      type,
      style: GoogleFonts.inter(
          color: colors[type] ?? AppTheme.text2,
          fontWeight: FontWeight.w700,
          fontSize: 11),
    );
  }
}
