import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String passwordHash;

  @HiveField(2)
  String shopName; // <-- Add this field here

  User({
    required this.username,
    required this.passwordHash,
    this.shopName = '',
  });
}
