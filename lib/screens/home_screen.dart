// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
// Sesuaikan path import
import 'package:convert_uas/models/conversion_models.dart';
import 'package:convert_uas/screens/converter_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  // --- INI ADALAH DATA LENGKAP YANG KITA BUTUHKAN ---
  final List<ConversionCategory> categories = [
    ConversionCategory(
      name: 'Length',
      icon: Icons.straighten,
      units: [
        Unit(name: 'Meter', conversionFactor: 1.0),
        Unit(name: 'Kilometer', conversionFactor: 1000.0),
        Unit(name: 'Centimeter', conversionFactor: 0.01),
        Unit(name: 'Millimeter', conversionFactor: 0.001),
        Unit(name: 'Mile', conversionFactor: 1609.34),
        Unit(name: 'Yard', conversionFactor: 0.9144),
        Unit(name: 'Foot', conversionFactor: 0.3048),
        Unit(name: 'Inch', conversionFactor: 0.0254),
      ],
    ),
    ConversionCategory(
      name: 'Weight/Mass',
      icon: Icons.scale,
      units: [
        Unit(name: 'Kilogram', conversionFactor: 1.0),
        Unit(name: 'Gram', conversionFactor: 0.001),
        Unit(name: 'Milligram', conversionFactor: 0.000001),
        Unit(name: 'Tonne', conversionFactor: 1000.0),
        Unit(name: 'Pound', conversionFactor: 0.453592),
        Unit(name: 'Ounce', conversionFactor: 0.0283495),
      ],
    ),
    ConversionCategory(
      name: 'Temperature',
      icon: Icons.thermostat,
      units: [
        Unit(name: 'Celsius', conversionFactor: 1.0),
        Unit(name: 'Fahrenheit', conversionFactor: 1.0),
        Unit(name: 'Kelvin', conversionFactor: 1.0),
      ],
    ),
    ConversionCategory(
      name: 'Volume',
      icon: Icons.local_drink,
      units: [
        Unit(name: 'Liter', conversionFactor: 1.0),
        Unit(name: 'Milliliter', conversionFactor: 0.001),
        Unit(name: 'Cubic Meter', conversionFactor: 1000.0),
        Unit(name: 'Gallon (US)', conversionFactor: 3.78541),
        Unit(name: 'Pint (US)', conversionFactor: 0.473176),
      ],
    ),
    ConversionCategory(
      name: 'Speed',
      icon: Icons.speed,
      units: [
        Unit(name: 'm/s', conversionFactor: 1.0),
        Unit(name: 'km/h', conversionFactor: 0.277778),
        Unit(name: 'mph', conversionFactor: 0.44704),
        Unit(name: 'knot', conversionFactor: 0.514444),
      ],
    ),
    ConversionCategory(
      name: 'Area',
      icon: Icons.crop_square,
      units: [
        Unit(name: 'Square Meter', conversionFactor: 1.0),
        Unit(name: 'Square Kilometer', conversionFactor: 1000000.0),
        Unit(name: 'Hectare', conversionFactor: 10000.0),
        Unit(name: 'Square Mile', conversionFactor: 2590000.0),
        Unit(name: 'Acre', conversionFactor: 4046.86),
      ],
    ),
    ConversionCategory(
      name: 'Time',
      icon: Icons.timer,
      units: [
        Unit(name: 'Second', conversionFactor: 1.0),
        Unit(name: 'Minute', conversionFactor: 60.0),
        Unit(name: 'Hour', conversionFactor: 3600.0),
        Unit(name: 'Day', conversionFactor: 86400.0),
        Unit(name: 'Week', conversionFactor: 604800.0),
        Unit(name: 'Month', conversionFactor: 2628000.0), // Rata-rata
        Unit(name: 'Year', conversionFactor: 31540000.0), // Rata-rata
      ],
    ),
    ConversionCategory(
      name: 'Pressure',
      icon: Icons.compress,
      units: [
        Unit(name: 'Pascal', conversionFactor: 1.0),
        Unit(name: 'Bar', conversionFactor: 100000.0),
        Unit(name: 'PSI', conversionFactor: 6894.76),
        Unit(name: 'Atmosphere (atm)', conversionFactor: 101325.0),
      ],
    ),
    ConversionCategory(
      name: 'Storage',
      icon: Icons.sd_storage,
      units: [
        Unit(name: 'Bit', conversionFactor: 1.0),
        Unit(name: 'Byte', conversionFactor: 8.0),
        Unit(name: 'Kilobyte (KB)', conversionFactor: 8000.0),
        Unit(name: 'Megabyte (MB)', conversionFactor: 8e+6),
        Unit(name: 'Gigabyte (GB)', conversionFactor: 8e+9),
        Unit(name: 'Terabyte (TB)', conversionFactor: 8e+12),
      ],
    ),
  ];
  // --- AKHIR DARI DATA LENGKAP ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar akan otomatis di-style oleh tema global
      appBar: AppBar(
        title: Text('Unit Converter'),
      ),
      // --- Menggunakan ListView (sesuai harmoni desain) ---
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          // Panggil widget list item yang baru
          return _buildCategoryListItem(context, category);
        },
      ),
    );
  }

  // --- Widget untuk List Item (sesuai harmoni desain) ---
  Widget _buildCategoryListItem(
      BuildContext context, ConversionCategory category) {
    // Gunakan Card agar selaras dengan halaman mata uang
    return Card(
      // Beri sedikit margin antar card
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: ListTile(
        // Ikon di sebelah kiri
        leading: Icon(
          category.icon,
          // Ikon akan menggunakan warna primer (biru)
          color: Theme.of(context).primaryColor,
          size: 30.0,
        ),
        // Teks di tengah
        title: Text(
          category.name,
          // Font style otomatis adaptif
          style: Theme.of(context).textTheme.titleMedium,
        ),
        // Ikon panah di sebelah kanan
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.0,
          color: Colors.grey[500],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConverterScreen(category: category),
            ),
          );
        },
      ),
    );
  }
}