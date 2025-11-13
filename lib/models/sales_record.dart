import 'package:hive/hive.dart';

part 'sales_record.g.dart';

@HiveType(
  typeId: 3,
) // Make sure to use a unique typeId different from your other Hive models
class SalesRecord extends HiveObject {
  @HiveField(0)
  String ownerUsername;

  @HiveField(1)
  String itemName;

  @HiveField(2)
  int quantitySold;

  @HiveField(3)
  double price;

  @HiveField(4)
  DateTime saleDate;

  SalesRecord({
    required this.ownerUsername,
    required this.itemName,
    required this.quantitySold,
    required this.price,
    required this.saleDate,
  });
}
