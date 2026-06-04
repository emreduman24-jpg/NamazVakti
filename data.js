// Namaz Vakitleri & Dini Bilgiler - Veri Katmanı

export const DINI_GUNLER = [
  { tarih: "26 Ocak 2026", gun: "Pazartesi", ad: "Regaib Kandili" },
  { tarih: "13 Şubat 2026", gun: "Cuma", ad: "Miraç Kandili" },
  { tarih: "2 Mart 2026", gun: "Pazartesi", ad: "Berat Kandili" },
  { tarih: "19 Mart 2026", gun: "Perşembe", ad: "Ramazan Başlangıcı" },
  { tarih: "14 Nisan 2026", gun: "Salı", ad: "Kadir Gecesi" },
  { tarih: "17 Nisan 2026", gun: "Cuma", ad: "Ramazan Bayramı Arefesi" },
  { tarih: "18 Nisan 2026", gun: "Cumartesi", ad: "Ramazan Bayramı (1. Gün)" },
  { tarih: "19 Nisan 2026", gun: "Pazar", ad: "Ramazan Bayramı (2. Gün)" },
  { tarih: "20 Nisan 2026", gun: "Pazartesi", ad: "Ramazan Bayramı (3. Gün)" },
  { tarih: "25 Mayıs 2026", gun: "Pazartesi", ad: "Kurban Bayramı Arefesi" },
  { tarih: "26 Mayıs 2026", gun: "Salı", ad: "Kurban Bayramı (1. Gün)" },
  { tarih: "27 Mayıs 2026", gun: "Çarşamba", ad: "Kurban Bayramı (2. Gün)" },
  { tarih: "28 Mayıs 2026", gun: "Perşembe", ad: "Kurban Bayramı (3. Gün)" },
  { tarih: "29 Mayıs 2026", gun: "Cuma", ad: "Kurban Bayramı (4. Gün)" },
  { tarih: "16 Haziran 2026", gun: "Salı", ad: "Hicri Yılbaşı (1 Muharrem 1448)" },
  { tarih: "25 Haziran 2026", gun: "Perşembe", ad: "Aşure Günü" },
  { tarih: "23 Ağustos 2026", gun: "Pazar", ad: "Mevlid Kandili" }
];

export const VAKTIN_AYETLERI = [
  {
    title: "Talak - 3. Ayet",
    text: "Şüphesiz Allah, muttakilerin dostu, yardımcısı ve koruyucusudur. (Casiye - 19)", // Matching user screenshot exact text even if labeled Talak 3
    ref: "Casiye - 19"
  },
  {
    title: "Bakara - 186. Ayet",
    text: "Kullarım sana beni sorduklarında bilsinler ki ben onlara çok yakınım. Bana dua edenlerin dualarını kabul ederim.",
    ref: "Bakara - 186"
  },
  {
    title: "İnşirah - 5-6. Ayet",
    text: "Elbette zorlukla beraber bir kolaylık vardır. Gerçekten, zorlukla beraber bir kolaylık vardır.",
    ref: "İnşirah - 5-6"
  },
  {
    title: "Âl-i İmrân - 139. Ayet",
    text: "Gevşemeyin, hüzünlenmeyin. Eğer gerçekten inanıyorsanız üstün olan sizsinizdir.",
    ref: "Âl-i İmrân - 139"
  },
  {
    title: "Ankebut - 45. Ayet",
    text: "Şüphesiz namaz, insanı hayasızlıktan ve kötülükten alıkoyar. Allah'ı anmak elbette en büyük ibadettir.",
    ref: "Ankebut - 45"
  }
];

export const VAKTIN_HADISLERI = [
  {
    title: "Hadis-i Şerif - Ebû Hüreyre",
    text: "Kim Kadir gecesini imanla ihya ederse, geçmiş günahları bağışlanır. (Buhari)",
    ref: "Buhari, Terâvih 2"
  },
  {
    title: "Hadis-i Şerif - Tirmizi",
    text: "Dua ibadetin ta kendisidir.",
    ref: "Tirmizi, Tefsir 2"
  },
  {
    title: "Hadis-i Şerif - Müslim",
    text: "Müslüman müslümanın kardeşidir. Ona zulmetmez, onu tehlikede yalnız bırakmaz.",
    ref: "Müslim, Birr 58"
  },
  {
    title: "Hadis-i Şerif - Buhari",
    text: "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.",
    ref: "Buhari, İlim 12"
  },
  {
    title: "Hadis-i Şerif - Müslim",
    text: "Temizlik imanın yarısıdır. Elhamdülillah mizanı doldurur.",
    ref: "Müslim, Taharet 1"
  }
];

export const GUNUN_ISIMLERI = [
  { kiz: "Melisa", erkek: "Eymen" },
  { kiz: "Zeynep", erkek: "Ömer" },
  { kiz: "Elif", erkek: "Ali" },
  { kiz: "Defne", erkek: "Yusuf" },
  { kiz: "Meryem", erkek: "Hamza" },
  { kiz: "Asya", erkek: "Miraç" },
  { kiz: "Zehra", erkek: "Mustafa" }
];

export const ESMAUL_HUSNA = [
  { no: 1, ad: "Allah", arapca: "الله", anlam: "Her şeyin yaratıcısı, tek ilah.", zikir: 66, fazilet: "İnanç kuvveti, isteklerin kabulü" },
  { no: 2, ad: "er-Rahmân", arapca: "الرَّحْمَانُ", anlam: "Dünyadaki tüm yaratılanlara şefkat gösteren.", zikir: 298, fazilet: "Gönül ferahlığı, merhamet kazanma" },
  { no: 3, ad: "er-Rahîm", arapca: "الرَّحِيمُ", anlam: "Ahirette sadece müminlere merhamet edecek olan.", zikir: 258, fazilet: "Maddi ve manevi rızk bolluğu" },
  { no: 4, ad: "el-Melik", arapca: "الْمَلِكُ", anlam: "Kainatın tek hakimi ve mutlak sahibi.", zikir: 90, fazilet: "Maddi ve manevi güçlü olmak" },
  { no: 5, ad: "el-Kuddûs", arapca: "الْقُدُّوسُ", anlam: "Her türlü noksanlıktan uzak, tertemiz olan.", zikir: 170, fazilet: "Ruhsal temizlik, korkulardan emin olma" },
  { no: 6, ad: "es-Selâm", arapca: "السَّلَامُ", anlam: "Esenlik veren, kullarını selamete çıkaran.", zikir: 131, fazilet: "Huzur, korkulardan kurtulma, şifa" },
  { no: 7, ad: "el-Mü'min", arapca: "الْمُؤْمِنُ", anlam: "Güven veren, koruyan, sığınak olan.", zikir: 137, fazilet: "Kötülüklerden korunma, emniyet" },
  { no: 8, ad: "el-Müheymin", arapca: "الْمُهَيْمِنُ", anlam: "Gözeten, koruyan ve her şeyi yöneten.", zikir: 145, fazilet: "İnsanların sevgisini kazanmak" },
  { no: 9, ad: "el-Azîz", arapca: "الْعَزِيزُ", anlam: "Mağlup edilmesi imkansız olan, en yüce.", zikir: 94, fazilet: "İzzet sahibi olmak, düşmanlara galip gelmek" },
  { no: 10, ad: "el-Cebbâr", arapca: "الْجَبَّارُ", anlam: "Dilediğini zorla yaptıran, eksikleri tamamlayan.", zikir: 206, fazilet: "Dileklerin olması, haksızlıklardan korunma" },
  { no: 11, ad: "el-Mütekebbir", arapca: "الْمُتَكَبِّرُ", anlam: "Büyüklükte eşi benzeri olmayan.", zikir: 662, fazilet: "İzzet, şeref ve bereket bulma" },
  { no: 12, ad: "el-Hâlık", arapca: "الْخَالِقُ", anlam: "Her şeyi yoktan var eden, yaratan.", zikir: 731, fazilet: "İşlerde başarı, sıkıntılardan kurtuluş" },
  { no: 13, ad: "el-Bâri", arapca: "الْبَارِئُ", anlam: "Her şeyi kusursuz ve uyumlu yaratan.", zikir: 213, fazilet: "Maddi manevi başarı, şifa bulma" },
  { no: 14, ad: "el-Musavvir", arapca: "الْمُصَوِّرُ", anlam: "Her şeye en güzel şekli veren.", zikir: 336, fazilet: "Zor işlerin kolaylaşması, başarı" },
  { no: 15, ad: "el-Gaffâr", arapca: "الْغَفَّارُ", anlam: "Günahları örten, bağışlaması bol olan.", zikir: 1281, fazilet: "Günahların affı, cehennem azabından korunma" }
];

