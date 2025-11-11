// lib/models/history_model.dart

// Model ini akan menyimpan satu entri riwayat
class HistoryItem {
  final String fromCode;
  final String toCode;
  final double fromValue;
  final double toValue;
  final DateTime timestamp; // Kapan ini disimpan

  HistoryItem({
    required this.fromCode,
    required this.toCode,
    required this.fromValue,
    required this.toValue,
    required this.timestamp,
  });

  // --- Ini penting untuk SharedPreferences ---

  // Mengubah objek HistoryItem menjadi Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'fromCode': fromCode,
      'toCode': toCode,
      'fromValue': fromValue,
      'toValue': toValue,
      // Simpan timestamp sebagai string standar (ISO 8601)
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Membuat objek HistoryItem dari Map (JSON)
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      fromCode: json['fromCode'],
      toCode: json['toCode'],
      fromValue: json['fromValue'],
      toValue: json['toValue'],
      // Ubah string kembali menjadi objek DateTime
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}