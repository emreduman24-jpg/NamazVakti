import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'prayer_data.dart';

class PrayerRepository {
  static const String baseUrl = 'https://ezanvakti.emushaf.net';

  // Key names for SharedPreferences
  static const String keyCityName = 'selected_city_name';
  static const String keyCityId = 'selected_city_id';
  static const String keyDistrictName = 'selected_district_name';
  static const String keyDistrictId = 'selected_district_id';
  static const String keyPrayerTimes = 'cached_prayer_times';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keyThemeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String keyZikirCount = 'zikir_count';
  static const String keyZikirTarget = 'zikir_target';
  static const String keyDuaList = 'dua_list';

  // Fetch Cities (defaults to Turkey country ID 2)
  Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sehirler/2'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
    // Static fallback list of major Turkish cities if offline
    return [
      {"SehirAdi": "ISTANBUL", "SehirID": "539"},
      {"SehirAdi": "ANKARA", "SehirID": "501"},
      {"SehirAdi": "IZMIR", "SehirID": "540"},
      {"SehirAdi": "BURSA", "SehirID": "512"},
      {"SehirAdi": "ADANA", "SehirID": "500"},
      {"SehirAdi": "ANTALYA", "SehirID": "503"},
      {"SehirAdi": "KONYA", "SehirID": "547"}
    ];
  }

  // Fetch Districts by City ID
  Future<List<Map<String, dynamic>>> getDistricts(String cityId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ilceler/$cityId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
    // Fallback if offline
    if (cityId == "539") {
      return [
        {"IlceAdi": "FATIH", "IlceID": "9541"},
        {"IlceAdi": "KADIKOY", "IlceID": "9546"},
        {"IlceAdi": "USKUDAR", "IlceID": "9562"}
      ];
    }
    return [
      {"IlceAdi": "Merkez", "IlceID": "9541"}
    ];
  }

  // Fetch and Cache Prayer Times
  Future<List<Map<String, dynamic>>> getPrayerTimes(String districtId, {bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!forceRefresh) {
      final cached = prefs.getString(keyPrayerTimes);
      if (cached != null) {
        final List<dynamic> decoded = json.decode(cached);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/vakitler/$districtId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> times = data.map((e) => Map<String, dynamic>.from(e)).toList();
        
        // Cache in SharedPreferences
        await prefs.setString(keyPrayerTimes, json.encode(times));
        return times;
      }
    } catch (e) {
      print('Error fetching prayer times from API, utilizing cached or fallback: $e');
    }

    // Try reading cached again in case we did a forceRefresh and failed
    final cached = prefs.getString(keyPrayerTimes);
    if (cached != null) {
      final List<dynamic> decoded = json.decode(cached);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Fallback to static mock offline times (Istanbul Fatih)
    final List<dynamic> fallbackData = OFFLINE_VAKITLER["9541"] ?? [];
    return fallbackData.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Helper properties to retrieve stored configurations
  Future<Map<String, String?>> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'cityName': prefs.getString(keyCityName),
      'cityId': prefs.getString(keyCityId),
      'districtName': prefs.getString(keyDistrictName),
      'districtId': prefs.getString(keyDistrictId),
    };
  }

  Future<void> saveLocation(String cityName, String cityId, String districtName, String districtId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCityName, cityName);
    await prefs.setString(keyCityId, cityId);
    await prefs.setString(keyDistrictName, districtName);
    await prefs.setString(keyDistrictId, districtId);
  }

  Future<bool> isLocationSelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyDistrictId) != null;
  }

  Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCityName);
    await prefs.remove(keyCityId);
    await prefs.remove(keyDistrictName);
    await prefs.remove(keyDistrictId);
    await prefs.remove(keyPrayerTimes);
  }

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotificationEnabled) ?? true;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotificationEnabled, enabled);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyThemeMode) ?? 'light';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, mode);
  }

  // Zikir Counter Store
  Future<int> getZikirCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyZikirCount) ?? 0;
  }

  Future<void> setZikirCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyZikirCount, count);
  }

  Future<int> getZikirTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyZikirTarget) ?? 33;
  }

  Future<void> setZikirTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyZikirTarget, target);
  }

  static const String keyToolsList = 'cached_tools_list';
  static const String keyBlockStatus = 'cached_block_status';
  static const String keyQuestionList = 'cached_question_list';

  static const String apiBaseUrl = 'http://10.0.2.2:5173/api';

  static const List<Map<String, dynamic>> defaultTools = [
    { "id": "dini-gunler", "title": "Dini Günler", "desc": "Kandiller ve bayramlar", "icon": "📅", "color": "0xFFEAF7F1", "sira": 1, "aktif": true },
    { "id": "dua-iste", "title": "Dua İste", "desc": "Dualarınızı paylaşın", "icon": "🤲", "color": "0xFFEAF4FB", "sira": 2, "aktif": true },
    { "id": "soru-cevap", "title": "Soru Cevap", "desc": "Dini danışmana soru sorun", "icon": "💬", "color": "0xFFFFF7EA", "sira": 3, "aktif": true },
    { "id": "canli-sohbet", "title": "Canlı Kur'an Radyosu", "desc": "7/24 Kesintisiz Diyanet Kur'an Radyo", "icon": "🎧", "color": "0xFFFBEAEA", "sira": 4, "aktif": true },
    { "id": "peygamber-hayati", "title": "Peygamberin Hayatı", "desc": "Hz. Muhammed'in yaşamı", "icon": "📖", "color": "0xFFEAF7F1", "sira": 5, "aktif": true },
    { "id": "kuran-kerim", "title": "Kuran-ı Kerim", "desc": "30 cüz sesli okuma ve takip", "icon": "🕌", "color": "0xFFFFF7EA", "sira": 6, "aktif": true },
    { "id": "esmaul-husna", "title": "Esmaül Hüsna", "desc": "Allah'ın 99 ismi", "icon": "✨", "color": "0xFFEAF4FB", "sira": 7, "aktif": true },
    { "id": "kible-bulucu", "title": "Kıble Bulucu", "desc": "Dijital pusula ile yön", "icon": "🧭", "color": "0xFFFFF7EA", "sira": 8, "aktif": true },
    { "id": "zikirmatik", "title": "Zikirmatik", "desc": "Dijital tesbih sayacı", "icon": "📿", "color": "0xFFEAF4FB", "sira": 9, "aktif": true },
    { "id": "yakindaki-camiler", "title": "Yakındaki Camiler", "desc": "Konumunuza en yakın camiler", "icon": "📍", "color": "0xFFFFF7EA", "sira": 10, "aktif": true },
    { "id": "hadis-40", "title": "40 Hadis-i Şerif", "desc": "40 Hadis meali ve dersler", "icon": "📜", "color": "0xFFEAF4FB", "sira": 11, "aktif": true },
    { "id": "gunluk-dualar", "title": "Dualar", "desc": "Hayatın her anı için dualar", "icon": "🤲", "color": "0xFFEAF7F1", "sira": 12, "aktif": true },
    { "id": "zekat-hesaplama", "title": "Zekat Hesaplama", "desc": "Zekat miktarını hesaplayın", "icon": "💰", "color": "0xFFFFF7EA", "sira": 13, "aktif": true },
    { "id": "sahabe-hayatlari", "title": "Sahabe Hayatları", "desc": "Peygamberin ashabı", "icon": "👥", "color": "0xFFEAF4FB", "sira": 14, "aktif": true },
    { "id": "namaz-kilma", "title": "Namaz Kılma Rehberi", "desc": "Adım adım namaz öğrenin", "icon": "🚶", "color": "0xFFEAF7F1", "sira": 15, "aktif": true },
    { "id": "abdest-rehberi", "title": "Abdest Rehberi", "desc": "Adım adım abdest alınışı", "icon": "💧", "color": "0xFFEAF7F1", "sira": 16, "aktif": true },
    { "id": "gusul-abdesti", "title": "Gusül Abdesti", "desc": "Boy abdesti farz ve sünnetleri", "icon": "🚿", "color": "0xFFFFF7EA", "sira": 17, "aktif": true },
    { "id": "ezkar", "title": "Sabah Akşam Ezkarı", "desc": "Günlük sabah ve akşam zikirleri", "icon": "📿", "color": "0xFFEAF4FB", "sira": 18, "aktif": true },
    { "id": "kaza-namazlari", "title": "Kazaya Kalan Namazlar", "desc": "Kaza çetelesi ve takibi", "icon": "📊", "color": "0xFFFBEAEA", "sira": 19, "aktif": true },
    { "id": "islam-sartlari", "title": "İslam'ın Şartları", "desc": "İslam şartları rehberi", "icon": "⭐", "color": "0xFFEAF4FB", "sira": 20, "aktif": true },
    { "id": "dini-hoca", "title": "Dini Danışman", "desc": "Yapay zeka ile dini sohbet", "icon": "👳", "color": "0xFFFFF7EA", "sira": 21, "aktif": true }
  ];

  // Dynamic Tools list
  Future<List<Map<String, dynamic>>> getDynamicTools() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tools')
          .get()
          .timeout(const Duration(seconds: 4));
      
      if (snap.docs.isNotEmpty) {
        final List<Map<String, dynamic>> tools = snap.docs.map((doc) {
          final data = doc.data();
          return {
            'id': data['id'] ?? doc.id,
            'title': data['title'] ?? '',
            'desc': data['desc'] ?? '',
            'icon': data['icon'] ?? '✨',
            'color': data['color'] ?? '0xFFEAF7F1',
            'sira': data['sira'] ?? 999,
            'aktif': data['aktif'] ?? true,
          };
        }).toList();
        await prefs.setString(keyToolsList, json.encode(tools));
        return tools;
      }
    } catch (e) {
      print('Error fetching tools from Firestore: $e. Using cache.');
    }

    final cached = prefs.getString(keyToolsList);
    if (cached != null) {
      final List<dynamic> decoded = json.decode(cached);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return defaultTools;
  }

  // Global Block Status
  Future<bool> getGlobalBlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('block_status')
          .doc('global')
          .get()
          .timeout(const Duration(seconds: 4));
      
      if (doc.exists) {
        final bool blocked = doc.data()?['blocked'] ?? false;
        await prefs.setBool(keyBlockStatus, blocked);
        return blocked;
      }
    } catch (e) {
      print('Error getting block status from Firestore: $e');
    }
    return prefs.getBool(keyBlockStatus) ?? false;
  }

  // Dua requests list store (using server + SharedPreferences cache)
  Future<List<Map<String, dynamic>>> getDuaList() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('duas')
          .get()
          .timeout(const Duration(seconds: 4));
      
      final List<Map<String, dynamic>> duas = snap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['id'] ?? int.tryParse(doc.id) ?? DateTime.now().millisecondsSinceEpoch,
          'yazar': data['yazar'] ?? 'Anonim',
          'dua': data['dua'] ?? '',
          'amin': data['amin'] ?? 0,
          'durum': data['durum'] ?? 'bekliyor',
          'tarih': data['tarih'] ?? '',
        };
      }).toList();
      
      // Sort: newest first
      duas.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
      
      await prefs.setString(keyDuaList, json.encode(duas));
      return duas;
    } catch (e) {
      print('Error fetching duas from Firestore: $e. Using cache.');
    }

    final cached = prefs.getString(keyDuaList);
    if (cached != null) {
      final List<dynamic> decoded = json.decode(cached);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Default list
    final defaultList = [
      {"id": 1, "yazar": "Ahmet Y.", "dua": "Hastalarımız için şifa, dertlerimiz için deva istiyoruz...", "amin": 45, "durum": "yayinda", "tarih": "17.05.2026 01:10"},
      {"id": 2, "yazar": "Fatma K.", "dua": "Evlatlarımızın sınavlarında başarılar dileriz, dualarınızı bekliyoruz.", "amin": 12, "durum": "yayinda", "tarih": "17.05.2026 01:10"},
      {"id": 3, "yazar": "Mehmet A.", "dua": "Tüm Müslümanlar için hayırlı işler diliyoruz.", "amin": 28, "durum": "yayinda", "tarih": "17.05.2026 01:10"}
    ];
    await prefs.setString(keyDuaList, json.encode(defaultList));
    return defaultList;
  }

  Future<void> addDua(String author, String text) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch;
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      
      await FirebaseFirestore.instance.collection('duas').add({
        "id": id,
        "yazar": author,
        "dua": text,
        "durum": "bekliyor",
        "amin": 0,
        "tarih": dateStr,
      }).timeout(const Duration(seconds: 4));
    } catch (e) {
      print('Error adding dua to Firestore: $e');
    }
  }

  Future<void> addAmin(int id) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('duas')
          .where('id', isEqualTo: id)
          .get()
          .timeout(const Duration(seconds: 4));
      for (var doc in snap.docs) {
        await doc.reference.update({
          'amin': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error adding amin: $e');
    }
  }

  // Question & Answers list store (using server + SharedPreferences cache)
  Future<List<Map<String, dynamic>>> getQuestionList() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('questions')
          .get()
          .timeout(const Duration(seconds: 4));
      
      final List<Map<String, dynamic>> questions = snap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['id'] ?? int.tryParse(doc.id) ?? DateTime.now().millisecondsSinceEpoch,
          'soru': data['soru'] ?? '',
          'cevap': data['cevap'] ?? '',
          'yazar': data['yazar'] ?? 'Anonim',
          'tarih': data['tarih'] ?? '',
        };
      }).toList();
      
      questions.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
      
      await prefs.setString(keyQuestionList, json.encode(questions));
      return questions;
    } catch (e) {
      print('Error fetching questions from Firestore: $e. Using cache.');
    }

    final cached = prefs.getString(keyQuestionList);
    if (cached != null) {
      final List<dynamic> decoded = json.decode(cached);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [
      {
        "id": 1,
        "soru": "Oruçlu iken diş fırçalamak orucu bozar mı?",
        "cevap": "Diyanet İşleri Başkanlığı'nın fetvasına göre, boğaza su kaçırmamak şartıyla macunlu veya macunsuz diş fırçalamak orucu bozmaz. Ancak macunun yutulması durumunda oruç bozulur ve kaza gerekir.",
        "tarih": "20.05.2026 14:32",
        "yazar": "Ahmet Yılmaz"
      }
    ];
  }

  Future<void> sendQuestion(String author, String text) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch;
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      await FirebaseFirestore.instance.collection('questions').add({
        "id": id,
        "yazar": author,
        "soru": text,
        "cevap": "",
        "tarih": dateStr,
      }).timeout(const Duration(seconds: 4));
    } catch (e) {
      print('Error sending question to Firestore: $e');
    }
  }

  Future<void> saveDuaList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDuaList, json.encode(list));
  }
}
