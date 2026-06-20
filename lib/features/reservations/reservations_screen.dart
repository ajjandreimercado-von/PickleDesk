import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import 'reservation_providers.dart';
import '../../core/models/reservation.dart';
import 'package:go_router/go_router.dart';

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
    final upcoming = reservations.where((r) => r.date.isAfter(_now.subtract(const Duration(days: 1)))).toList()..sort((a,b)=>a.date.compareTo(b.date));
    final history = reservations.where((r) => r.date.isBefore(_now.subtract(const Duration(days: 1)))).toList()..sort((a,b)=>b.date.compareTo(a.date));
    final items = _showUpcoming ? upcoming : history;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Reservations',
            style: GoogleFonts.montserrat(
                color: AppTheme.text1,
                fontWeight: FontWeight.w700,
                fontSize: 22)),
        backgroundColor: Color(0xE0111410),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                _Tab('Upcoming', _showUpcoming, () => setState(() => _showUpcoming = true)),
                _Tab('History', !_showUpcoming, () => setState(() => _showUpcoming = false)),
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
                    SizedBox(width: 320, child: _MiniCalendar(now: _now)),
                    const SizedBox(width: 20),
                    Expanded(child: _ReservationList(items: items)),
                  ],
                )
              : Column(
                  children: [
                    _MiniCalendar(now: _now),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _AddReservationSheet(ref: ref),
    );
  }
}

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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Reservation', style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 20)),
          const SizedBox(height: 20),
          TextField(controller: _courtCtrl, decoration: const InputDecoration(labelText: 'Court Name'), style: GoogleFonts.inter(color: AppTheme.text1)),
          const SizedBox(height: 12),
          Text('Date', style: GoogleFonts.inter(color: AppTheme.text2, fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}', style: GoogleFonts.inter(color: AppTheme.text1, fontSize: 15)),
                  const Icon(Icons.calendar_today, color: AppTheme.text2, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), style: GoogleFonts.inter(color: AppTheme.text1)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Save Reservation'))),
        ],
      ),
    );
  }
}

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

class _MiniCalendar extends StatelessWidget {
  final DateTime now;
  const _MiniCalendar({required this.now});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(now.year, now.month, 1);
    final startOffset = firstDay.weekday % 7; // 0=Sun
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return PDCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.chevron_left, color: AppTheme.text2),
              Text(
                '${_monthName(now.month)} ${now.year}',
                style: GoogleFonts.montserrat(
                    color: AppTheme.text1,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              Icon(Icons.chevron_right, color: AppTheme.text2),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) => Expanded(
                  child: Text(d,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: AppTheme.text3,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (ctx, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final isToday = day == now.day;
              final isHighlighted = day == now.day + 1 || day == now.day + 4;

              Color? bg;
              Color fg = AppTheme.text1;
              if (isToday) {
                bg = AppTheme.primary;
                fg = AppTheme.primaryFg;
              } else if (isHighlighted) {
                bg = AppTheme.primaryDark;
                fg = AppTheme.primary;
              }

              return Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                    color: bg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('$day',
                    style: GoogleFonts.inter(
                        color: bg != null ? fg : AppTheme.text1,
                        fontSize: 13,
                        fontWeight: bg != null ? FontWeight.w700 : FontWeight.w400)),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int m) => const ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m];
}

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
                      Text('${r.date.month}/${r.date.day}/${r.date.year}',
                          style: GoogleFonts.inter(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      Text('${r.startTime.hour}:${r.startTime.minute.toString().padLeft(2, '0')} - ${r.endTime.hour}:${r.endTime.minute.toString().padLeft(2, '0')}',
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      onTap: () => ref.read(reservationListProvider.notifier).deleteReservation(r.id),
                      child: Icon(Icons.delete_outline, size: 20, color: AppTheme.loseText.withValues(alpha: 0.7)),
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

