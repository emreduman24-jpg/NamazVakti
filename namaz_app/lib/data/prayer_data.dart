// Namaz Vakitleri & Dini Bilgiler - Veri Katmanı (Dart)

const List<Map<String, String>> DINI_GUNLER = [
  {"tarih": "26 Ocak 2026", "gun": "Pazartesi", "ad": "Regaib Kandili"},
  {"tarih": "13 Şubat 2026", "gun": "Cuma", "ad": "Miraç Kandili"},
  {"tarih": "2 Mart 2026", "gun": "Pazartesi", "ad": "Berat Kandili"},
  {"tarih": "19 Mart 2026", "gun": "Perşembe", "ad": "Ramazan Başlangıcı"},
  {"tarih": "14 Nisan 2026", "gun": "Salı", "ad": "Kadir Gecesi"},
  {"tarih": "17 Nisan 2026", "gun": "Cuma", "ad": "Ramazan Bayramı Arefesi"},
  {"tarih": "18 Nisan 2026", "gun": "Cumartesi", "ad": "Ramazan Bayramı (1. Gün)"},
  {"tarih": "19 Nisan 2026", "gun": "Pazar", "ad": "Ramazan Bayramı (2. Gün)"},
  {"tarih": "20 Nisan 2026", "gun": "Pazartesi", "ad": "Ramazan Bayramı (3. Gün)"},
  {"tarih": "25 Mayıs 2026", "gun": "Pazartesi", "ad": "Kurban Bayramı Arefesi"},
  {"tarih": "26 Mayıs 2026", "gun": "Salı", "ad": "Kurban Bayramı (1. Gün)"},
  {"tarih": "27 Mayıs 2026", "gun": "Çarşamba", "ad": "Kurban Bayramı (2. Gün)"},
  {"tarih": "28 Mayıs 2026", "gun": "Perşembe", "ad": "Kurban Bayramı (3. Gün)"},
  {"tarih": "29 Mayıs 2026", "gun": "Cuma", "ad": "Kurban Bayramı (4. Gün)"},
  {"tarih": "16 Haziran 2026", "gun": "Salı", "ad": "Hicri Yılbaşı (1 Muharrem 1448)"},
  {"tarih": "25 Haziran 2026", "gun": "Perşembe", "ad": "Aşure Günü"},
  {"tarih": "23 Ağustos 2026", "gun": "Pazar", "ad": "Mevlid Kandili"}
];

const List<Map<String, String>> VAKTIN_AYETLERI = [
  {
    "title": "Talak - 3. Ayet",
    "text": "Şüphesiz Allah, muttakilerin dostu, yardımcısı ve koruyucusudur. (Casiye - 19)",
    "ref": "Casiye - 19"
  },
  {
    "title": "Bakara - 186. Ayet",
    "text": "Kullarım sana beni sorduklarında bilsinler ki ben onlara çok yakınım. Bana dua edenlerin dualarını kabul ederim.",
    "ref": "Bakara - 186"
  },
  {
    "title": "İnşirah - 5-6. Ayet",
    "text": "Elbette zorlukla beraber bir kolaylık vardır. Gerçekten, zorlukla beraber bir kolaylık vardır.",
    "ref": "İnşirah - 5-6"
  },
  {
    "title": "Âl-i İmrân - 139. Ayet",
    "text": "Gevşemeyin, hüzünlenmeyin. Eğer gerçekten inanıyorsanız üstün olan sizsinizdir.",
    "ref": "Âl-i İmrân - 139"
  },
  {
    "title": "Ankebut - 45. Ayet",
    "text": "Şüphesiz namaz, insanı hayasızlıktan ve kötülükten alıkoyar. Allah'ı anmak elbette en büyük ibadettir.",
    "ref": "Ankebut - 45"
  }
];

