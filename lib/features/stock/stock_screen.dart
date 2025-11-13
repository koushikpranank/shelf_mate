import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/stock_item.dart';
import '../../providers/stock_provider.dart';
import '../../providers/session_provider.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final currentUser = sessionProvider.loggedInUser?.username;
    // Initialize stock data for current user
    stockProvider.init(currentUser: currentUser);
  }

  Future<void> addItem(BuildContext context) async {
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    final currentUser = sessionProvider.loggedInUser?.username;
    if (currentUser == null || currentUser.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    final newStockItem = await showDialog<StockItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Qty'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text) ?? 0;
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (name.isEmpty || qty <= 0 || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid values')),
                  );
                  return;
                }
                final stockItem = StockItem(
                  ownerUsername: currentUser,
                  itemName: name,
                  quantity: qty,
                  price: price,
                );
                Navigator.pop(context, stockItem);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newStockItem != null) {
      await stockProvider.addItem(newStockItem);
    }
  }

  Future<void> editItem(BuildContext context, StockItem item) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    final nameCtrl = TextEditingController(text: item.itemName);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final qtyCtrl = TextEditingController(text: item.quantity.toString());

    final editedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Qty'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameCtrl.text.trim(),
                  'price': double.tryParse(priceCtrl.text) ?? 0.0,
                  'qty': int.tryParse(qtyCtrl.text) ?? 0,
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (editedData != null) {
      item.itemName = editedData['name'];
      item.price = editedData['price'];
      item.quantity = editedData['qty'];
      await stockProvider.updateItem(item);
    }
  }

  void removeItem(BuildContext context, StockItem item) {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '${item.itemName}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await stockProvider.deleteItem(item);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addItem(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<StockProvider>(
        builder: (context, stockProvider, _) {
          final items = stockProvider.items;
          if (items.isEmpty) {
            return const Center(child: Text('No stock items found. Add some!'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, idx) {
              final item = items[idx];
              return Card(
                child: ListTile(
                  title: Text(item.itemName),
                  subtitle: Text(
                    'Qty: ${item.quantity} - ₹${item.price.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editItem(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => removeItem(context, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
