import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app.dart'; // Import where ThemeProvider is defined

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isBackupOn = true;
  bool dailySummary = false;

  @override
  Widget build(BuildContext context) {
    // Access global theme provider
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark (night) theme'),
              value: isDarkMode,
              onChanged: (val) {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme(val);
              },
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Cloud Backup'),
              subtitle: const Text('Enable automatic data backup'),
              value: isBackupOn,
              onChanged: (v) => setState(() => isBackupOn = v),
              secondary: const Icon(Icons.cloud_upload),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Daily Sales Summary'),
              subtitle: const Text('Get notified with daily stats'),
              value: dailySummary,
              onChanged: (v) => setState(() => dailySummary = v),
              secondary: const Icon(Icons.notifications_active),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Manage Shop Info'),
              subtitle: const Text('Update shop name, owner, type'),
              leading: const Icon(Icons.storefront),
              onTap: () {
                // TODO: open shop info edit page/dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit shop info tapped')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Privacy Policy'),
              leading: const Icon(Icons.privacy_tip),
              onTap: () {
                // TODO: show privacy policy details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy tapped')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Contact Support'),
              leading: const Icon(Icons.support_agent),
              onTap: () {
                // TODO: open support/contact action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact Support tapped')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