const List<Map<String, String>> VAKTIN_HADISLERI = [
  {
    "title": "Hadis-i Şerif - Ebû Hüreyre",
    "text": "Kim Kadir gecesini imanla ihya ederse, geçmiş günahları bağışlanır. (Buhari)",
    "ref": "Buhari, Terâvih 2"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Dua ibadetin ta kendisidir.",
    "ref": "Tirmizi, Tefsir 2"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Müslüman müslümanın kardeşidir. Ona zulmetmez, onu tehlikede yalnız bırakmaz.",
    "ref": "Müslim, Birr 58"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.",
    "ref": "Buhari, İlim 12"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Temizlik imanın yarısıdır. Elhamdülillah mizanı doldurur.",
    "ref": "Müslim, Taharet 1"
  }
];

const List<Map<String, String>> GUNUN_ISIMLERI = [
  {"kiz": "Melisa", "erkek": "Eymen"},
  {"kiz": "Zeynep", "erkek": "Ömer"},
  {"kiz": "Elif", "erkek": "Ali"},
  {"kiz": "Defne", "erkek": "Yusuf"},
  {"kiz": "Meryem", "erkek": "Hamza"},
  {"kiz": "Asya", "erkek": "Miraç"},
  {"kiz": "Zehra", "erkek": "Mustafa"}
];

const List<Map<String, dynamic>> ESMAUL_HUSNA = [
  {"no": 1, "ad": "Allah", "arapca": "الله", "anlam": "Her şeyin yaratıcısı, tek ilah.", "zikir": 66, "fazilet": "İnanç kuvveti, isteklerin kabulü"},
  {"no": 2, "ad": "er-Rahmân", "arapca": "الرَّحْمَانُ", "anlam": "Dünyadaki tüm yaratılanlara şefkat gösteren.", "zikir": 298, "fazilet": "Gönül ferahlığı, merhamet kazanma"},
  {"no": 3, "ad": "er-Rahîm", "arapca": "الرَّحِيمُ", "anlam": "Ahirette sadece müminlere merhamet edecek olan.", "zikir": 258, "fazilet": "Maddi ve manevi rızk bolluğu"},
  {"no": 4, "ad": "el-Melik", "arapca": "الْمَلِكُ", "anlam": "Kainatın tek hakimi ve mutlak sahibi.", "zikir": 90, "fazilet": "Maddi ve manevi güçlü olmak"},
  {"no": 5, "ad": "el-Kuddûs", "arapca": "الْقُدُّوسُ", "anlam": "Her türlü noksanlıktan uzak, tertemiz olan.", "zikir": 170, "fazilet": "Ruhsal temizlik, korkulardan emin olma"},
  {"no": 6, "ad": "es-Selâm", "arapca": "السَّلَامُ", "anlam": "Esenlik veren, kullarını selamete çıkaran.", "zikir": 131, "fazilet": "Huzur, korkulardan kurtulma, şifa"},
  {"no": 7, "ad": "el-Mü'min", "arapca": "الْمُؤْمِنُ", "anlam": "Güven veren, koruyan, sığınak olan.", "zikir": 137, "fazilet": "Kötülüklerden korunma, emniyet"},
  {"no": 8, "ad": "el-Müheymin", "arapca": "الْمُهَيْمِنُ", "anlam": "Gözeten, koruyan ve her şeyi yöneten.", "zikir": 145, "fazilet": "İnsanların sevgisini kazanmak"},
  {"no": 9, "ad": "el-Azîz", "arapca": "الْعَزِيزُ", "anlam": "Mağlup edilmesi imkansız olan, en yüce.", "zikir": 94, "fazilet": "İzzet sahibi olmak, düşmanlara galip gelmek"},
  {"no": 10, "ad": "el-Cebbâr", "arapca": "الْجَبَّارُ", "anlam": "Dilediğini zorla yaptıran, eksikleri tamamlayan.", "zikir": 206, "fazilet": "Dileklerin olması, haksızlıklardan korunma"},
  {"no": 11, "ad": "el-Mütekebbir", "arapca": "الْمُتَكَبِّرُ", "anlam": "Büyüklükte eşi benzeri olmayan.", "zikir": 662, "fazilet": "İzzet, şeref ve bereket bulma"},
  {"no": 12, "ad": "el-Hâlık", "arapca": "الْخَالِقُ", "anlam": "Her şeyi yoktan var eden, yaratan.", "zikir": 731, "fazilet": "İşlerde başarı, sıkıntılardan kurtuluş"},
  {"no": 13, "ad": "el-Bâri", "arapca": "الْبَارِئُ", "anlam": "Her şeyi kusursuz ve uyumlu yaratan.", "zikir": 213, "fazilet": "Maddi manevi başarı, şifa bulma"},
  {"no": 14, "ad": "el-Musavvir", "arapca": "الْمُصَوِّرُ", "anlam": "Her şeye en güzel şekli veren.", "zikir": 336, "fazilet": "Zor işlerin kolaylaşması, başarı"},
  {"no": 15, "ad": "el-Gaffâr", "arapca": "الْغَفَّارُ", "anlam": "Günahları örten, bağışlaması bol olan.", "zikir": 1281, "fazilet": "Günahların affı, cehennem azabından korunma"}
];

