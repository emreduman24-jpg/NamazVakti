Widget _buildWeekViewChart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
        children: [
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: const Color(0xFF27A770), size: 20),
              SizedBox(width: 8),
              Text(
                "Bu Haftanın Zikir Takibi",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _greenColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.g
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    zikir['ad'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27A770),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    zikir['arapca'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _greenColor,
                      fontFamily: 'Traditional Arabic',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "“${zikir['anlam']}”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: _isDark ? Colors.white60 : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF9EDD4)),
                    ),
                    child: Text(
                      zikir['fazilet'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Zikir circle button
          GestureDetector(
            onTap: _incrementZikir,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27A770), width: 8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRad

























          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardBgColor,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Sıfırla"),
                      content: Text(
                        "Sayacı sıfırlamak istediğinize emin misiniz?",
                      ),
                      actions: [
                        TextButton(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _greenColor,
                      fontFamily: 'Traditional Arabic',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "“${zikir['anlam']}”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: _isDark ? Colors.white60 : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF9EDD4)),
                    ),
                    child: Text(
                      zikir['fazilet'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Zikir circle button
          GestureDetector(
            onTap: _incrementZikir,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF27A770), width: 8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$_zikirCount",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _greenColor,
                      ),
                    ),
                    Text(
                      _zikirTarget == 9999 ? "/ ∞" : "/ $_zikirTarget",
                      style: TextStyle(fontSize: 13, color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildWeekViewChart(),
          SizedBox(height: 16),
          // Zikir actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardBgColor,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Sıfırla"),
                      content: Text(
                        "Sayacı sıfırlamak istediğinize emin misiniz?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetZikir();
                            Navigator.pop(context);
                          },
                          child: Text("Evet"),
                        ),
                      ],
                    ),
                  );
                },
                child: Text("Sıfırla", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _zikirSoundEnabled ? const Color(0xFF27A770) : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _zikirSoundEnabled = !_zikirSoundEnabled;
                  });
                },
                child: Text(







































































































































































































































              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF27A770)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Konumunuza yakın camiler aranıyor...",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : _dynamicMosquesList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mosque, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            "Yakınınızda cami bulunamadı.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _getUserLocation(forceRefresh: true),
                            icon: Icon(Icons.refresh, size: 18),
                            label: Text("Tekrar Dene"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27A770),
                              foregroundColor: Colors.white,








































































































































































































                              backgroundColor: Color(0xFFEAF7F1),
                              child: Icon(Icons.mosque, color: Color(0xFF27A770)),
                            ),
                            title: Text(
                              camii['ad'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              "📍 ${camii['adres'] ?? ''}",
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  camii['mesafeText'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF27A770),
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Icon(Icons.directions, size: 16, color: Color(0xFF27A770)),





































































































































































































































































































                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 17. Günlük Dualar
  Widget _buildGunlukDualar() {
    return ListView.builder(
      itemCount: DUALAR.length,
      itemBuilder: (context, index) {
        final dua = DUALAR[index];
        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua['ad'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _greenColor,
                  ),
                ),
                Divider(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dua['arapca'] ?? '',
                    style: TextStyle(
                        );
                        setState(() {
                          _tesbihCount = 0;
                          if (_tesbihStep < TESBIHAT_STEPS.length - 1) {
                            _tesbihStep++;
                          } else {
                            _tesbihStep = 0;
                          }
                        });
                      }
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7F1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF27A770),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "$_tesbihCount / $target",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _greenColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }