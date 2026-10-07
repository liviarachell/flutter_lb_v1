
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o ponto de leitura de cada obra no dispositivo.
class ReadingRepository {
  static final ValueNotifier<int> revision = ValueNotifier(0);
  static const _prefix = 'reading_progress_';

  static Future<double> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getDouble('$_prefix$bookId') ?? 0).clamp(0.0, 1.0);
  }

  static Future<void> saveProgress(String bookId, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_prefix$bookId', value.clamp(0.0, 1.0));
    revision.value++;
  }
}
