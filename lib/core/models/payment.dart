import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum ExpenseCategory { courtFee, tournamentFee, equipment, coaching, miscellaneous }

class Payment {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String notes;

  Payment({
    String? id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();
}

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 4;

  @override
  Payment read(BinaryReader reader) {
    return Payment(
      id: reader.readString(),
      amount: reader.readDouble(),
      category: ExpenseCategory.values[reader.readInt()],
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      notes: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.category.index);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.notes);
  }
}
