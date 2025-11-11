// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sesuaikan path import
import 'package:convert_uas/providers/theme_provider.dart';
import 'package:convert_uas/screens/unit_stats_screen.dart'; // <-- IMPORT BARU
import 'package:convert_uas/screens/currency_stats_screen.dart'; // <-- IMPORT BARU

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil themeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- KARTU 1: DARK MODE ---
          Card(
            child: SwitchListTile(
              title: Text('Dark Mode'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),

          SizedBox(height: 32.0), // Jarak

          // --- KARTU 2: JUDUL LAPORAN ---
          Text(
            'Laporan Statistik',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16.0),

          // --- KARTU 3: TOMBOL LAPORAN UNIT ---
          Card(
            child: ListTile(
              leading: Icon(Icons.change_circle_outlined, color: Theme.of(context).primaryColor),
              title: Text('Statistik Unit Converter'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UnitStatsScreen()),
                );
              },
            ),
          ),

          SizedBox(height: 12.0),

          // --- KARTU 4: TOMBOL LAPORAN MATA UANG ---
          Card(
            child: ListTile(
              leading: Icon(Icons.currency_exchange, color: Theme.of(context).primaryColor),
              title: Text('Statistik Mata Uang'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CurrencyStatsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}