import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/court.dart';
import '../core/models/match.dart';
import '../core/models/payment.dart';
import '../core/models/player_session.dart';
import '../core/models/reservation.dart';
import '../core/models/settings.dart';
import '../core/models/tournament.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(CourtAdapter());
    Hive.registerAdapter(PlayerSessionAdapter());
    Hive.registerAdapter(ReservationAdapter());
    Hive.registerAdapter(PaymentAdapter());
    Hive.registerAdapter(TournamentAdapter());
    Hive.registerAdapter(MatchAdapter());
    Hive.registerAdapter(SettingsAdapter());

    // Open Boxes with corruption recovery
    await _openBoxSafe<Court>('courts');
    await _openBoxSafe<PlayerSession>('sessions');
    await _openBoxSafe<Reservation>('reservations');
    await _openBoxSafe<Payment>('payments');
    await _openBoxSafe<Tournament>('tournaments');
    await _openBoxSafe<Match>('matches');
    await _openBoxSafe<Settings>('settings');
  }

  /// Opens a Hive box. If the box is corrupt, it deletes it and opens a fresh one.
  static Future<Box<T>> _openBoxSafe<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      // Box is corrupt (e.g. from a previous incompatible TypeAdapter).
      // Delete the box from disk and open a fresh empty box.
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<T>(boxName);
    }
  }
}
