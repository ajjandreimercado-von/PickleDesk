import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/player_session.dart';
import '../courts/court_providers.dart';
import 'session_providers.dart';

class AddSessionScreen extends ConsumerStatefulWidget {
  const AddSessionScreen({super.key});

  @override
  ConsumerState<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends ConsumerState<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _opponentsController = TextEditingController();
  
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  String? _selectedCourtId;
  String _result = 'D';

  void _saveSession() {
    if (_formKey.currentState!.validate() && _selectedCourtId != null) {
      final start = DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute);
      final end = DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute);
      
      final opponentsList = _opponentsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newSession = PlayerSession(
        courtId: _selectedCourtId!,
        date: _date,
        startTime: start,
        endTime: end,
        opponents: opponentsList,
        notes: _notesController.text.trim(),
        result: _result,
        sessionType: 'Match',
      );

      ref.read(sessionListProvider.notifier).addSession(newSession);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session logged!')),
      );
      
      context.pop();
    } else if (_selectedCourtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a court.')),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _opponentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courts = ref.watch(courtListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Session', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Court'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCourtId,
                dropdownColor: Theme.of(context).cardTheme.color,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                items: courts.map((court) {
                  return DropdownMenuItem<String>(
                    value: court.id,
                    child: Text(court.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCourtId = val),
                validator: (value) => value == null ? 'Please select a court' : null,
              ),
              if (courts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 12),
                  child: Text('No courts available. Add a court first!', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  const Text('Date', style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectDate,
                    child: Text('${_date.month}/${_date.day}/${_date.year}', style: const TextStyle(color: Colors.white)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                ],
              ),
              const Divider(color: Color(0xFF253028)),
              Row(
                children: [
                  const Text('Start Time', style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectTime(true),
                    child: Text(_startTime.format(context), style: const TextStyle(color: Colors.white)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                ],
              ),
              const Divider(color: Color(0xFF253028)),
              Row(
                children: [
                  const Text('End Time', style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectTime(false),
                    child: Text(_endTime.format(context), style: const TextStyle(color: Colors.white)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Opponents'),
              TextFormField(
                controller: _opponentsController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'e.g. Alex, Sam',
                  prefixIcon: Icon(Icons.people_outline),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Result'),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'W', label: Text('Win')),
                  ButtonSegment(value: 'L', label: Text('Loss')),
                  ButtonSegment(value: 'D', label: Text('Draw/Practice')),
                ],
                selected: {_result},
                onSelectionChanged: (set) => setState(() => _result = set.first),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Notes'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Great morning session!',
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Duration Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF253028)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Duration', '1h 30m'), // Mocked duration calculation
                    Container(width: 1, height: 40, color: const Color(0xFF253028)),
                    _buildStatCol('Total Play Hours', '12.5h'), // Mocked total
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSession,
                  child: const Text('Save Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
