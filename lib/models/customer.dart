import 'package:hive/hive.dart';
import 'payment_entry.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? mobile;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  double paidAmount;

  @HiveField(4)
  List<PaymentEntry> paymentHistory;

  Customer({
    required this.name,
    this.mobile,
    required this.totalAmount,
    this.paidAmount = 0,
    List<PaymentEntry>? paymentHistory,
  }) : paymentHistory = paymentHistory ?? [];

  double get remainingAmount => totalAmount - paidAmount;

  bool get isFullyPaid => remainingAmount <= 0;
}