const List<Map<String, String>> DUALAR = [
  {"ad": "Yemek Duası", "arapca": "الْحَمْدُ للهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ", "anlam": "Bizi yediren, içiren ve Müslüman kılan Allah'a hamdolsun."},
  {"ad": "Uykudan Uyanınca", "arapca": "الْحَمْدُ للهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ", "anlam": "Bizi öldürdükten sonra dirilten Allah'a hamdolsun. Dönüş ancak O'nadır."},
  {"ad": "Nazar Duası (Kalem 51-52)", "arapca": "وَإِن يَكَادُ الَّذِينَ كَفَرُوا لَيُzْلِقُونَكَ بِأَبْصَارِهِمْ لَمَّا سَمِعُوا الذِّكْرَ وَيَقُولُونَ إِنَّهُ لَمَجْنُونٌ", "anlam": "Şüphesiz inkâr edenler Zikr’i (Kur’an’ı) duydukları zaman neredeyse seni gözleriyle devireceklerdi. 'O mutlaka bir delidir' diyorlar."},
  {"ad": "Eve Girerken", "arapca": "اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ بِسْمِ اللَّهِ وَلَجْنَا", "anlam": "Allah'ım! Senden hayırlı giriş ve hayırlı çıkış dilerim. Allah'ın adıyla girdik, Allah'ın adıyla çıktık."},
  {"ad": "Sınava Girerken", "arapca": "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي", "anlam": "Rabbim! Göğsümü genişlet, işimi kolaylaştır, dilimin düğümünü çöz ki sözümü anlasınlar."}
];

const List<Map<String, dynamic>> HADISLER_40 = [
  {"no": 1, "metin": "Ameller ancak niyetlere göredir ve herkese niyet ettiği şey vardır.", "kaynak": "Buhari"},
  {"no": 2, "metin": "Din nasihattir (samimiyettir).", "kaynak": "Müslim"},
  {"no": 3, "metin": "Sizden biriniz kendisi için istediğini kardeşi için de istemedikçe iman etmiş olmaz.", "kaynak": "Buhari"},
  {"no": 4, "metin": "Hayra vesile olan, hayrı yapan gibidir.", "kaynak": "Tirmizi"},
  {"no": 5, "metin": "Müslüman, elinden ve dilinden müslümanların güvende olduğu kimsedir.", "kaynak": "Buhari"},
  {"no": 6, "metin": "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.", "kaynak": "Buhari"},
  {"no": 7, "metin": "İnsanların en hayırlısı, insanlara faydalı olanıdır.", "kaynak": "Beyhaki"},
  {"no": 8, "metin": "İki nimet vardır ki insanların çoğu bunda aldanmıştır: Sağlık ve boş vakit.", "kaynak": "Buhari"},
  {"no": 9, "metin": "Hiçbir baba evladına güzel ahlaktan daha değerli bir miras bırakamaz.", "kaynak": "Tirmizi"},
  {"no": 10, "metin": "Temizlik imanın yarısıdır.", "kaynak": "Müslim"},
  {"no": 11, "metin": "Nerede olursan ol Allah'tan kork. Kötülüğün arkasından hemen bir iyilik yap ki onu silsin.", "kaynak": "Tirmizi"},
  {"no": 12, "metin": "Gerçek zenginlik mal çokluğu değil, gönül zenginliğidir.", "kaynak": "Buhari"},
  {"no": 13, "metin": "Öfkelenen kimse sussun.", "kaynak": "Ahmed bin Hanbel"},
  {"no": 14, "metin": "Komşusu açken tok yatan bizden değildir.", "kaynak": "Hakim"},
  {"no": 15, "metin": "Güzel söz sadakadır.", "kaynak": "Buhari"}
];

