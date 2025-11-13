import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart'; // for firstWhereOrNull

import '../../models/stock_item.dart';
import '../../models/sales_record.dart';
import '../../providers/session_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/sales_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sessionProvider = Provider.of<SessionProvider>(
        context,
        listen: false,
      );
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      if (sessionProvider.loggedInUser != null) {
        await salesProvider.init(
          currentUser: sessionProvider.loggedInUser!.username,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddSaleDialog(BuildContext context) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    final currentUser = sessionProvider.loggedInUser;

    final formKey = GlobalKey<FormState>();
    String? selectedProduct;
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final selectedStockItem = selectedProduct == null
                ? null
                : stockProvider.items.firstWhereOrNull(
                    (item) => item.itemName == selectedProduct,
                  );

            return AlertDialog(
              title: const Text('Add Sale'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Product',
                          ),
                          items: stockProvider.items
                              .where((item) => item.quantity > 0)
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.itemName,
                                  child: Text(item.itemName),
                                ),
                              )
                              .toList(),
                          value: selectedProduct,
                          onChanged: (val) {
                            setState(() {
                              selectedProduct = val;
                              qtyController.text = '';
                            });
                          },
                          validator: (val) => val == null || val.isEmpty
                              ? 'Select a product'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        if (selectedStockItem != null &&
                            selectedStockItem.quantity == 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'No stock available for this item!',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        TextFormField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Quantity Sold',
                            errorText: (() {
                              if (qtyController.text.isEmpty) return null;
                              final inputQty = int.tryParse(qtyController.text);
                              if (inputQty == null || inputQty <= 0)
                                return 'Enter valid quantity';
                              if (selectedStockItem != null &&
                                  inputQty > selectedStockItem.quantity) {
                                return 'Only ${selectedStockItem.quantity} available';
                              }
                              return null;
                            })(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter quantity';
                            }
                            final n = int.tryParse(val);
                            if (n == null || n <= 0) {
                              return 'Enter valid quantity';
                            }
                            if (selectedStockItem != null &&
                                n > selectedStockItem.quantity) {
                              return 'Only ${selectedStockItem.quantity} available';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Price per unit',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter price';
                            }
                            final n = double.tryParse(val);
                            if (n == null || n <= 0) return 'Enter valid price';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;

                    if (currentUser == null || currentUser.username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No logged-in user found'),
                        ),
                      );
                      return;
                    }

                    if (selectedStockItem == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product not found in stock'),
                        ),
                      );
                      return;
                    }

                    if (selectedStockItem.quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No stock available for this item!'),
                        ),
                      );
                      return;
                    }

                    final qty = int.parse(qtyController.text.trim());
                    final price = double.parse(priceController.text.trim());

                    if (qty > selectedStockItem.quantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Only ${selectedStockItem.quantity} in stock',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await salesProvider.addSale(
                        SalesRecord(
                          ownerUsername: currentUser.username,
                          itemName: selectedProduct!,
                          quantitySold: qty,
                          price: price,
                          saleDate: DateTime.now(),
                        ),
                      );

                      selectedStockItem.quantity =
                          (selectedStockItem.quantity - qty)
                              .clamp(0, double.infinity)
                              .toInt();
                      await stockProvider.updateItem(selectedStockItem);

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sale added and stock updated!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sale failed: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.13),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardAction(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.13),
            ),
            child: Icon(icon, size: 30, color: Colors.blueAccent),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget buildDashboard(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final stockProvider = Provider.of<StockProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);

    final currentUser = sessionProvider.loggedInUser;
    final shopName =
        currentUser?.shopName ?? currentUser?.username ?? "My Shop";

    final items = stockProvider.items;
    final lowStockList = items.where((item) => item.quantity <= 3).toList();
    final lowStockItems = lowStockList.length;

    final weeklyProfit = items
        .fold<double>(
          0,
          (sum, item) => sum + (item.price * item.quantity * 0.1),
        )
        .toInt();
    final todaysSales = (weeklyProfit * 0.2).toInt();

    final topProducts = List<StockItem>.from(items)
      ..sort((a, b) => (b.price * b.quantity).compareTo(a.price * a.quantity));
    final topProductsSlice = topProducts.take(5).toList();

    final dailySales = salesProvider.getDailySalesTotals();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final horizontalPadding = isWide ? 48.0 : 16.0;
        final cardWidth =
            (constraints.maxWidth -
                horizontalPadding * 2 -
                (isWide ? 48 : 24)) /
            (isWide ? 4 : 2);

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20,
          ),
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph, color: Colors.blue, size: 40),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $shopName!',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'All your shop info at a glance.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => _showAddSaleDialog(context),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add Sale'),
                    ),
                  ],
                ),
              ),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildSummaryCard(
                    "Today's Sales",
                    "₹$todaysSales",
                    Colors.green,
                    Icons.currency_rupee,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildSummaryCard(
                    "Profit (Week)",
                    "₹$weeklyProfit",
                    Colors.blue,
                    Icons.trending_up_outlined,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildSummaryCard(
                    "Low Stock",
                    "$lowStockItems",
                    Colors.red,
                    Icons.warning,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildSummaryCard(
                    "Top Products",
                    "${topProductsSlice.length}",
                    Colors.orange,
                    Icons.star,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDashboardAction(
                    Icons.add_box,
                    'Add Item',
                    () => Navigator.pushNamed(context, '/stock'),
                  ),
                  _buildDashboardAction(
                    Icons.point_of_sale,
                    'Add Sale',
                    () => _showAddSaleDialog(context),
                  ),
                  _buildDashboardAction(
                    Icons.receipt_long,
                    'Bill',
                    () => Navigator.pushNamed(context, '/sales'),
                  ),
                  _buildDashboardAction(
                    Icons.analytics,
                    'Analytics',
                    () => Navigator.pushNamed(context, '/analytics'),
                  ),
                  _buildDashboardAction(Icons.backup, 'Backup', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup triggered')),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sales Trend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: dailySales.isEmpty
                          ? const Center(child: Text("No sales data available"))
                          : BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(),
                                  rightTitles: AxisTitles(),
                                  topTitles: AxisTitles(),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        const dayLabels = [
                                          'M',
                                          'T',
                                          'W',
                                          'T',
                                          'F',
                                          'S',
                                          'S',
                                        ];
                                        final idx = value.toInt();
                                        if (idx >= 0 &&
                                            idx < dayLabels.length) {
                                          return Text(dayLabels[idx]);
                                        }
                                        return const SizedBox.shrink();
                                      },
                                      reservedSize: 25,
                                    ),
                                  ),
                                ),
                                barGroups: List.generate(
                                  dailySales.length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: dailySales[index],
                                        color: Colors.blueAccent,
                                        width: 16,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.only(right: 8, bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Top-Selling Items",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (topProductsSlice.isEmpty)
                            const Text('No items found.')
                          else
                            ...topProductsSlice.map(
                              (p) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                ),
                                title: Text(
                                  p.itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Text(
                                  '₹${(p.price * p.quantity).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.only(left: 8, bottom: 16),
                    color: Colors.red.shade50,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.warning, color: Colors.red, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Low Stock Alert',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (lowStockItems > 0)
                            ...lowStockList.map(
                              (s) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '${s.itemName}: Only ${s.quantity} left',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else
                            const Text(
                              'No low stock items',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaleHistoryCard(SalesRecord sale, String dateString) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.14),
              child: const Icon(Icons.point_of_sale, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        sale.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${(sale.price * sale.quantitySold).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${sale.quantitySold} pcs at ₹${sale.price.toStringAsFixed(2)}/pc',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateString,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSalesTab(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final currentUser = sessionProvider.loggedInUser;

    // If you have no user, show friendly message.
    if (currentUser == null) {
      return const Center(child: Text('No user logged in.'));
    }

    // Sort sales newest-to-oldest.
    final sales = List<SalesRecord>.from(salesProvider.sales);
    sales.sort((a, b) => b.saleDate.compareTo(a.saleDate));

    if (sales.isEmpty) {
      return const Center(
        child: Text(
          'No sales yet. All completed sales will appear here!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: sales.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final sale = sales[index];
        // Optionally, pretty format the date and time
        final dateString =
            "${sale.saleDate.day.toString().padLeft(2, '0')}/${sale.saleDate.month.toString().padLeft(2, '0')}/${sale.saleDate.year}, "
            "${sale.saleDate.hour.toString().padLeft(2, '0')}:${sale.saleDate.minute.toString().padLeft(2, '0')}";

        return _buildSaleHistoryCard(sale, dateString);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SessionProvider>(
          builder: (_, sessionProvider, __) {
            final currentUser = sessionProvider.loggedInUser;
            final shopName =
                currentUser?.shopName ?? currentUser?.username ?? "My Shop";
            return Row(
              children: [
                const Icon(Icons.store, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  shopName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
            Tab(icon: Icon(Icons.receipt_long), text: "Sales"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              final sessionProvider = Provider.of<SessionProvider>(
                context,
                listen: false,
              );
              final stockProvider = Provider.of<StockProvider>(
                context,
                listen: false,
              );
              final salesProvider = Provider.of<SalesProvider>(
                context,
                listen: false,
              );

              sessionProvider.logout();
              stockProvider.clearItemsOnLogout();
              salesProvider.clearSalesOnLogout();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (r) => false,
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildDashboard(context), buildSalesTab(context)],
      ),
    );
  }
}
