// lib/screens/unit_stats_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
// Sesuaikan path import
import 'package:convert_uas/providers/theme_provider.dart';
import 'package:convert_uas/screens/home_screen.dart';

class UnitStatsScreen extends StatefulWidget {
  const UnitStatsScreen({Key? key}) : super(key: key);

  @override
  _UnitStatsScreenState createState() => _UnitStatsScreenState();
}

class _UnitStatsScreenState extends State<UnitStatsScreen> {
  int _totalConversions = 0;
  Map<String, double> _categoryStats = {};
  bool _isLoading = true;

  final List<String> _categoryNames = HomeScreen()
      .categories
      .map((cat) => cat.name)
      .toList()
      .take(8)
      .toList();

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, double> stats = {};

    _totalConversions = prefs.getInt('stats_totalConversions') ?? 0;

    for (String name in _categoryNames) {
      int count = prefs.getInt('stats_category_$name') ?? 0;
      if (count > 0) {
        stats[name] = count.toDouble();
      }
    }

    setState(() {
      _categoryStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistik Unit'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Kartu Total Konversi ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Konversi Unit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$_totalConversions Kali',
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

          // --- Kartu Bar Chart ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Sering Digunakan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 24.0),
                  _categoryStats.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Belum ada data konversi unit.'),
                    ),
                  )
                      : _buildBarChart(context, isDarkMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK BAR CHART (Kode sama persis) ---
  Widget _buildBarChart(BuildContext context, bool isDarkMode) {
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Container(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _categoryStats.values.reduce((a, b) => a > b ? a : b) + 2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _categoryStats.keys.length) {
                    final key = _categoryStats.keys.elementAt(index);
                    final String shortKey = key.length > 3 ? key.substring(0, 3) : key;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0,
                      child: Text(shortKey, style: TextStyle(fontSize: 10, color: textColor)),
                    );
                  }
                  return Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 5,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: textColor),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _categoryStats.entries
              .toList()
              .asMap()
              .map((index, entry) {
            return MapEntry(
              index,
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Theme.of(context).primaryColor,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          })
              .values
              .toList(),
        ),
      ),
    );
  }
}