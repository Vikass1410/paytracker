import 'package:hive/hive.dart';

part 'payment_entry.g.dart';

@HiveType(typeId: 1)
class PaymentEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String note;

  PaymentEntry({
    required this.date,
    required this.amount,
    this.note = '',
  });
}
