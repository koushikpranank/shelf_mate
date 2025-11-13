# Ensure lib/models directory exists
$modelsPath = "lib\models"
if (-not (Test-Path $modelsPath)) {
    New-Item -ItemType Directory -Path $modelsPath | Out-Null
}

# Create sales_record.dart if it doesn't exist
$salesRecordPath = "$modelsPath\sales_record.dart"
if (-not (Test-Path $salesRecordPath)) {
@"
import 'package:hive/hive.dart';

part 'sales_record.g.dart';

@HiveType(typeId: 3)  // Unique typeId, adjust if conflicts
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
"@ | Set-Content $salesRecordPath -Encoding UTF8

    Write-Output "Created: lib/models/sales_record.dart"
} else {
    Write-Output "Skipped: lib/models/sales_record.dart already exists"
}

# Ensure lib/providers directory exists
$providersPath = "lib\providers"
if (-not (Test-Path $providersPath)) {
    New-Item -ItemType Directory -Path $providersPath | Out-Null
}

# Create sales_provider.dart if it doesn't exist
$salesProviderPath = "$providersPath\sales_provider.dart"
if (-not (Test-Path $salesProviderPath)) {
@"
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/sales_record.dart';

class SalesProvider extends ChangeNotifier {
  String? _currentUser;
  Box<SalesRecord>? _salesBox;
  List<SalesRecord> _sales = [];

  List<SalesRecord> get sales => _sales;

  /// Initialize provider with optional currentUser.
  /// Call this before usage or when user changes.
  Future<void> init({String? currentUser}) async {
    _currentUser = currentUser;

    if (!Hive.isBoxOpen('sales_box')) {
      _salesBox = await Hive.openBox<SalesRecord>('sales_box');
    } else {
      _salesBox = Hive.box<SalesRecord>('sales_box');
    }

    await _loadSales();
  }

  Future<void> _loadSales() async {
    if (_salesBox == null || _currentUser == null) {
      _sales = [];
    } else {
      _sales = _salesBox!.values
          .where((sale) => sale.ownerUsername == _currentUser)
          .toList();
    }
    notifyListeners();
  }

  Future<void> addSale(SalesRecord sale) async {
    await _salesBox!.add(sale);
    await _loadSales();
  }

  Future<void> updateSale(SalesRecord sale) async {
    await sale.save();
    await _loadSales();
  }

  Future<void> deleteSale(SalesRecord sale) async {
    await sale.delete();
    await _loadSales();
  }

  /// Call this when user logs out to clear cached sales data
  void clearSalesOnLogout() {
    _sales = [];
    _currentUser = null;
    notifyListeners();
  }

  /// Aggregate daily sales totals for last 7 days, ordered oldest first
  List<double> getDailySalesTotals() {
    if (_currentUser == null) return [];

    final now = DateTime.now();
    List<double> dailyTotals = List.filled(7, 0.0);

    for (var sale in _sales) {
      final daysDiff = now.difference(sale.saleDate).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        // Aggregate sales amount = sale.price * sale.quantitySold
        dailyTotals[6 - daysDiff] += sale.price * sale.quantitySold;
      }
    }

    return dailyTotals;
  }

  /// Category-wise sales totals assuming your SalesRecord's itemName can be mapped to categories externally
  /// Here we simulate — you may want to expand your SalesRecord with `category` field for accuracy
  Map<String, double> getCategorySalesTotals(Map<String, String> itemNameToCategory) {
    final Map<String, double> totals = {};

    for (var sale in _sales) {
      final category = itemNameToCategory[sale.itemName.toLowerCase()] ?? 'Others';
      totals[category] = (totals[category] ?? 0.0) + sale.price * sale.quantitySold;
    }

    return totals;
  }
}
"@ | Set-Content $salesProviderPath -Encoding UTF8

    Write-Output "Created: lib/providers/sales_provider.dart"
} else {
    Write-Output "Skipped: lib/providers/sales_provider.dart already exists"
}
