import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/stock_item.dart';
import 'package:collection/collection.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // Cart: stock item Hive key -> quantity selected
  final Map<dynamic, int> cart = {};

  // Add 1 quantity to cart for the given key, if stock permits
  void addToCart(dynamic key, int stockQty) {
    setState(() {
      final currentQty = cart[key] ?? 0;
      if (currentQty < stockQty) {
        cart[key] = currentQty + 1;
        debugPrint("Added 1 to cart for key=$key; cart quantity=${cart[key]}");
      } else {
        debugPrint(
          "Cannot add more for key=$key; reached stock limit=$stockQty",
        );
      }
    });
  }

  // Remove 1 quantity from cart for the given key
  void removeFromCart(dynamic key) {
    setState(() {
      if (!cart.containsKey(key)) return;

      final currentQty = cart[key]!;
      if (currentQty <= 1) {
        cart.remove(key);
        debugPrint("Removed item from cart for key=$key");
      } else {
        cart[key] = currentQty - 1;
        debugPrint(
          "Decreased cart qty for key=$key; new quantity=${cart[key]}",
        );
      }
    });
  }

  // Calculate total price in cart
  double getTotal(Map<dynamic, int> cart, List<StockItem> products) {
    double sum = 0;
    for (var entry in cart.entries) {
      final key = entry.key;
      final qty = entry.value;
      final product = products.firstWhereOrNull((p) => p.key == key);
      if (product == null) {
        debugPrint("Product with key=$key not found, skipping in total calc.");
        continue;
      }
      sum += product.price * qty;
    }
    debugPrint("Calculated total price: $sum for cart items.");
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales & Billing')),
      body: Consumer<StockProvider>(
        builder: (context, stockProvider, _) {
          final products = stockProvider.items;

          if (products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, idx) {
                    final product = products[idx];
                    final id = product.key;
                    final inCartQty = cart[id] ?? 0;

                    return ListTile(
                      title: Text(product.itemName),
                      subtitle: Text(
                        '₹${product.price.toStringAsFixed(2)} | Stock: ${product.quantity}',
                      ),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: inCartQty > 0
                                  ? () => removeFromCart(id)
                                  : null,
                              tooltip: 'Remove one',
                            ),
                            Text(
                              '$inCartQty',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: inCartQty < product.quantity
                                  ? () => addToCart(id, product.quantity)
                                  : null,
                              tooltip: 'Add one',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '₹${getTotal(cart, products).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              final totalAmount = getTotal(cart, products);
                              debugPrint(
                                "Generating invoice with total: $totalAmount and ${cart.length} items.",
                              );

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Invoice'),
                                  content: Text(
                                    'Total: ₹${totalAmount.toStringAsFixed(2)}\n'
                                    'Number of unique items: ${cart.length}',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                      child: const Text('Generate Invoice'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
