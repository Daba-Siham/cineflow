import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineflow/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Apparence", 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text("Mode Sombre"),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeThumbColor: Colors.red,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("À propos", 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Version de l'application"),
            subtitle: Text("1.0.0"),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text("Développé par l'équipe CineFlow"),
            onTap: () {
              // Action optionnelle
            },
          ),
        ],
      ),
    );
  }
}