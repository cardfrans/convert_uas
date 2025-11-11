// lib/screens/currency_converter_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
// Sesuaikan path import
import 'package:convert_uas/models/history_model.dart';
import 'package:convert_uas/screens/history_screen.dart';
import 'package:convert_uas/providers/theme_provider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:provider/provider.dart';

// Class helper
class CurrencyInfo {
  final String name;
  final String countryCode;
  CurrencyInfo(this.name, this.countryCode);
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({Key? key}) : super(key: key);

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  // --- Variabel State (Tidak berubah) ---
  bool _isLoading = true;
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  Map<String, dynamic> _rates = {};
  List<String> _currencies = [];
  double _inputValue = 1.0;
  double _resultValue = 0.0;
  final TextEditingController _controller = TextEditingController();
  final Map<String, CurrencyInfo> _currencyInfoMap = {
    'USD': CurrencyInfo('US Dollar', 'US'),
    'IDR': CurrencyInfo('Indonesian Rupiah', 'ID'),
    'EUR': CurrencyInfo('Euro', 'EU'),
    'JPY': CurrencyInfo('Japanese Yen', 'JP'),
    'GBP': CurrencyInfo('British Pound', 'GB'),
    'AUD': CurrencyInfo('Australian Dollar', 'AU'),
    'CAD': CurrencyInfo('Canadian Dollar', 'CA'),
    'CHF': CurrencyInfo('Swiss Franc', 'CH'),
    'CNY': CurrencyInfo('Chinese Yuan', 'CN'),
    'HKD': CurrencyInfo('Hong Kong Dollar', 'HK'),
    'SGD': CurrencyInfo('Singapore Dollar', 'SG'),
    'MYR': CurrencyInfo('Malaysian Ringgit', 'MY'),
    'KRW': CurrencyInfo('South Korean Won', 'KR'),
    'NZD': CurrencyInfo('New Zealand Dollar', 'NZ'),
    'INR': CurrencyInfo('Indian Rupee', 'IN'),
    'BRL': CurrencyInfo('Brazilian Real', 'BR'),
    'RUB': CurrencyInfo('Russian Ruble', 'RU'),
    'ZAR': CurrencyInfo('South African Rand', 'ZA'),
    'SAR': CurrencyInfo('Saudi Riyal', 'SA'),
    'AED': CurrencyInfo('UAE Dirham', 'AE'),
  };
  bool _isChartLoading = true;
  String _selectedRange = '1M';
  List<FlSpot> _chartSpots = [];
  double _percentChange = 0.0;
  double _chartMinY = 0.0;
  double _chartMaxY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.text = _inputValue.toString();
    _fetchCurrencies();
    _fetchHistoricalData();
  }

  // --- Logika API (Tidak berubah) ---
  Future<void> _fetchCurrencies() async {
    // ... (Logika tidak berubah) ...
    setState(() { _isLoading = true; });
    try {
      final response = await http.get(Uri.parse(
          'https://api.exchangerate-api.com/v4/latest/$_fromCurrency'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _rates = data['rates'];
        List<String> allApiCurrencies = _rates.keys.toList();
        List<String> filteredCurrencies = allApiCurrencies
            .where((currency) => _currencyInfoMap.containsKey(currency))
            .toList();
        setState(() {
          _isLoading = false;
          _currencies = filteredCurrencies;
          _currencies.sort();
          if (!_currencies.contains(_fromCurrency)) {
            _fromCurrency = _currencies.firstWhere((c) => c == 'USD',
                orElse: () => _currencies.first);
          }
          if (!_currencies.contains(_toCurrency)) {
            _toCurrency = _currencies.firstWhere((c) => c == 'IDR',
                orElse: () => _currencies.last);
          }
          _performConversion();
        });
      } else { throw Exception('Gagal memuat data kurs'); }
    } catch (e) { setState(() { _isLoading = false; }); }
  }

  void _performConversion() {
    // ... (Logika tidak berubah) ...
    if (_rates.isEmpty) return;
    _inputValue = double.tryParse(_controller.text) ?? 0.0;
    double? toRate = _rates[_toCurrency];
    if (toRate != null) { setState(() { _resultValue = _inputValue * toRate; }); }
  }

  Future<void> _fetchHistoricalData() async {
    // ... (Logika tidak berubah) ...
    if (_fromCurrency == _toCurrency) {
      setState(() {
        _isChartLoading = false;
        _chartSpots = [FlSpot(0, 1), FlSpot(1, 1)];
        _percentChange = 0.0; _chartMinY = 0.5; _chartMaxY = 1.5;
      });
      return;
    }
    setState(() { _isChartLoading = true; });
    try {
      final Map<String, String> dateRange = _getDateRange(_selectedRange);
      final String startDate = dateRange['start']!;
      final String endDate = dateRange['end']!;
      final String apiUrl =
          'https://api.frankfurter.app/$startDate..$endDate?from=$_fromCurrency&to=$_toCurrency';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) { throw Exception('Gagal memuat data chart. Coba ganti mata uang.'); }
      final data = jsonDecode(response.body);
      final Map<String, dynamic> rates = data['rates'];
      final sortedEntries = rates.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      List<FlSpot> spots = [];
      double minY = double.maxFinite;
      double maxY = double.minPositive;
      for (int i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];
        final double rate = (entry.value as Map).values.first.toDouble();
        spots.add(FlSpot(i.toDouble(), rate));
        if (rate < minY) minY = rate;
        if (rate > maxY) maxY = rate;
      }
      if (spots.isEmpty) { throw Exception('Data historis tidak tersedia.'); }
      final double startRate = spots.first.y;
      final double endRate = spots.last.y;
      final double change = (endRate - startRate) / startRate * 100;
      setState(() {
        _chartSpots = spots;
        _percentChange = change;
        _chartMinY = minY * 0.98;
        _chartMaxY = maxY * 1.02;
        _isChartLoading = false;
      });
    } catch (e) {
      setState(() {
        _isChartLoading = false;
        _chartSpots = []; _percentChange = 0.0;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ));
      });
    }
  }

  Map<String, String> _getDateRange(String range) {
    // ... (Logika tidak berubah, ini sudah benar) ...
    final DateTime now = DateTime.now();
    DateTime start;
    switch (range) {
      case '5D': start = now.subtract(Duration(days: 5)); break;
      case '1M': start = now.subtract(Duration(days: 30)); break;
      case '6M': start = now.subtract(Duration(days: 180)); break;
      case '1Y': start = now.subtract(Duration(days: 365)); break;
      case 'MAX': start = DateTime(2000, 1, 1); break;
      default: // 1D (otomatis mengambil 5 hari, sudah benar)
        start = now.subtract(Duration(days: 5));
    }
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return { 'start': formatter.format(start), 'end': formatter.format(now), };
  }

  // --- PERBAIKAN LOGIKA 1D DI SINI ---
  void _handleRangeSelected(String range) {
    // if (range == '1D') range = '5D'; // <-- HAPUS BARIS INI
    setState(() {
      _selectedRange = range; // <-- Biarkan '1D' terpilih
    });
    _fetchHistoricalData(); // _getDateRange akan tetap mengambil data 5D
  }

  Future<void> _saveConversion() async {
    // ... (Logika tidak berubah) ...
    final newItem = HistoryItem(
      fromCode: _fromCurrency, toCode: _toCurrency,
      fromValue: _inputValue, toValue: _resultValue,
      timestamp: DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    final String historyString = prefs.getString('history_list') ?? '[]';
    final List<dynamic> historyJson = jsonDecode(historyString);
    List<Map<String, dynamic>> historyList =
    historyJson.cast<Map<String, dynamic>>();
    historyList.insert(0, newItem.toJson());
    final String newHistoryString = jsonEncode(historyList);
    await prefs.setString('history_list', newHistoryString);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Conversion saved to history!'),
      backgroundColor: Colors.green, duration: Duration(seconds: 2),
    ));
  }

  void _swapCurrencies() {
    // ... (Logika tidak berubah) ...
    final temp = _fromCurrency;
    setState(() {
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _fetchCurrencies();
    _fetchHistoricalData();
  }

  Widget _getFlagIcon(String currencyCode) {
    // ... (Logika tidak berubah) ...
    String? countryCode = _currencyInfoMap[currencyCode]?.countryCode;
    if (countryCode != null) {
      return CountryFlag.fromCountryCode(
        countryCode, height: 20, width: 30, borderRadius: 4,
      );
    } else {
      return Icon(
        Icons.monetization_on_outlined, size: 24, color: Colors.grey[600],
      );
    }
  }

  // --- UI (Hampir tidak berubah, kecuali _buildChart) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Convert'),
        actions: [
          TextButton(
            onPressed: _saveConversion,
            child: Text('Save'),
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    _buildCurrencySelectorBox(
                      title: 'From',
                      currencyCode: _fromCurrency,
                      currencyName:
                      _currencyInfoMap[_fromCurrency]?.name ?? '',
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() { _fromCurrency = newValue; });
                          _fetchCurrencies();
                          _fetchHistoricalData();
                        }
                      },
                    ),
                    Spacer(),
                    _buildCurrencySelectorBox(
                      title: 'To',
                      currencyCode: _toCurrency,
                      currencyName:
                      _currencyInfoMap[_toCurrency]?.name ?? '',
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() { _toCurrency = newValue; });
                          _performConversion();
                          _fetchHistoricalData();
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 3
                      )
                  ),
                  child: IconButton(
                    icon: Icon(Icons.swap_horiz),
                    onPressed: _swapCurrencies,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            _buildAmountBox(
              isInput: true, controller: _controller,
              currencyCode: _fromCurrency,
              onChanged: (value) => _performConversion(),
            ),
            SizedBox(height: 16),
            _buildAmountBox(
              isInput: false, value: _resultValue,
              currencyCode: _toCurrency,
            ),
            SizedBox(height: 40),
            _buildChart(), // <-- Perbaikan ada di dalam sini
          ],
        ),
      ),
    );
  }

  // --- Widget Helper (Hanya _buildChart & _buildRangeButtons yg diubah) ---

  Widget _buildCurrencySelectorBox({
    // ... (Logika tidak berubah) ...
    required String title, required String currencyCode,
    required String currencyName, required ValueChanged<String?> onChanged,
  }) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: currencyCode,
              isExpanded: true,
              underline: Container(),
              icon: Icon(Icons.arrow_downward, size: 20),
              dropdownColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.grey[800] : Colors.white,
              items: _currencies.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Row(
                    children: [
                      _getFlagIcon(currency),
                      SizedBox(width: 10),
                      Text(currency),
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return _currencies.map((String currency) {
                  return Row(
                    children: [
                      _getFlagIcon(currency),
                      SizedBox(width: 10),
                      Text(
                          currency,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22)
                      ),
                    ],
                  );
                }).toList();
              },
              onChanged: onChanged,
            ),
            SizedBox(height: 4),
            Text(
              currencyName,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBox({
    // ... (Logika tidak berubah) ...
    required bool isInput, TextEditingController? controller,
    double? value, required String currencyCode,
    ValueChanged<String>? onChanged,
  }) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: isInput
                  ? TextField(
                controller: controller,
                style: Theme.of(context).textTheme.headlineSmall,
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration.collapsed( hintText: '0.0', ),
                onChanged: onChanged,
              )
                  : Text(
                value?.toStringAsFixed(2) ?? '0.0',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text(
                currencyCode,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)
            ),
          ],
        ),
      ),
    );
  }

  // --- PERBAIKAN OVERFLOW DI SINI ---
  Widget _buildChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChartHeader(),
            SizedBox(height: 24),
            Container(
              height: 200,
              width: double.infinity,
              child: _isChartLoading
                  ? Center(child: CircularProgressIndicator())
                  : _chartSpots.isEmpty
                  ? Center( child: Text('Data historis tidak tersedia.'),)
                  : LineChart(
                LineChartData(
                  minY: _chartMinY, maxY: _chartMaxY,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartSpots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.5),
                            Theme.of(context).primaryColor.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // --- BUNGKUS TOMBOL DENGAN SCROLLVIEW ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // Tambahkan 'child' agar Row bisa di-scroll
              child: _buildRangeButtons(),
            ),
            // ------------------------------------

          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    // ... (Logika tidak berubah) ...
    bool isPositive = _percentChange >= 0;
    Color changeColor = isPositive ? Colors.green : Colors.red;
    IconData changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_fromCurrency}/${_toCurrency} Chart',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: changeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Icon(changeIcon, color: changeColor, size: 14),
              SizedBox(width: 4),
              Text(
                '${_percentChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor, fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PERBAIKAN PADDING TOMBOL DI SINI ---
  Widget _buildRangeButtons() {
    final ranges = ['1D', '5D', '1M', '6M', '1Y', 'MAX'];
    final unselectedColor = Theme.of(context).textTheme.bodySmall?.color;

    return Row(
      // Ganti 'spaceAround' menjadi 'start' agar rapi di dalam scroll
      mainAxisAlignment: MainAxisAlignment.start,
      children: ranges.map((range) {
        bool isSelected = _selectedRange == range;
        return Padding(
          // Tambahkan padding antar tombol
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: TextButton(
            onPressed: () => _handleRangeSelected(range),
            style: TextButton.styleFrom(
              backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              range,
              style: TextStyle(
                color: isSelected ? Colors.white : unselectedColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}