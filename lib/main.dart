import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';
import 'models/stock_item.dart';
import 'models/sales_record.dart';
import 'providers/session_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/sales_provider.dart';
import 'app.dart';
// If you have a ThemeProvider, make sure to import it correctly
// import 'providers/theme_provider.dart'; // Adjust import path accordingly

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive before using it
  await Hive.initFlutter();

  // Register Hive adapters (make sure these adapters are generated and imported)
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(StockItemAdapter());
  Hive.registerAdapter(SalesRecordAdapter());

  // Open Hive boxes before running the app
  await Hive.openBox<User>('users');
  await Hive.openBox<String>('session');
  await Hive.openBox<StockItem>('stock_items_box');
  await Hive.openBox<SalesRecord>('sales_box');

  // Load onboarding flag from shared preferences
  final prefs = await SharedPreferences.getInstance();
  final onboardingSeen = prefs.getBool('onboarding_complete') ?? false;

  // Get Hive boxes for providers
  final userBox = Hive.box<User>('users');
  final sessionBox = Hive.box<String>('session');

  // Initialize providers with boxes and any initialization logic as needed
  final sessionProvider = SessionProvider(userBox, sessionBox);
  final stockProvider = StockProvider();
  final salesProvider = SalesProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionProvider>.value(value: sessionProvider),
        ChangeNotifierProvider<StockProvider>.value(value: stockProvider),
        ChangeNotifierProvider<SalesProvider>.value(value: salesProvider),
        // If ThemeProvider exists, provide it as well
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: ShelfMateApp(
        onboardingSeen: onboardingSeen,
        isLoggedIn: sessionProvider.isLoggedIn,
      ),
    ),
  );
}