const List<Map<String, String>> PEYGAMBER_HAYATI = [
  {
    "baslik": "Çocukluk Dönemi",
    "icerik": "Peygamber Efendimiz (s.a.v.), 571 yılında Mekke'de doğdu. Doğmadan önce babası Abdullah'ı, 6 yaşında ise annesi Âmine'yi kaybetti. Dedesi Abdülmuttalib'in ve daha sonra amcası Ebû Tâlib'in himayesinde büyüdü. Çocukluğunda dürüstlüğü ve güvenilirliğiyle 'Muhammedü'l-Emîn' unvanını aldı."
  },
  {
    "baslik": "Gençlik Dönemi",
    "icerik": "Gençlik yıllarında ticaretle uğraştı. Ticaretteki doğruluğu ve ahlakıyla herkesin takdirini kazandı. 25 yaşında Hz. Hatice ile evlendi. Mekke'de haksızlıklara karşı kurulan 'Hilfü'l-Fudûl' (Erdemliler Birliği) derneğine katılarak mazlumların yanında yer aldı."
  },
  {
    "baslik": "Peygamberlik Dönemi",
    "icerik": "40 yaşında (610 yılı Ramazan ayında) Nur Dağı'ndaki Hira Mağarası'nda ilk vahiy geldi ('Oku!'). Tevhidi tebliğ etmeye başladı. Mekke'de maruz kaldığı ağır baskı ve zulümlere rağmen İslam dinini yaymaktan vazgeçmedi."
  },
  {
    "baslik": "Hicret ve Medine",
    "icerik": "Müslümanlar üzerindeki zulüm dayanılmaz hale gelince, 622 yılında Medine'ye hicret edildi. Medine'de İslam Devleti'nin temelleri atıldı. Mescid-i Nebevî inşa edildi. Mekkeli müşriklerle Bedir, Uhud ve Hendek savaşları yapıldı."
  },
  {
    "baslik": "Veda Haccı ve Vefat",
    "icerik": "632 yılında yüz bini aşkın Müslümana Arafat'ta Veda Hutbesi'ni irat etti. İnsan hakları, eşitlik ve adaleti vurgulayan bu hutbeden kısa süre sonra, aynı yıl Medine'de vefat etti. Kabr-i Şerif'i Medine'deki Mescid-i Nebevî içerisindedir."
  }
];

