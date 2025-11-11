// lib/screens/converter_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sesuaikan path import ini dengan nama proyek Anda
import 'package:convert_uas/models/conversion_models.dart';
import 'package:convert_uas/services/conversion_service.dart';
import 'package:convert_uas/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConverterScreen extends StatefulWidget {
  final ConversionCategory category;

  const ConverterScreen({Key? key, required this.category}) : super(key: key);

  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late Unit _fromUnit;
  late Unit _toUnit;
  double _inputValue = 0.0;
  String _resultValue = '0.0';

  final TextEditingController _inputController = TextEditingController();
  final ConversionService _conversionService = ConversionService();

  @override
  void initState() {
    super.initState();
    // Inisialisasi state
    _fromUnit = widget.category.units.first;
    _toUnit = widget.category.units.length > 1
        ? widget.category.units[1]
        : widget.category.units.first;
    _inputController.text = _inputValue.toString();
  }



  // Fungsi untuk melakukan perhitungan
  void _performConversion() async { // <-- 1. Tambahkan 'async'
    // --- 2. TAMBAHKAN BLOK 'try/catch' INI ---
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tambah +1 ke total konversi
      int totalConversions = (prefs.getInt('stats_totalConversions') ?? 0) + 1;
      await prefs.setInt('stats_totalConversions', totalConversions);

      // Tambah +1 ke kategori spesifik
      String categoryName = widget.category.name;
      int categoryCount = (prefs.getInt('stats_category_$categoryName') ?? 0) + 1;
      await prefs.setInt('stats_category_$categoryName', categoryCount);

    } catch (e) {
      // Gagal menyimpan statistik, tidak apa-apa,
      // jangan hentikan konversi
      debugPrint('Gagal menyimpan statistik: $e');
    }
    // ------------------------------------

    // --- (Ini adalah kode Anda yang sudah ada, biarkan saja) ---
    setState(() {
      _inputValue = double.tryParse(_inputController.text) ?? 0.0;
      double result = _conversionService.convert(
        _inputValue,
        _fromUnit,
        _toUnit,
        widget.category.name,
      );
      _resultValue = result.toStringAsFixed(4);
    });
  }

  // Fungsi untuk menukar unit
  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _performConversion(); // Hitung ulang setelah ditukar
    });
  }
  Widget _buildResultDescription(BuildContext context) {
    String inputText;

    // Cek jika _inputValue adalah bilangan bulat (e.g., 1.0)
    // agar kita bisa menampilkannya sebagai "1" (bukan "1.0")
    if (_inputValue == _inputValue.floor()) {
      inputText = _inputValue.toInt().toString();
    } else {
      inputText = _inputValue.toString(); // Tampilkan sebagai "1.5"
    }

    // _resultValue sudah berupa String yang diformat dari _performConversion
    String resultText = _resultValue;

    // Tampilkan deskripsi lengkapnya
    return Text(
      // Contoh: "1 Meter = 0.0010 Kilometer"
      '$inputText ${_fromUnit.name} = $resultText ${_toUnit.name}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        // color: Theme.of(context).primaryColor, // Warna aksen (biru)
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
  // --- AKHIR FUNGSI HELPER BARU ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar otomatis di-style oleh tema global
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BAGIAN INPUT (ATAS) ---
            _buildConversionRow(
              isInput: true,
              controller: _inputController,
              selectedUnit: _fromUnit,
              // INI FUNGSI AGAR DROPDOWN ATAS BERFUNGSI
              onUnitChanged: (Unit? newUnit) {
                if (newUnit != null) {
                  setState(() {
                    _fromUnit = newUnit;
                  });
                  _performConversion();
                }
              },
            ),
            SizedBox(height: 24.0),

            // --- TOMBOL SWAP ---
            IconButton(
              icon: Icon(Icons.swap_vert, size: 40.0),
              // Ikon otomatis menggunakan warna primer
              color: Theme.of(context).primaryColor,
              onPressed: _swapUnits,
            ),
            SizedBox(height: 24.0),

            // --- BAGIAN HASIL (BAWAH) ---
            _buildConversionRow(
              isInput: false,
              resultValue: _resultValue,
              selectedUnit: _toUnit,
              // INI FUNGSI AGAR DROPDOWN BAWAH BERFUNGSI
              onUnitChanged: (Unit? newUnit) {
                if (newUnit != null) {
                  setState(() {
                    _toUnit = newUnit;
                  });
                  _performConversion();
                }
              },
            ),
            // --- TAMBAHKAN KODE INI DI SINI ---
            SizedBox(height: 32.0), // Memberi jarak
            _buildResultDescription(context), // Panggil helper baru kita
            // ---------------------------------
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER (SUDAH FINAL) ---
  Widget _buildConversionRow({
    required bool isInput,
    TextEditingController? controller,
    String? resultValue,
    required Unit selectedUnit,
    required ValueChanged<Unit?> onUnitChanged, // <-- Parameter fungsi
  }) {
    // Gunakan Card agar style-nya (warna, rounded corner)
    // diambil dari 'cardTheme' di main.dart
    return Card(
      // Kita atur padding di dalam Card
      child: Padding(
        // Sesuaikan padding vertikal agar tidak terlalu tinggi
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Row(
          children: [
            // --- BAGIAN KIRI (INPUT / HASIL) ---
            Expanded(
              flex: 2,
              child: isInput
                  ? TextField(
                controller: controller,
                // Font style otomatis adaptif
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 24), // Samakan ukuran font
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),

                // --- PERBAIKAN BUG VISUAL TEXTFIELD ---
                decoration: InputDecoration(
                  hintText: '0.0',
                  border: InputBorder.none, // Hilangkan garis bawah
                  contentPadding:
                  EdgeInsets.zero, // Hilangkan padding internal
                ),
                // ------------------------------------

                onChanged: (value) => _performConversion(),
              )
                  : Text(
                resultValue ?? '0.0',
                // Font style otomatis adaptif
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 24), // Samakan ukuran font
              ),
            ),
            SizedBox(width: 16.0),
            // --- BAGIAN KANAN (DROPDOWN) ---
            Expanded(
              flex: 3,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Unit>(
                  value: selectedUnit,
                  isExpanded: true,
                  // Warna dropdown adaptif
                  dropdownColor:
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.grey[800]
                      : Colors.white,
                  // Ikon dropdown adaptif
                  icon: Icon(Icons.arrow_drop_down,
                      color: Theme.of(context).primaryColor),
                  // Font style adaptif
                  style: Theme.of(context).textTheme.titleMedium,
                  items: widget.category.units.map((Unit unit) {
                    return DropdownMenuItem<Unit>(
                      value: unit,
                      child: Text(
                        unit.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  // --- INI KONEKSI KE FUNGSI ---
                  onChanged: onUnitChanged, // <-- Sangat penting
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}