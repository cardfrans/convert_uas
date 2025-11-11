import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Default ke dark mode, sesuai permintaan awal Anda
  bool _isDarkMode = true;

  // 'getter' agar widget lain bisa membaca status saat ini
  bool get isDarkMode => _isDarkMode;

  // Constructor: Panggil _loadTheme saat ThemeProvider pertama kali dibuat
  ThemeProvider() {
    _loadTheme();
  }

  // Fungsi untuk memuat preferensi tema dari penyimpanan
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Baca 'isDarkMode'. Jika tidak ada, default ke true (dark)
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners(); // Beritahu widget yang mendengarkan
  }

  // Fungsi untuk mengubah tema
  void toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners(); // Beritahu widget

    // Simpan preferensi
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
}