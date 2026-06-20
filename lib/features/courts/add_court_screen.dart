import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/court.dart';
import 'court_providers.dart';

class AddCourtScreen extends ConsumerStatefulWidget {
  const AddCourtScreen({super.key});

  @override
  ConsumerState<AddCourtScreen> createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends ConsumerState<AddCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isIndoor = false;
  String _surfaceType = 'Hard Court';

  final List<String> _surfaceOptions = ['Hard Court', 'Clay', 'Grass', 'Wood', 'Other'];

  void _saveCourt() {
    if (_formKey.currentState!.validate()) {
      final newCourt = Court(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        isIndoor: _isIndoor,
        surfaceType: _surfaceType,
        notes: _notesController.text.trim(),
      );

      ref.read(courtListProvider.notifier).addCourt(newCourt);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Court saved!')),
      );
      
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Court', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('Court Details', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Court Name *',
                  prefixIcon: Icon(Icons.sports_tennis),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Location / Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF253028)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Indoor Court', style: TextStyle(color: Colors.white)),
                      value: _isIndoor,
                      onChanged: (val) => setState(() => _isIndoor = val),
                      secondary: const Icon(Icons.roofing, color: Colors.white54),
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                    ),
                    const Divider(color: Color(0xFF253028), height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: _surfaceType,
                        dropdownColor: Theme.of(context).cardTheme.color,
                        decoration: const InputDecoration(
                          hintText: 'Surface Type',
                          prefixIcon: Icon(Icons.layers_outlined),
                          filled: false, // Override to remove background fill in the card
                        ),
                        items: _surfaceOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _surfaceType = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('Notes', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Optional details about the court...',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCourt,
                  child: const Text('Save Court'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
