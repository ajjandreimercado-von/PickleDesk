import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum TournamentFormat { singleElimination, doubleElimination, roundRobin }

class Tournament {
  final String id;
  final String name;
  final DateTime date;
  final TournamentFormat format;
  final double entryFee;
  final String location;
  final List<String> participants;

  Tournament({
    String? id,
    required this.name,
    required this.date,
    required this.format,
    required this.entryFee,
    required this.location,
    this.participants = const [],
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
      format: TournamentFormat.values[reader.readInt()],
      entryFee: reader.readDouble(),
      location: reader.readString(),
      participants: reader.readStringList(),
    );
  }

  @override
  void write(BinaryWriter writer, Tournament obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.format.index);
    writer.writeDouble(obj.entryFee);
    writer.writeString(obj.location);
    writer.writeStringList(obj.participants);
  }
}
