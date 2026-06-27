import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingService {
  // TODO: Replace with your actual RevenueCat API keys
  static const String _androidApiKey = 'goog_cPOiFOCxSoLwLFVxIGhlFlIcUCg';
  static const String _iosApiKey = 'appl_wnROoObgCRUkrjUuVKcJaMxEIVC';
  static const String _entitlementId = 'Vakit Dua: Namaz & Kıble Pro';

  static bool _isInitialized = false;

  /// Initializes the RevenueCat SDK and sets up listeners for subscription updates
  static Future<void> initialize(String appUserId) async {
    if (_isInitialized) {
      // Re-identify if the user ID changed (e.g. login/logout)
      try {
        final currentAppUserId = await Purchases.appUserID;
        if (currentAppUserId != appUserId) {
          await Purchases.logIn(appUserId);
          if (kDebugMode) {
            print("RevenueCat: Re-identified user from $currentAppUserId to $appUserId");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("RevenueCat re-identification error: $e");
        }
      }
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      String apiKey = '';
      if (Platform.isAndroid) {
        apiKey = _androidApiKey;
      } else if (Platform.isIOS) {
        apiKey = _iosApiKey;
      }

      if (apiKey.isEmpty) {
        if (kDebugMode) {
          print("RevenueCat: API Key is empty for this platform.");
        }
        return;
      }

      final configuration = PurchasesConfiguration(apiKey)..appUserID = appUserId;
      await Purchases.configure(configuration);
      _isInitialized = true;

      if (kDebugMode) {
        print("RevenueCat: Initialized successfully for user: $appUserId");
      }

      // Listen to subscription updates in real-time
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        syncPremiumStatus(customerInfo);
      });

      // Initial check
      final customerInfo = await Purchases.getCustomerInfo();
      await syncPremiumStatus(customerInfo);
    } catch (e) {
      if (kDebugMode) {
        print("RevenueCat initialization error: $e");
      }
    }
  }

  /// Synchronizes the active subscription status with local storage and Firestore
  static Future<void> syncPremiumStatus(CustomerInfo customerInfo) async {
    try {
      final isActive = customerInfo.entitlements.active.containsKey(_entitlementId);
      final prefs = await SharedPreferences.getInstance();
      final isSimulated = prefs.getBool('is_simulated_premium') ?? false;
      final targetActive = isActive || isSimulated;

      // 1. Update SharedPreferences
      final localIsPremium = prefs.getBool('is_premium') ?? false;
      if (localIsPremium != targetActive) {
        await prefs.setBool('is_premium', targetActive);
        if (kDebugMode) {
          print("RevenueCat: Updated local premium status to: $targetActive (Simulated: $isSimulated)");
        }
      }

      // 2. Synchronize with Firestore
      final docId = prefs.getString('guest_uuid');

      if (docId != null && docId.isNotEmpty) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(docId);
        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final dbIsPremium = docSnap.data()?['isPremium'] ?? false;
          if (dbIsPremium != targetActive) {
            await docRef.update({'isPremium': targetActive});
            if (kDebugMode) {
              print("RevenueCat: Synchronized premium status ($targetActive) with Firestore for $docId");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("RevenueCat status sync error: $e");
      }
    }
  }

  /// Fetches the current offerings configured in RevenueCat console
  static Future<List<Package>> fetchOfferings() async {
    if (!_isInitialized) return [];
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      if (kDebugMode) {
        print("RevenueCat fetchOfferings error: $e");
      }
    }
    return [];
  }

  /// Purchases a subscription package
  static Future<bool> purchase(Package package) async {
    if (!_isInitialized) return false;
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;
      final isActive = customerInfo.entitlements.active.containsKey(_entitlementId);
      await syncPremiumStatus(customerInfo);
      return isActive;
    } catch (e) {
      if (kDebugMode) {
        print("RevenueCat purchase error: $e");
      }
      return false;
    }
  }

  /// Restores previous purchases (e.g. when reinstalling app)
  static Future<bool> restorePurchases() async {
    if (!_isInitialized) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive = customerInfo.entitlements.active.containsKey(_entitlementId);
      await syncPremiumStatus(customerInfo);
      return isActive;
    } catch (e) {
      if (kDebugMode) {
        print("RevenueCat restorePurchases error: $e");
      }
      return false;
    }
  }
}