const List<Map<String, String>> RAMAZAN_HAKKINDA = [
  {
    "baslik": "Oruç İbadeti",
    "icerik": "Ramazan ayı, İslam'ın beş şartından biri olan oruç ibadetinin yerine getirildiği mübarek aydır. İmsak vaktinden akşam ezanına kadar niyet edilerek yeme, içme ve nefsi arzulardan uzak durulur."
  },
  {
    "baslik": "Kadir Gecesi",
    "icerik": "Kur'an-ı Kerim bu ayda inmeye başlamıştır. Kur'an'da 'bin aydan daha hayırlı' olduğu belirtilen Kadir Gecesi, Ramazan ayının son on günü içerisinde aranır."
  },
  {
    "baslik": "Zekat ve Fitre",
    "icerik": "Bu ayda yardımlaşma en üst seviyetedir. Her Müslümanın vermesi gereken Sadaka-i Fıtır (Fitre) bu ayda ihtiyaç sahiplerine ulaştırılır. Zekatlar da genellikle bu ayda dağıtılır."
  },
  {
    "baslik": "Ramazan Bayramı",
    "icerik": "Ramazan ayının bitimiyle birlikte üç gün süren Şevval ayının ilk günlerinde kutlanan bayramdır. Müminlerin bir aylık sabır ve ibadetinin ödülüdür."
  }
];

const Map<String, dynamic> ORUC_REHBERI = {
  "bozanlar": [
    "Bilerek bir şey yemek veya içmek",
    "Sigara içmek, tütün mamulleri kullanmak veya nargile tüttürmek",
    "Gıda veya güç verici serumlar, iğneler yaptırmak",
    "Ağza giren yağmur, kar veya suyu bilerek yutmak",
    "Astım spreyi kullanmak (Diyanet'in bazı fetvalarına göre acil durumlar hariç kaza gerektirir)"
  ],
  "bozmayanlar": [
    "Unutarak bir şey yemek veya içmek (oruçlu olunduğu hatırlanır hatırlanmaz ağız çalkalanıp devam edilir)",
    "Kan vermek veya kan aldırmak",
    "Banyo yapmak, duş almak veya yüzmek (ağız ve burundan su kaçırmamak şartıyla)",
    "Göz, kulak veya burun damlası kullanmak (boğaza ulaşmayacak miktarda)",
    "Diş fırçalamak veya misvak kullanmak (macun yutulmamak kaydıyla)"
  ],
  "cesitler": [
    {"ad": "Farz Oruç", "aciklama": "Ramazan ayında tutulan oruçtur."},
    {"ad": "Vacip Oruç", "aciklama": "Adak orucu veya bozulan nafile orucun kazasıdır."},
    {"ad": "Nafile Oruç", "aciklama": "Şevval orucu, Aşure orucu, Pazartesi-Perşembe oruçları gibi sünnet olan oruçlardır."}
  ]
};

const List<Map<String, String>> MOCK_CAMILER = [
  {"ad": "Fatih Camii ve Külliyesi", "mesafe": "0.4 km", "adres": "Fatih, İstanbul", "harita": "https://maps.google.com/?q=Fatih+Camii+Istanbul"},
  {"ad": "Süleymaniye Camii", "mesafe": "1.2 km", "adres": "Süleymaniye, Fatih/İstanbul", "harita": "https://maps.google.com/?q=Suleymaniye+Camii+Istanbul"},
  {"ad": "Sultanahmet Camii", "mesafe": "2.5 km", "adres": "Sultanahmet, Fatih/İstanbul", "harita": "https://maps.google.com/?q=Sultanahmet+Camii+Istanbul"},
  {"ad": "Yavuz Selim Camii", "mesafe": "1.1 km", "adres": "Balat, Fatih/İstanbul", "harita": "https://maps.google.com/?q=Yavuz+Selim+Camii+Istanbul"},
  {"ad": "Nuruosmaniye Camii", "mesafe": "2.1 km", "adres": "Çemberlitaş, Fatih/İstanbul", "harita": "https://maps.google.com/?q=Nuruosmaniye+Camii+Istanbul"}
];

