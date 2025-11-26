import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final ThemeService themeService;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: Text(
                user['name'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to profile edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile editing coming soon!')),
              );
            },
          ),
          const Divider(),

          // Appearance Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: Icon(
              themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeService.isDarkMode ? 'Enabled' : 'Disabled',
            ),
            trailing: Switch(
              value: themeService.isDarkMode,
              onChanged: (value) {
                themeService.toggleTheme();
              },
            ),
          ),
          const Divider(),

          // About Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.primary),
            title: const Text('App Version'),
            subtitle: const Text('2.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AppTheme.primary),
            title: const Text('Documentation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check README.md for documentation'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

