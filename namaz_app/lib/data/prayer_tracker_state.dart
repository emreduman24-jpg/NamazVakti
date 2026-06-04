import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTrackerState extends ChangeNotifier {
  static final PrayerTrackerState _instance = PrayerTrackerState._internal();
  factory PrayerTrackerState() => _instance;

  PrayerTrackerState._internal() {
    _loadHistory();
  }

  Map<String, List<bool>> _history = {};
  bool _loading = true;

  Map<String, List<bool>> get history => _history;
  bool get loading => _loading;

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('prayer_tracker_history');
      if (jsonStr != null) {
        final Map<String, dynamic> rawMap = json.decode(jsonStr);
        final Map<String, List<bool>> loadedHistory = {};
        rawMap.forEach((key, val) {
          if (val is List) {
            loadedHistory[key] = val.map((e) => e == true).toList();
          }
        });
        _history = loadedHistory;
      }
    } catch (e) {
      debugPrint("Load history error: $e");
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, List<bool>> cleanMap = {};
      _history.forEach((key, val) {
        if (val.any((element) => element == true)) {
          cleanMap[key] = val;
        }
      });
      final String jsonStr = json.encode(cleanMap);
      await prefs.setString('prayer_tracker_history', jsonStr);
    } catch (e) {
      debugPrint("Save history error: $e");
    }
  }

  void togglePrayer(String dateStr, int prayerIndex) {
    final list = List<bool>.from(_history[dateStr] ?? [false, false, false, false, false]);
    list[prayerIndex] = !list[prayerIndex];
    _history[dateStr] = list;
    notifyListeners();
    saveHistory();
  }

  void setHistory(Map<String, List<bool>> newHistory) {
    _history = Map<String, List<bool>>.from(newHistory);
    notifyListeners();
    saveHistory();
  }

  void forceReload() {
    _loadHistory();
  }
}
