// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesRecordAdapter extends TypeAdapter<SalesRecord> {
  @override
  final int typeId = 3;

  @override
  SalesRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesRecord(
      ownerUsername: fields[0] as String,
      itemName: fields[1] as String,
      quantitySold: fields[2] as int,
      price: fields[3] as double,
      saleDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SalesRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ownerUsername)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.quantitySold)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.saleDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