export const DUALAR = [
  { ad: "Yemek Duası", arapca: "الْحَمْدُ للهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ", anlam: "Bizi yediren, içiren ve Müslüman kılan Allah'a hamdolsun." },
  { ad: "Uykudan Uyanınca", arapca: "الْحَمْدُ للهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ", anlam: "Bizi öldürdükten sonra dirilten Allah'a hamdolsun. Dönüş ancak O'nadır." },
  { ad: "Nazar Duası (Kalem 51-52)", arapca: "وَإِن يَكَادُ الَّذِينَ كَفَرُوا لَيُزْلِقُونَكَ بِأَبْصَارِهِمْ لَمَّا سَمِعُوا الذِّكْرَ وَيَقُولُونَ إِنَّهُ لَمَجْنُونٌ", anlam: "Şüphesiz inkâr edenler Zikr’i (Kur’an’ı) duydukları zaman neredeyse seni gözleriyle devireceklerdi. 'O mutlaka bir delidir' diyorlar." },
  { ad: "Eve Girerken", arapca: "اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ بِسْمِ اللَّهِ وَلَجْنَا", anlam: "Allah'ım! Senden hayırlı giriş ve hayırlı çıkış dilerim. Allah'ın adıyla girdik, Allah'ın adıyla çıktık." },
  { ad: "Sınava Girerken", arapca: "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي", anlam: "Rabbim! Göğsümü genişlet, işimi kolaylaştır, dilimin düğümünü çöz ki sözümü anlasınlar." }
];

export const HADISLER_40 = [
  { no: 1, metin: "Ameller ancak niyetlere göredir ve herkese niyet ettiği şey vardır.", kaynak: "Buhari" },
  { no: 2, metin: "Din nasihattir (samimiyettir).", kaynak: "Müslim" },
  { no: 3, metin: "Sizden biriniz kendisi için istediğini kardeşi için de istemedikçe iman etmiş olmaz.", kaynak: "Buhari" },
  { no: 4, metin: "Hayra vesile olan, hayrı yapan gibidir.", kaynak: "Tirmizi" },
  { no: 5, metin: "Müslüman, elinden ve dilinden müslümanların güvende olduğu kimsedir.", kaynak: "Buhari" },
  { no: 6, metin: "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.", kaynak: "Buhari" },
  { no: 7, metin: "İnsanların en hayırlısı, insanlara faydalı olanıdır.", kaynak: "Beyhaki" },
  { no: 8, metin: "İki nimet vardır ki insanların çoğu bunda aldanmıştır: Sağlık ve boş vakit.", kaynak: "Buhari" },
  { no: 9, metin: "Hiçbir baba evladına güzel ahlaktan daha değerli bir miras bırakamaz.", kaynak: "Tirmizi" },
  { no: 10, metin: "Temizlik imanın yarısıdır.", kaynak: "Müslim" },
  { no: 11, metin: "Nerede olursan ol Allah'tan kork. Kötülüğün arkasından hemen bir iyilik yap ki onu silsin.", kaynak: "Tirmizi" },
  { no: 12, metin: "Gerçek zenginlik mal çokluğu değil, gönül zenginliğidir.", kaynak: "Buhari" },
  { no: 13, metin: "Öfkelenen kimse sussun.", kaynak: "Ahmed bin Hanbel" },
  { no: 14, metin: "Komşusu açken tok yatan bizden değildir.", kaynak: "Hakim" },
  { no: 15, metin: "Güzel söz sadakadır.", kaynak: "Buhari" }
];

export const KURAN_CUZLER = Array.from({ length: 30 }, (_, i) => ({
  cuz: i + 1,
  sureler: `Cüz ${i + 1} - Sesli Tilavet ve Takip`,
  sureList: ["Fatiha", "Bakara", "Ali İmran", "Nisa"][i % 4]
}));

export const OFFLINE_VAKITLER = {
  "9541": [ // İstanbul Merkez Vakitleri Örnek (2026 Mayıs için uyumlu)
    {
      MiladiTarihKisa: "21.05.2026",
      MiladiTarihUzun: "21 Mayıs 2026 Perşembe",
      HicriTarihUzun: "4 Zilhicce 1447",
      Imsak: "03:34",
      Gunes: "05:34",
      Ogle: "13:06",
      Ikindi: "17:02",
      Aksam: "20:28",
      Yatsi: "22:10"
    },
    {
      MiladiTarihKisa: "22.05.2026",
      MiladiTarihUzun: "22 Mayıs 2026 Cuma",
      HicriTarihUzun: "5 Zilhicce 1447",
      Imsak: "03:33",
      Gunes: "05:33",
      Ogle: "13:06",
      Ikindi: "17:03",
      Aksam: "20:29",
      Yatsi: "22:11"
    }
  ]
};

// YENİ EKLENEN VERİLER:

export const PEYGAMBER_HAYATI = [
  { baslik: "Çocukluk Dönemi", icerik: "Peygamber Efendimiz (s.a.v.), 571 yılında Mekke'de doğdu. Doğmadan önce babası Abdullah'ı, 6 yaşında ise annesi Âmine'yi kaybetti. Dedesi Abdülmuttalib'in ve daha sonra amcası Ebû Tâlib'in himayesinde büyüdü. Çocukluğunda dürüstlüğü ve güvenilirliğiyle 'Muhammedü'l-Emîn' unvanını aldı." },
  { baslik: "Gençlik Dönemi", icerik: "Gençlik yıllarında ticaretle uğraştı. Ticaretteki doğruluğu ve ahlakıyla herkesin takdirini kazandı. 25 yaşında Hz. Hatice ile evlendi. Mekke'de haksızlıklara karşı kurulan 'Hilfü'l-Fudûl' (Erdemliler Birliği) derneğine katılarak mazlumların yanında yer aldı." },
  { baslik: "Peygamberlik Dönemi", icerik: "40 yaşında (610 yılı Ramazan ayında) Nur Dağı'ndaki Hira Mağarası'nda ilk vahiy geldi ('Oku!'). Tevhidi tebliğ etmeye başladı. Mekke'de maruz kaldığı ağır baskı ve zulümlere rağmen İslam dinini yaymaktan vazgeçmedi." },
  { baslik: "Hicret ve Medine", icerik: "Müslümanlar üzerindeki zulüm dayanılmaz hale gelince, 622 yılında Medine'ye hicret edildi. Medine'de İslam Devleti'nin temelleri atıldı. Mescid-i Nebevî inşa edildi. Mekkeli müşriklerle Bedir, Uhud ve Hendek savaşları yapıldı." },
  { baslik: "Veda Haccı ve Vefat", icerik: "632 yılında yüz bini aşkın Müslümana Arafat'ta Veda Hutbesi'ni irat etti. İnsan hakları, eşitlik ve adaleti vurgulayan bu hutbeden kısa süre sonra, aynı yıl Medine'de vefat etti. Kabr-i Şerif'i Medine'deki Mescid-i Nebevî içerisindedir." }
];

