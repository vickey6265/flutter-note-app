import 'package:first_flutter/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Consumer<ThemeProvider>(
        builder: (ctx, provider, __) {
          return SwitchListTile.adaptive(
            title: const Text("Dark Mode"),
            subtitle: const Text("Manage Light/Dark mode here"),
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            value: themeProvider.isDarkMode,
          );
        },
      ),
    );
  }
}