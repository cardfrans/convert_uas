// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:convert_uas/screens/home_screen.dart'; // Menu 1
import 'package:convert_uas/screens/currency_converter_screen.dart'; // Menu 2
import 'package:convert_uas/screens/settings_screen.dart'; // Menu 3

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
// -----------------------------------------------------------------

}

// --- BAGIAN 2: STATE (YANG BERISI LOGIKA) ---
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Indeks halaman yang sedang aktif

  // Daftar semua halaman/menu kita
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Ini adalah halaman Unit Converter Anda
    CurrencyConverterScreen(), // Ini halaman baru untuk Mata Uang
    SettingsScreen(), // Halaman pengaturan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berganti-ganti sesuai menu yang dipilih
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Ini adalah menu navigasi di bagian bawah
      bottomNavigationBar: BottomNavigationBar(
        // Tema (warna, dll.) otomatis diambil dari main.dart
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.change_circle_outlined),
            label: 'Unit Converter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Mata Uang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Fungsi yang dipanggil saat menu diklik
      ),
    );
  }
}