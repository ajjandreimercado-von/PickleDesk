import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/models/court.dart';
import '../core/models/match.dart';
import '../core/models/payment.dart';
import '../core/models/player_session.dart';
import '../core/models/reservation.dart';
import '../core/models/settings.dart';
import '../core/models/tournament.dart';
import 'base_repository.dart';

final courtRepositoryProvider = Provider<BaseRepository<Court>>((ref) {
  return BaseRepository<Court>(Hive.box<Court>('courts'));
});

final sessionRepositoryProvider = Provider<BaseRepository<PlayerSession>>((ref) {
  return BaseRepository<PlayerSession>(Hive.box<PlayerSession>('sessions'));
});

final reservationRepositoryProvider = Provider<BaseRepository<Reservation>>((ref) {
  return BaseRepository<Reservation>(Hive.box<Reservation>('reservations'));
});

final paymentRepositoryProvider = Provider<BaseRepository<Payment>>((ref) {
  return BaseRepository<Payment>(Hive.box<Payment>('payments'));
});

final tournamentRepositoryProvider = Provider<BaseRepository<Tournament>>((ref) {
  return BaseRepository<Tournament>(Hive.box<Tournament>('tournaments'));
});

final matchRepositoryProvider = Provider<BaseRepository<Match>>((ref) {
  return BaseRepository<Match>(Hive.box<Match>('matches'));
});

final settingsRepositoryProvider = Provider<BaseRepository<Settings>>((ref) {
  return BaseRepository<Settings>(Hive.box<Settings>('settings'));
});
