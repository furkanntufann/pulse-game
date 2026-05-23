import 'package:shared_preferences/shared_preferences.dart';

/// Cihazda kalıcı skor kaydı (SharedPreferences).
class StorageService {
  static const _keyBestScore = 'best_score';
  static const _keyBestCombo = 'best_combo';
  static const _keyTodayScore = 'today_score';
  static const _keyTodayDate = 'today_date';

  static Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> _prefs() {
    _prefsFuture ??= SharedPreferences.getInstance();
    return _prefsFuture!;
  }

  Future<int> loadBestScore() async {
    final prefs = await _prefs();
    return prefs.getInt(_keyBestScore) ?? 0;
  }

  Future<int> loadBestCombo() async {
    final prefs = await _prefs();
    return prefs.getInt(_keyBestCombo) ?? 0;
  }

  Future<int> loadTodayBest() async {
    final prefs = await _prefs();
    final today = _todayKey();
    final savedDate = prefs.getString(_keyTodayDate);
    if (savedDate != today) return 0;
    return prefs.getInt(_keyTodayScore) ?? 0;
  }

  /// Oyun sonu skorlarını kaydeder; güncel rekor ve bugün değerlerini döner.
  Future<({int bestScore, int todayScore, int bestCombo})> persistRun({
    required int score,
    required int combo,
  }) async {
    final prefs = await _prefs();
    final today = _todayKey();

    var bestScore = prefs.getInt(_keyBestScore) ?? 0;
    if (score > bestScore) {
      bestScore = score;
      await prefs.setInt(_keyBestScore, bestScore);
    }

    var bestCombo = prefs.getInt(_keyBestCombo) ?? 0;
    if (combo > bestCombo) {
      bestCombo = combo;
      await prefs.setInt(_keyBestCombo, bestCombo);
    }

    final savedDate = prefs.getString(_keyTodayDate);
    var todayScore = 0;
    if (savedDate == today) {
      todayScore = prefs.getInt(_keyTodayScore) ?? 0;
    }
    if (score > todayScore) {
      todayScore = score;
      await prefs.setInt(_keyTodayScore, todayScore);
      await prefs.setString(_keyTodayDate, today);
    }

    return (bestScore: bestScore, todayScore: todayScore, bestCombo: bestCombo);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
