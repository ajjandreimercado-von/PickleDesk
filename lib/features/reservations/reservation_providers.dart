import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/reservation.dart';
import '../../services/local_storage_service.dart';

class ReservationListNotifier extends Notifier<List<Reservation>> {
  @override
  List<Reservation> build() {
    final box = Hive.box<Reservation>(LocalStorageService.reservationsBoxName);
    return box.values.toList().cast<Reservation>();
  }

  Future<void> addReservation(Reservation reservation) async {
    final box = Hive.box<Reservation>(LocalStorageService.reservationsBoxName);
    await box.put(reservation.id, reservation);
    state = box.values.toList().cast<Reservation>();
  }

  Future<void> deleteReservation(String id) async {
    final box = Hive.box<Reservation>(LocalStorageService.reservationsBoxName);
    await box.delete(id);
    state = box.values.toList().cast<Reservation>();
  }
}

final reservationListProvider = NotifierProvider<ReservationListNotifier, List<Reservation>>(
  ReservationListNotifier.new,
);
