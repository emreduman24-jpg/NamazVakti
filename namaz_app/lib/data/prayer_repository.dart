import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    { "id": "canli-sohbet", "title": "Canlı Dini Sohbet", "desc": "Sohbete katılın", "icon": "🎧", "color": "0xFFFBEAEA", "sira": 4, "aktif": true },
    { "id": "peygamber-hayati", "title": "Peygamberin Hayatı", "desc": "Hz. Muhammed'in yaşamı", "icon": "📖", "color": "0xFFEAF7F1", "sira": 5, "aktif": true },
    { "id": "kuran-kerim", "title": "Kuran-ı Kerim", "desc": "30 cüz sesli okuma ve takip", "icon": "🕌", "color": "0xFFFFF7EA", "sira": 6, "aktif": true },
    { "id": "esmaul-husna", "title": "Esmaül Hüsna", "desc": "Allah'ın 99 ismi", "icon": "✨", "color": "0xFFEAF4FB", "sira": 7, "aktif": true },
    { "id": "ramazan-hakkinda", "title": "Ramazan Hakkında", "desc": "Mübarek ayın önemi", "icon": "🌙", "color": "0xFFFBEAEA", "sira": 8, "aktif": true },
    { "id": "oruc-rehberi", "title": "Oruç Rehberi", "desc": "Oruç ibadetinin detayları", "icon": "🍽️", "color": "0xFFEAF7F1", "sira": 9, "aktif": true },
    { "id": "kible-bulucu", "title": "Kıble Bulucu", "desc": "Dijital pusula ile yön", "icon": "🧭", "color": "0xFFFFF7EA", "sira": 10, "aktif": true },
    { "id": "zikirmatik", "title": "Zikirmatik", "desc": "Dijital tesbih sayacı", "icon": "📿", "color": "0xFFEAF4FB", "sira": 11, "aktif": true },
    { "id": "miladi-hicri", "title": "Miladi - Hicri", "desc": "Tarih çevirici", "icon": "🔄", "color": "0xFFFBEAEA", "sira": 12, "aktif": true },
    { "id": "yasin-suresi", "title": "Yasin Suresi", "desc": "Kuran'ın kalbi", "icon": "💚", "color": "0xFFEAF7F1", "sira": 13, "aktif": true },
    { "id": "yakindaki-camiler", "title": "Yakındaki Camiler", "desc": "Konumunuza en yakın camiler", "icon": "📍", "color": "0xFFFFF7EA", "sira": 14, "aktif": true },
    { "id": "hadis-40", "title": "40 Hadis-i Şerif", "desc": "İmam Nevevi koleksiyonu", "icon": "📜", "color": "0xFFEAF4FB", "sira": 15, "aktif": true },
    { "id": "namaz-tesbihati", "title": "Namaz Tesbihatı", "desc": "Namaz sonrası dualar", "icon": "📿", "color": "0xFFFBEAEA", "sira": 16, "aktif": true },
    { "id": "gunluk-dualar", "title": "Günlük Dualar", "desc": "Hayatın her anı için dualar", "icon": "🤲", "color": "0xFFEAF7F1", "sira": 17, "aktif": true },
    { "id": "zekat-hesaplama", "title": "Zekat Hesaplama", "desc": "Zekat miktarını hesaplayın", "icon": "💰", "color": "0xFFFFF7EA", "sira": 18, "aktif": true },
    { "id": "sahabe-hayatlari", "title": "Sahabe Hayatları", "desc": "Peygamberin ashabı", "icon": "👥", "color": "0xFFEAF4FB", "sira": 19, "aktif": true },
    { "id": "islam-tarihi", "title": "İslam Tarihi", "desc": "Önemli olaylar ve dönemler", "icon": "⏳", "color": "0xFFFBEAEA", "sira": 20, "aktif": true },
    { "id": "namaz-kilma", "title": "Namaz Kılma Rehberi", "desc": "Adım adım namaz öğrenin", "icon": "🚶", "color": "0xFFEAF7F1", "sira": 21, "aktif": true },
    { "id": "vitir-namazi", "title": "Vitir Namazı", "desc": "Yatsı sonrası vacip namaz", "icon": "🌟", "color": "0xFFFFF7EA", "sira": 22, "aktif": true },
    { "id": "cuma-namazi", "title": "Cuma Namazı Rehberi", "desc": "Cuma namazı şartları ve adabı", "icon": "🕌", "color": "0xFFEAF7F1", "sira": 23, "aktif": true },
    { "id": "teravih-namazi", "title": "Teravih Namazı", "desc": "Kılınışı ve faziletleri", "icon": "🌙", "color": "0xFFEAF4FB", "sira": 24, "aktif": true },
    { "id": "bayram-namazi", "title": "Bayram Namazı", "desc": "Bayram namazı kılınışı", "icon": "🎉", "color": "0xFFFFF7EA", "sira": 25, "aktif": true },
    { "id": "cenaze-namazi", "title": "Cenaze Namazı", "desc": "Kılınışı ve duaları", "icon": "⚰️", "color": "0xFFFBEAEA", "sira": 26, "aktif": true },
    { "id": "abdest-rehberi", "title": "Abdest Rehberi", "desc": "Adım adım abdest alınışı", "icon": "💧", "color": "0xFFEAF7F1", "sira": 27, "aktif": true },
    { "id": "gusul-abdesti", "title": "Gusül Abdesti", "desc": "Boy abdesti farz ve sünnetleri", "icon": "🚿", "color": "0xFFFFF7EA", "sira": 28, "aktif": true },
    { "id": "teyemmum", "title": "Teyemmüm Rehberi", "desc": "Toprakla abdest alma rehberi", "icon": "⏳", "color": "0xFFEAF4FB", "sira": 29, "aktif": true },
    { "id": "secdei-sehiv", "title": "Secde-i Sehiv", "desc": "Yanılgı secdesi yapılışı", "icon": "🚶", "color": "0xFFFBEAEA", "sira": 30, "aktif": true },
    { "id": "secdei-tilavet", "title": "Secde-i Tilavet", "desc": "Tilavet secdesi ve yapılışı", "icon": "📖", "color": "0xFFEAF7F1", "sira": 31, "aktif": true },
    { "id": "kunut-duasi", "title": "Kunut Duaları", "desc": "Kunut 1 ve Kunut 2 duaları", "icon": "🤲", "color": "0xFFFFF7EA", "sira": 32, "aktif": true },
    { "id": "ezkar", "title": "Sabah Akşam Ezkarı", "desc": "Günlük sabah ve akşam zikirleri", "icon": "📿", "color": "0xFFEAF4FB", "sira": 33, "aktif": true },
    { "id": "kandiller", "title": "Mübarek Kandiller", "desc": "Kandil geceleri ibadetleri", "icon": "✨", "color": "0xFFFBEAEA", "sira": 34, "aktif": true },
    { "id": "hac-rehberi", "title": "Hac Rehberi", "desc": "Adım adım hac ibadeti", "icon": "🕋", "color": "0xFFEAF7F1", "sira": 35, "aktif": true },
    { "id": "umre-rehberi", "title": "Umre Rehberi", "desc": "Umre duaları ve rehberi", "icon": "🕋", "color": "0xFFEAF4FB", "sira": 36, "aktif": true },
    { "id": "hac-dualari", "title": "Hac Duaları", "desc": "Hacda okunacak dualar", "icon": "🤲", "color": "0xFFFFF7EA", "sira": 37, "aktif": true },
    { "id": "helal-haram", "title": "Helal ve Haramlar", "desc": "İslamda helal ve haram sınırlar", "icon": "⚖️", "color": "0xFFFBEAEA", "sira": 38, "aktif": true },
    { "id": "aile-hukuku", "title": "Aile Hukuku", "desc": "Evlilik ve aile hayatı rehberi", "icon": "🏠", "color": "0xFFEAF7F1", "sira": 39, "aktif": true },
    { "id": "ticaret-fikhi", "title": "Ticaret Fıkhı", "desc": "İslamda helal ticaret esasları", "icon": "💼", "color": "0xFFEAF4FB", "sira": 40, "aktif": true },
    { "id": "miras-hukuku", "title": "Miras Hukuku", "desc": "Miras paylaşımı ve kuralları", "icon": "📄", "color": "0xFFFFF7EA", "sira": 41, "aktif": true },
    { "id": "islam-ahlaki", "title": "İslam Ahlakı", "desc": "Güzel ahlak ve edep kuralları", "icon": "🌸", "color": "0xFFFBEAEA", "sira": 42, "aktif": true },
    { "id": "komsu-haklar", "title": "Komşu Hakları", "desc": "Komşuluk adabı ve hakları", "icon": "🤝", "color": "0xFFEAF7F1", "sira": 43, "aktif": true },
    { "id": "anne-baba", "title": "Anne-Baba Hakları", "desc": "Ebeveyne karşı görevlerimiz", "icon": "❤️", "color": "0xFFEAF4FB", "sira": 44, "aktif": true },
    { "id": "misafir-adabi", "title": "Misafir Adabı", "desc": "Misafirlik ve ikram kuralları", "icon": "☕", "color": "0xFFFFF7EA", "sira": 45, "aktif": true },
    { "id": "kaza-namazlari", "title": "Kazaya Kalan Namazlar", "desc": "Kaza çetelesi ve takibi", "icon": "📊", "color": "0xFFFBEAEA", "sira": 46, "aktif": true },
    { "id": "teheccud", "title": "Teheccüd Namazı", "desc": "Gece namazı faziletleri ve kılınışı", "icon": "🌌", "color": "0xFFEAF7F1", "sira": 47, "aktif": true },
    { "id": "istigfar", "title": "Tövbe ve İstiğfar", "desc": "Bağışlanma duaları", "icon": "🤲", "color": "0xFFEAF4FB", "sira": 48, "aktif": true },
    { "id": "sukur", "title": "Şükür İbadeti", "desc": "Nimetlere karşı şükür adabı", "icon": "🙌", "color": "0xFFFFF7EA", "sira": 49, "aktif": true },
    { "id": "tovbe", "title": "Tövbe Nasıl Yapılır", "desc": "Nasuh tövbesi ve kabulü", "icon": "🔑", "color": "0xFFFBEAEA", "sira": 50, "aktif": true },
    { "id": "iman-esaslar", "title": "İmanın Esasları", "desc": "İman şartları detaylı açıklaması", "icon": "🛡️", "color": "0xFFEAF7F1", "sira": 51, "aktif": true },
    { "id": "islam-sartlari", "title": "İslam'ın Şartları", "desc": "İslam şartları rehberi", "icon": "⭐", "color": "0xFFEAF4FB", "sira": 52, "aktif": true },
    { "id": "kader-kaza", "title": "Kader ve Kaza", "desc": "Kader inancı ve tevekkül", "icon": "🌀", "color": "0xFFFFF7EA", "sira": 53, "aktif": true },
    { "id": "ahiret", "title": "Ahiret İnancı", "desc": "Kabir hayatı ve ahiret aşamaları", "icon": "⏳", "color": "0xFFFBEAEA", "sira": 54, "aktif": true },
    { "id": "muharrem", "title": "Muharrem Ayı", "desc": "Aşure günü ve orucu", "icon": "🥣", "color": "0xFFEAF7F1", "sira": 55, "aktif": true },
    { "id": "recep", "title": "Recep Ayı", "desc": "Üç ayların başlangıcı", "icon": "🌙", "color": "0xFFEAF4FB", "sira": 56, "aktif": true },
    { "id": "saban", "title": "Şaban Ayı", "desc": "Berat gecesi ve orucu", "icon": "🌙", "color": "0xFFFFF7EA", "sira": 57, "aktif": true },
    { "id": "zilhicce", "title": "Zilhicce Ayı", "desc": "Kurban bayramı ve zilhicce günleri", "icon": "🐏", "color": "0xFFFBEAEA", "sira": 58, "aktif": true },
    { "id": "tevhid", "title": "Kelime-i Tevhid", "desc": "Kelime-i Tevhid sayacı", "icon": "📿", "color": "0xFFEAF7F1", "sira": 59, "aktif": true },
    { "id": "tefriciye", "title": "Salat-ı Tefriciye", "desc": "4444 Tefriciye zikir sayacı", "icon": "📿", "color": "0xFFEAF4FB", "sira": 60, "aktif": true },
    { "id": "ummiye", "title": "Salat-ı Ümmiye", "desc": "Salat-ı Ümmiye zikir sayacı", "icon": "📿", "color": "0xFFFFF7EA", "sira": 61, "aktif": true },
    { "id": "cevsen", "title": "Cevşen Duaları", "desc": "Cevşen-ül Kebir okunuşu ve meali", "icon": "🛡️", "color": "0xFFFBEAEA", "sira": 62, "aktif": true },
    { "id": "berat-duasi", "title": "Berat Gecesi Duaları", "desc": "Berat gecesinde okunacak dualar", "icon": "🤲", "color": "0xFFEAF7F1", "sira": 63, "aktif": true },
    { "id": "kadir-gecesi", "title": "Kadir Gecesi Duaları", "desc": "Kadir gecesi ibadetleri", "icon": "🌟", "color": "0xFFEAF4FB", "sira": 64, "aktif": true },
    { "id": "halifeler", "title": "Dört Halife Dönemi", "icon": "👑", "color": "0xFFFFF7EA", "sira": 65, "aktif": true, "desc": "Hulefa-i Raşidin hayatları" },
    { "id": "medeniyet", "title": "İslam Medeniyeti", "icon": "🏛️", "color": "0xFFFBEAEA", "sira": 66, "aktif": true, "desc": "İslamın bilim ve kültüre katkıları" },
    { "id": "alimler", "title": "İslam Alimleri", "icon": "🎓", "color": "0xFFEAF7F1", "sira": 67, "aktif": true, "desc": "Büyük fıkıh ve itikat imamları" },
    { "id": "gazveler", "title": "Gazve ve Seriyyeler", "icon": "⚔️", "color": "0xFFEAF4FB", "sira": 68, "aktif": true, "desc": "Peygamberimizin katıldığı savaşlar" },
    { "id": "rabbena-dualari", "title": "Rabbena Duaları", "icon": "🤲", "color": "0xFFFFF7EA", "sira": 69, "aktif": true, "desc": "Namazda okunan Rabbena duaları" },
    { "id": "peygamber-dualari", "title": "Peygamber Duaları", "icon": "🤲", "color": "0xFFFBEAEA", "sira": 70, "aktif": true, "desc": "Kuran'daki peygamber duaları" }
  ];

  // Dynamic Tools list
  Future<List<Map<String, dynamic>>> getDynamicTools() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/tools')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        await prefs.setString(keyToolsList, response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error fetching tools: $e. Using cache.');
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
      final response = await http.get(Uri.parse('$apiBaseUrl/block_status')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final bool blocked = data['blocked'] ?? false;
        await prefs.setBool(keyBlockStatus, blocked);
        return blocked;
      }
    } catch (e) {
      print('Error getting block status: $e');
    }
    return prefs.getBool(keyBlockStatus) ?? false;
  }

  // Dua requests list store (using server + SharedPreferences cache)
  Future<List<Map<String, dynamic>>> getDuaList() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/duas')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        await prefs.setString(keyDuaList, response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error fetching duas: $e. Using cache.');
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
      await http.post(
        Uri.parse('$apiBaseUrl/duas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "yazar": author,
          "dua": text,
          "durum": "bekliyor",
          "amin": 0,
        }),
      ).timeout(const Duration(seconds: 2));
    } catch (e) {
      print('Error adding dua: $e');
    }
  }

  Future<void> addAmin(int id) async {
    try {
      await http.post(
        Uri.parse('$apiBaseUrl/duas/amin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"id": id}),
      ).timeout(const Duration(seconds: 2));
    } catch (e) {
      print('Error adding amin: $e');
    }
  }

  // Question & Answers list store (using server + SharedPreferences cache)
  Future<List<Map<String, dynamic>>> getQuestionList() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/questions')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        await prefs.setString(keyQuestionList, response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error fetching questions: $e. Using cache.');
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
      await http.post(
        Uri.parse('$apiBaseUrl/questions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "yazar": author,
          "soru": text,
          "cevap": "",
        }),
      ).timeout(const Duration(seconds: 2));
    } catch (e) {
      print('Error sending question: $e');
    }
  }

  Future<void> saveDuaList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDuaList, json.encode(list));
  }
}
