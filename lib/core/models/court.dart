import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Court {
  final String id;
  final String name;
  final String location;
  final bool isIndoor;
  final String surfaceType;
  final String notes;

  Court({
    String? id,
    required this.name,
    this.location = '',
    this.isIndoor = false,
    this.surfaceType = '',
    this.notes = '',
  }) : id = id ?? const Uuid().v4();
}

class CourtAdapter extends TypeAdapter<Court> {
  @override
  final int typeId = 1;

  @override
  Court read(BinaryReader reader) {
    return Court(
      id: reader.readString(),
      name: reader.readString(),
      location: reader.readString(),
      isIndoor: reader.readBool(),
      surfaceType: reader.readString(),
      notes: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Court obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.location);
    writer.writeBool(obj.isIndoor);
    writer.writeString(obj.surfaceType);
    writer.writeString(obj.notes);
  }
}
