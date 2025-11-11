// lib/screens/history_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// Sesuaikan path import
import 'package:convert_uas/models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, List<HistoryItem>> _groupedHistory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // ... (Logika tidak berubah) ...
    final prefs = await SharedPreferences.getInstance();
    final String historyString = prefs.getString('history_list') ?? '[]';
    final List<dynamic> historyJson = jsonDecode(historyString);
    final List<HistoryItem> historyItems = historyJson
        .map((jsonItem) => HistoryItem.fromJson(jsonItem))
        .toList();
    _groupHistory(historyItems);
  }

  void _groupHistory(List<HistoryItem> items) {
    // ... (Logika tidak berubah) ...
    final Map<String, List<HistoryItem>> grouped = {};
    final DateTime now = DateTime.now();

    for (var item in items) {
      final String groupName = _getGroupName(item.timestamp, now);
      if (grouped[groupName] == null) {
        grouped[groupName] = [];
      }
      grouped[groupName]!.add(item);
    }
    setState(() {
      _groupedHistory = grouped;
      _isLoading = false;
    });
  }

  String _getGroupName(DateTime date, DateTime now) {
    // ... (Logika tidak berubah) ...
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    final DateTime itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(itemDate).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // HAPUS 'Theme(data: ThemeData.dark())'
    return Scaffold(
      appBar: AppBar(
        title: Text('Converting History'), // Style otomatis
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _groupedHistory.isEmpty
          ? Center(
        child: Text(
          'No history saved yet.',
          // Style otomatis
        ),
      )
          : ListView.builder(
        itemCount: _groupedHistory.keys.length,
        itemBuilder: (context, index) {
          String groupName = _groupedHistory.keys.elementAt(index);
          List<HistoryItem> items = _groupedHistory[groupName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16.0, 24.0, 16.0, 8.0),
                child: Text(
                  groupName,
                  // Style otomatis
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                ),
              ),
              ...items
                  .map((item) => _buildHistoryCard(item))
                  .toList(),
            ],
          );
        },
      ),
    );
  }

  // BUNGKUS KONTEN DENGAN 'Card'
  Widget _buildHistoryCard(HistoryItem item) {
    return Card( // <-- GUNAKAN Card
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding( // <-- Tambahkan Padding
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From ${item.fromCode} to ${item.toCode}',
                  // Style otomatis
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat('MMMM d, yyyy, hh:mm a').format(item.timestamp),
                  // Style otomatis
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.fromValue.toStringAsFixed(2)} ${item.fromCode}',
                  // Style otomatis
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  '${item.toValue.toStringAsFixed(2)} ${item.toCode}',
                  // Style otomatis
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}