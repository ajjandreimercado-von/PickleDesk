import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/court.dart';
import '../../repositories/providers.dart';

class CourtListNotifier extends Notifier<List<Court>> {
  StreamSubscription? _subscription;

  @override
  List<Court> build() {
    final repo = ref.watch(courtRepositoryProvider);
    
    // Listen to Hive box changes
    _subscription = repo.watch().listen((event) {
      state = repo.getAll();
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return repo.getAll();
  }

  Future<void> addCourt(Court court) async {
    final repo = ref.read(courtRepositoryProvider);
    await repo.add(court);
    // State is automatically updated via the listener
  }

  Future<void> deleteCourt(String id) async {
    final repo = ref.read(courtRepositoryProvider);
    await repo.delete(id);
  }
}

final courtListProvider = NotifierProvider<CourtListNotifier, List<Court>>(
  CourtListNotifier.new,
);
