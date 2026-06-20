import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum ReservationStatus { upcoming, completed, cancelled }

class Reservation {
  final String id;
  final String courtId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String notes;
  final ReservationStatus status;

  Reservation({
    String? id,
    required this.courtId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.notes = '',
    this.status = ReservationStatus.upcoming,
  }) : id = id ?? const Uuid().v4();
}

class ReservationAdapter extends TypeAdapter<Reservation> {
  @override
  final int typeId = 3;

  @override
  Reservation read(BinaryReader reader) {
    return Reservation(
      id: reader.readString(),
      courtId: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      startTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      notes: reader.readString(),
      status: ReservationStatus.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, Reservation obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.courtId);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.startTime.millisecondsSinceEpoch);
    writer.writeInt(obj.endTime.millisecondsSinceEpoch);
    writer.writeString(obj.notes);
    writer.writeInt(obj.status.index);
  }
}
