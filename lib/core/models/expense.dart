import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String notes;

  Expense({
    String? id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 3;

  @override
  Expense read(BinaryReader reader) {
    return Expense(
      id: reader.readString(),
      amount: reader.readDouble(),
      category: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      notes: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.notes);
  }
}
