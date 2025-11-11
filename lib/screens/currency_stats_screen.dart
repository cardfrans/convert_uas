// lib/screens/currency_stats_screen.dart

import 'dart:convert';
import 'dart:math'; // Untuk warna acak
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
// Sesuaikan path import
import 'package:convert_uas/models/history_model.dart';

class CurrencyStatsScreen extends StatefulWidget {
  const CurrencyStatsScreen({Key? key}) : super(key: key);

  @override
  _CurrencyStatsScreenState createState() => _CurrencyStatsScreenState();
}

class _CurrencyStatsScreenState extends State<CurrencyStatsScreen> {
  int _totalSaved = 0;
  Map<String, double> _pairStats = {};
  bool _isLoading = true;
  List<Color> _pieColors = []; // Untuk menyimpan warna chart

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final String historyString = prefs.getString('history_list') ?? '[]';
    final List<dynamic> historyJson = jsonDecode(historyString);

    // 1. Dapatkan Total Konversi Tersimpan
    _totalSaved = historyJson.length;

    // 2. Hitung Pasangan Favorit
    Map<String, double> pairCounts = {};
    for (var jsonItem in historyJson) {
      final item = HistoryItem.fromJson(jsonItem);
      // Buat key, e.g., "USD / IDR"
      String pair = '${item.fromCode} / ${item.toCode}';
      // Tambahkan 1 ke jumlah pasangan
      pairCounts[pair] = (pairCounts[pair] ?? 0) + 1;
    }

    // Urutkan dari yang terbesar (opsional, tapi bagus)
    _pairStats = Map.fromEntries(
        pairCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );

    // 3. Buat daftar warna acak untuk Pie Chart
    _pieColors = List.generate(_pairStats.length, (_) => _getRandomColor());

    setState(() {
      _isLoading = false;
    });
  }

  // Helper untuk warna acak
  Color _getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(200), // Batasi agar tidak terlalu terang
      random.nextInt(200),
      random.nextInt(200),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistik Mata Uang'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Kartu Total Konversi Tersimpan ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Konversi Tersimpan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$_totalSaved Kali',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.0),

          // --- Kartu Pie Chart ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pasangan Konversi Favorit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 24.0),
                  _pairStats.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Belum ada riwayat tersimpan.'),
                    ),
                  )
                      : _buildPieChart(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK PIE CHART ---
  Widget _buildPieChart(BuildContext context) {
    return Container(
      height: 300,
      child: PieChart(
        PieChartData(
          // Data irisan (slices)
          sections: _pairStats.entries
              .toList()
              .asMap()
              .map((index, entry) {
            final isTouched = false; // Bisa dikembangkan nanti
            final double fontSize = isTouched ? 16.0 : 12.0;
            final double radius = isTouched ? 110.0 : 100.0;

            return MapEntry(
              index,
              PieChartSectionData(
                color: _pieColors[index],
                value: entry.value, // Jumlah (mis: 5)
                title: '${entry.key}\n(${entry.value.toInt()})', // Teks
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          })
              .values
              .toList(),

          // Pengaturan lain
          sectionsSpace: 2, // Jarak antar irisan
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}