const List<Map<String, String>> TESBIHAT_STEPS = [
  {"ad": "İstiğfar & Salavat", "arapca": "أَسْتَغْفِرُ اللهَ... اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ", "okunus": "Estağfirullah (3 Kez) - Allahümme entesselamü ve minkesselam...", "anlam": "Allah'tan bağışlanma dilerim. Allah'ım sen esenliksin..."},
  {"ad": "Salat-ı Münciye", "arapca": "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلاَةً تُنْجِينَا بِهَا...", "okunus": "Allahümme salli ala seyyidina Muhammedin salaten tuncina biha...", "anlam": "Allah'ım! Efendimiz Muhammed'e salat eyle. Öyle bir salat ki bizi tüm korku ve afetlerden kurtarsın..."},
  {"ad": "Subhanallah", "arapca": "سُبْحَانَ اللهِ", "okunus": "Sübhanallah (33 Kez)", "anlam": "Allah noksan sıfatlardan uzaktır."},
  {"ad": "Elhamdülillah", "arapca": "الْحَمْدُ للهِ", "okunus": "Elhamdülillah (33 Kez)", "anlam": "Hamd Allah'adır."},
  {"ad": "Allahu Ekber", "arapca": "اللهُ أَكْبَرُ", "okunus": "Allahu Ekber (33 Kez)", "anlam": "Allah en büyüktür."},
  {"ad": "Kelime-i Tevhid", "arapca": "لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ...", "okunus": "La ilahe illallahü vahdehû la şerîke leh...", "anlam": "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur..."}
];

const List<Map<String, String>> SAHABE_HAYATLARI = [
  {"ad": "Hz. Ebû Bekir (r.a.)", "unvan": "Sıddık (Sadık)", "ozet": "Peygamber Efendimiz'in en yakın dostu ve ilk halifesidir. İslam'ı kabul eden ilk hür erkektir. Hicret esnasında Peygamberimiz ile birlikte mağarada bulunmuştur. Cömertliği ve sadakatiyle bilinir."},
  {"ad": "Hz. Ömer (r.a.)", "unvan": "Faruk (Adaletli)", "ozet": "İkinci halifedir. Adaleti, cesareti ve hak ile batılı ayırt etmedeki hassasiyeti nedeniyle 'Faruk' unvanını almıştır. Onun döneminde İslam coğrafyası çok genişlemiş ve devlet kurumları teşkilatlanmıştır."},
  {"ad": "Hz. Osman (r.a.)", "unvan": "Zinnûreyn (Çift Işıklı)", "ozet": "Üçüncü halifedir. Peygamber Efendimiz'in iki kızıyla evlendiği için 'Zinnûreyn' denmiştir. Kur'an-ı Kerim'in çoğaltılmasını sağlamıştır. Cömertliği, hayası ve yumuşak huyluluğuyla tanınır."},
  {"ad": "Hz. Ali (r.a.)", "unvan": "Esedullah (Allah'ın Aslanı)", "ozet": "Dördüncü halifedir. Peygamber Efendimiz'in amcasının oğlu ve damadıdır. Çocuk yaşta İslam'ı ilk kabul edendir. İlmi, cesareti, hitabeti ve kahramanlığıyla İslam tarihinde eşsiz bir yere sahiptir."},
  {"ad": "Hz. Hamza (r.a.)", "unvan": "Seyyidüşşüheda", "ozet": "Peygamber Efendimiz'in amcasıdır. Müslüman oluşuyla İslam safına büyük güç katmıştır. Uhud Savaşı'nda kahramanca çarpışırken şehit düşmüştür."},
  {"ad": "Hz. Bilal-i Habeşî (r.a.)", "unvan": "Müezzin-i Resûl", "ozet": "İslam'ın ilk müezzinidir. Köle iken inancından dolayı ağır işkencelere maruz kalmış, Hz. Ebû Bekir tarafından özgürleştirilmiştir. Sesiyle İslam alemine ezan okuma şerefine nail olmuştur."}
];

