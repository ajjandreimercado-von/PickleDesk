import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class PlayerSession {
  final String id;
  final String courtId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> opponents;
  final String notes;

  PlayerSession({
    String? id,
    required this.courtId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.opponents = const [],
    this.notes = '',
  }) : id = id ?? const Uuid().v4();

  Duration get duration => endTime.difference(startTime);
}

class PlayerSessionAdapter extends TypeAdapter<PlayerSession> {
  @override
  final int typeId = 2;

  @override
  PlayerSession read(BinaryReader reader) {
    return PlayerSession(
      id: reader.readString(),
      courtId: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      startTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      endTime: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      opponents: reader.readStringList(),
      notes: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, PlayerSession obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.courtId);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.startTime.millisecondsSinceEpoch);
    writer.writeInt(obj.endTime.millisecondsSinceEpoch);
    writer.writeStringList(obj.opponents);
    writer.writeString(obj.notes);
  }
}
