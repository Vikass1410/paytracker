// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentEntryAdapter extends TypeAdapter<PaymentEntry> {
  @override
  final int typeId = 1;

  @override
  PaymentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentEntry(
      date: fields[0] as DateTime,
      amount: fields[1] as double,
      note: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
