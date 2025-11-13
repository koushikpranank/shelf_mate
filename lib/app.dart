import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/dashboard/home_screen.dart';
import 'features/stock/stock_screen.dart';
import 'features/sales/sales_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/settings_screen.dart';

// ThemeProvider class (unchanged, just included for completeness)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ShelfMateApp extends StatelessWidget {
  final bool onboardingSeen;
  final bool isLoggedIn;

  const ShelfMateApp({
    super.key,
    required this.onboardingSeen,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    // Decide initial route based on onboarding and login state
    String initialRoute;
    if (!onboardingSeen) {
      initialRoute = '/onboarding';
    } else if (isLoggedIn) {
      initialRoute = '/dashboard';
    } else {
      initialRoute = '/login';
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'ShelfMate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,
          initialRoute: initialRoute,
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/dashboard': (context) => const HomeScreen(),
            '/stock': (context) => const StockScreen(),
            '/sales': (context) => const SalesScreen(),
            '/analytics': (context) => const AnalyticsScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
