import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/player_session.dart';
import '../../repositories/providers.dart';

class SessionListNotifier extends Notifier<List<PlayerSession>> {
  StreamSubscription? _subscription;

  @override
  List<PlayerSession> build() {
    final repo = ref.watch(sessionRepositoryProvider);
    
    _subscription = repo.watch().listen((event) {
      final allSessions = repo.getAll();
      allSessions.sort((a, b) => b.date.compareTo(a.date)); // Newest first
      state = allSessions;
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    final allSessions = repo.getAll();
    allSessions.sort((a, b) => b.date.compareTo(a.date));
    return allSessions;
  }

  Future<void> addSession(PlayerSession session) async {
    final repo = ref.read(sessionRepositoryProvider);
    await repo.add(session);
  }

  Future<void> deleteSession(String id) async {
    final repo = ref.read(sessionRepositoryProvider);
    await repo.delete(id);
  }
}

final sessionListProvider = NotifierProvider<SessionListNotifier, List<PlayerSession>>(
  SessionListNotifier.new,
);
