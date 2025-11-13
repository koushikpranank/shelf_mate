import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/stock_item.dart';

/// Provider to manage stock items for the current logged-in user.
/// Responsible for loading, adding, updating, deleting items in Hive box.
class StockProvider extends ChangeNotifier {
  String? _currentUser;
  Box<StockItem>? _stockBox;
  List<StockItem> _items = [];

  /// Returns the current list of stock items for the logged-in user.
  List<StockItem> get items => _items;

  /// Initializes provider by opening Hive box and loading items for [currentUser].
  /// Call after login or user change.
  Future<void> init({String? currentUser}) async {
    _currentUser = currentUser;

    if (!Hive.isBoxOpen('stock_items_box')) {
      _stockBox = await Hive.openBox<StockItem>('stock_items_box');
    } else {
      _stockBox = Hive.box<StockItem>('stock_items_box');
    }

    await _loadItems();
  }

  /// Loads stock items from Hive box filtered by current user.
  Future<void> _loadItems() async {
    if (_stockBox == null || _currentUser == null) {
      _items = [];
    } else {
      _items = _stockBox!.values
          .where((item) => item.ownerUsername == _currentUser)
          .toList();
    }
    notifyListeners();
  }

  /// Refreshes the stock items list from storage.
  Future<void> refreshItems() async {
    await _loadItems();
  }

  /// Adds a new [item] to the stock list.
  /// Throws an exception if an item with the same name already exists for the user.
  Future<void> addItem(StockItem item) async {
    if (_stockBox == null) {
      throw Exception('Stock box is not initialized.');
    }

    // Check for duplicate (case-insensitive) item name for the current user
    final exists = _items.any(
      (i) =>
          i.ownerUsername == item.ownerUsername &&
          i.itemName.toLowerCase() == item.itemName.toLowerCase(),
    );

    if (exists) {
      throw Exception('Item with the same name already exists.');
    }

    await _stockBox!.add(item);
    await _loadItems();
  }

  /// Updates an existing stock [item].
  /// Throws if [item] is null or save operation fails.
  Future<void> updateItem(StockItem item) async {
    if (item == null) {
      throw Exception('Cannot update null stock item.');
    }
    await item.save(); // Persist changes to Hive
    await _loadItems(); // Refresh the items list and notify listeners
  }

  /// Deletes a stock [item] from Hive and refreshes list.
  Future<void> deleteItem(StockItem item) async {
    await item.delete();
    await _loadItems();
  }

  /// Clears all stock items and resets user on logout.
  void clearItemsOnLogout() {
    _items = [];
    _currentUser = null;
    notifyListeners();
  }
}