export const RAMAZAN_HAKKINDA = [
  { baslik: "Oruç İbadeti", icerik: "Ramazan ayı, İslam'ın beş şartından biri olan oruç ibadetinin yerine getirildiği mübarek aydır. İmsak vaktinden akşam ezanına kadar niyet edilerek yeme, içme ve nefsi arzulardan uzak durulur." },
  { baslik: "Kadir Gecesi", icerik: "Kur'an-ı Kerim bu ayda inmeye başlamıştır. Kur'an'da 'bin aydan daha hayırlı' olduğu belirtilen Kadir Gecesi, Ramazan ayının son on günü içerisinde aranır." },
  { baslik: "Zekat ve Fitre", icerik: "Bu ayda yardımlaşma en üst seviyetedir. Her Müslümanın vermesi gereken Sadaka-i Fıtır (Fitre) bu ayda ihtiyaç sahiplerine ulaştırılır. Zekatlar da genellikle bu ayda dağıtılır." },
  { baslik: "Ramazan Bayramı", icerik: "Ramazan ayının bitimiyle birlikte üç gün süren Şevval ayının ilk günlerinde kutlanan bayramdır. Müminlerin bir aylık sabır ve ibadetinin ödülüdür." }
];

export const ORUC_REHBERI = {
  bozanlar: [
    "Bilerek bir şey yemek veya içmek",
    "Sigara içmek, tütün mamulleri kullanmak veya nargile tüttürmek",
    "Gıda veya güç verici serumlar, iğneler yaptırmak",
    "Ağza giren yağmur, kar veya suyu bilerek yutmak",
    "Astım spreyi kullanmak (Diyanet'in bazı fetvalarına göre acil durumlar hariç kaza gerektirir)"
  ],
  bozmayanlar: [
    "Unutarak bir şey yemek veya içmek (oruçlu olunduğu hatırlanır hatırlanmaz ağız çalkalanıp devam edilir)",
    "Kan vermek veya kan aldırmak",
    "Banyo yapmak, duş almak veya yüzmek (ağız ve burundan su kaçırmamak şartıyla)",
    "Göz, kulak veya burun damlası kullanmak (boğaza ulaşmayacak miktarda)",
    "Diş fırçalamak veya misvak kullanmak (macun yutulmamak kaydıyla)"
  ],
  cesitler: [
    { ad: "Farz Oruç", aciklama: "Ramazan ayında tutulan oruçtur." },
    { ad: "Vacip Oruç", aciklama: "Adak orucu veya bozulan nafile orucun kazasıdır." },
    { ad: "Nafile Oruç", aciklama: "Şevval orucu, Aşure orucu, Pazartesi-Perşembe oruçları gibi sünnet olan oruçlardır." }
  ]
};

export const MOCK_CAMILER = [
  { ad: "Fatih Camii ve Külliyesi", mesafe: "0.4 km", adres: "Fatih, İstanbul", harita: "https://maps.google.com/?q=Fatih+Camii+Istanbul" },
  { ad: "Süleymaniye Camii", mesafe: "1.2 km", adres: "Süleymaniye, Fatih/İstanbul", harita: "https://maps.google.com/?q=Suleymaniye+Camii+Istanbul" },
  { ad: "Sultanahmet Camii", mesafe: "2.5 km", adres: "Sultanahmet, Fatih/İstanbul", harita: "https://maps.google.com/?q=Sultanahmet+Camii+Istanbul" },
  { ad: "Yavuz Selim Camii", mesafe: "1.1 km", adres: "Balat, Fatih/İstanbul", harita: "https://maps.google.com/?q=Yavuz+Selim+Camii+Istanbul" },
  { ad: "Nuruosmaniye Camii", mesafe: "2.1 km", adres: "Çemberlitaş, Fatih/İstanbul", harita: "https://maps.google.com/?q=Nuruosmaniye+Camii+Istanbul" }
];

export const TESBIHAT_STEPS = [
  { ad: "İstiğfar & Salavat", arapca: "أَسْتَغْفِرُ اللهَ... اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ", okunus: "Estağfirullah (3 Kez) - Allahümme entesselamü ve minkesselam...", anlam: "Allah'tan bağışlanma dilerim. Allah'ım sen esenliksin..." },
  { ad: "Salat-ı Münciye", arapca: "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ صَلاَةً تُنْجِينَا بِهَا...", okunus: "Allahümme salli ala seyyidina Muhammedin salaten tuncina biha...", anlam: "Allah'ım! Efendimiz Muhammed'e salat eyle. Öyle bir salat ki bizi tüm korku ve afetlerden kurtarsın..." },
  { ad: "Subhanallah", arapca: "سُبْحَانَ اللهِ", okunus: "Sübhanallah (33 Kez)", anlam: "Allah noksan sıfatlardan uzaktır." },
  { ad: "Elhamdülillah", arapca: "الْحَمْدُ للهِ", okunus: "Elhamdülillah (33 Kez)", anlam: "Hamd Allah'adır." },
  { ad: "Allahu Ekber", arapca: "اللهُ أَكْبَرُ", okunus: "Allahu Ekber (33 Kez)", anlam: "Allah en büyüktür." },
  { ad: "Kelime-i Tevhid", arapca: "لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ...", okunus: "La ilahe illallahü vahdehû la şerîke leh...", anlam: "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur..." }
];

export const SAHABE_HAYATLARI = [
  { ad: "Hz. Ebû Bekir (r.a.)", unvan: "Sıddık (Sadık)", ozet: "Peygamber Efendimiz'in en yakın dostu ve ilk halifesidir. İslam'ı kabul eden ilk hür erkektir. Hicret esnasında Peygamberimiz ile birlikte mağarada bulunmuştur. Cömertliği ve sadakatiyle bilinir." },
  { ad: "Hz. Ömer (r.a.)", unvan: "Faruk (Adaletli)", ozet: "İkinci halifedir. Adaleti, cesareti ve hak ile batılı ayırt etmedeki hassasiyeti nedeniyle 'Faruk' unvanını almıştır. Onun döneminde İslam coğrafyası çok genişlemiş ve devlet kurumları teşkilatlanmıştır." },
  { ad: "Hz. Osman (r.a.)", unvan: "Zinnûreyn (Çift Işıklı)", ozet: "Üçüncü halifedir. Peygamber Efendimiz'in iki kızıyla evlendiği için 'Zinnûreyn' denmiştir. Kur'an-ı Kerim'in çoğaltılmasını sağlamıştır. Cömertliği, hayası ve yumuşak huyluluğuyla tanınır." },
  { ad: "Hz. Ali (r.a.)", unvan: "Esedullah (Allah'ın Aslanı)", ozet: "Dördüncü halifedir. Peygamber Efendimiz'in amcasının oğlu ve damadıdır. Çocuk yaşta İslam'ı ilk kabul edendir. İlmi, cesareti, hitabeti ve kahramanlığıyla İslam tarihinde eşsiz bir yere sahiptir." },
  { ad: "Hz. Hamza (r.a.)", unvan: "Seyyidüşşüheda", ozet: "Peygamber Efendimiz'in amcasıdır. Müslüman oluşuyla İslam safına büyük güç katmıştır. Uhud Savaşı'nda kahramanca çarpışırken şehit düşmüştür." },
  { ad: "Hz. Bilal-i Habeşî (r.a.)", unvan: "Müezzin-i Resûl", ozet: "İslam'ın ilk müezzinidir. Köle iken inancından dolayı ağır işkencelere maruz kalmış, Hz. Ebû Bekir tarafından özgürleştirilmiştir. Sesiyle İslam alemine ezan okuma şerefine nail olmuştur." }
];

