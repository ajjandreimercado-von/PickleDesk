import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pd_card.dart';
import 'tournament_providers.dart';
import '../../core/models/tournament.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen> {
  bool _isCreating = false;
  Tournament? _selected;

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(tournamentListProvider);

    if (_isCreating) {
      return _CreateTournament(
        ref: ref,
        onBack: () => setState(() => _isCreating = false),
        onDone: () => setState(() => _isCreating = false),
      );
    }
    if (_selected != null) {
      return _TournamentDetail(
        ref: ref,
        tournament: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('My competitions', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12)),
            Text('Tournaments', style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
          ],
        ),
        backgroundColor: const Color(0xE0111410),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Make Your Own CTA
            GestureDetector(
              onTap: () => setState(() => _isCreating = true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryFg.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_box_outlined, color: AppTheme.primaryFg, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Make Your Own', style: GoogleFonts.montserrat(color: AppTheme.primaryFg, fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Single · Double · Round Robin', style: GoogleFonts.inter(color: const Color(0xFF1a4a16), fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.primaryFg),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('MY TOURNAMENTS', style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            ...tournaments.map((t) {
              final statusBg = t.status == 'Active' ? AppTheme.primaryDark : t.status == 'Upcoming' ? AppTheme.surface2 : AppTheme.surface3;
              final statusFg = t.status == 'Active' ? AppTheme.primary : AppTheme.text2;
              final dateStr = '${t.date.month}/${t.date.day}/${t.date.year}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selected = t),
                  child: PDCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.name, style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w600, fontSize: 17)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: AppTheme.text2, size: 14),
                                      const SizedBox(width: 6),
                                      Text(dateStr, style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(t.type, style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                              child: Text(t.status, style: GoogleFonts.inter(color: statusFg, fontWeight: FontWeight.w700, fontSize: 11)),
                            ),
                          ],
                        ),
                        if (t.status != 'Upcoming') ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${t.type} · ${t.participants.length} Players', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 13)),
                              Text(t.status == 'Active' ? 'In Progress' : 'Complete', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4)),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: t.status == 'Active' ? 0.5 : 1.0,
                              child: Container(decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
                            ),
                          ),
                        ],
                        if (t.result != null && t.result!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.only(top: 12),
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x9942493e)))),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events, color: AppTheme.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(t.result!, style: GoogleFonts.montserrat(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.only(top: 12),
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x9942493e)))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t.location, style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 12)),
                              Text('\$${t.entryFee.toStringAsFixed(0)} entry', style: GoogleFonts.inter(color: AppTheme.text2, fontWeight: FontWeight.w700, fontSize: 12)),
                              GestureDetector(
                                onTap: () => ref.read(tournamentListProvider.notifier).deleteTournament(t.id),
                                child: Icon(Icons.delete_outline, size: 20, color: AppTheme.loseText.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// ── Tournament Creation Flow ──────────────────────────────────────────────────

class _CreateTournament extends StatefulWidget {
  final WidgetRef ref;
  final VoidCallback onBack;
  final VoidCallback onDone;
  const _CreateTournament({required this.ref, required this.onBack, required this.onDone});

  @override
  State<_CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<_CreateTournament> {
  int _step = 0; // 0: type, 1: setup, 2: players, 3: bracket
  String? _format;
  String _name = '';
  String _date = '';
  String _location = '';
  String _entryFee = '';
  List<String> _players = ['You'];
  final TextEditingController _playerCtrl = TextEditingController();
  Map<String, String> _winners = {};

  final _formats = [
    (id: 'Single Elimination', label: 'Single Elimination', tag: 'Most Common', desc: "One loss and you're out. The fastest format — perfect for day-of tournaments.", rules: ["Players/teams are seeded into a bracket", "Lose once → eliminated immediately", "Games to 11, win by 2", "Winner advances; bracket shrinks each round"], bestFor: '4 – 32 players · Quick events'),
    (id: 'Double Elimination', label: 'Double Elimination', tag: 'Fairest', desc: "Two losses to be eliminated. Gives every player a second chance.", rules: ["Winners bracket: standard single elim path", "Losers bracket: second chance after first loss", "Lose twice → eliminated", "Grand Final reset if Losers bracket winner wins"], bestFor: '8 – 16 players · Half-day events'),
    (id: 'Round Robin', label: 'Round Robin', tag: 'Most Play', desc: "Everyone plays everyone. Standings determine the champion.", rules: ["Every player plays all others once", "Win = 2 pts, Draw = 1 pt, Loss = 0 pts", "Tiebreakers: head-to-head → point differential", "Optional playoffs for top 2–4 after pool play"], bestFor: '4 – 10 players · Social/league play'),
  ];

  void _addPlayer() {
    final name = _playerCtrl.text.trim();
    if (name.isNotEmpty && !_players.contains(name)) {
      setState(() {
        _players.add(name);
        _playerCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0: return _buildTypeStep();
      case 1: return _buildSetupStep();
      case 2: return _buildPlayersStep();
      case 3: return _buildBracketStep();
      default: return const SizedBox();
    }
  }

  Widget _buildTypeStep() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: widget.onBack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New tournament', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12)),
            Text('Choose Format', style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
          ],
        ),
        backgroundColor: const Color(0xE0111410),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a tournament format. Each plays differently — choose what suits your group.', style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 14)),
            const SizedBox(height: 16),
            ..._formats.map((f) {
              final isSel = _format == f.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() { _format = f.id; _step = 1; }),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF1d2a1c) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSel ? AppTheme.primary : AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
                              child: const Icon(Icons.emoji_events_outlined, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(f.label, style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: AppTheme.primaryDark, borderRadius: BorderRadius.circular(20)),
                                        child: Text(f.tag, style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(f.desc, style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 13, height: 1.2)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.only(top: 12),
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x9942493e)))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: f.rules.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('→', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 11)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(r, style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12, height: 1.2))),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(f.bestFor, style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 11)),
                            Row(
                              children: [
                                Text('Select', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                                const Icon(Icons.chevron_right, color: AppTheme.primary, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupStep() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => setState(() => _step = 0)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_format ?? '', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12)),
            Text('Tournament Details', style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
          ],
        ),
        backgroundColor: const Color(0xE0111410),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Tournament Name', 'e.g. Summer Smash 2025', (v) => _name = v, _name),
            const SizedBox(height: 16),
            _buildTextField('Date', 'e.g. Jul 20, 2025', (v) => _date = v, _date),
            const SizedBox(height: 16),
            _buildTextField('Location', 'e.g. Central Court Complex', (v) => _location = v, _location),
            const SizedBox(height: 16),
            _buildTextField('Entry Fee (\$)', '0 for free', (v) => _entryFee = v, _entryFee, TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _name.trim().isNotEmpty ? () => setState(() => _step = 2) : null,
                child: const Text('Next: Add Players →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onChanged, String initial, [TextInputType type = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppTheme.text2, fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initial,
          onChanged: onChanged,
          keyboardType: type,
          style: GoogleFonts.inter(color: AppTheme.text1, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersStep() {
    final minPlayers = _format == 'Round Robin' ? 3 : 4;
    final ready = _players.length >= minPlayers;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => setState(() => _step = 1)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_players.length} added', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12)),
            Text('Add Players', style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
          ],
        ),
        backgroundColor: const Color(0xE0111410),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Minimum $minPlayers players for $_format. For Single/Double Elimination, bracket sizes are padded to the nearest power of 2 with byes.', style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _playerCtrl,
                    onSubmitted: (_) => _addPlayer(),
                    style: GoogleFonts.inter(color: AppTheme.text1, fontSize: 15),
                    decoration: const InputDecoration(hintText: 'Player name…'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addPlayer,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add, color: AppTheme.primaryFg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._players.asMap().entries.map((e) {
              final i = e.key;
              final name = e.value;
              final isYou = name == 'You';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: isYou ? AppTheme.primaryDark : AppTheme.surface2, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(isYou ? '★' : '${i + 1}', style: GoogleFonts.inter(color: isYou ? AppTheme.primary : AppTheme.text2, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Text(name, style: GoogleFonts.inter(color: isYou ? AppTheme.primary : AppTheme.text1, fontWeight: FontWeight.w500, fontSize: 15)),
                            if (isYou) Padding(padding: const EdgeInsets.only(left: 6), child: Text('(you)', style: GoogleFonts.inter(color: AppTheme.text3, fontWeight: FontWeight.w500, fontSize: 10))),
                          ],
                        ),
                      ),
                      if (!isYou)
                        GestureDetector(
                          onTap: () => setState(() => _players.remove(name)),
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(color: AppTheme.loseBg, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: AppTheme.loseText, size: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ready ? () {
                  final t = Tournament(
                    name: _name.isEmpty ? 'My Tournament' : _name,
                    date: DateTime.now(),
                    type: _format!,
                    location: _location,
                    entryFee: double.tryParse(_entryFee) ?? 0,
                    status: 'Active',
                    participants: _players,
                    winners: {},
                  );
                  widget.ref.read(tournamentListProvider.notifier).addTournament(t);
                  widget.onDone();
                } : null,
                child: Text(ready ? 'Generate Bracket & Save →' : 'Need ${minPlayers - _players.length} more players'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketStep() {
    return const SizedBox();
  }
}

// ── Single/Double Elimination Bracket ──

class _SEBracket extends StatelessWidget {
  final String name, format;
  final List<String> players;
  final Map<String, String> winners;
  final Function(String, String) onWin;
  final VoidCallback onBack, onDone;
  final bool isDouble;

  const _SEBracket({required this.name, required this.format, required this.players, required this.winners, required this.onWin, required this.onBack, required this.onDone, required this.isDouble});

  @override
  Widget build(BuildContext context) {
    // Generate bracket structure
    final size = math.pow(2, (math.log(math.max(players.length, 2)) / math.ln2).ceil()).toInt();
    final seeded = List<String>.from(players);
    while (seeded.length < size) { seeded.add('BYE'); }

    final liveRounds = <List<List<String>>>[];
    var current = List<String>.from(seeded);
    while (current.length > 1) {
      final pairs = <List<String>>[];
      for (int i = 0; i < current.length; i += 2) {
        pairs.add([current[i], current[i + 1]]);
      }
      liveRounds.add(pairs);

      final nextRound = <String>[];
      for (int pi = 0; pi < pairs.length; pi++) {
        final pair = pairs[pi];
        final key = 'r${liveRounds.length - 1}m$pi';
        final w = winners[key];
        nextRound.add(w ?? (pair[1] == 'BYE' ? pair[0] : '?'));
      }
      current = nextRound;
    }

    final champion = winners['r${liveRounds.length - 1}m0'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: onBack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$format · ${players.length} players', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12)),
            Text(name.isEmpty ? 'My Tournament' : name, style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
          ],
        ),
        backgroundColor: const Color(0xE0111410),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (champion != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1d2a1c), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5))),
                child: Row(
                  children: [
                    Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle), child: const Icon(Icons.emoji_events, color: AppTheme.primaryFg, size: 20)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CHAMPION', style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                        Text(champion, style: GoogleFonts.montserrat(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text(isDouble ? 'WINNERS BRACKET' : 'BRACKET', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: liveRounds.asMap().entries.map((entry) {
                  final ri = entry.key;
                  final pairs = entry.value;
                  final spacing = math.pow(2, ri).toInt();

                  return Padding(
                    padding: EdgeInsets.only(right: ri < liveRounds.length - 1 ? 28 : 0),
                    child: Column(
                      children: pairs.asMap().entries.map((pe) {
                        final pi = pe.key;
                        final pair = pe.value;
                        final key = 'r${ri}m$pi';
                        final w = winners[key];

                        return Padding(
                          padding: EdgeInsets.only(top: pi == 0 ? 0 : (spacing * 60).toDouble()),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: w != null ? AppTheme.primary : AppTheme.border),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                _BracketPlayer(name: pair[0], isWinner: w == pair[0], isLoser: w != null && w != pair[0], onWin: () => onWin(key, pair[0]), disabled: pair[0] == '?' || pair[0] == 'BYE' || w != null),
                                const Divider(height: 1, color: AppTheme.border),
                                _BracketPlayer(name: pair[1], isWinner: w == pair[1], isLoser: w != null && w != pair[1], onWin: () => onWin(key, pair[1]), disabled: pair[1] == '?' || pair[1] == 'BYE' || w != null),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onDone,
                child: const Text('Save & Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BracketPlayer extends StatelessWidget {
  final String name;
  final bool isWinner, isLoser, disabled;
  final VoidCallback onWin;

  const _BracketPlayer({required this.name, required this.isWinner, required this.isLoser, required this.disabled, required this.onWin});

  @override
  Widget build(BuildContext context) {
    final isBye = name == 'BYE';
    final isPending = name == '?';
    final isYou = name == 'You';

    Color bg = AppTheme.surface;
    if (isWinner) bg = AppTheme.primaryDark;
    if (isLoser) bg = AppTheme.background;
    if (isBye) bg = AppTheme.background;

    Color fg = AppTheme.text2;
    if (isYou && !isLoser) fg = AppTheme.primary;
    if (isBye || isPending || isLoser) fg = AppTheme.border;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: disabled ? null : onWin,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              if (isWinner) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.check, color: AppTheme.primary, size: 12)),
              Expanded(
                child: Text(isBye ? '— BYE —' : name,
                  style: GoogleFonts.inter(color: fg, fontSize: 12, fontWeight: FontWeight.w500, fontStyle: isBye ? FontStyle.italic : null),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Round Robin Bracket ──

class _RRBracket extends StatelessWidget {
  final String name;
  final List<String> players;
  final Map<String, String> winners;
  final Function(String, String) onWin;
  final VoidCallback onBack, onDone;

  const _RRBracket({required this.name, required this.players, required this.winners, required this.onWin, required this.onBack, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final matches = <List<String>>[];
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        matches.add([players[i], players[j]]);
      }
    }

    final points = <String, int>{};
    for (final p in players) { points[p] = 0; }
    for (int i = 0; i < matches.length; i++) {
      final w = winners['rr$i'];
      if (w != null) points[w] = (points[w] ?? 0) + 2;
    }

    final standings = List<String>.from(players)..sort((a, b) => (points[b] ?? 0).compareTo(points[a] ?? 0));
    final played = winners.length;
    final champion = played == matches.length ? standings.first : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: onBack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Round Robin · ${players.length} players', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 12)),
            Text(name.isEmpty ? 'My Tournament' : name, style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 22)),
          ],
        ),
        backgroundColor: const Color(0xE0111410),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (champion != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1d2a1c), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5))),
                child: Row(
                  children: [
                    Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle), child: const Icon(Icons.emoji_events, color: AppTheme.primaryFg, size: 20)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CHAMPION', style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                        Text(champion, style: GoogleFonts.montserrat(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text('STANDINGS', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Column(
              children: standings.asMap().entries.map((e) {
                final rank = e.key;
                final p = e.value;
                final isTop = rank == 0 && played > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isTop ? const Color(0xFF1d2a1c) : AppTheme.surface,
                    border: Border.all(color: isTop ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: isTop ? AppTheme.primary : AppTheme.surface2, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${rank + 1}', style: GoogleFonts.montserrat(color: isTop ? AppTheme.primaryFg : AppTheme.text3, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(p, style: GoogleFonts.inter(color: p == 'You' ? AppTheme.primary : AppTheme.text1, fontWeight: FontWeight.w500, fontSize: 14))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${points[p]}', style: GoogleFonts.montserrat(color: AppTheme.text1, fontWeight: FontWeight.w700, fontSize: 18)),
                          Text('pts', style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text('MATCHES ($played/${matches.length})', style: GoogleFonts.inter(color: AppTheme.text2, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Column(
              children: matches.asMap().entries.map((e) {
                final i = e.key;
                final p1 = e.value[0];
                final p2 = e.value[1];
                final key = 'rr$i';
                final w = winners[key];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: w != null ? AppTheme.surface.withValues(alpha: 0.6) : AppTheme.surface,
                    border: Border.all(color: w != null ? AppTheme.border.withValues(alpha: 0.6) : AppTheme.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Match ${i + 1}'.toUpperCase(), style: GoogleFonts.inter(color: AppTheme.text3, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.8)),
                          if (w != null) Text('✓ Done', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: w == p1 ? AppTheme.primaryDark : w != null ? AppTheme.background : AppTheme.surface2,
                                foregroundColor: w == p1 ? AppTheme.primary : w != null ? AppTheme.border : AppTheme.text1,
                                elevation: 0,
                                side: BorderSide(color: w == p1 ? AppTheme.primary : AppTheme.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: w == null ? () => onWin(key, p1) : null,
                              child: Text(p1 == 'You' ? '★ You' : p1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('vs', style: GoogleFonts.inter(color: AppTheme.text3, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: w == p2 ? AppTheme.primaryDark : w != null ? AppTheme.background : AppTheme.surface2,
                                foregroundColor: w == p2 ? AppTheme.primary : w != null ? AppTheme.border : AppTheme.text1,
                                elevation: 0,
                                side: BorderSide(color: w == p2 ? AppTheme.primary : AppTheme.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: w == null ? () => onWin(key, p2) : null,
                              child: Text(p2 == 'You' ? '★ You' : p2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onDone,
                child: const Text('Save & Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Models ─────────────────────────────────────────────────────────────

class _TournamentDetail extends StatelessWidget {
  final Tournament tournament;
  final WidgetRef ref;
  final VoidCallback onBack;

  const _TournamentDetail({required this.ref, required this.tournament, required this.onBack});

  void _handleWin(String key, String winner) {
    final updatedWinners = Map<String, String>.from(tournament.winners);
    updatedWinners[key] = winner;
    
    // Check if tournament complete
    String status = 'Active';
    // Simplified logic: if winners map is full, it's Complete.
    
    final t = Tournament(
      id: tournament.id,
      name: tournament.name,
      date: tournament.date,
      type: tournament.type,
      location: tournament.location,
      entryFee: tournament.entryFee,
      status: status,
      participants: tournament.participants,
      result: tournament.result,
      winners: updatedWinners,
    );
    ref.read(tournamentListProvider.notifier).updateTournament(t);
  }

  @override
  Widget build(BuildContext context) {
    if (tournament.type == 'Round Robin') {
      return _RRBracket(
        name: tournament.name, players: tournament.participants, winners: tournament.winners,
        onWin: _handleWin, onBack: onBack, onDone: onBack,
      );
    }
    return _SEBracket(
      name: tournament.name,
      format: tournament.type,
      players: tournament.participants.isEmpty ? ['You', 'Alex', 'Sam', 'Jordan'] : tournament.participants,
      winners: tournament.winners,
      onWin: _handleWin,
      onBack: onBack,
      onDone: onBack,
      isDouble: tournament.type == 'Double Elimination',
    );
  }
}
