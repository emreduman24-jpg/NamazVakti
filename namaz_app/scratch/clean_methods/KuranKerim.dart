Widget _buildKuranKerim() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF27A770).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.music_note, color: Color(0xFF27A770), size: 36),
              SizedBox(height: 8),
              Text(
                _currentTrackName.isEmpty
                    ? "Cüz seçin ve oynatın"
                                              fontWeight: FontWeight.bold,
                                              color: _greenColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            item['cevap'] ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _textColor,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }