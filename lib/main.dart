// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:convert_uas/providers/theme_provider.dart';
import 'package:convert_uas/screens/splash_screen.dart';

void main() {
  // Bungkus 'runApp' dengan 'ChangeNotifierProvider'
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Membuat ThemeProvider
      child: const UnitConverterApp(),
    ),
  );
}

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gunakan 'Consumer' agar MaterialApp 'listen' ke ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Unit Converter',

          // Tentukan tema terang dan gelap
          theme: _buildLightTheme(),      // Tema saat 'isDarkMode' false
          darkTheme: _buildDarkTheme(),   // Tema saat 'isDarkMode' true

          // Ini adalah kuncinya:
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
      },
    );
  }

  // --- FUNGSI TEMA GELAP (Sudah diperbaiki) ---
  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.blueAccent,
      // --- PERBAIKAN: Mengatur colorScheme ---
      // Ini akan otomatis memperbaiki warna Switch (pengganti toggleableActiveColor)
      colorScheme: ColorScheme.dark(
        primary: Colors.blueAccent,
        secondary: Colors.blueAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[700],
      ),
      // --- PERBAIKAN: Menggunakan 'CardThemeData' ---
      cardTheme: CardThemeData(
        color: Colors.grey[900],
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      // 'toggleableActiveColor' sudah dihapus, diganti oleh colorScheme
    );
  }

  // --- FUNGSI TEMA TERANG (Sudah diperbaiki) ---
  ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Color(0xFFF4F6F8), // Latar belakang putih keabuan
      primaryColor: Colors.blueAccent,
      // --- PERBAIKAN: Mengatur colorScheme ---
      // Ini akan otomatis memperbaiki warna Switch (pengganti toggleableActiveColor)
      colorScheme: ColorScheme.light(
        primary: Colors.blueAccent,
        secondary: Colors.blueAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFF4F6F8), // AppBar putih keabuan
        elevation: 0,
        foregroundColor: Colors.black, // Teks & ikon di AppBar jadi hitam
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent, // Ikon/Label aktif
        unselectedItemColor: Colors.grey[600], // Ikon/Label non-aktif
      ),
      // --- PERBAIKAN: Menggunakan 'CardThemeData' ---
      cardTheme: CardThemeData(
        color: Colors.white, // Kartu putih
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      // 'toggleableActiveColor' sudah dihapus, diganti oleh colorScheme
    );
  }
}