// lib/models/conversion_models.dart

import 'package:flutter/material.dart';

// Class untuk satu unit (mis: Meter, Kaki, Gram)
class Unit {
  final String name;
  final double conversionFactor; // Faktor konversi ke unit dasar (mis: Meter, Kilogram)

  Unit({required this.name, required this.conversionFactor});
}

// Class untuk satu kategori (mis: Length, Weight)
class ConversionCategory {
  final String name;
  final IconData icon;
  final List<Unit> units;

  ConversionCategory({
    required this.name,
    required this.icon,
    required this.units,
  });
}