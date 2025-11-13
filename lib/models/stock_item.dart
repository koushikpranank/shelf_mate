import 'package:hive/hive.dart';

part 'stock_item.g.dart';

@HiveType(typeId: 2)
class StockItem extends HiveObject {
  @HiveField(0)
  String ownerUsername;

  @HiveField(1)
  String itemName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double price;

  StockItem({
    required this.ownerUsername,
    required this.itemName,
    required this.quantity,
    required this.price,
  });
}
