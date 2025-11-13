import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/sales_record.dart';

/// Provider to manage sales records for the current logged-in user.
/// Responsible for loading, adding, updating, deleting sales in Hive box.
class SalesProvider extends ChangeNotifier {
  String? _currentUser;
  Box<SalesRecord>? _salesBox;
  List<SalesRecord> _sales = [];

  /// Returns the list of sales for the current user.
  List<SalesRecord> get sales => _sales;

  /// Initialize the provider by opening Hive box and loading sales for [currentUser].
  /// Call this after login or user switch.
  Future<void> init({String? currentUser}) async {
    _currentUser = currentUser;
    debugPrint('Initializing SalesProvider for user: $_currentUser');

    if (!Hive.isBoxOpen('sales_box')) {
      debugPrint('Opening Hive box: sales_box');
      _salesBox = await Hive.openBox<SalesRecord>('sales_box');
    } else {
      debugPrint('Hive box already open: sales_box');
      _salesBox = Hive.box<SalesRecord>('sales_box');
    }

    await _loadSales();
  }

  /// Loads sales for the current user from Hive box.
  Future<void> _loadSales() async {
    if (_salesBox == null || _currentUser == null) {
      _sales = [];
    } else {
      _sales = _salesBox!.values
          .where((sale) => sale.ownerUsername == _currentUser)
          .toList();
    }
    debugPrint("Loaded ${_sales.length} sales for user $_currentUser");
    notifyListeners();
  }

  /// Adds a new sale record and refreshes the sales list.
  Future<void> addSale(SalesRecord sale) async {
    if (_salesBox == null) {
      throw Exception('Sales box is not initialized.');
    }

    debugPrint(
      'Adding sale: ${sale.itemName}, qty: ${sale.quantitySold}, price: ${sale.price} for user: ${sale.ownerUsername}',
    );
    await _salesBox!.add(sale);
    await _loadSales();
    debugPrint('Sale added successfully.');
  }

  /// Updates an existing sale record and reloads the sales list.
  Future<void> updateSale(SalesRecord sale) async {
    debugPrint('Updating sale id: ${sale.key} for user: ${sale.ownerUsername}');
    await sale.save();
    await _loadSales();
  }

  /// Deletes a sale record and reloads the sales list.
  Future<void> deleteSale(SalesRecord sale) async {
    debugPrint('Deleting sale id: ${sale.key} for user: ${sale.ownerUsername}');
    await sale.delete();
    await _loadSales();
  }

  /// Clears cached sales and resets current user info.
  void clearSalesOnLogout() {
    debugPrint('Clearing sales data and current user');
    _sales = [];
    _currentUser = null;
    notifyListeners();
  }

  /// Computes total sales amounts for each of the last 7 days.
  /// Returns a list indexed 0..6 from oldest to newest day.
  List<double> getDailySalesTotals() {
    if (_currentUser == null) {
      debugPrint('No current user, returning empty daily sales totals.');
      return [];
    }

    final now = DateTime.now();
    List<double> dailyTotals = List.filled(7, 0.0);

    for (var sale in _sales) {
      final daysDiff = now.difference(sale.saleDate).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        dailyTotals[6 - daysDiff] += sale.price * sale.quantitySold;
      }
    }

    debugPrint('Daily sales totals: $dailyTotals');
    return dailyTotals;
  }

  /// Returns a map of category to total sales amount, using [itemCategoryMap]
  /// to map item names (case-insensitive) to categories. Defaults to 'Others'.
  /// Only returns data if [currentUser] matches the logged-in user.
  Map<String, double> getCategorySalesData(
    String currentUser, {
    Map<String, String>? itemCategoryMap,
  }) {
    if (_currentUser == null) {
      debugPrint('No current user, returning empty category sales data.');
      return {};
    }
    if (currentUser != _currentUser) {
      debugPrint(
        'Current user mismatch: $currentUser != $_currentUser. Returning empty data.',
      );
      return {};
    }

    final Map<String, double> totals = {};

    for (var sale in _sales) {
      final itemNameLower = sale.itemName.toLowerCase();
      final category = itemCategoryMap != null
          ? (itemCategoryMap[itemNameLower] ?? 'Others')
          : 'Others';

      totals[category] =
          (totals[category] ?? 0.0) + sale.price * sale.quantitySold;
    }

    debugPrint('Category sales data: $totals');
    return totals;
  }
}
