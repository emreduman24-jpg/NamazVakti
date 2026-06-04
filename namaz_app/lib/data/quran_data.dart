class QuranSurah {
  final int number;
  final String name;
  final String arabicName;
  final int versesCount;
  final String revelationPlace;
  final String audioUrl;

  const QuranSurah({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.versesCount,
    required this.revelationPlace,
    required this.audioUrl,
  });
}

class QuranJuz {
  final int number;
  final String title;
  final String range;
  final String arabicLabel;
  final String audioUrl;

  const QuranJuz({
    required this.number,
    required this.title,
    required this.range,
    required this.arabicLabel,
    required this.audioUrl,
  });
}

class OfflineVerse {
  final int number;
  final String arabic;
  final String transliteration;
  final String translation;
  final String? surahName;
  final int? surahNumber;

  const OfflineVerse({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.surahName,
    this.surahNumber,
  });
}

const List<QuranJuz> QURAN_JUZS = [
  QuranJuz(number: 1, title: "1. Cüz", range: "Fâtiha - Bakara (1-141)", arabicLabel: "الجزء ١", audioUrl: "https://server8.mp3quran.net/afs/001.mp3"),
  QuranJuz(number: 2, title: "2. Cüz", range: "Bakara (142-252)", arabicLabel: "الجزء ٢", audioUrl: "https://server8.mp3quran.net/afs/002.mp3"),
  QuranJuz(number: 3, title: "3. Cüz", range: "Bakara - Âl-i İmrân (253-92)", arabicLabel: "الجزء ٣", audioUrl: "https://server8.mp3quran.net/afs/003.mp3"),
  QuranJuz(number: 4, title: "4. Cüz", range: "Âl-i İmrân - Nisâ (93-23)", arabicLabel: "الجزء ٤", audioUrl: "https://server8.mp3quran.net/afs/004.mp3"),
  QuranJuz(number: 5, title: "5. Cüz", range: "Nisâ (24-147)", arabicLabel: "الجزء ٥", audioUrl: "https://server8.mp3quran.net/afs/005.mp3"),
  QuranJuz(number: 6, title: "6. Cüz", range: "Nisâ - Mâide (148-81)", arabicLabel: "الجزء ٦", audioUrl: "https://server8.mp3quran.net/afs/006.mp3"),
  QuranJuz(number: 7, title: "7. Cüz", range: "Mâide - En'âm (82-110)", arabicLabel: "الجزء ٧", audioUrl: "https://server8.mp3quran.net/afs/007.mp3"),
  QuranJuz(number: 8, title: "8. Cüz", range: "En'âm - A'râf (111-87)", arabicLabel: "الجزء ٨", audioUrl: "https://server8.mp3quran.net/afs/008.mp3"),
  QuranJuz(number: 9, title: "9. Cüz", range: "A'râf - Enfâl (88-40)", arabicLabel: "الجزء ٩", audioUrl: "https://server8.mp3quran.net/afs/009.mp3"),
  QuranJuz(number: 10, title: "10. Cüz", range: "Enfâl - Tevbe (41-92)", arabicLabel: "الجزء ١٠", audioUrl: "https://server8.mp3quran.net/afs/010.mp3"),
  QuranJuz(number: 11, title: "11. Cüz", range: "Tevbe - Yûnus (93-5)", arabicLabel: "الجزء ١١", audioUrl: "https://server8.mp3quran.net/afs/011.mp3"),
  QuranJuz(number: 12, title: "12. Cüz", range: "Yûnus - Hûd (6-52)", arabicLabel: "الجزء ١٢", audioUrl: "https://server8.mp3quran.net/afs/012.mp3"),
  QuranJuz(number: 13, title: "13. Cüz", range: "Hûd - İbrâhîm (53-52)", arabicLabel: "الجزء ١٣", audioUrl: "https://server8.mp3quran.net/afs/013.mp3"),
  QuranJuz(number: 14, title: "14. Cüz", range: "Hicr - Nahl (1-128)", arabicLabel: "الجزء ١٤", audioUrl: "https://server8.mp3quran.net/afs/014.mp3"),
  QuranJuz(number: 15, title: "15. Cüz", range: "İsrâ - Kehf (1-74)", arabicLabel: "الجزء ١٥", audioUrl: "https://server8.mp3quran.net/afs/015.mp3"),
  QuranJuz(number: 16, title: "16. Cüz", range: "Kehf - Tâhâ (75-135)", arabicLabel: "الجزء ١٦", audioUrl: "https://server8.mp3quran.net/afs/016.mp3"),
  QuranJuz(number: 17, title: "17. Cüz", range: "Enbiyâ - Hac (1-78)", arabicLabel: "الجزء ١٧", audioUrl: "https://server8.mp3quran.net/afs/017.mp3"),
  QuranJuz(number: 18, title: "18. Cüz", range: "Mü'minûn - Furkân (1-20)", arabicLabel: "الجزء ١٨", audioUrl: "https://server8.mp3quran.net/afs/018.mp3"),
  QuranJuz(number: 19, title: "19. Cüz", range: "Furkân - Neml (21-55)", arabicLabel: "الجزء ١٩", audioUrl: "https://server8.mp3quran.net/afs/019.mp3"),
  QuranJuz(number: 20, title: "20. Cüz", range: "Neml - Ankebût (56-45)", arabicLabel: "الجزء ٢٠", audioUrl: "https://server8.mp3quran.net/afs/020.mp3"),
  QuranJuz(number: 21, title: "21. Cüz", range: "Ankebût - Ahzâb (46-30)", arabicLabel: "الجزء ٢١", audioUrl: "https://server8.mp3quran.net/afs/021.mp3"),
  QuranJuz(number: 22, title: "22. Cüz", range: "Ahzâb - Yâsîn (31-27)", arabicLabel: "الجزء ٢٢", audioUrl: "https://server8.mp3quran.net/afs/022.mp3"),
  QuranJuz(number: 23, title: "23. Cüz", range: "Yâsîn - Zümer (28-31)", arabicLabel: "الجزء ٢٣", audioUrl: "https://server8.mp3quran.net/afs/023.mp3"),
  QuranJuz(number: 24, title: "24. Cüz", range: "Zümer - Fussilet (32-46)", arabicLabel: "الجزء ٢٤", audioUrl: "https://server8.mp3quran.net/afs/024.mp3"),
  QuranJuz(number: 25, title: "25. Cüz", range: "Fussilet - Câsiye (47-37)", arabicLabel: "الجزء ٢٥", audioUrl: "https://server8.mp3quran.net/afs/025.mp3"),
  QuranJuz(number: 26, title: "26. Cüz", range: "Ahkâf - Zâriyât (1-30)", arabicLabel: "الجزء ٢٦", audioUrl: "https://server8.mp3quran.net/afs/026.mp3"),
  QuranJuz(number: 27, title: "27. Cüz", range: "Zâriyât - Hadîd (31-29)", arabicLabel: "الجزء ٢٧", audioUrl: "https://server8.mp3quran.net/afs/027.mp3"),
  QuranJuz(number: 28, title: "28. Cüz", range: "Mücâdele - Tahrîm (1-12)", arabicLabel: "الجزء ٢٨", audioUrl: "https://server8.mp3quran.net/afs/028.mp3"),
  QuranJuz(number: 29, title: "29. Cüz", range: "Mülk - Mürselât (1-50)", arabicLabel: "الجزء ٢٩", audioUrl: "https://server8.mp3quran.net/afs/029.mp3"),
  QuranJuz(number: 30, title: "30. Cüz", range: "Nebe' - Nâs (1-6)", arabicLabel: "الجزء ٣٠", audioUrl: "https://server8.mp3quran.net/afs/030.mp3"),
];

