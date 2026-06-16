import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static bool _isInitialized = false;

  // AdMob Test Banner Ad Unit IDs
  static const String _androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';

  // Production AdMob Banner Ad Unit IDs
  static const String _androidRealBannerId = 'ca-app-pub-8869776194218180/1586853910';
  static const String _iosRealBannerId = 'ca-app-pub-8869776194218180/3435122202';

  /// Initializes the AdMob SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      if (kDebugMode) {
        print("AdMob initialized successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AdMob initialization error: $e");
      }
    }
  }

  /// Check if ads should be displayed (non-premium users only)
  static Future<bool> shouldShowAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('is_premium') ?? false;
      return !isPremium;
    } catch (e) {
      return true;
    }
  }

  /// Returns the appropriate Banner Ad Unit ID based on platform and debug mode
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _androidTestBannerId : _iosTestBannerId;
    } else {
      // In production, return real IDs (currently set to test IDs, can be updated later)
      return Platform.isAndroid ? _androidRealBannerId : _iosRealBannerId;
    }
  }
}
