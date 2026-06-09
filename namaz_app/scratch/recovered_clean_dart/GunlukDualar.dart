    final Map<String, List<Map<String, String>>> grouped = {
      'sabah_aksam': [],
      'namaz': [],
      'yemek': [],
      'uyku': [],
      'yolculuk': [],
      'genel': [],
    };
    
    for (var dua in filteredList) {
      final cat = dua['kategori'] ?? 'genel';
      grouped[cat]?.add(dua);
    }

    final categories = [
      {'key': 'sabah_aksam', 'title': 'Sabah & Akşam Ezkarı', 'emoji': '☀️'},
      {'key': 'namaz', 'title': 'Namaz Duaları', 'emoji': '🕌'},
      {'key': 'yemek', 'title': 'Yemek Duaları', 'emoji': '🍴'},
      {'key': 'uyku', 'title': 'Uyku Duaları', 'emoji': '🌙'},
      {'key': 'yolculuk', 'title': 'Yolculuk Duaları', 'emoji': '🚗'},
      {'key': 'genel', 'title': 'Genel Dualar', 'emoji': '✨'},
    ];