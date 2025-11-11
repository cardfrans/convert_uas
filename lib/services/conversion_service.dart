// lib/services/conversion_service.dart

import 'package:convert_uas/models/conversion_models.dart';
import 'dart:math';

class ConversionService {

  // Fungsi utama untuk mengkonversi
  double convert(double value, Unit from, Unit to, String categoryName) {
    // Pengecualian khusus untuk Suhu (Temperature)
    if (categoryName == 'Temperature') {
      return _convertTemperature(value, from.name, to.name);
    }

    // Konversi standar (berbasis faktor)
    // 1. Ubah nilai input ke unit dasar
    double valueInBaseUnit = value * from.conversionFactor;

    // 2. Ubah dari unit dasar ke unit tujuan
    double result = valueInBaseUnit / to.conversionFactor;

    return result;
  }

  // Fungsi khusus untuk Suhu karena rumusnya tidak linear (bukan cuma perkalian)
  double _convertTemperature(double value, String fromName, String toName) {
    if (fromName == toName) return value;

    double celsius;

    // 1. Ubah semua input ke Celsius terlebih dahulu
    switch (fromName) {
      case 'Celsius':
        celsius = value;
        break;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    // 2. Konversi dari Celsius ke unit tujuan
    switch (toName) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return (celsius * 9 / 5) + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }
}