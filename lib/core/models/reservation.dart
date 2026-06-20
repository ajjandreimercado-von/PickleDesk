import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Reservation {
  final String id;
  final String courtName;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String notes;

  Reservation({
    String? id,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();
}

class ReservationAdapter extends TypeAdapter<Reservation> {
  @override
  final int typeId = 4;

  @override
  Reservation read(BinaryReader reader) {
    return Reservation(
      id: reader.readString(),
      courtName: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      startTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      status: reader.readString(),
      notes: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Reservation obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.courtName);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.startTime.millisecondsSinceEpoch);
    writer.writeInt(obj.endTime.millisecondsSinceEpoch);
    writer.writeString(obj.status);
    writer.writeString(obj.notes);
  }
}
