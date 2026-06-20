import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/tournament.dart';
import '../../services/local_storage_service.dart';

class TournamentListNotifier extends Notifier<List<Tournament>> {
  @override
  List<Tournament> build() {
    final box = Hive.box<Tournament>(LocalStorageService.tournamentsBoxName);
    return box.values.toList().cast<Tournament>();
  }

  Future<void> addTournament(Tournament tournament) async {
    final box = Hive.box<Tournament>(LocalStorageService.tournamentsBoxName);
    await box.put(tournament.id, tournament);
    state = box.values.toList().cast<Tournament>();
  }

  Future<void> updateTournament(Tournament tournament) async {
    final box = Hive.box<Tournament>(LocalStorageService.tournamentsBoxName);
    await box.put(tournament.id, tournament);
    state = box.values.toList().cast<Tournament>();
  }

  Future<void> deleteTournament(String id) async {
    final box = Hive.box<Tournament>(LocalStorageService.tournamentsBoxName);
    await box.delete(id);
    state = box.values.toList().cast<Tournament>();
  }
}

final tournamentListProvider = NotifierProvider<TournamentListNotifier, List<Tournament>>(
  TournamentListNotifier.new,
);
