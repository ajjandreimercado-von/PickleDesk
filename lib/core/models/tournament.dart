import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Tournament {
  final String id;
  final String name;
  final DateTime date;
  final String type;
  final String location;
  final double entryFee;
  final String status;
  final List<String> participants;
  final String? result;
  final Map<String, String> winners;

  Tournament({
    String? id,
    required this.name,
    required this.date,
    required this.type,
    required this.location,
    required this.entryFee,
    required this.status,
    this.participants = const [],
    this.result,
    this.winners = const {},
  }) : id = id ?? const Uuid().v4();
}

class TournamentAdapter extends TypeAdapter<Tournament> {
  @override
  final int typeId = 5;

  @override
  Tournament read(BinaryReader reader) {
    return Tournament(
      id: reader.readString(),
      name: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      type: reader.readString(),
      location: reader.readString(),
      entryFee: reader.readDouble(),
      status: reader.readString(),
      participants: reader.readStringList(),
      result: reader.readString(),
      winners: Map<String, String>.from(reader.readMap()),
    );
  }

  @override
  void write(BinaryWriter writer, Tournament obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.type);
    writer.writeString(obj.location);
    writer.writeDouble(obj.entryFee);
    writer.writeString(obj.status);
    writer.writeStringList(obj.participants);
    writer.writeString(obj.result ?? '');
    writer.writeMap(obj.winners);
  }
}
