import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Match {
  final String id;
  final String tournamentId;
  final int round;
  final String player1;
  final String player2;
  final int score1;
  final int score2;
  final String? winnerId;

  Match({
    String? id,
    required this.tournamentId,
    required this.round,
    required this.player1,
    required this.player2,
    this.score1 = 0,
    this.score2 = 0,
    this.winnerId,
  }) : id = id ?? const Uuid().v4();
}

class MatchAdapter extends TypeAdapter<Match> {
  @override
  final int typeId = 6;

  @override
  Match read(BinaryReader reader) {
    return Match(
      id: reader.readString(),
      tournamentId: reader.readString(),
      round: reader.readInt(),
      player1: reader.readString(),
      player2: reader.readString(),
      score1: reader.readInt(),
      score2: reader.readInt(),
      winnerId: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Match obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.tournamentId);
    writer.writeInt(obj.round);
    writer.writeString(obj.player1);
    writer.writeString(obj.player2);
    writer.writeInt(obj.score1);
    writer.writeInt(obj.score2);
    if (obj.winnerId != null) {
      writer.writeBool(true);
      writer.writeString(obj.winnerId!);
    } else {
      writer.writeBool(false);
    }
  }
}
