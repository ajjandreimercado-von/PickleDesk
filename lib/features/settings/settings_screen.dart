import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import '../sessions/session_providers.dart';
import 'theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _reminders = true;

  Future<void> _exportCSV() async {
    try {
      final sessions = ref.read(sessionListProvider);
      List<List<dynamic>> rows = [];
      rows.add(["Date", "Start", "End", "Opponents", "Result", "Notes", "Type"]);
      for (var s in sessions) {
        rows.add([
          s.date.toIso8601String(),
          s.startTime.toIso8601String(),
          s.endTime.toIso8601String(),
          s.opponents.join(', '),
          s.result ?? '',
          s.notes,
          s.sessionType ?? ''
        ]);
      }
      String csv = Csv().encode(rows);
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/pickledesk_sessions.csv';
      final file = File(path);
      await file.writeAsString(csv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported CSV to $path', style: const TextStyle(fontSize: 12))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export CSV: $e', style: const TextStyle(fontSize: 12))));
      }
    }
  }

  Future<void> _exportPDF() async {
    try {
      final sessions = ref.read(sessionListProvider);
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PickleDesk Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Total Sessions: ${sessions.length}', style: pw.TextStyle(fontSize: 16)),
              ]
            );
          }
        )
      );
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/pickledesk_report.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported PDF to $path', style: const TextStyle(fontSize: 12))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e', style: const TextStyle(fontSize: 12))));
      }
    }
  }

  static const _themes = [
    (id: 'default', label: 'Default', desc: 'Deep green · Pickleball palette',
     bg: Color(0xFF111410), card: Color(0xFF1d201c), accent: Color(0xFFa1d494), text: Color(0xFFe2e3dc)),
    (id: 'light',   label: 'Light',   desc: 'Clean white · High contrast',
     bg: Color(0xFFf2f5ef), card: Color(0xFFffffff), accent: Color(0xFF2d6b26), text: Color(0xFF1a1f17)),
    (id: 'dark',    label: 'Dark',    desc: 'Pure black · OLED friendly',
     bg: Color(0xFF000000), card: Color(0xFF111111), accent: Color(0xFFa1d494), text: Color(0xFFf0f0f0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.montserrat(
                color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
        backgroundColor: const Color(0xE0111410),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Theme ──
              _SectionHeader('Theme'),
              const SizedBox(height: 12),
              Builder(builder: (ctx) {
                final activeTheme = ref.watch(themeProvider);
                return Row(
                  children: _themes.map((t) {
                    final isActive = activeTheme == t.id;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => ref.read(themeProvider.notifier).setTheme(t.id),
                      child: Padding(
                        padding: EdgeInsets.only(right: t.id != 'dark' ? 8 : 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive ? AppTheme.primary : AppTheme.border,
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // Mini preview
                              Container(
                                color: t.bg,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                                color: t.accent.withValues(alpha: 0.6),
                                                shape: BoxShape.circle)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                            child: Container(
                                                height: 6,
                                                decoration: BoxDecoration(
                                                    color: t.text.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(3)))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: t.card,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                              color: t.text.withValues(alpha: 0.1))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              height: 5,
                                              width: 48,
                                              decoration: BoxDecoration(
                                                  color: t.text.withValues(alpha: 0.3),
                                                  borderRadius: BorderRadius.circular(2))),
                                          const SizedBox(height: 4),
                                          Container(
                                              height: 8,
                                              width: 32,
                                              decoration: BoxDecoration(
                                                  color: t.accent,
                                                  borderRadius: BorderRadius.circular(2))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: List.generate(5, (i) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 1),
                                          child: Container(
                                            height: ([10, 16, 8, 20, 12][i]).toDouble(),
                                            decoration: BoxDecoration(
                                              color: i == 3 ? t.accent : t.text.withValues(alpha: 0.15),
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                              // Label
                              Container(
                                color: AppTheme.surface,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Column(
                                  children: [
                                    Text(t.label,
                                        style: GoogleFonts.montserrat(
                                            color: isActive ? AppTheme.primary : AppTheme.text2,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12)),
                                    Text(t.desc,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                            color: AppTheme.text3,
                                            fontSize: 9,
                                            height: 1.3),
                                        maxLines: 2),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  color: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Center(
                                    child: Text('✓ Active',
                                        style: GoogleFonts.inter(
                                            color: AppTheme.primaryFg,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                );
              }),
              const SizedBox(height: 28),

              // ── Notifications ──
              _SectionHeader('Notifications'),
              const SizedBox(height: 12),
              PDCard(
                child: Column(
                  children: [
                    _ToggleRow('Push Notifications', _notifications,
                        () => setState(() => _notifications = !_notifications)),
                    const Divider(height: 1, color: AppTheme.border),
                    _ToggleRow('Reservation Reminders', _reminders,
                        () => setState(() => _reminders = !_reminders)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Data ──
              _SectionHeader('Data'),
              const SizedBox(height: 12),
              PDCard(
                child: Column(
                  children: [
                    'Export Data (CSV)',
                    'Export Report (PDF)',
                    'Backup Data',
                    'Restore from Backup',
                  ].asMap().entries.map((entry) {
                    final i = entry.key;
                    final label = entry.value;
                    return Column(
                      children: [
                        if (i > 0)
                          const Divider(height: 1, color: AppTheme.border),
                        ListTile(
                          title: Text(label,
                              style: GoogleFonts.inter(
                                  color: AppTheme.text1,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15)),
                          trailing: const Icon(Icons.chevron_right,
                              color: AppTheme.text2),
                          onTap: () {
                            if (i == 0) _exportCSV();
                            if (i == 1) _exportPDF();
                            if (i > 1) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!')));
                            }
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // App info
              Center(
                child: Column(
                  children: [
                    Text('PickleDesk',
                        style: GoogleFonts.montserrat(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Version 1.0.0 · Offline First',
                        style: GoogleFonts.inter(
                            color: AppTheme.text3, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(),
        style: GoogleFonts.inter(
            color: AppTheme.text3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2));
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onToggle;
  const _ToggleRow(this.label, this.value, this.onToggle);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppTheme.text1,
                  fontWeight: FontWeight.w500,
                  fontSize: 15)),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: value ? AppTheme.primary : AppTheme.border,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