const List<Map<String, String>> ISLAM_TARIHI = [
  {"yil": "571", "olay": "Peygamber Efendimiz'in Dünyaya Gelişi", "detay": "Mekke'de Rebiülevvel ayının 12. gecesi doğmuştur."},
  {"yil": "610", "olay": "İlk Vahiy ve Nübüvvet", "detay": "Hira Mağarası'nda Alak Suresi'nin ilk 5 ayeti nazil oldu."},
  {"yil": "615", "olay": "Habeşistan'a Hicret", "detay": "Müslümanlar üzerindeki baskılar nedeniyle ilk hicret gerçekleştirildi."},
  {"yil": "620", "olay": "İsra ve Miraç Mucizesi", "detay": "Peygamberimizin Mescid-i Aksa'ya götürülmesi ve oradan semaya yükselişi."},
  {"yil": "622", "olay": "Medine'ye Hicret (Hicri Başlangıç)", "detay": "İslam devletinin kurulması ve Müslümanların Medine'ye göçü."},
  {"yil": "624", "olay": "Bedir Gazvesi", "detay": "Müslümanların Mekkeli müşriklere karşı kazandığı ilk büyük askeri zafer."},
  {"yil": "625", "olay": "Uhud Gazvesi", "detay": "Müslümanların disiplin ve emirlere itaatin önemini kavradığı çetin mücadele."},
  {"yil": "630", "olay": "Mekke'nin Fethi", "detay": "Kan dökülmeden Mekke fethedilmiş ve Kabe putlardan temizlenmiştir."},
  {"yil": "632", "olay": "Veda Haccı ve Vefat", "detay": "Peygamber Efendimiz Medine'de 63 yaşında vefat etmiştir."}
];

const Map<String, dynamic> NAMAZ_KILMA_REHBERI = {
  "erkek": [
    {"ad": "Niyet ve Tekbir", "aciklama": "Kıbleye dönülür, niyet edilir. Eller kulak hizasına kaldırılıp başparmak kulak memesine değdirilerek 'Allahu Ekber' denir ve eller göbek altında bağlanır."},
    {"ad": "Kıyam ve Kıraat", "aciklama": "Ayakta durulur. Sırasıyla Sübhaneke, Euzü-Besmele, Fatiha ve ek bir sure (zamm-ı sure) okunur."},
    {"ad": "Rükû", "aciklama": "'Allahu Ekber' diyerek eğilinir. Sırt düz tutulur, ellerle diz kapakları kavranır. 3 defa 'Sübhâne Rabbiye'l-Azîm' denir. Doğrulurken 'Semiallahü limen hamideh', ayakta tam doğrulunca 'Rabbena leke'l-hamd' denir."},
    {"ad": "Secde", "aciklama": "'Allahu Ekber' diyerek yere kapanılır. Önce dizler, sonra eller, alın ve burun yere konur. Ayaklar yere basar konumdadır. 3 defa 'Sübhâne Rabbiye'l-A'lâ' denir. İki secde arasında kısa bir süre oturulur ve tekrar secdeye gidilir."},
    {"ad": "Oturuş (Ka'de-i Ahîre)", "aciklama": "Son rekatta oturulur. Sol ayak yatırılıp üzerine oturulur, sağ ayak dik tutulur. Ettehıyyatü, Salli-Barik ve Rabbena duaları okunur. Önce sağa sonra sola 'Es-selâmü aleyküm ve rahmetullah' diyerek selam verilir."}
  ],
  "kadin": [
    {"ad": "Niyet ve Tekbir", "aciklama": "Kıbleye dönülür, niyet edilir. Eller göğüs (omuz) hizasına kaldırılır, parmak uçları omuz hizasını geçmez. 'Allahu Ekber' denerek eller göğüs üstünde (sağ el sol elin üzerinde olacak şekilde) bağlanır."},
    {"ad": "Kıyam ve Kıraat", "aciklama": "Ayakta durulur. Sırasıyla Sübhaneke, Euzü-Besmele, Fatiha ve ek bir sure (zamm-ı sure) okunur."},
    {"ad": "Rükû", "aciklama": "'Allahu Ekber' diyerek eğilinir. Erkekler kadar çok eğilinmez, dizler hafif bükük tutulabilir ve sırt tam düzleştirilmez. Eller diz kapaklarına sadece dokundurulur, kavranmaz. 3 defa 'Sübhâne Rabbiye'l-Azîm' denir."},
    {"ad": "Secde", "aciklama": "'Allahu Ekber' diyerek secdeye gidilir. Erkeklerden farklı olarak kollar vücuda yapışık, karın da uyluklara yakın tutulur. Ayaklar sağa doğru yatırılır. 3 defa 'Sübhâne Rabbiye'l-A'lâ' denir."},
    {"ad": "Oturuş (Ka'de-i Ahîre)", "aciklama": "Son rekatta oturulur. Ayaklar sağ taraftan çıkarılarak kalça üzerine yere oturulur. Ettehıyyatü, Salli-Barik ve Rabbena duaları okunarak sağa ve sola selam verilip namaz tamamlanır."}
  ]
};

