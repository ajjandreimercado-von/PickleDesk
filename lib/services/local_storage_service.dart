import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/court.dart';
import '../core/models/player_session.dart';
import '../core/models/expense.dart';
import '../core/models/reservation.dart';
import '../core/models/tournament.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageService {
  static const String courtsBoxName = 'courts';
  static const String sessionsBoxName = 'sessions';
  static const String expensesBoxName = 'expenses';
  static const String reservationsBoxName = 'reservations';
  static const String tournamentsBoxName = 'tournaments';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CourtAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PlayerSessionAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ExpenseAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ReservationAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(TournamentAdapter());

    // Clean up potentially corrupted lock files
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      for (var file in files) {
        if (file.path.endsWith('.lock') || file.path.endsWith('.hivec')) {
          try {
            await File(file.path).delete();
          } catch (e) {
            print("Could not delete lock file: ${file.path}");
          }
        }
      }
    } catch (e) {
      print("Error cleaning up hive files: $e");
    }

    // Safely open boxes
    await _safeOpenBox<Court>(courtsBoxName);
    await _safeOpenBox<PlayerSession>(sessionsBoxName);
    await _safeOpenBox<Expense>(expensesBoxName);
    await _safeOpenBox<Reservation>(reservationsBoxName);
    await _safeOpenBox<Tournament>(tournamentsBoxName);
  }

  static Future<void> _safeOpenBox<T>(String boxName) async {
    try {
      await Hive.openBox<T>(boxName);
    } catch (e) {
      print("Error opening box $boxName: $e. Deleting and reopening.");
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox<T>(boxName);
    }
  }
}