export const ISLAM_TARIHI = [
  { yil: "571", olay: "Peygamber Efendimiz'in Dünyaya Gelişi", detay: "Mekke'de Rebiülevvel ayının 12. gecesi doğmuştur." },
  { yil: "610", olay: "İlk Vahiy ve Nübüvvet", detay: "Hira Mağarası'nda Alak Suresi'nin ilk 5 ayeti nazil oldu." },
  { yil: "615", olay: "Habeşistan'a Hicret", detay: "Müslümanlar üzerindeki baskılar nedeniyle ilk hicret gerçekleştirildi." },
  { yil: "620", olay: "İsra ve Miraç Mucizesi", detay: "Peygamberimizin Mescid-i Aksa'ya götürülmesi ve oradan semaya yükselişi." },
  { yil: "622", olay: "Medine'ye Hicret (Hicri Başlangıç)", detay: "İslam devletinin kurulması ve Müslümanların Medine'ye göçü." },
  { yil: "624", olay: "Bedir Gazvesi", detay: "Müslümanların Mekkeli müşriklere karşı kazandığı ilk büyük askeri zafer." },
  { yil: "625", olay: "Uhud Gazvesi", detay: "Müslümanların disiplin ve emirlere itaatin önemini kavradığı çetin mücadele." },
  { yil: "630", olay: "Mekke'nin Fethi", detay: "Kan dökülmeden Mekke fethedilmiş ve Kabe putlardan temizlenmiştir." },
  { yil: "632", olay: "Veda Haccı ve Vefat", detay: "Peygamber Efendimiz Medine'de 63 yaşında vefat etmiştir." }
];

export const NAMAZ_KILMA_REHBERI = {
  erkek: [
    { ad: "Niyet ve Tekbir", aciklama: "Kıbleye dönülür, niyet edilir. Eller kulak hizasına kaldırılıp başparmak kulak memesine değdirilerek 'Allahu Ekber' denir ve eller göbek altında bağlanır." },
    { ad: "Kıyam ve Kıraat", aciklama: "Ayakta durulur. Sırasıyla Sübhaneke, Euzü-Besmele, Fatiha ve ek bir sure (zamm-ı sure) okunur." },
    { ad: "Rükû", aciklama: "'Allahu Ekber' diyerek eğilinir. Sırt düz tutulur, ellerle diz kapakları kavranır. 3 defa 'Sübhâne Rabbiye'l-Azîm' denir. Doğrulurken 'Semiallahü limen hamideh', ayakta tam doğrulunca 'Rabbena leke'l-hamd' denir." },
    { ad: "Secde", aciklama: "'Allahu Ekber' diyerek yere kapanılır. Önce dizler, sonra eller, alın ve burun yere konur. Ayaklar yere basar konumdadır. 3 defa 'Sübhâne Rabbiye'l-A'lâ' denir. İki secde arasında kısa bir süre oturulur ve tekrar secdeye gidilir." },
    { ad: "Oturuş (Ka'de-i Ahîre)", aciklama: "Son rekatta oturulur. Sol ayak yatırılıp üzerine oturulur, sağ ayak dik tutulur. Ettehıyyatü, Salli-Barik ve Rabbena duaları okunur. Önce sağa sonra sola 'Es-selâmü aleyküm ve rahmetullah' diyerek selam verilir." }
  ],
  kadin: [
    { ad: "Niyet ve Tekbir", aciklama: "Kıbleye dönülür, niyet edilir. Eller göğüs (omuz) hizasına kaldırılır, parmak uçları omuz hizasını geçmez. 'Allahu Ekber' denerek eller göğüs üstünde (sağ el sol elin üzerinde olacak şekilde) bağlanır." },
    { ad: "Kıyam ve Kıraat", aciklama: "Ayakta durulur. Sırasıyla Sübhaneke, Euzü-Besmele, Fatiha ve ek bir sure (zamm-ı sure) okunur." },
    { ad: "Rükû", aciklama: "'Allahu Ekber' diyerek eğilinir. Erkekler kadar çok eğilinmez, dizler hafif bükük tutulabilir ve sırt tam düzleştirilmez. Eller diz kapaklarına sadece dokundurulur, kavranmaz. 3 defa 'Sübhâne Rabbiye'l-Azîm' denir." },
    { ad: "Secde", aciklama: "'Allahu Ekber' diyerek secdeye gidilir. Erkeklerden farklı olarak kollar vücuda yapışık, karın da uyluklara yakın tutulur. Ayaklar sağa doğru yatırılır. 3 defa 'Sübhâne Rabbiye'l-A'lâ' denir." },
    { ad: "Oturuş (Ka'de-i Ahîre)", aciklama: "Son rekatta oturulur. Ayaklar sağ taraftan çıkarılarak kalça üzerine yere oturulur. Ettehıyyatü, Salli-Barik ve Rabbena duaları okunarak sağa ve sola selam verilip namaz tamamlanır." }
  ]
};

export const VITIR_NAMAZI = {
  aciklama: "Vitir namazı, yatsı namazından sonra kılınan 3 rekatlık vacip bir namazdır. Diğer namazlardan farkı, 3. rekatında Fatiha ve sure okunduktan sonra rükûya gitmeden önce tekbir alınması ve Kunut dualarının okunmasıdır.",
  kunut1: {
    arapca: "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنَسْتَهْدِيكَ وَنُؤْمِنُ بِكَ وَنَتُوبُ إِلَيْكَ...",
    okunus: "Allahümme innâ nesteînüke ve nestağfirüke ve nestehdîke. Ve nü'minü bike ve netûbü ileyk. Ve netevekkelü aleyke ve nüsnî aleykel-hayra küllehû neşkürük. Ve lâ nekfürük. Ve nahleu ve netrükü men yefcürük.",
    anlam: "Allah'ım! Senden yardım isteriz, günahlarımızı bağışlamanı isteriz, razı olduğun şeylere hidayet etmeni isteriz. Sana inanırız, sana tövbe ederiz. Sana güveniriz. Bize verdiğin bütün nimetleri bilerek seni hayırla överiz. Sana şükrederiz, nankörlük etmeyiz. Sana isyan edenleri bırakır ve onlardan ayrılırız."
  },
  kunut2: {
    arapca: "اللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّي وَنَسْجُدُ وَإِلَيْكَ نَسْعَى وَنَحْفِدُ...",
    okunus: "Allahümme iyyâke na'büdü ve leke nüsallî ve nescüdü ve ileyke nes'â ve nahfid. Nercû rahmeteke ve nahşâ azâbeke inne azâbeke bil-küffâri mülhık.",
    anlam: "Allah'ım! Biz yalnız sana kulluk ederiz. Ancak senin için namaz kılar ve sana secde ederiz. Sana ulaşmaya çalışır ve ibadetle koşarız. Rahmetini umarız ve azabından korkarız. Şüphesiz senin azabın kâfirlere ulaşacaktır."
  }
};