const Map<String, dynamic> VITIR_NAMAZI = {
  "aciklama": "Vitir namazı, yatsı namazından sonra kılınan 3 rekatlık vacip bir namazdır. Diğer namazlardan farkı, 3. rekatında Fatiha ve sure okunduktan sonra rükûya gitmeden önce tekbir alınması ve Kunut dualarının okunmasıdır.",
  "kunut1": {
    "arapca": "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنَسْتَهْدِيكَ وَنُؤْمِنُ بِكَ وَنَتُوبُ إِلَيْكَ...",
    "okunus": "Allahümme innâ nesteînüke ve nestağfirüke ve nestehdîke. Ve nü'minü bike ve netûbü ileyk. Ve netevekkelü aleyke ve nüsnî aleykel-hayra küllehû neşkürük. Ve lâ nekfürük. Ve nahleu ve netrükü men yefcürük.",
    "anlam": "Allah'ım! Senden yardım isteriz, günahlarimizi bağişlamani isteriz, razı olduğun şeylere hidayet etmeni isteriz. Sana inanırız, sana tövbe ederiz. Sana güveniriz. Bize verdiğin bütün nimetleri bilerek seni hayırla överiz. Sana şükrederiz, nankörlük etmeyiz. Sana isyan edenleri bırakır ve onlardan ayrılırız."
  },
  "kunut2": {
    "arapca": "اللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّي وَنَسْجُدُ وَإِلَيْكَ نَسْعَى وَنَحْفِدُ...",
    "okunus": "Allahümme iyyâke na'büdü ve leke nüsallî ve nescüdü ve ileyke nes'â ve nahfid. Nercû rahmeteke ve nahşâ azâbeke inne azâbeke bil-küffâri mülhık.",
    "anlam": "Allah'ım! Biz yalnız sana kulluk ederiz. Ancak senin için namaz kılar ve sana secde ederiz. Sana ulaşmaya çalışır ve ibadetle koşarız. Rahmetini umarız ve azabından korkarız. Şüphesiz senin azabın kâfirlere ulaşacaktır."
  }
};

const Map<String, dynamic> OFFLINE_VAKITLER = {
  "9541": [
    {
      "MiladiTarihKisa": "21.05.2026",
      "MiladiTarihUzun": "21 Mayıs 2026 Perşembe",
      "HicriTarihUzun": "4 Zilhicce 1447",
      "Imsak": "03:34",
      "Gunes": "05:34",
      "Ogle": "13:06",
      "Ikindi": "17:02",
      "Aksam": "20:28",
      "Yatsi": "22:10"
    },
    {
      "MiladiTarihKisa": "22.05.2026",
      "MiladiTarihUzun": "22 Mayıs 2026 Cuma",
      "HicriTarihUzun": "5 Zilhicce 1447",
      "Imsak": "03:33",
      "Gunes": "05:33",
      "Ogle": "13:06",
      "Ikindi": "17:03",
      "Aksam": "20:29",
      "Yatsi": "22:11"
    }
  ]
};
