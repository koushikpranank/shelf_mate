cd .\lib

function New-DartFile {
    param ([string]$path, [string]$content)
    if (-not (Test-Path $path)) {
        $content | Out-File -FilePath $path -Encoding utf8
    }
}

# --- Core ---
$coreFolders = @('core', 'core\theme', 'core\utils')
$coreFiles = @{
    'core\theme\app_theme.dart' = @'
class AppTheme {
  // TODO: Define app themes
}
'@;
    'core\constants.dart' = @'
// App constants
enum AppConstants { }
'@;
    'core\utils\responsive.dart' = @'
class Responsive {
  // TODO: Add responsive helpers
}
'@
}

# --- Data ---
$dataFolders = @('data')
$dataFiles = @{}

# --- Global Widgets ---
$widgetFolders = @('widgets')
$widgetFiles = @{
    'widgets\custom_button.dart' = @"
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ElevatedButton(onPressed: (){}, child: Text('Button'));
}
"@;
    'widgets\custom_card.dart' = @"
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(child: SizedBox(height:40));
}
"@
}

# --- Features & Screens ---
$features = @(
    'features', 'features\onboarding', 'features\onboarding\widgets',
    'features\auth',
    'features\dashboard', 'features\dashboard\widgets',
    'features\stock',
    'features\sales',
    'features\analytics',
    'features\notifications',
    'features\backup',
    'features\settings'
)
$featureFiles = @{
    'features\onboarding\onboarding_screen.dart' = @"
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Onboarding')));
}
"@;
    'features\onboarding\widgets\onboarding_slide.dart' = @"
import 'package:flutter/material.dart';

class OnboardingSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(child: Text('Slide'));
}
"@;
    'features\auth\login_screen.dart' = @"
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Login')));
}
"@;
    'features\auth\signup_screen.dart' = @"
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Signup')));
}
"@;
    'features\dashboard\home_screen.dart' = @"
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Dashboard')));
}
"@;
    'features\dashboard\widgets\today_stats_card.dart' = @"
import 'package:flutter/material.dart';

class TodayStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(child: Text('Stats'));
}
"@;
    'features\stock\stock_screen.dart' = @"
import 'package:flutter/material.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Stock')));
}
"@;
    'features\sales\sales_screen.dart' = @"
import 'package:flutter/material.dart';

class SalesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Sales')));
}
"@;
    'features\analytics\analytics_screen.dart' = @"
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Analytics')));
}
"@;
    'features\notifications\notifications_screen.dart' = @"
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Notifications')));
}
"@;
    'features\backup\backup_screen.dart' = @"
import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Backup & Restore')));
}
"@;
    'features\settings\settings_screen.dart' = @"
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Settings')));
}
"@
}

# --- l10n ---
$l10nFolders = @('l10n')
$l10nFiles = @{
    'l10n\app_en.arb' = @'
{
  "title": "ShelfMate"
}
'@;
    'l10n\app_hi.arb' = @'
{
  "title": "शेल्फमेट"
}
'@
}

# --- Main App Files ---
$mainFiles = @{
    'main.dart' = @"
import 'package:flutter/material.dart';
import 'app.dart';

void main() => runApp(const ShelfMateApp());
"@;
    'app.dart' = @"
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';

class ShelfMateApp extends StatelessWidget {
  const ShelfMateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShelfMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const OnboardingScreen(),
    );
  }
}
"@
}

# --- Create All Folders ---
$allFolders = $coreFolders + $dataFolders + $widgetFolders + $features + $l10nFolders
foreach ($folder in $allFolders) {
    if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
}

# --- Create Dart Files with Starter Content ---
$allFiles = $coreFiles + $widgetFiles + $featureFiles + $mainFiles + $l10nFiles
foreach ($filePath in $allFiles.Keys) {
    New-DartFile $filePath $allFiles[$filePath]
}

Write-Host "`nShelfMate app structure, subfolders, and starter Dart (and l10n) files have been created!"
