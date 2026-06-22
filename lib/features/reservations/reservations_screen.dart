import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import 'reservation_providers.dart';
import '../../core/models/reservation.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  bool _showUpcoming = true;
  final _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reservations = ref.watch(reservationListProvider);
    final upcoming = reservations
        .where((r) => r.date.isAfter(_now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final history = reservations
        .where((r) => r.date.isBefore(_now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final items = _showUpcoming ? upcoming : history;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations',
            style: GoogleFonts.montserrat(
                color: AppTheme.text1,
                fontWeight: FontWeight.w700,
                fontSize: 22)),
        backgroundColor: const Color(0xE0111410),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                _Tab('Upcoming', _showUpcoming,
                    () => setState(() => _showUpcoming = true)),
                _Tab('History', !_showUpcoming,
                    () => setState(() => _showUpcoming = false)),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 320,
                        child: _MiniCalendar(
                            reservations: reservations, now: _now)),
                    const SizedBox(width: 20),
                    Expanded(child: _ReservationList(items: items)),
                  ],
                )
              : Column(
                  children: [
                    _MiniCalendar(reservations: reservations, now: _now),
                    const SizedBox(height: 16),
                    _ReservationList(items: items),
                  ],
                ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReservationSheet(context, ref),
        child: const Icon(Icons.add, color: AppTheme.primaryFg),
      ),
    );
  }

  void _showAddReservationSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _AddReservationSheet(ref: ref),
    );
  }
}

// ── Add Reservation Bottom Sheet ─────────────────────────────────────────────

class _AddReservationSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddReservationSheet({required this.ref});

  @override
  State<_AddReservationSheet> createState() => _AddReservationSheetState();
}

class _AddReservationSheetState extends State<_AddReservationSheet> {
  final _courtCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (_courtCtrl.text.isEmpty) return;
    final r = Reservation(
      courtName: _courtCtrl.text,
      date: _selectedDate,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      status: 'Upcoming',
      notes: _notesCtrl.text,
    );
    widget.ref.read(reservationListProvider.notifier).addReservation(r);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Reservation',
              style: GoogleFonts.montserrat(
                  color: AppTheme.text1,
                  fontWeight: FontWeight.w700,
                  fontSize: 20)),
          const SizedBox(height: 20),
          TextField(
              controller: _courtCtrl,
              decoration: const InputDecoration(labelText: 'Court Name'),
              style: GoogleFonts.inter(color: AppTheme.text1)),
          const SizedBox(height: 12),
          Text('Date',
              style: GoogleFonts.inter(
                  color: AppTheme.text2,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                      style:
                          GoogleFonts.inter(color: AppTheme.text1, fontSize: 15)),
                  const Icon(Icons.calendar_today,
                      color: AppTheme.text2, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
              style: GoogleFonts.inter(color: AppTheme.text1)),
          const SizedBox(height: 20),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Reservation'))),
        ],
      ),
    );
  }
}

// ── Tab ───────────────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab(this.label, this.isActive, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: isActive ? AppTheme.primary : AppTheme.text2,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.4),
              ),
            ),
            if (isActive)
              Container(height: 2, color: AppTheme.primary, margin: EdgeInsets.zero),
          ],
        ),
      ),
    );
  }
}

// ── Calendar — reads real reservation dates ───────────────────────────────────

class _MiniCalendar extends StatefulWidget {
  final List<Reservation> reservations;
  final DateTime now;
  const _MiniCalendar({required this.reservations, required this.now});

  @override
  State<_MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<_MiniCalendar> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(widget.now.year, widget.now.month);
  }

  void _prevMonth() =>
      setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1));
  void _nextMonth() =>
      setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final startOffset = firstDay.weekday % 7; // 0=Sun
    final daysInMonth =
        DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;

    // Build a set of days (in this month) that have reservations
    final reservedDays = <int>{};
    for (final r in widget.reservations) {
      if (r.date.year == _viewMonth.year && r.date.month == _viewMonth.month) {
        reservedDays.add(r.date.day);
      }
    }

    final isCurrentMonth = _viewMonth.year == widget.now.year &&
        _viewMonth.month == widget.now.month;

    return PDCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.text2),
                onPressed: _prevMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '${_monthName(_viewMonth.month)} ${_viewMonth.year}',
                style: GoogleFonts.montserrat(
                    color: AppTheme.text1,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.text2),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day-of-week headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: AppTheme.text3,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (ctx, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final isToday = isCurrentMonth && day == widget.now.day;
              final hasReservation = reservedDays.contains(day);

              Color? bg;
              Color fg = AppTheme.text1;

              if (isToday) {
                bg = AppTheme.primary;
                fg = AppTheme.primaryFg;
              } else if (hasReservation) {
                bg = AppTheme.primaryDark;
                fg = AppTheme.primary;
              }

              return Container(
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: hasReservation && !isToday
                        ? Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1)
                        : null),
                alignment: Alignment.center,
                child: Text('$day',
                    style: GoogleFonts.inter(
                        color: bg != null ? fg : AppTheme.text1,
                        fontSize: 12,
                        fontWeight: bg != null ? FontWeight.w700 : FontWeight.w400)),
              );
            },
          ),
          // Legend
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppTheme.primary, label: 'Today'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.primaryDark, label: 'Reserved'),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 11)),
      ],
    );
  }
}

// ── Reservation List ──────────────────────────────────────────────────────────

class _ReservationList extends ConsumerWidget {
  final List<Reservation> items;
  const _ReservationList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text('No reservations',
              style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 14)),
        ),
      );
    }

    return Column(
      children: items.map((r) {
        final statusBg = r.status == 'Upcoming'
            ? AppTheme.primaryDark
            : r.status == 'Cancelled'
                ? AppTheme.loseBg
                : AppTheme.surface2;
        final statusFg = r.status == 'Upcoming'
            ? AppTheme.primary
            : r.status == 'Cancelled'
                ? AppTheme.loseText
                : AppTheme.text2;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PDCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.courtName,
                          style: GoogleFonts.montserrat(
                              color: AppTheme.text1,
                              fontWeight: FontWeight.w600,
                              fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(
                          '${r.date.month}/${r.date.day}/${r.date.year}',
                          style: GoogleFonts.inter(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      Text(
                          '${r.startTime.hour}:${r.startTime.minute.toString().padLeft(2, '0')} - ${r.endTime.hour}:${r.endTime.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(
                              color: AppTheme.text2, fontSize: 13)),
                      if (r.notes.isNotEmpty)
                        Text(r.notes,
                            style: GoogleFonts.inter(
                                color: AppTheme.text3, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(r.status,
                          style: GoogleFonts.inter(
                              color: statusFg,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => ref
                          .read(reservationListProvider.notifier)
                          .deleteReservation(r.id),
                      child: Icon(Icons.delete_outline,
                          size: 20,
                          color: AppTheme.loseText.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
