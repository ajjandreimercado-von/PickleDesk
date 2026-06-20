import 'package:hive/hive.dart';

class Settings {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final int defaultSessionDurationMinutes;

  Settings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.defaultSessionDurationMinutes = 60,
  });

  Settings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    int? defaultSessionDurationMinutes,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultSessionDurationMinutes: defaultSessionDurationMinutes ?? this.defaultSessionDurationMinutes,
    );
  }
}

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 7;

  @override
  Settings read(BinaryReader reader) {
    return Settings(
      isDarkMode: reader.readBool(),
      notificationsEnabled: reader.readBool(),
      defaultSessionDurationMinutes: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.writeBool(obj.isDarkMode);
    writer.writeBool(obj.notificationsEnabled);
    writer.writeInt(obj.defaultSessionDurationMinutes);
  }
}