const List<QuranSurah> QURAN_SURAHS = [
  QuranSurah(number: 1, name: "Fâtiha", arabicName: "الفاتحة", versesCount: 7, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/001.mp3"),
  QuranSurah(number: 2, name: "Bakara", arabicName: "البقرة", versesCount: 286, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/002.mp3"),
  QuranSurah(number: 3, name: "Âl-i İmrân", arabicName: "آl عمران", versesCount: 200, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/003.mp3"),
  QuranSurah(number: 4, name: "Nisâ", arabicName: "النساء", versesCount: 176, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/004.mp3"),
  QuranSurah(number: 5, name: "Mâide", arabicName: "المائدة", versesCount: 120, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/005.mp3"),
  QuranSurah(number: 6, name: "En'âm", arabicName: "الأنعام", versesCount: 165, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/006.mp3"),
  QuranSurah(number: 7, name: "A'râf", arabicName: "الأعراف", versesCount: 206, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/007.mp3"),
  QuranSurah(number: 8, name: "Enfâl", arabicName: "الأنفال", versesCount: 75, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/008.mp3"),
  QuranSurah(number: 9, name: "Tevbe", arabicName: "التوبة", versesCount: 129, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/009.mp3"),
  QuranSurah(number: 10, name: "Yûnus", arabicName: "يونس", versesCount: 109, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/010.mp3"),
  QuranSurah(number: 11, name: "Hûd", arabicName: "هود", versesCount: 123, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/011.mp3"),
  QuranSurah(number: 12, name: "Yûsuf", arabicName: "يوسف", versesCount: 111, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/012.mp3"),
  QuranSurah(number: 13, name: "Ra'd", arabicName: "الرعد", versesCount: 43, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/013.mp3"),
  QuranSurah(number: 14, name: "İbrâhîm", arabicName: "إبراهيم", versesCount: 52, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/014.mp3"),
  QuranSurah(number: 15, name: "Hicr", arabicName: "الحجر", versesCount: 99, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/015.mp3"),
  QuranSurah(number: 16, name: "Nahl", arabicName: "النحل", versesCount: 128, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/016.mp3"),
  QuranSurah(number: 17, name: "İsrâ", arabicName: "الإسراء", versesCount: 111, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/017.mp3"),
  QuranSurah(number: 18, name: "Kehf", arabicName: "الكهف", versesCount: 110, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/018.mp3"),
  QuranSurah(number: 19, name: "Meryem", arabicName: "مريم", versesCount: 98, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/019.mp3"),
  QuranSurah(number: 20, name: "Tâhâ", arabicName: "طه", versesCount: 135, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/020.mp3"),
  QuranSurah(number: 21, name: "Enbiyâ", arabicName: "الأنبياء", versesCount: 112, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/021.mp3"),
  QuranSurah(number: 22, name: "Hac", arabicName: "الحج", versesCount: 78, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/022.mp3"),
  QuranSurah(number: 23, name: "Mü'minûn", arabicName: "المؤمنون", versesCount: 118, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/023.mp3"),
  QuranSurah(number: 24, name: "Nûr", arabicName: "النور", versesCount: 64, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/024.mp3"),
  QuranSurah(number: 25, name: "Furkân", arabicName: "الفرقان", versesCount: 77, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/025.mp3"),
  QuranSurah(number: 26, name: "Şuarâ", arabicName: "الشعراء", versesCount: 227, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/026.mp3"),
  QuranSurah(number: 27, name: "Neml", arabicName: "النمل", versesCount: 93, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/027.mp3"),
  QuranSurah(number: 28, name: "Kasas", arabicName: "القصص", versesCount: 88, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/028.mp3"),
  QuranSurah(number: 29, name: "Ankebût", arabicName: "العنكبوت", versesCount: 69, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/029.mp3"),
  QuranSurah(number: 30, name: "Rûm", arabicName: "الروم", versesCount: 60, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/030.mp3"),
  QuranSurah(number: 31, name: "Lokmân", arabicName: "لقمان", versesCount: 34, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/031.mp3"),
  QuranSurah(number: 32, name: "Secde", arabicName: "السجدة", versesCount: 30, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/032.mp3"),
  QuranSurah(number: 33, name: "Ahzâb", arabicName: "الأحزاب", versesCount: 73, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/033.mp3"),
  QuranSurah(number: 34, name: "Sebe'", arabicName: "سبأ", versesCount: 54, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/034.mp3"),
  QuranSurah(number: 35, name: "Fâtır", arabicName: "فاطر", versesCount: 45, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/035.mp3"),
  QuranSurah(number: 36, name: "Yâsîn", arabicName: "يس", versesCount: 83, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/036.mp3"),
  QuranSurah(number: 37, name: "Sâffât", arabicName: "الصافات", versesCount: 182, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/037.mp3"),
  QuranSurah(number: 38, name: "Sâd", arabicName: "ص", versesCount: 88, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/038.mp3"),
  QuranSurah(number: 39, name: "Zümer", arabicName: "الزمر", versesCount: 75, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/039.mp3"),
  QuranSurah(number: 40, name: "Mü'min", arabicName: "غافر", versesCount: 85, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/040.mp3"),
  QuranSurah(number: 41, name: "Fussilet", arabicName: "فصلت", versesCount: 54, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/041.mp3"),
  QuranSurah(number: 42, name: "Şûrâ", arabicName: "الشورى", versesCount: 53, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/042.mp3"),
  QuranSurah(number: 43, name: "Zuhruf", arabicName: "الزخرف", versesCount: 89, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/043.mp3"),
  QuranSurah(number: 44, name: "Duhân", arabicName: "الدخان", versesCount: 59, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/044.mp3"),
  QuranSurah(number: 45, name: "Câsiye", arabicName: "الجاثية", versesCount: 37, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/045.mp3"),
  QuranSurah(number: 46, name: "Ahkâf", arabicName: "الأحقاف", versesCount: 35, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/046.mp3"),
  QuranSurah(number: 47, name: "Muhammed", arabicName: "محمد", versesCount: 38, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/047.mp3"),
  QuranSurah(number: 48, name: "Fetih", arabicName: "الفتح", versesCount: 29, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/048.mp3"),
  QuranSurah(number: 49, name: "Hucurât", arabicName: "الحجرات", versesCount: 18, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/049.mp3"),
  QuranSurah(number: 50, name: "Kâf", arabicName: "ق", versesCount: 45, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/050.mp3"),
  QuranSurah(number: 51, name: "Zâriyât", arabicName: "الذاريات", versesCount: 60, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/051.mp3"),
  QuranSurah(number: 52, name: "Tûr", arabicName: "الطور", versesCount: 49, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/052.mp3"),
  QuranSurah(number: 53, name: "Necm", arabicName: "النجم", versesCount: 62, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/053.mp3"),
  QuranSurah(number: 54, name: "Kamer", arabicName: "القمر", versesCount: 55, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/054.mp3"),
  QuranSurah(number: 55, name: "Rahmân", arabicName: "الرحمن", versesCount: 78, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/055.mp3"),
  QuranSurah(number: 56, name: "Vâkıa", arabicName: "الواقعة", versesCount: 96, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/056.mp3"),
  QuranSurah(number: 57, name: "Hadîd", arabicName: "الحديد", versesCount: 29, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/057.mp3"),
  QuranSurah(number: 58, name: "Mücâdele", arabicName: "المجادلة", versesCount: 22, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/058.mp3"),
  QuranSurah(number: 59, name: "Haşr", arabicName: "الحشر", versesCount: 24, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/059.mp3"),
  QuranSurah(number: 60, name: "Mümtehine", arabicName: "الممتحنة", versesCount: 13, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/060.mp3"),
  QuranSurah(number: 61, name: "Saf", arabicName: "الصف", versesCount: 14, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/061.mp3"),
  QuranSurah(number: 62, name: "Cuma", arabicName: "الجمعة", versesCount: 11, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/062.mp3"),
  QuranSurah(number: 63, name: "Münâfikûn", arabicName: "المنافقون", versesCount: 11, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/063.mp3"),
  QuranSurah(number: 64, name: "Tegâbün", arabicName: "التغابن", versesCount: 18, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/064.mp3"),
  QuranSurah(number: 65, name: "Talâk", arabicName: "الطلاق", versesCount: 12, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/065.mp3"),
  QuranSurah(number: 66, name: "Tahrîm", arabicName: "التحريم", versesCount: 12, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/066.mp3"),
  QuranSurah(number: 67, name: "Mülk", arabicName: "الملك", versesCount: 30, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/067.mp3"),
  QuranSurah(number: 68, name: "Kalem", arabicName: "القلم", versesCount: 52, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/068.mp3"),
  QuranSurah(number: 69, name: "Hâkka", arabicName: "الحاقة", versesCount: 52, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/069.mp3"),
  QuranSurah(number: 70, name: "Meâric", arabicName: "المعارج", versesCount: 44, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/070.mp3"),
  QuranSurah(number: 71, name: "Nûh", arabicName: "نوح", versesCount: 28, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/071.mp3"),
  QuranSurah(number: 72, name: "Cin", arabicName: "الجن", versesCount: 28, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/072.mp3"),
  QuranSurah(number: 73, name: "Müzzemmil", arabicName: "المزمل", versesCount: 20, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/073.mp3"),
  QuranSurah(number: 74, name: "Müddessir", arabicName: "المدثر", versesCount: 56, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/074.mp3"),
  QuranSurah(number: 75, name: "Kıyâme", arabicName: "القيامة", versesCount: 40, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/075.mp3"),
  QuranSurah(number: 76, name: "İnsân", arabicName: "الإنسان", versesCount: 31, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/076.mp3"),
  QuranSurah(number: 77, name: "Mürselât", arabicName: "المرسلات", versesCount: 50, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/077.mp3"),
  QuranSurah(number: 78, name: "Nebe'", arabicName: "النبأ", versesCount: 40, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/078.mp3"),
  QuranSurah(number: 79, name: "Nâziât", arabicName: "النازعات", versesCount: 46, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/079.mp3"),
  QuranSurah(number: 80, name: "Abese", arabicName: "عبس", versesCount: 42, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/080.mp3"),
  QuranSurah(number: 81, name: "Tekvîr", arabicName: "التكوير", versesCount: 29, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/081.mp3"),
  QuranSurah(number: 82, name: "İnfitâr", arabicName: "الانفطار", versesCount: 19, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/082.mp3"),
  QuranSurah(number: 83, name: "Mutaffifîn", arabicName: "المطففين", versesCount: 36, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/083.mp3"),
  QuranSurah(number: 84, name: "İnşikâk", arabicName: "الانشقاق", versesCount: 25, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/084.mp3"),
  QuranSurah(number: 85, name: "Burûc", arabicName: "البروج", versesCount: 22, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/085.mp3"),
  QuranSurah(number: 86, name: "Târık", arabicName: "الطارق", versesCount: 17, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/086.mp3"),
  QuranSurah(number: 87, name: "A'lâ", arabicName: "الأعلى", versesCount: 19, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/087.mp3"),
  QuranSurah(number: 88, name: "Gâşiye", arabicName: "الغاشية", versesCount: 26, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/088.mp3"),
  QuranSurah(number: 89, name: "Fecr", arabicName: "الفجر", versesCount: 30, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/089.mp3"),
  QuranSurah(number: 90, name: "Beled", arabicName: "البلد", versesCount: 20, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/090.mp3"),
  QuranSurah(number: 91, name: "Şems", arabicName: "الشمس", versesCount: 15, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/091.mp3"),
  QuranSurah(number: 92, name: "Leyl", arabicName: "الليل", versesCount: 21, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/092.mp3"),
  QuranSurah(number: 93, name: "Duha", arabicName: "الضحى", versesCount: 11, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/093.mp3"),
  QuranSurah(number: 94, name: "İnşirâh", arabicName: "الشرح", versesCount: 8, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/094.mp3"),
  QuranSurah(number: 95, name: "Tîn", arabicName: "التين", versesCount: 8, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/095.mp3"),
  QuranSurah(number: 96, name: "Alak", arabicName: "العلق", versesCount: 19, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/096.mp3"),
  QuranSurah(number: 97, name: "Kadr", arabicName: "القدر", versesCount: 5, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/097.mp3"),
  QuranSurah(number: 98, name: "Beyyine", arabicName: "البينة", versesCount: 8, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/098.mp3"),
  QuranSurah(number: 99, name: "Zilzâl", arabicName: "الزلزلة", versesCount: 8, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/099.mp3"),
  QuranSurah(number: 100, name: "Âdiyât", arabicName: "العاديات", versesCount: 11, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/100.mp3"),
  QuranSurah(number: 101, name: "Kâria", arabicName: "القارعة", versesCount: 11, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/101.mp3"),
  QuranSurah(number: 102, name: "Tekâsür", arabicName: "التكاثر", versesCount: 8, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/102.mp3"),
  QuranSurah(number: 103, name: "Asr", arabicName: "العصر", versesCount: 3, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/103.mp3"),
  QuranSurah(number: 104, name: "Humeze", arabicName: "الهمزة", versesCount: 9, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/104.mp3"),
  QuranSurah(number: 105, name: "Fîl", arabicName: "الفيل", versesCount: 5, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/105.mp3"),
  QuranSurah(number: 106, name: "Kureyş", arabicName: "قريش", versesCount: 4, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/106.mp3"),
  QuranSurah(number: 107, name: "Mâûn", arabicName: "الماعون", versesCount: 7, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/107.mp3"),
  QuranSurah(number: 108, name: "Kevser", arabicName: "الكوثر", versesCount: 3, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/108.mp3"),
  QuranSurah(number: 109, name: "Kâfirûn", arabicName: "الكافرون", versesCount: 6, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/109.mp3"),
  QuranSurah(number: 110, name: "Nasr", arabicName: "النصر", versesCount: 3, revelationPlace: "Medine", audioUrl: "https://server8.mp3quran.net/afs/110.mp3"),
  QuranSurah(number: 111, name: "Tebbet", arabicName: "المسد", versesCount: 5, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/111.mp3"),
  QuranSurah(number: 112, name: "İhlâs", arabicName: "الإخلاص", versesCount: 4, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/112.mp3"),
  QuranSurah(number: 113, name: "Felak", arabicName: "الفلق", versesCount: 5, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/113.mp3"),
  QuranSurah(number: 114, name: "Nâs", arabicName: "الناس", versesCount: 6, revelationPlace: "Mekke", audioUrl: "https://server8.mp3quran.net/afs/114.mp3"),
];

const Map<int, List<OfflineVerse>> OFFLINE_SURAHS = {
  1: [
    OfflineVerse(number: 1, arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", transliteration: "Bismillâhirrahmânirrahîm.", translation: "Rahmân ve Rahîm olan Allah'ın adıyla."),
    OfflineVerse(number: 2, arabic: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", transliteration: "Elhamdü lillâhi rabbil'âlemîn.", translation: "Hamd, Âlemlerin Rabbi Allah'adır."),
    OfflineVerse(number: 3, arabic: "الرَّحْمَٰنِ الرَّحِيمِ", transliteration: "Errahmânirrahîm.", translation: "O, Rahmân'dır, Rahîm'dir."),
    OfflineVerse(number: 4, arabic: "مَلِكِ يَوْمِ الدِّينِ", transliteration: "Mâliki yevmiddîn.", translation: "Din ve hesap gününün malikidir."),
    OfflineVerse(number: 5, arabic: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ", transliteration: "İyyâke na'büdü ve iyyâke neste'în.", translation: "Yalnız Sana ibadet eder ve yalnız Senden yardım dileriz."),
    OfflineVerse(number: 6, arabic: "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ", transliteration: "İhdinessırâtel müstakîm.", translation: "Bizi dosdoğru yola ilet;"),
    OfflineVerse(number: 7, arabic: "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ", transliteration: "Sırâtellezîne en'amte aleyhim gayrilmagdûbi aleyhim veleddâllîn.", translation: "Kendilerine nimet verdiklerinin yoluna; gazaba uğramışların ve sapmışların yoluna değil."),
  ],
  108: [
    OfflineVerse(number: 1, arabic: "إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ", transliteration: "İnnâ a'taynâkel kevser.", translation: "Şüphesiz biz sana Kevser'i verdik."),
    OfflineVerse(number: 2, arabic: "فَصَلِّ LİRABBİKE VENHAR", transliteration: "Fesalli lirabbike venhar.", translation: "Öyleyse Rabbin için namaz kıl ve kurban kes."),
    OfflineVerse(number: 3, arabic: "إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ", transliteration: "İnne şânieke hüvel ebter.", translation: "Asıl soyu kesik olan, sana buğzedenin kendisidir."),
  ],
  112: [
    OfflineVerse(number: 1, arabic: "قُلْ هُوَ اللَّهُ أَحَدٌ", transliteration: "Kul hüvellâhü ehad.", translation: "De ki: O, Allah'tır, tektir."),
    OfflineVerse(number: 2, arabic: "اللَّهُ الصَّمَدُ", transliteration: "Allâhüs samed.", translation: "Allah Samed'dir (her şey O'na muhtaçtır, O hiçbir şeye muhtaç değildir)."),
    OfflineVerse(number: 3, arabic: "لَمْ يَلِدْ وَلَمْ يُولَدْ", transliteration: "Lem yelid ve lem yûled.", translation: "O, doğurmamış ve doğurulmamıştır."),
    OfflineVerse(number: 4, arabic: "وَلَمْ يَكُنْ لَّهُ كُفُوًا أَحَدٌ", transliteration: "Ve lem yekül lehû küfüven ehad.", translation: "Ve hiçbir şey O'nun dengi/benzeri olmamıştır."),
  ],
  113: [
    OfflineVerse(number: 1, arabic: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ", transliteration: "Kul eûzü birabbil felak.", translation: "De ki: Yarattığı şeylerin kötülüğünden,"),
    OfflineVerse(number: 2, arabic: "مِن شَرِّ مَا خَلَقَ", transliteration: "Min şerri mâ halak.", translation: "Karanlığı çöktüğü zaman gecenin kötülüğünden,"),
    OfflineVerse(number: 3, arabic: "وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ", transliteration: "Ve min şerri gâsikın izâ vekab.", translation: "Düğümlere üfleyenlerin kötülüğünden,"),
    OfflineVerse(number: 4, arabic: "وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ", transliteration: "Ve min şerri neffâsâti fil ukad.", translation: "Ve haset ettiği zaman hasetçinin kötülüğünden sabahın Rabbine sığınırım."),
    OfflineVerse(number: 5, arabic: "وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ", transliteration: "Ve min şerri hâsidin izâ hased.", translation: "Haset ettiği zaman hasetçinin kötülüğünden sabahın Rabbine sığınırım."),
  ],
  114: [
    OfflineVerse(number: 1, arabic: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ", transliteration: "Kul eûzü birabbin nâs.", translation: "De ki: İnsanların Rabbine sığınırım,"),
    OfflineVerse(number: 2, arabic: "مَلِكِ النَّاسِ", transliteration: "Melikin nâs.", translation: "İnsanların malikine,"),
    OfflineVerse(number: 3, arabic: "إِلَٰهِ النَّاسِ", transliteration: "İlâhin nâs.", translation: "İnsanların ilahına;"),
    OfflineVerse(number: 4, arabic: "مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ", transliteration: "Min şerril vesvâsil hannâs.", translation: "O sinsi vesvesecinin kötülüğünden,"),
    OfflineVerse(number: 5, arabic: "الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ", transliteration: "Ellezî yüvesvisü fî sudûrin nâs.", translation: "Ki o, insanların göğüslerine vesvese verir,"),
    OfflineVerse(number: 6, arabic: "مِنَ الْجِنَّةِ وَالنَّاسِ", transliteration: "Minel cinneti vennâs.", translation: "Gerek cinlerden gerekse insanlardan olsun."),
  ]
};
