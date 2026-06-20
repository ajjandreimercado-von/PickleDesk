import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'court_providers.dart';

class CourtsScreen extends ConsumerWidget {
  const CourtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courts = ref.watch(courtListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courts', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('My Courts', style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: courts.isEmpty
                ? const Center(child: Text('No courts added', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      final court = courts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF253028)),
                        ),
                        child: Row(
                          children: [
                            // Placeholder for Court Image
                            Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              child: const Icon(Icons.sports_tennis, color: Colors.green),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                        const Icon(Icons.favorite, color: Colors.red, size: 16),
                                      ],
                                    ),
                                    Text(court.isIndoor ? 'Indoor' : 'Outdoor', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('24', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                            const Text('Sessions', style: TextStyle(fontSize: 10, color: Colors.white54)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('May 21', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                            const Text('Last played', style: TextStyle(fontSize: 10, color: Colors.white54)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.chevron_right, color: Colors.white54),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/add-court'),
                icon: const Icon(Icons.add),
                label: const Text('Add Court'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