export const PEYGAMBER_REHBERI = {
  donemler: [
    {
      baslik: "Doğumu ve Çocukluk Yılları (571 - 583)",
      yil: "571 - 583",
      icerik: "Peygamber Efendimiz Hz. Muhammed (s.a.v.), 571 yılında (12 Rebiülevvel) Mekke'de yetim olarak doğdu. Babası Abdullah o doğmadan önce vefat etmişti. Annesi Âmine, onu temiz çöl havasında büyümesi ve fasih Arapça öğrenmesi için sütanne Halime Hanım'a emanet etti. 4 yaşına kadar Taif bölgesindeki çöl ortamında sütannesi ve süt kardeşleriyle yaşadı. 6 yaşına geldiğinde, annesi Âmine ile babasının Medine'deki kabrini ziyaretten dönerken Ebva köyünde annesi vefat etti. Yanlarında bulunan sadık dadısı Ümmü Eymen onu Mekke'ye getirip dedesi Abdülmuttalib'e teslim etti. 8 yaşında dedesini de kaybeden Peygamberimiz, amcası Ebû Tâlib'in himayesine girdi ve onunla ticaret kervanlarına katılarak Şam ve Yemen bölgelerine seyahat etti.",
      ayet: "O, seni bir yetim iken bulup barındırmadı mı? Seni yolunu kaybetmiş olarak bulup doğru yola iletmedi mi? Seni muhtaç bulup zengin etmedi mi? (Duha Suresi, 6-8)",
      ek_bilgi: "Süt Anneleri: Süveybe Hanım, Halime-i Sa'diyye • Dedesi: Abdülmuttalib • Amcası: Ebû Tâlib • Dadısı: Ümmü Eymen"
    },
    {
      baslik: "Gençliği, Ticaret Hayatı ve Evliliği (583 - 610)",
      yil: "583 - 610",
      icerik: "Gençlik yıllarında dürüstlüğü, haramlardan uzak duruşu ve güvenilirliği sebebiyle Mekkeliler ona 'Muhammedü'l-Emîn' (Güvenilir Muhammed) unvanını verdi. 20'li yaşlarında Mekke'de asayişi sağlamak, haksızlığa uğrayan yabancı tüccarları ve mazlumları korumak amacıyla kurulan Hilfü'l-Fudûl (Erdemliler Birliği) topluluğuna katıldı. 25 yaşında, ahlakı ve güvenirliğine hayran kalan Hz. Hatice validemiz ile evlendi. Bu evlilikten Kasım, Abdullah, Zeynep, Rukiyye, Ümmü Gülsüm ve Fatıma dünyaya geldi. 35 yaşında Kâbe'nin tamiri sırasında Hacerü'l-Esved taşının yerine konulması hususunda kabileler arasında çıkan büyük anlaşmazlığı, hırkasını yere serip taşı kabile reislerine taşıtarak Kâbe Hakemliğiyle barışçıl bir şekilde çözdü.",
      ayet: "Rabbin sana verecek, sen de hoşnut kalacaksın. (Duha Suresi, 5)",
      ek_bilgi: "İlk Eşi: Hz. Hatice-i Kübra • Katıldığı Kurul: Hilfü'l-Fudûl • Hakemlik Yaşı: 35 (Kâbe Hakemliği)"
    },
    {
      baslik: "Peygamberliğin Başlangıcı ve Mekke Dönemi (610 - 622)",
      yil: "610 - 622",
      icerik: "40 yaşına yaklaştığında Mekke'deki putperestlikten ve ahlaki yozlaşmadan uzaklaşarak Nur Dağı'ndaki Hira Mağarası'nda tefekküre çekilmeye başladı. 610 yılı Ramazan ayında Hira'da tefekkürde iken vahiy meleği Cebrail (a.s.) gelerek Alak Suresi'nin ilk beş ayetini ('Oku!') ulaştırdı. Peygamberliğini ilan eden Efendimiz'e ilk olarak eşi Hz. Hatice, Hz. Ebu Bekir, Hz. Ali ve kölesi Hz. Zeyd iman etti. İlk üç yıl daveti gizli yürüttü, ardından açık tebliğ emri gelince Safa Tepesi'nden tüm Mekke halkına seslendi. Müşrikler, İslam'ın yayılmasını engellemek için Müslümanlara işkence, boykot ve sosyal tecrit uygulamaya başladılar. 615 ve 616 yıllarında bazı Müslümanlar Habeşistan'a hicret etti. 619 yılında koruyucusu Ebu Talib'i ve eşi Hz. Hatice'yi kaybetmesiyle bu yıla 'Hüzün Yılı' denildi. Taif'e giderek sığınacak yer aradı ancak taşlanarak şehirden çıkarıldı. Hemen ardından İsra ve Miraç mucizeleriyle teselli edildi.",
      ayet: "Şüphesiz sen yüce bir ahlâk üzeresin. (Kalem Suresi, 4)",
      ek_bilgi: "İlk Vahiy: Alak Suresi, 1-5 • Hüzün Yılı: Ebu Talib ve Hz. Hatice'nin vefatı (619) • Mucizeler: İsra ve Miraç (620)"
    },
    {
      baslik: "Medine'ye Hicret ve Devletin Kuruluşu (622 - 624)",
      yil: "622 - 624",
      icerik: "Mekkeli müşriklerin Müslümanlar üzerindeki baskıları katlanılamaz boyuta ulaşınca ve Peygamberimiz'i öldürme planları yapınca, Medineli Müslümanlarla yapılan Akabe Biatları neticesinde hicret kararı alındı. Peygamberimiz, Hz. Ebu Bekir ile birlikte Sevr Mağarası'nda üç gün saklandıktan sonra mucizelerle dolu bir yolculuğun ardından Medine'ye ulaştı. Medine'ye girmeden önce Kuba'da ilk mescidi inşa etti. Medine'ye varınca Ensar (Medineli Müslümanlar) ile Muhacir (Mekke'den göç edenler) arasında sarsılmaz bir kardeşlik köprüsü kurdu (Muahat). Yahudiler, müşrikler ve Müslümanlar arasında barış içinde yaşama prensiplerini belirleyen, tarihin ilk yazılı anayasası niteliğindeki Medine Vesikası'nı imzaladı ve Mescid-i Nebevî'nin inşasını başlattı.",
      ayet: "Eğer siz ona yardım etmezseniz, bilin ki inkâr edenler onu Mekke'den çıkardıklarında mağaradaki iki kişiden biri olarak Allah ona yardım etmişti. (Tevbe Suresi, 40)",
      ek_bilgi: "Hicret Yılı: 622 • Yol Arkadaşı: Hz. Ebû Bekir (r.a.) • İlk İnşa Edilen Mescid: Kuba Mescidi • Kardeşlik: Muahat Anlaşması"
    },
    {
      baslik: "Savunma Mücadeleleri ve Hudeybiye Barışı (624 - 628)",
      yil: "624 - 628",
      icerik: "Medine'de kurulan İslam Devleti'ni yok etmek isteyen Mekkeli müşriklerin saldırılarına karşı koymak için Bedir, Uhud ve Hendek savaşları yapıldı. 624 yılında yapılan Bedir Savaşı'nda Müslümanlar kendilerinden üç kat güçlü müşrik ordusunu mağlup etti. 625 yılındaki Uhud Savaşı'nda okçuların tepeyi izinsiz terk etmesi sonucu Müslümanlar kayıplar verdi, Peygamberimiz yaralandı ve Hz. Hamza şehit oldu. 627 yılındaki Hendek Savaşı'nda ise Medine çevresine büyük hendekler kazılarak başarılı bir savunma yapıldı. 628 yılında Müslümanlar Kabe'yi ziyaret etmek amacıyla Mekke'ye yürüdü. Yapılan müzakereler sonucu 10 yıllık bir barış süreci başlatan Hudeybiye Antlaşması imzalanarak barış sağlandı. Bu antlaşma sayesinde İslam barışçıl ortamda hızla yayıldı.",
      ayet: "Şüphesiz biz sana apaçık bir fetih ihsan ettik. (Fetih Suresi, 1)",
      ek_bilgi: "Bedir Savaşı: 624 • Uhud Savaşı: 625 • Hendek Savaşı: 627 • Hudeybiye Barış Antlaşması: 628"
    },
    {
      baslik: "Mekke'nin Fethi, Veda Haccı ve Vefatı (630 - 632)",
      yil: "630 - 632",
      icerik: "Mekkeli müşriklerin Hudeybiye Barış Antlaşması'nı ihlal etmesi üzerine, Peygamber Efendimiz 630 yılında 10.000 kişilik muazzam bir ordu ile Mekke üzerine yürüdü. Şehir neredeyse hiç kan dökülmeden fethedildi. Peygamberimiz Kâbe'ye girerek tüm putları kırdı ve ardından kendisine 20 yıl boyunca zulmeden Mekkelileri genel af ilan ederek serbest bıraktı. 632 yılında yüz binden fazla Müslüman ile Veda Haccı'nı gerçekleştirdi ve Arafat'ta insan hakları, adalet, kadın hakları ve eşitlik esaslarını vurgulayan Veda Hutbesi'ni irat etti. Medine'ye döndükten sonra hastalanarak 8 Haziran 632 tarihinde vefat etti. Mübarek kabri, Medine'deki Mescid-i Nebevî'de, vefat ettiği Hz. Aişe validemizin odasındadır (Ravza-i Mutahhara).",
      ayet: "Bugün sizin için dininizi kemale erdirdim. Üzerinizdeki nimetimi tamamladım ve sizin için din olarak İslam'dan razı oldum. (Maide Suresi, 3)",
      ek_bilgi: "Mekke'nin Fethi: 630 • Veda Hutbesi Sahabe Sayısı: 100.000+ • Vefat Tarihi: 8 Haziran 632 • Defnedildiği Yer: Ravza-i Mutahhara"
    }
  ],
  semail: [
    {
      baslik: "Fiziki Görünüşü (Hilye-i Şerif)",
      detay: "Peygamber Efendimiz'in (s.a.v.) mübarek hilyesini sahabiler şöyle tarif eder: Orta boyluydu; ne aşırı uzun ne de dikkat çekecek kadar kısaydı. Ten rengi ne kireç gibi beyaz ne de koyu esmerdi; beyazla kırmızının karışımı, parlak ve nurlu bir cilde sahipti. Gözleri siyah, son derece iri ve berraktı; kirpikleri uzun ve sıktı. Mübarek dişleri inci gibi parlar, konuştuğunda ön dişlerinin arasından nur süzülürdü. Saçları aşırı kıvırcık ya da dümdüz olmayıp dalgalıydı; sakalı gür ve heybetliydi. Alnı geniş, iki omuzu arası enliydi. Göğsünden göbeğine kadar ince bir kıl şeridi uzanırdı. İki omuzu arasında peygamberlik mührü (Nübüvvet Mührü) bulunmaktaydı."
    },
    {
      baslik: "Yürüyüşü ve Duruşu",
      detay: "Peygamberimiz yürürken adımlarını geniş atar, sanki yüksek bir yokuştan aşağı iniyormuş gibi hafifçe öne doğru eğilerek vakarlı ve hızlı adımlarla yürürdü. Arkasından seslenen birine sadece başını çevirerek değil, bütün vücuduyla yönelerek hitap ederdi. Bu duruşu muhatabına verdiği ehemmiyeti gösterirdi. Son derece heybetli bir duruşu vardı; ancak bu heybet korkutucu değil, saygı ve sevgi uyandırıcıydı. Oturduğu zaman mecliste en mütevazı köşeyi seçer, çevresindekileri rahatsız edecek şekilde kurulmazdı."
    },
    {
      baslik: "Mübarek Kokusu ve Sesi",
      detay: "Efendimiz'in teni ve teri son derece güzel kokardı. Sahabiler, onun geçtiği yolları mübarek kokusundan tanırlardı. Kendisiyle tokalaşan bir sahabi, gün boyu elinde o güzel kokuyu hissederdi. Bebekleri ve çocukları sevip başlarını okşadığında, o çocuklar arkadaşları arasında mis gibi kokularıyla fark edilirdi. Konuştuğunda sesi son derece gür, tatlı ve etkileyiciydi. Kelimeleri tane tane telaffuz eder, dinleyenler dilerse söylediklerini ezberleyebilirdi. Konuşurken gereksiz yere sözü uzatmaz, 'Cevâmiu'l-Kelim' (Az sözle çok mana ifade etme) yeteneğine sahipti."
    }
  ],
  ahlak: [
    {
      baslik: "Muhammedü'l-Emin (Güvenilirliği)",
      detay: "Daha İslam tebliğ edilmeden önce Mekke halkı ona 'Emin' lakabını takmıştı. Hayatında bir kez olsun yalan söylememiş, şaka dahi olsa kimseyi aldatmamıştır. İslam'a en düşman olanlar bile dürüstlüğünü kabul ederdi. Hicret gecesi kendisini öldürmek için evini saran müşriklerin ona bıraktığı emanetleri, canını hiçe sayarak Hz. Ali'yi yatağında bırakmak suretiyle sahiplerine iade etmiştir. Düşmanının dahi emanetine hıyanet etmeyen bir ahlaka sahipti."
    },
    {
      baslik: "Eşsiz Merhameti ve Taif Kıssası",
      detay: "Mekke'de zulüm doruğa ulaştığında, destek bulmak için Taif şehrine gitti. Ancak Taif liderleri köleleri ve çocukları kışkırtarak Peygamberimiz'i taşlattılar. Ayakları kan içinde kalan Efendimiz, bir bağa sığındı. Cebrail (a.s.) gelerek dağlar meleğinin emrinde olduğunu ve dilerse Taif halkını iki dağ arasında helak edebileceğini söyledi. Ancak merhamet abidesi olan Efendimiz: 'Hayır, ben azap için değil, rahmet olarak gönderildim. Ben onların helak olmasını değil, nesillerinden Allah'a ibadet edecek muvahidlerin gelmesini dilerim' diyerek onlar için dua etti."
    },
    {
      baslik: "Mekke'nin Fethi ve Genel Af Anekdotu",
      detay: "630 yılında Mekke fethedildiğinde, Müslümanlara 20 yıl boyunca işkence etmiş, yurtlarından sürmüş ve savaş açmış olan Mekkeliler Kâbe'nin çevresinde korkuyla Efendimiz'in vereceği kararı bekliyordu. Peygamberimiz onlara: 'Şimdi benden size ne yapacağımı bekliyorsunuz?' diye sordu. Mekkeliler: 'Sen kerim bir kardeşsin, kerim bir kardeş oğlusun' dediler. Efendimiz, tarihte eşi benzeri görülmemiş bir kararla: 'Bugün size kınama yoktur. Gidiniz, hepiniz serbestsiniz!' buyurarak kendisine ve ashabına zulmeden azılı düşmanlarını tamamen affetti."
    },
    {
      baslik: "Adaleti ve Kendi Üzerindeki Kısası",
      detay: "Adalet konusunda asla taviz vermez, zengin-fakir ayrımı yapmazdı. Bir gün asil bir kabilenden hırsızlık yapan kadının affedilmesi için aracı olan Hz. Üsame'ye çok kızarak: 'Geçmiş milletler, aralarındaki soylular suç işleyince onları affedip fakirleri cezalandırdıkları için helak oldular. Allah'a yemin ederim ki, kızım Fatıma dahi hırsızlık yapsaydı elini keserdim' buyurdu. Vefatına yakın bir süre kala mescitte ashabını toplayarak: 'Kimin sırtına vurduysam işte sırtım, gelsin vursun. Kimin malını aldıysam işte malım, gelsin alsın' diyerek kul hakkına gösterdiği titizliği kısas hakkı vererek göstermiştir."
    },
    {
      baslik: "Tevazuu ve Müşterek Hayat Kıssası",
      detay: "Devlet başkanı ve peygamber olmasına rağmen ashabından ayırt edilmek istemezdi. Bir yolculuk sırasında ashabı yemek yapmak için iş bölümü yaptı. Biri koyunu kesmeyi, diğeri yüzmeyi üstlendi. Efendimiz de: 'Odun toplamayı da ben üstleniyorum' buyurdu. Sahabiler: 'Ey Allah'ın Resulü, biz o işi de yaparız, siz yorulmayın' deyince: 'Sizin benim işimi yapacağınızı biliyorum. Fakat ben sizden ayrıcalıklı bir konumda bulunmaktan hoşlanmam. Şüphesiz Allah, kulunun arkadaşları arasında ayrıcalıklı görünmesinden hoşlanmaz' buyurarak bizzat odun toplamıştır."
    }
  ],
  aile: {
    anne_baba: [
      { ad: "Abdullah bin Abdulmuttalib", rol: "Babası", bilgi: "Kureyş'in en yakışıklı ve saygın gençlerinden biriydi. Ticaret için gittiği Şam yolculuğundan dönerken Medine'de hastalanarak genç yaşta vefat etti. Peygamberimiz henüz anne karnında iken yetim kaldı." },
      { ad: "Âmine bint Vehb", rol: "Annesi", bilgi: "Zühreoğulları kabilesinin saygın bir hanımıydı. Peygamberimiz 6 yaşında iken Medine dönüşü Ebva köyünde vefat etti. Kabri Ebva'dadır." },
      { ad: "Halime-i Sa'diyye", rol: "Süt Annesi", bilgi: "Sa'doğulları kabilesindendir. Peygamberimiz'i 4 yaşına kadar emzirip büyütmüştür. Evine Peygamberimiz'in gelişiyle büyük bir bereket yayılmıştır." },
      { ad: "Ebû Tâlib", rol: "Amcası", bilgi: "Dedesi Abdülmuttalib'in vefatından sonra 8 yaşından itibaren Peygamberimiz'i evine almış, öz evladı gibi büyütmüş ve peygamberliği döneminde müşriklere karşı onu hep korumuştur." }
    ],
    esleri: [
      { ad: "Hz. Hatice-i Kübra (r.anha)", bilgi: "Peygamberimiz'in ilk eşidir. 25 yıl evli kalmışlardır. İslam'ı kabul eden ilk kişidir. Peygamberimiz'e en zor zamanlarında canıyla ve malıyla en büyük desteği vermiştir. Efendimiz'in Hz. İbrahim dışındaki tüm çocuklarının annesidir." },
      { ad: "Hz. Aişe-i Sıddıka (r.anha)", bilgi: "Hz. Ebu Bekir'in kızıdır. İslam fıkhı, hadis ve tefsir ilminde sahabenin önde gelen alimlerindendir. Peygamberimiz'den 2000'den fazla hadis rivayet etmiştir." },
      { ad: "Hz. Sevde bint Zema (r.anha)", bilgi: "Hz. Hatice'nin vefatından sonra evlendiği ikinci eşidir. Yetimlerin bakımında ve ev işlerinde Peygamberimiz'e büyük destek olmuştur." },
      { ad: "Hz. Hafsa bint Ömer (r.anha)", bilgi: "Hz. Ömer'in kızıdır. Okuma yazma bilen, ibadete son derece düşkün bir hanımdı. Hz. Ebu Bekir döneminde mushaf haline getirilen Kur'an-ı Kerim nüshası ona emanet edilmiştir." },
      { ad: "Hz. Ümmü Seleme (r.anha)", bilgi: "Mekke'nin ilk Müslümanlarındandır. Eşi Uhud'da şehit düştükten sonra Efendimiz'in himayesine girmiştir. Son derece zeki ve ferasetli bir hanımdı; Hudeybiye antlaşmasında verdiği fikirle sahabenin kurban kesmesini sağlamıştır." },
      { ad: "Hz. Zeynep bint Cahş (r.anha)", bilgi: "Efendimiz'in halasının kızıdır. El işi yapar, kazandığını fakirlere ve yetimlere cömertçe dağıtırdı. Cömertliğiyle bilinirdi." },
      { ad: "Hz. Safiyye bint Huyey (r.anha)", bilgi: "Hayber fethi sonrası Müslüman olmuş ve Efendimiz ile evlenmiştir. İbadete, cömertliğe ve sadakate düşkünlüğüyle bilinirdi." },
      { ad: "Hz. Mariye-i Kıbtiyye (r.anha)", bilgi: "Mısır Mukavkısı tarafından hediye olarak gönderilmiş, Müslüman olduktan sonra Efendimiz ile evlenmiştir. Peygamberimiz'in en küçük oğlu Hz. İbrahim'in annesidir." }
    ],
    cocuklari: [
      { ad: "Kâsım", bilgi: "Efendimiz'in ilk çocuğudur. Çok küçük yaşta Mekke'de vefat etmiştir. Peygamberimiz bu sebeple 'Ebu'l-Kasım' (Kasım'ın Babası) künyesini almıştır." },
      { ad: "Hz. Zeynep (r.anha)", bilgi: "Efendimiz'in en büyük kızıdır. Ebu'l-As ile evlenmiştir. Medine'ye hicret esnasında büyük zorluklar çekmiş, genç yaşta vefat etmiştir." },
      { ad: "Hz. Rukiyye (r.anha)", bilgi: "Hz. Osman ile evlenmiştir. Habeşistan'a ilk hicret eden grupta yer almıştır. Bedir Savaşı günlerinde Medine'de vefat etmiştir." },
      { ad: "Hz. Ümmü Gülsüm (r.anha)", bilgi: "Ablası Rukiyye'nin vefatından sonra Hz. Osman ile evlenmiştir. Hz. Osman'a bu evlilik sebebiyle 'Zinnûreyn' (İki nurlu) denmiştir." },
      { ad: "Hz. Fâtımatü'z-Zehra (r.anha)", bilgi: "Efendimiz'in en sevgili kızıdır. Hz. Ali ile evlenmiştir. Efendimiz'in soyu onun çocukları Hz. Hasan ve Hz. Hüseyin üzerinden devam etmiştir. Efendimiz'in vefatından 6 ay sonra vefat etmiştir." },
      { ad: "Abdullah", bilgi: "Mekke'de peygamberlik geldikten sonra doğmuş, 'Tayyib' ve 'Tahir' lakaplarıyla anılmıştır. Küçük yaşta vefat etmiştir." },
      { ad: "İbrahim", bilgi: "Peygamberimiz'in Hz. Mariye validemizden doğan en küçük oğludur. 1.5 yaşında Medine'de vefat etmiştir. Vefat ettiği gün güneş tutulması gerçekleşmiştir." }
    ]
  },
  gazveler: [
    {
      ad: "Bedir Savaşı (624 / Hicri 2)",
      detay: "Müslümanlar ile Mekkeli müşrikler arasındaki ilk büyük savaştır. Müşriklerin Şam kervanından elde edilen ganimetleri korumak bahanesiyle 1000 kişilik bir orduyla çıkmasına karşın Müslümanlar 313 kişiyle karşı koydular. Allah'ın yardımıyla Müslümanlar zafer kazandı. Ebu Cehil dahil 70 müşrik öldürüldü, 70'i esir alındı. Esirlerden okuma-yazma bilenler, 10 Müslümana okuma-yazma öğretme karşılığında serbest bırakılarak okumaya verilen önem gösterildi.",
      sonuc: "Müslümanlar kesin zafer kazandı. İslam Devleti'nin gücü kanıtlandı.",
      ders: "Sayıca az olunsa bile inanç, istişare ve Allah'ın yardımıyla büyük zaferler kazanılabilir."
    },
    {
      ad: "Uhud Savaşı (625 / Hicri 3)",
      detay: "Mekkelilerin Bedir'in intikamını almak için 3000 kişilik orduyla Medine'ye saldırması üzerine yapıldı. Peygamberimiz Uhud Dağı'ndaki bir geçide kritik 50 okçu yerleştirdi ve 'Kuşların cesetlerimizi kapıştığını görseniz bile yerinizi terk etmeyiniz' talimatını verdi. Savaşın başında Müslümanlar üstün geldi. Ancak okçular savaşın kazanıldığını sanıp yerlerini terk edince, Halid bin Velid komutasındaki müşrik süvarileri arkadan saldırdı. Peygamberimiz yaralandı, Hz. Hamza dahil 70 sahabe şehit oldu.",
      sonuc: "Müslümanlar disiplinsizlik sebebiyle büyük kayıplar verdi ve savaş berabere/müşrik üstünlüğüyle bitti.",
      ders: "Peygamber'in (Liderin) emirlerine itaatin ve disiplinin ne kadar hayati olduğu acı bir tecrübeyle öğrenildi."
    },
    {
      ad: "Hendek Savaşı (627 / Hicri 5)",
      detay: "Yahudilerin kışkırtmasıyla müşrikler ve müttefik kabileler 10.000 kişilik dev bir orduyla Medine'yi kuşattı. Selman-ı Farisi'nin (r.a.) teklifi üzerine Medine'nin düzlük yerlerine atların ve insanların aşamayacağı genişlikte derin hendekler kazıldı. Kuşatma yaklaşık 1 ay sürdü. Müşrikler hendeği aşamadı. Çıkan şiddetli fırtına ve soğuk hava nedeniyle müşrik ordusu perişan oldu ve kuşatmayı kaldırıp Mekke'ye geri çekilmek zorunda kaldı.",
      sonuc: "Müslümanlar başarılı bir stratejiyle Medine'yi korudu. Müşriklerin son taarruzu oldu, savunma sırası Müslümanlara geçti.",
      ders: "Askeri stratejide yenilikçi fikirlere (Hendek kazma) ve sabra dayalı ortak akıl başarının anahtarıdır."
    },
    {
      ad: "Mekke'nin Fethi (630 / Hicri 8)",
      detay: "Kureyşlilerin Hudeybiye barış antlaşmasını bozmaları üzerine Efendimiz 10.000 kişilik muazzam bir orduyla Mekke'ye hareket etti. Kimsenin kanının dökülmesini istemeyen Efendimiz, orduyu gizli tutarak Mekke'ye ani giriş yaptı. Savaşsız ve kansız bir şekilde Mekke fethedildi. Efendimiz Kabe'yi putlardan temizledi ve Kabe'nin kapısında bekleyen Mekkelilere genel af ilan ederek İslam'ın merhamet dini olduğunu tüm dünyaya gösterdi.",
      sonuc: "Mekke kan dökülmeden fethedildi. Hicaz bölgesinde putperestlik tamamen son buldu.",
      ders: "Zafer anında kibirlenmeyip tevazu göstermek ve intikam yerine affetmeyi seçmek en büyük ahlaki zaferdir."
    }
  ],
  hadis_sunnet: [
    {
      kategori: "Yeme ve İçme Sünnetleri",
      detaylar: [
        "Yemeğe mutlaka besmele ('Bismillahirrahmanirrahim') ile başlamak.",
        "Yemeği sağ el ile yemek ve önünden almak.",
        "Yemek kabına veya bardağa nefes vermemek, suyu üç yudumda dinlenerek içmek.",
        "Sofradan tam doymadan kalkmak (Midenin üçte birini yemeğe, üçte birini suya, üçte birini nefese ayırmak).",
        "Lokmaları küçük almak ve iyice çiğnemek.",
        "Yemekten sonra elhamdülillah diyerek şükretmek ve elleri yıkamak."
      ]
    },
    {
      kategori: "Kişisel Temizlik Sünnetleri",
      detaylar: [
        "Misvak kullanmak (Her abdestte ve namaz öncesinde dişleri temizlemek).",
        "Güzel koku (misk/amber) sürünmek.",
        "Tırnakları cuma günleri kesmek.",
        "Saç ve sakal bakımına özen göstermek, temiz tutup taramak.",
        "Kıyafet temizliğine dikkat etmek ve sade giyinmek.",
        "Abdest organlarını kurulamak ve temiz tutmak."
      ]
    },
    {
      kategori: "Sosyal İlişkiler Sünnetleri",
      detaylar: [
        "Selamlaşmayı yaymak (Tanıdığı ve tanımadığı herkese selam vermek).",
        "Konuşurken muhatabına doğru dönmek ve göz teması kurmak.",
        "İnsanlara tebessüm etmek (Tebessüm etmek sadakadır).",
        "Hediyeleşmek (Hediyeleşin ki birbirinize olan sevginiz artsın).",
        "Söz verildiğinde sözünde durmak.",
        "Gıybet yapmamak, başkalarının kusurlarını örtmek."
      ]
    },
    {
      kategori: "Uyku ve Dinlenme Sünnetleri",
      detaylar: [
        "Uyumadan önce abdest almak.",
        "Sağ taraf üzerine yatıp sağ eli yanağın altına koyarak uzanmak.",
        "Uyumadan önce İhlas, Felak ve Nas surelerini okuyup avuç içine üfleyerek vücudu mesh etmek.",
        "Yatsı namazından sonra gereksiz konuşmaları bırakıp erken uyumak.",
        "Sabah namazı vaktinde uyanık olmak, güneş doğana kadar uyumamak.",
        "Günün ortasında (Öğle sıcağında) 'Kaylule' uykusuyla kısa bir süre dinlenmek."
      ]
    }
  ],
  zaman_cizelgesi: [
    { yil: "571", olay: "Peygamber Efendimiz'in Mekke'de Dünyaya Gelişi", ikon: "👶" },
    { yil: "577", olay: "Annesi Âmine Hanım'ın vefatı (Ebvâ Köyü)", ikon: "😢" },
    { yil: "579", olay: "Dedesi Abdülmuttalib'in vefatı", ikon: "👴" },
    { yil: "596", olay: "Hz. Hatice validemiz ile evliliği ve ticari ortaklığı", ikon: "💍" },
    { yil: "605", olay: "Kâbe Hakemliği (Hacerü'l-Esved'in yerine konması)", ikon: "🕋" },
    { yil: "610", olay: "İlk Vahiy ve Peygamberlik Görevinin Başlaması (Cebrail ile Hira'da)", ikon: "📖" },
    { yil: "615", olay: "Baskılar nedeniyle Habeşistan'a ilk hicretin gerçekleşmesi", ikon: "⛵" },
    { yil: "619", olay: "Hüzün Yılı (Amcası Ebu Talib ve Eşi Hz. Hatice'nin vefatı)", ikon: "🖤" },
    { yil: "620", olay: "İsra ve Miraç Mucizesi", ikon: "✨" },
    { yil: "622", olay: "Akabe Biatları ve Medine'ye Büyük Hicret", ikon: "🐫" },
    { yil: "624", olay: "Müşriklere karşı Bedir Savaşı Zaferi", ikon: "⚔️" },
    { yil: "625", olay: "Uhud Savaşı ve Hz. Hamza'nın şehit edilişi", ikon: "🛡️" },
    { yil: "627", olay: "Hendek Savaşı ve savunma hattının kurulması", ikon: "🪵" },
    { yil: "628", olay: "Hudeybiye Barış Antlaşması ve Hayber Kalesi'nin Fethi", ikon: "📜" },
    { yil: "630", olay: "Mekke'nin Fethi ve Kâbe'nin putlardan arındırılması", ikon: "🔓" },
    { yil: "632", olay: "Veda Haccı, Veda Hutbesi ve Peygamberimiz'in vefatı", ikon: "🕌" }
  ],
  hadisler_secme: [
    { no: 1, metin: "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.", kaynak: "Buhârî, İlim, 11" },
    { no: 2, metin: "İnsanların en hayırlısı, insanlara faydalı olanıdır.", kaynak: "Taberânî, el-Mu'cemü'l-Evsat" },
    { no: 3, metin: "Müslüman, dilinden ve elinden Müslümanların güvende olduğu kimsedir.", kaynak: "Buhârî, Îmân, 4" },
    { no: 4, metin: "Sizden biriniz, kendisi için istediğini din kardeşi için de istemedikçe tam iman etmiş olmaz.", kaynak: "Buhârî, Îmân, 7" },
    { no: 5, metin: "Dua, ibadetin özüdür.", kaynak: "Tirmizî, Tefsîru Sûre, 40" },
    { no: 6, metin: "Temizlik, imanın yarısıdır.", kaynak: "Müslim, Tahâret, 1" },
    { no: 7, metin: "Hiçbir anne baba, evladına güzel ahlaktan daha değerli bir miras bırakamaz.", kaynak: "Tirmizî, Birr, 33" },
    { no: 8, metin: "Gerçek zenginlik mal çokluğu ile değildir. Gerçek zenginlik gönül zenginliğidir.", kaynak: "Buhârî, Rikâk, 15" },
    { no: 9, metin: "Güzel söz söylemek sadakadır.", kaynak: "Buhârî, Cihâd, 128" },
    { no: 10, metin: "Allah katında amellerin en sevimlisi, az da olsa devamlı olanıdır.", kaynak: "Buhârî, Rikâk, 18" }
  ]
};
