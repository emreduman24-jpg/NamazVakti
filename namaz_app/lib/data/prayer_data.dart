// Namaz Vakitleri & Dini Bilgiler - Veri Katmanı (Dart)

const List<Map<String, String>> DINI_GUNLER = [
  {"tarih": "15 Ocak 2026", "gun": "Perşembe", "ad": "Miraç Kandili"},
  {"tarih": "2 Şubat 2026", "gun": "Pazartesi", "ad": "Berat Kandili"},
  {"tarih": "19 Şubat 2026", "gun": "Perşembe", "ad": "Ramazan Başlangıcı"},
  {"tarih": "16 Mart 2026", "gun": "Pazartesi", "ad": "Kadir Gecesi"},
  {"tarih": "19 Mart 2026", "gun": "Perşembe", "ad": "Ramazan Bayramı Arefesi"},
  {"tarih": "20 Mart 2026", "gun": "Cuma", "ad": "Ramazan Bayramı (1. Gün)"},
  {"tarih": "21 Mart 2026", "gun": "Cumartesi", "ad": "Ramazan Bayramı (2. Gün)"},
  {"tarih": "22 Mart 2026", "gun": "Pazar", "ad": "Ramazan Bayramı (3. Gün)"},
  {"tarih": "26 Mayıs 2026", "gun": "Salı", "ad": "Kurban Bayramı Arefesi"},
  {"tarih": "27 Mayıs 2026", "gun": "Çarşamba", "ad": "Kurban Bayramı (1. Gün)"},
  {"tarih": "28 Mayıs 2026", "gun": "Perşembe", "ad": "Kurban Bayramı (2. Gün)"},
  {"tarih": "29 Mayıs 2026", "gun": "Cuma", "ad": "Kurban Bayramı (3. Gün)"},
  {"tarih": "30 Mayıs 2026", "gun": "Cumartesi", "ad": "Kurban Bayramı (4. Gün)"},
  {"tarih": "16 Haziran 2026", "gun": "Salı", "ad": "Hicri Yılbaşı (1 Muharrem 1448)"},
  {"tarih": "25 Haziran 2026", "gun": "Perşembe", "ad": "Aşure Günü"},
  {"tarih": "24 Ağustos 2026", "gun": "Pazartesi", "ad": "Mevlid Kandili"},
  {"tarih": "10 Aralık 2026", "gun": "Perşembe", "ad": "Regaib Kandili"}
];

const List<Map<String, String>> VAKTIN_AYETLERI = [
  {
    "title": "Bakara - 152. Ayet",
    "text": "Öyleyse siz beni anın ki ben de sizi anayım. Bana şükredin; sakın nankörlük etmeyin.",
    "ref": "Bakara - 152"
  },
  {
    "title": "Bakara - 186. Ayet",
    "text": "Kullarım sana beni sorduklarında bilsinler ki ben onlara çok yakınım. Bana dua edenin duasına icabet ederim.",
    "ref": "Bakara - 186"
  },
  {
    "title": "İnşirah - 5-6. Ayet",
    "text": "Şüphesiz zorlukla beraber bir kolaylık vardır. Gerçekten, zorlukla beraber bir kolaylık vardır.",
    "ref": "İnşirah - 5-6"
  },
  {
    "title": "Âl-i İmrân - 139. Ayet",
    "text": "Gevşemeyin, hüzünlenmeyin. Eğer gerçekten inanıyorsanız üstün olan sizsinizdir.",
    "ref": "Âl-i İmrân - 139"
  },
  {
    "title": "Ankebut - 45. Ayet",
    "text": "Şüphesiz namaz, insanı hayasızlıktan ve kötülükten alıkoyar. Allah'ı anmak ise en büyük ibadettir.",
    "ref": "Ankebut - 45"
  },
  {
    "title": "Casiye - 19. Ayet",
    "text": "Şüphesiz Allah, takva sahiplerinin dostu ve koruyucusudur.",
    "ref": "Casiye - 19"
  },
  {
    "title": "Rad - 28. Ayet",
    "text": "Bilesiniz ki gönüller ancak Allah'ı anmakla huzur ve doyum bulur.",
    "ref": "Rad - 28"
  },
  {
    "title": "Bakara - 286. Ayet",
    "text": "Allah hiçbir kimseye gücünün yeteceğinden fazlasını yüklemez.",
    "ref": "Bakara - 286"
  },
  {
    "title": "Tevbe - 40. Ayet",
    "text": "Üzülme, çünkü Allah bizimle beraberdir.",
    "ref": "Tevbe - 40"
  },
  {
    "title": "Tevbe - 128. Ayet",
    "text": "Andolsun size kendinizden öyle bir peygamber gelmiştir ki sizin sıkıntıya uğramanız ona çok ağır gelir.",
    "ref": "Tevbe - 128"
  },
  {
    "title": "Âl-i İmrân - 159. Ayet",
    "text": "Kararını verdiğin zaman artık Allah'a dayanıp güven. Şüphesiz Allah kendisine dayanıp güvenenleri sever.",
    "ref": "Âl-i İmrân - 159"
  },
  {
    "title": "Nahl - 90. Ayet",
    "text": "Şüphesiz Allah; adaleti, iyilik yapmayı, yakınlara yardım etmeyi emreder; hayasızlığı, fenalığı ve azgınlığı yasaklar.",
    "ref": "Nahl - 90"
  },
  {
    "title": "İsra - 23. Ayet",
    "text": "Rabbin, sadece kendisine kulluk etmenizi ve anne babanıza iyi davranmanızı kesin olarak emretti.",
    "ref": "İsra - 23"
  },
  {
    "title": "İsra - 80. Ayet",
    "text": "De ki: Rabbim! Gireceğim yere doğruluk ve esenlikle girmemi sağla; çıkacağım yerden de doğruluk ve esenlikle çıkmamı nasip eyle.",
    "ref": "İsra - 80"
  },
  {
    "title": "İsra - 82. Ayet",
    "text": "Biz Kur'an'dan, inananlar için şifa ve rahmet olan şeyler indiriyoruz.",
    "ref": "İsra - 82"
  },
  {
    "title": "Kehf - 10. Ayet",
    "text": "Rabbimiz! Bize katından bir rahmet ver ve içinde bulunduğumuz şu durumdan bize bir kurtuluş ve doğruluğa ulaşış yolu hazırla!",
    "ref": "Kehf - 10"
  },
  {
    "title": "Furkan - 74. Ayet",
    "text": "Rabbimiz! Eşlerimizi ve çocuklarımızı bize göz aydınlığı kıl ve bizi takva sahiplerine önder eyle.",
    "ref": "Furkan - 74"
  },
  {
    "title": "Şuara - 80. Ayet",
    "text": "Hastalandığım zaman bana şifa veren O'dur.",
    "ref": "Şuara - 80"
  },
  {
    "title": "Neml - 62. Ayet",
    "text": "Darda kalana, dua ettiği zaman icabet eden ve sıkıntıyı gideren kimdir?",
    "ref": "Neml - 62"
  },
  {
    "title": "Zümer - 53. Ayet",
    "text": "De ki: Ey kendilerinin aleyhine aşırı giden kullarım! Allah'ın rahmetinden ümidinizi kesmeyin. Şüphesiz Allah bütün günahları bağışlar.",
    "ref": "Zümer - 53"
  },
  {
    "title": "Şura - 30. Ayet",
    "text": "Başınıza gelen her musibet kendi ellerinizle işledikleriniz yüzündendir; bununla beraber Allah birçoğunu da affeder.",
    "ref": "Şura - 30"
  },
  {
    "title": "Feth - 4. Ayet",
    "text": "İmanlarını bir kat daha artırsınlar diye müminlerin kalplerine huzur ve güven indiren O'dur.",
    "ref": "Feth - 4"
  },
  {
    "title": "Hucurat - 10. Ayet",
    "text": "Müminler ancak kardeştirler. Öyleyse kardeşlerinizin arasını düzeltin ve Allah'a karşı gelmekten sakının ki size merhamet edilsin.",
    "ref": "Hucurat - 10"
  },
  {
    "title": "Hucurat - 12. Ayet",
    "text": "Ey iman edenler! Zannın birçoğundan kaçının. Çünkü zannın bir kısmı günahtır. Birbirinizin kusurunu araştırmayın.",
    "ref": "Hucurat - 12"
  },
  {
    "title": "Kaf - 16. Ayet",
    "text": "Andolsun insanı biz yarattık ve nefsinin ona ne fısıldadığını biliriz. Çünkü biz ona şah damarından daha yakınız.",
    "ref": "Kaf - 16"
  },
  {
    "title": "Hadid - 4. Ayet",
    "text": "Nerede olursanız olun O, sizinle beraberdir. Allah yaptıklarınızı hakkıyla görendir.",
    "ref": "Hadid - 4"
  },
  {
    "title": "Hasr - 22. Ayet",
    "text": "O, kendisinden başka hiçbir ilah olmayan Allah'tır. Gaybı da görünen alemi de bilendir. O, Rahman'dır, Rahim'dir.",
    "ref": "Hasr - 22"
  },
  {
    "title": "Cuma - 9. Ayet",
    "text": "Ey iman edenler! Cuma günü namaz için çağrı yapıldığı zaman hemen Allah'ı anmaya koşun ve alışverişi bırakın.",
    "ref": "Cuma - 9"
  },
  {
    "title": "Talak - 3. Ayet",
    "text": "Kim Allah'a tevekkül ederse O, ona kafidir. Şüphesiz Allah, emrini yerine getirendir.",
    "ref": "Talak - 3"
  },
  {
    "title": "Tin - 4. Ayet",
    "text": "Şüphesiz biz insanı en güzel biçimde (ahsen-i takvim) yarattık.",
    "ref": "Tin - 4"
  },
  {
    "title": "Alak - 1. Ayet",
    "text": "Yaratan Rabbinin adıyla oku!",
    "ref": "Alak - 1"
  },
  {
    "title": "Asr - 1-3. Ayet",
    "text": "Asra yemin olsun ki insan mutlaka ziyandadır. Ancak iman edip salih amel işleyenler, birbirlerine hakkı ve sabrı tavsiye edenler müstesna.",
    "ref": "Asr - 1-3"
  },
  {
    "title": "Taha - 25-26. Ayet",
    "text": "Rabbim! Göğsümü genişlet, işimi kolaylaştır.",
    "ref": "Taha - 25-26"
  },
  {
    "title": "Neml - 19. Ayet",
    "text": "Rabbim! Bana ve anne babama verdiğin nimete şükretmemi ve razı olacağın salih ameller işlememi bana nasip eyle.",
    "ref": "Neml - 19"
  },
  {
    "title": "Kadir - 3. Ayet",
    "text": "Kadir gecesi, bin aydan daha hayırlıdır.",
    "ref": "Kadir - 3"
  },
  {
    "title": "İbrahim - 7. Ayet",
    "text": "Andolsun eğer şükrederseniz elbette size nimetimi artırırım.",
    "ref": "İbrahim - 7"
  },
  {
    "title": "Bakara - 153. Ayet",
    "text": "Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.",
    "ref": "Bakara - 153"
  },
  {
    "title": "Enam - 162. Ayet",
    "text": "De ki: Şüphesiz benim namazım da ibadetlerim de yaşamam da ölümüm de alemlerin Rabbi olan Allah içindir.",
    "ref": "Enam - 162"
  },
  {
    "title": "Nisa - 36. Ayet",
    "text": "Allah'a ibadet edin ve O'na hiçbir şeyi ortak koşmayın. Anne babaya, akrabaya, yetimlere, yoksullara iyi davranın.",
    "ref": "Nisa - 36"
  },
  {
    "title": "Nisa - 103. Ayet",
    "text": "Şüphesiz namaz, müminler üzerine belirli vakitlere bağlı olarak farz kılınmıştır.",
    "ref": "Nisa - 103"
  },
  {
    "title": "Enbiya - 107. Ayet",
    "text": "Biz seni ancak alemlere rahmet olarak gönderdik.",
    "ref": "Enbiya - 107"
  },
  {
    "title": "Muminun - 118. Ayet",
    "text": "Rabbim! Bağışla, merhamet et. Sen merhamet edenlerin en hayırlısısın.",
    "ref": "Muminun - 118"
  },
  {
    "title": "Yusuf - 86. Ayet",
    "text": "Ben tasa ve üzüntümü ancak Allah'a arz ederim.",
    "ref": "Yusuf - 86"
  },
  {
    "title": "Araf - 180. Ayet",
    "text": "En güzel isimler (Esmaü'l-Hüsna) Allah'ındır. O halde O'na bu güzel isimlerle dua edin.",
    "ref": "Araf - 180"
  },
  {
    "title": "Araf - 205. Ayet",
    "text": "Rabbini, içinden, yalvararak ve korkarak, yüksek olmayan bir sesle sabah akşam an; gafillerden olma.",
    "ref": "Araf - 205"
  },
  {
    "title": "Enfal - 2. Ayet",
    "text": "Müminler ancak o kimselerdir ki; Allah anıldığı zaman kalpleri ürperir, O'nun ayetleri kendilerine okunduğu zaman imanlarını artırır.",
    "ref": "Enfal - 2"
  },
  {
    "title": "Enfal - 40. Ayet",
    "text": "Bilin ki Allah sizin mevlanızdır. O ne güzel mevla, ne güzel yardımcıdır!",
    "ref": "Enfal - 40"
  },
  {
    "title": "Yunus - 62. Ayet",
    "text": "Bilesiniz ki Allah'ın dostlarına hiçbir korku yoktur; onlar üzülmeyecekler de.",
    "ref": "Yunus - 62"
  },
  {
    "title": "Hud - 115. Ayet",
    "text": "Sabret, çünkü Allah iyilik yapanların mükafatını asla zayi etmez.",
    "ref": "Hud - 115"
  },
  {
    "title": "Nisa - 110. Ayet",
    "text": "Kim bir kötülük yapar yahut nefsine zulmeder de sonra Allah'tan bağışlanma dilerse, Allah'ı çok bağışlayıcı ve merhametli bulur.",
    "ref": "Nisa - 110"
  },
  {
    "title": "Mülk - 2. Ayet",
    "text": "O, hanginizin daha güzel amel yapacağını sınamak için ölümü ve hayatı yaratandır.",
    "ref": "Mülk - 2"
  },
  {
    "title": "Araf - 56. Ayet",
    "text": "Korkarak ve umarak O'na dua edin. Şüphesiz Allah'ın rahmeti iyilik yapanlara çok yakındır.",
    "ref": "Araf - 56"
  },
  {
    "title": "Mümin - 60. Ayet",
    "text": "Rabbiniz şöyle buyurdu: Bana dua edin, duanıza icabet edeyim.",
    "ref": "Mümin - 60"
  },
  {
    "title": "Ahzab - 35. Ayet",
    "text": "Allah'ı çokça zikreden erkekler ve zikreden kadınlar var ya; işte Allah onlar için bir bağışlanma ve büyük bir mükafat hazırlamıştır.",
    "ref": "Ahzab - 35"
  },
  {
    "title": "Ahzab - 56. Ayet",
    "text": "Şüphesiz Allah ve melekleri Peygamber'e salat ediyorlar. Ey iman edenler! Siz de ona salat edin, samimiyetle selam verin.",
    "ref": "Ahzab - 56"
  },
  {
    "title": "Nur - 35. Ayet",
    "text": "Allah, göklerin ve yerin nurudur.",
    "ref": "Nur - 35"
  },
  {
    "title": "Lokman - 33. Ayet",
    "text": "Ey insanlar! Rabbinize karşı gelmekten sakının. Hiçbir babanın çocuğuna, hiçbir çocuğun da babasına fayda sağlayamayacağı günden korkun.",
    "ref": "Lokman - 33"
  },
  {
    "title": "Secde - 17. Ayet",
    "text": "Yaptıklarına karşılık onlar için göz aydınlığı olacak ne mükafatlar saklandığını hiç kimse bilemez.",
    "ref": "Secde - 17"
  },
  {
    "title": "Duhan - 58. Ayet",
    "text": "Belki düşünüp öğüt alırlar diye biz o Kur'an'ı senin dilinle kolaylaştırdık.",
    "ref": "Duhan - 58"
  },
  {
    "title": "Saf - 13. Ayet",
    "text": "Seveceğiniz başka bir nimet daha var: Allah'tan bir yardım ve yakın bir fetih! Müminleri müjdele.",
    "ref": "Saf - 13"
  }
];

const List<Map<String, String>> VAKTIN_HADISLERI = [
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Ameller ancak niyetlere göredir; herkes niyet ettiği şeyin karşılığını alır.",
    "ref": "Buhari, Bed'ü'l-Vahy 1"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Din samimiyettir (nasihattir).",
    "ref": "Müslim, İman 95"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Sizden biriniz kendisi için istediğini din kardeşi için de istemedikçe tam iman etmiş olmaz.",
    "ref": "Buhari, İman 7"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Hayra vesile olan, o hayrı yapan gibidir.",
    "ref": "Tirmizi, İlim 14"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Müslüman, elinden ve dilinden diğer müslümanların güvende olduğu kimsedir.",
    "ref": "Buhari, İman 4"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.",
    "ref": "Buhari, Cihad 164"
  },
  {
    "title": "Hadis-i Şerif - Beyhaki",
    "text": "İnsanların en hayırlısı, insanlara en çok faydası dokunandır.",
    "ref": "Beyhaki, Şuabü'l-İman 6"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "İki nimet vardır ki insanların çoğu bunda aldanmıştır: Sağlık ve boş vakit.",
    "ref": "Buhari, Rikak 1"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Hiçbir baba evladına güzel ahlaktan daha değerli bir miras bırakamaz.",
    "ref": "Tirmizi, Birr 33"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Temizlik imanın yarısıdır.",
    "ref": "Müslim, Taharet 1"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Nerede olursan ol Allah'tan kork. Kötülüğün peşinden hemen bir iyilik yap ki onu silsin.",
    "ref": "Tirmizi, Birr 55"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Gerçek zenginlik mal çokluğu değil, gönül zenginliğidir.",
    "ref": "Buhari, Rikak 15"
  },
  {
    "title": "Hadis-i Şerif - Ahmed bin Hanbel",
    "text": "Öfkelenen kimse sussun.",
    "ref": "Ahmed b. Hanbel, Müsned 1/239"
  },
  {
    "title": "Hadis-i Şerif - Hakim",
    "text": "Komşusu açken kendisi tok yatan bizden değildir.",
    "ref": "Hakim, Müstedrek 2/15"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Güzel söz sadakadır.",
    "ref": "Buhari, Cihad 128"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Dua ibadetin özüdür.",
    "ref": "Tirmizi, Daavat 1"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Bizi aldatan bizden değildir.",
    "ref": "Müslim, İman 164"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "İman yönünden müminlerin en mükemmeli, ahlakı en güzel olanıdır.",
    "ref": "Tirmizi, Rada 11"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Her kim Allah'a ve ahiret gününe inanıyorsa misafirine ikram etsin.",
    "ref": "Buhari, Edeb 31"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Müslüman müslümanın kardeşidir. Ona zulmetmez, onu yalnız bırakmaz, onu hor görmez.",
    "ref": "Müslim, Birr 58"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Veren el, alan elden daha hayırlıdır.",
    "ref": "Buhari, Zekat 18"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Gözleri haramdan korumak ve dili tutmak, cennete götüren yollardandır.",
    "ref": "Tirmizi, Zühd 6"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Doğruluktan ayrılmayınız. Doğruluk insanı iyiliğe, iyilik de cennete götürür.",
    "ref": "Buhari, Edeb 69"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Birbirinize haset etmeyiniz, birbirinize buğzetmeyiniz ve ey Allah'ın kulları kardeş olunuz.",
    "ref": "Müslim, Birr 23"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Yumuşak huyluluktan mahrum olan, her türlü hayırdan mahrum kalır.",
    "ref": "Müslim, Birr 74"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Küçüklerimize merhamet etmeyen, büyüklerimize saygı göstermeyen bizden değildir.",
    "ref": "Tirmizi, Birr 15"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Mazlumun duasından sakınınız. Çünkü onun duasıyla Allah arasında hiçbir perde yoktur.",
    "ref": "Buhari, Zekat 63"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Her dinin bir ahlakı vardır, İslam'ın ahlakı da hayadır (utanma duygusudur).",
    "ref": "Muvatta, Hüsnü'l-Huluk 9"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Allah sizin dış görünüşünüze ve mallarınıza bakmaz; o sizin kalplerinize ve amellerinize bakar.",
    "ref": "Müslim, Birr 33"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Hiçbiriniz ölüm istemesin. Eğer iyi biriyse iyiliğini artırır, kötüyse tövbe eder.",
    "ref": "Buhari, Temenni 6"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Dünya müminin zindanı, kafirin ise cennetidir.",
    "ref": "Müslim, Zühd 1"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Namaz dinin direğidir.",
    "ref": "Tirmizi, İman 8"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Kulun Rabbine en yakın olduğu an secde anıdır. Secdede duayı çok yapın.",
    "ref": "Müslim, Salat 215"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Sizin en hayırlınız, Kur'an'ı öğrenen ve öğreteninizdir.",
    "ref": "Buhari, Fezailü'l-Kur'an 21"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "İlim talep etmek her müslümana farzdır.",
    "ref": "İbn Mace, Mukaddime 17"
  },
  {
    "title": "Hadis-i Şerif - Ebu Davud",
    "text": "Kolaylaştırın, güçleştirmeyin; müjdeleyin, nefret ettirmeyin.",
    "ref": "Ebu Davud, Edeb 20"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Misvak kullanmak ağzı temizler, Rabb'in rızasını kazandırır.",
    "ref": "Buhari, Savm 27"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Din kardeşinin yüzüne tebessüm etmen bir sadakadır.",
    "ref": "Tirmizi, Birr 36"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Kim bir müminin dünyadaki sıkıntılarından birini giderirse, Allah da onun ahiret sıkıntısını giderir.",
    "ref": "Müslim, Zikir 38"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Cennet annelerin ayakları altındadır.",
    "ref": "Nesai, Cihad 6"
  },
  {
    "title": "Hadis-i Şerif - Ebu Davud",
    "text": "İnsanlara merhamet etmeyene Allah da merhamet etmez.",
    "ref": "Buhari, Tevhid 2"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Kul, kardeşinin yardımında olduğu sürece Allah da kulun yardımındadır.",
    "ref": "Müslim, Zikir 38"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "İçinizde en sevdiğim ve ahirette bana en yakın olanınız, ahlakı en güzel olanınızdır.",
    "ref": "Tirmizi, Birr 71"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Yarım hurmayla da olsa kendinizi cehennem ateşinden koruyun.",
    "ref": "Buhari, Zekat 9"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Komşusu, zararından emin olmayan kimse cennete giremez.",
    "ref": "Müslim, İman 73"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Hakiki mücahit, nefsinin isteklerine karşı cihad edendir.",
    "ref": "Tirmizi, Fezailü'l-Cihad 2"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Şüphesiz Allah temizdir, temizliği sever; cömerttir, cömertliği sever.",
    "ref": "Tirmizi, Edeb 41"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Haset etmekten sakınınız. Çünkü haset, ateşin odunu yiyip tükettiği gibi iyilikleri yer bitirir.",
    "ref": "Ebu Davud, Edeb 44"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "İşçiye ücretini, alnının teri kurumadan veriniz.",
    "ref": "İbn Mace, Rehin 4"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Tevbe eden, hiç günah işlememiş gibidir.",
    "ref": "İbn Mace, Zühd 30"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Her iyilik bir sadakadır.",
    "ref": "Buhari, Edeb 33"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Söz taşıyan (koğuculuk yapan) kimse cennete giremez.",
    "ref": "Buhari, Edeb 49"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Kim din kardeşinin gıyabında onurunu korursa, Allah da kıyamet günü onun yüzünü ateşten korur.",
    "ref": "Tirmizi, Birr 20"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Haksızlık karşısında susan dilsiz şeytandır.",
    "ref": "İbn Kayyim, el-Cevabu'l-Kafi 1/136"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Bir işi emanet aldığınızda onu en güzel şekilde layıkıyla yerine getirin.",
    "ref": "Buhari, Rikak 35"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Mümin bir delikten iki defa ısırılmaz (aynı hatayı iki kez yapmaz).",
    "ref": "Buhari, Edeb 83"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Canım elinde olan Allah'a yemin ederim ki siz iman etmedikçe cennete giremezsiniz; birbirinizi sevmedikçe de tam iman etmiş sayılmazsınız.",
    "ref": "Müslim, İman 93"
  },
  {
    "title": "Hadis-i Şerif - Buhari",
    "text": "Gıpta edilecek iki kişi vardır: Biri Allah'ın verdiği malı hayır yolunda harcayan, diğeri ise Allah'ın verdiği ilimle amel edip onu öğreten.",
    "ref": "Buhari, İlim 15"
  },
  {
    "title": "Hadis-i Şerif - Tirmizi",
    "text": "Kendisini ilgilendirmeyen şeyleri terk etmesi, kişinin müslümanlığının güzelliğindendir.",
    "ref": "Tirmizi, Zühd 11"
  },
  {
    "title": "Hadis-i Şerif - Müslim",
    "text": "Zulüm, kıyamet günü karanlıklar olacaktır. Zulümden sakınınız.",
    "ref": "Müslim, Birr 56"
  }
];

const List<Map<String, String>> GUNUN_ISIMLERI = [
  {"kiz": "Melisa", "erkek": "Eymen"},
  {"kiz": "Zeynep", "erkek": "Ömer"},
  {"kiz": "Elif", "erkek": "Ali"},
  {"kiz": "Defne", "erkek": "Yusuf"},
  {"kiz": "Meryem", "erkek": "Hamza"},
  {"kiz": "Asya", "erkek": "Miraç"},
  {"kiz": "Zehra", "erkek": "Mustafa"},
  {"kiz": "Esra", "erkek": "Alperen"},
  {"kiz": "Fatma", "erkek": "Bilal"},
  {"kiz": "Ayşe", "erkek": "Hasan"},
  {"kiz": "Hatice", "erkek": "Hüseyin"},
  {"kiz": "Rümeysa", "erkek": "İbrahim"},
  {"kiz": "Feyza", "erkek": "Selim"},
  {"kiz": "Beyza", "erkek": "Kerem"},
  {"kiz": "İrem", "erkek": "Taha"},
  {"kiz": "Sena", "erkek": "Yasin"},
  {"kiz": "Büşra", "erkek": "Harun"},
  {"kiz": "Kübra", "erkek": "Yahya"},
  {"kiz": "Azra", "erkek": "Yunus"},
  {"kiz": "Sude", "erkek": "Eren"},
  {"kiz": "Nisa", "erkek": "Furkan"},
  {"kiz": "Ravza", "erkek": "Enes"},
  {"kiz": "Sümeyye", "erkek": "Mert"},
  {"kiz": "Hümeyra", "erkek": "Fatih"},
  {"kiz": "Esma", "erkek": "Yavuz"},
  {"kiz": "Şevval", "erkek": "Tarık"},
  {"kiz": "Ebrar", "erkek": "Arda"},
  {"kiz": "Yağmur", "erkek": "Baran"},
  {"kiz": "Damla", "erkek": "Kaan"},
  {"kiz": "Irmak", "erkek": "Doruk"},
  {"kiz": "Duru", "erkek": "Rüzgar"},
  {"kiz": "Hazal", "erkek": "Burak"},
  {"kiz": "Ceren", "erkek": "Emre"},
  {"kiz": "Tuğba", "erkek": "Hakan"},
  {"kiz": "Rabia", "erkek": "Yakup"},
  {"kiz": "Reyhan", "erkek": "Selman"},
  {"kiz": "Dilara", "erkek": "Halil"},
  {"kiz": "Hilal", "erkek": "Talha"},
  {"kiz": "Aslı", "erkek": "Semih"},
  {"kiz": "Pelin", "erkek": "Ozan"},
  {"kiz": "İpek", "erkek": "Metin"},
  {"kiz": "Gizem", "erkek": "Can"},
  {"kiz": "Gamze", "erkek": "Sinan"},
  {"kiz": "Ece", "erkek": "Cem"},
  {"kiz": "Gözde", "erkek": "Barış"},
  {"kiz": "Melike", "erkek": "Melih"},
  {"kiz": "Şule", "erkek": "Murat"},
  {"kiz": "Leyla", "erkek": "Yiğit"},
  {"kiz": "Havva", "erkek": "Adem"},
  {"kiz": "Sare", "erkek": "İshak"},
  {"kiz": "Hacer", "erkek": "İsmail"},
  {"kiz": "Emine", "erkek": "Ahmet"},
  {"kiz": "Betül", "erkek": "Sait"},
  {"kiz": "Asude", "erkek": "Rıdvan"},
  {"kiz": "Berrin", "erkek": "Ensar"},
  {"kiz": "Ezel", "erkek": "Kuzey"},
  {"kiz": "Derin", "erkek": "Toprak"},
  {"kiz": "Masal", "erkek": "Gökhan"},
  {"kiz": "Doğa", "erkek": "Kadir"},
  {"kiz": "Nihal", "erkek": "Serkan"}
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

const List<Map<String, String>> DUALAR = [];

const List<Map<String, String>> KURAN_DUALARI = [
  // --- SABAH & AKŞAM EZKARI (6) ---
  {
    "id": "kuran_1",
    "kategori": "sabah_aksam",
    "ad": "Felak Suresi – Kötülüklerden Sığınma",
    "sure": "Felak Suresi, 1-5",
    "arapca": "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ﴿١﴾ مِن شَرِّ مَا خَلَقَ ﴿٢﴾ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ﴿٤﴾ وَمِن شَرِّ حاسِدٍ إِذَا حَسَدَ ﴿٥﴾",
    "anlam": "De ki: Yarattığı şeylerin kötülüğünden, karanlığı çöktüğü zaman gecenin kötülüğünden, düğümlere üfleyen büyücülerin kötülüğünden, haset ettiği zaman hasetçinin kötülüğünden, sabahın Rabbine sığınırım.",
    "okunus": "Kul e'ûżu birabbi-lfelak(ı). Min şerri mâ halak(a). Ve min şerri gâsikın iżâ vekab(e). Ve min şerri-nneffâśâti fî-l'ukad(i). Ve min şerri hâsidin iżâ hased(e).",
    "ses": "https://server8.mp3quran.net/afs/113.mp3"
  },
  {
    "id": "kuran_2",
    "kategori": "sabah_aksam",
    "ad": "Nas Suresi – Vesveseden Korunma",
    "sure": "Nas Suresi, 1-6",
    "arapca": "قُل * أَعُوذُ بِرَبِّ النَّاسِ ﴿١﴾ مَلِكِ النَّاسِ ﴿٢﴾ إِلَهِ النَّاسِ ﴿٣﴾ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ﴿٤﴾ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ﴿٥﴾ مِنَ الْجِنَّةِ وَالنَّاسِ ﴿٦﴾",
    "anlam": "De ki: İnsanların kalplerine vesvese sokan, pusuya çekilen cin ve insan vesvesecisinin şerrinden insanların Rabbine, insanların Melik'ine (mutlak sahip ve hakimine), insanların İlahına sığınırım.",
    "okunus": "Kul e'ûżu birabbi-nnâs(i). Meliki-nnâs(i). İlâhi-nnâs(i). Min şerri-lvesvâsi-lhanâs(i). Elleżî yuvesvisu fî sudûri-nnâs(i). Mine-lcinneti vennâs(i).",
    "ses": "https://server8.mp3quran.net/afs/114.mp3"
  },
  {
    "id": "kuran_3",
    "kategori": "sabah_aksam",
    "ad": "Âyetü'l-Kürsî",
    "sure": "Bakara Suresi, 255",
    "arapca": "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهِمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ",
    "anlam": "Allah, O'ndan başka ilah yoktur; diridir, her şeyi yönetendir. O'nu ne bir uyuklama ne de bir uyku tutar. Göklerde ve yerde ne varsa hepsi O'nundur. İzni olmadan O'nun katında kim şefaat edebilir? O, kullarının önlerindekini ve arkalarındakini bilir. Onlar O'nun ilminden, kendisinin dilediği kadarından başka bir şey kavrayamazlar. O'nun kürsüsü gökleri ve yeri kaplamıştır. Onları koruyup gözetmek O'na zor gelmez. O, yücedir, büyüktür.",
    "okunus": "Allâhu lâ ilâhe illâ huve-lhayyu-lkayyûm(u), lâ te’ḣużuhu sinetun velâ nevm(un), lehu mâ fî-ssemâvâti vemâ fî-l-ard(i), men żê-lleżî yeşfeu ‘indehu illâ bi-iżnih(i), ya’lemu mâ beyne eydîhim vemâ ḣelfehum, velâ yuhîtûne bişey-in min ‘ilmihi illâ bimâ şâ(e), vesi’a kursiyyuhu-ssemâvâti vel-ard(a), velâ yeûduhu hıfżuhumâ, vehuve-l’aliyyu-l’aẓîm(u).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/002255.mp3"
  },
  {
    "id": "kuran_4",
    "kategori": "sabah_aksam",
    "ad": "İhlas Suresi – Tevhid Beyanı",
    "sure": "İhlas Suresi, 1-4",
    "arapca": "قُلْ هُوَ اللَّهُ أَحَدٌ ﴿١﴾ اللَّهُ الصَّمَدُ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿٣﴾ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ ﴿٤﴾",
    "anlam": "De ki: O Allah tektir. Allah sameddir (her şey O'na muhtaçtır, O hiçbir şeye muhtaç değildir). O'ndan çocuk olmamıştır ve Kendisi de doğmamıştır. Hiçbir şey O'nun dengi olmamıştır.",
    "okunus": "Kul huvallâhu ehad(un). Allâhu-ssamed(u). Lem yelid ve lem yûled. Ve lem yekun lehu kufuven ehad(un).",
    "ses": "https://server8.mp3quran.net/afs/112.mp3"
  },
  {
    "id": "kuran_5",
    "kategori": "sabah_aksam",
    "ad": "Şeytandan Sığınma Duası",
    "sure": "Mü'minûn Suresi, 97-98",
    "arapca": "وَقُلْ رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ ﴿٩٧﴾ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ ﴿٩٨﴾",
    "anlam": "De ki: 'Rabbim! Şeytanların kışkırtmalarından sana sığınırım. Rabbim! Onların yanımda bulunmalarından da sana sığınırım.'",
    "okunus": "Ve kul rabbi e'ûżu bike min hemezâti-şşeyâtîn(i). Ve e'ûżu bike rabbi en yahdurûn(i).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/023097.mp3"
  },
  {
    "id": "kuran_6",
    "kategori": "sabah_aksam",
    "ad": "Haşr Suresi Son 3 Ayet – Allah'ın Gücü ve İsimleri",
    "sure": "Haşr Suresi, 22-24",
    "arapca": "هُوَ اللَّهُ الَّذِي لَا إِلَهَ إِلَّا هُوَ عَالِمُ الْغَيْبِ وَالشَّهَادَةِ هُوَ الرَّحْمَنُ الرَّحِيمُ ﴿٢٢﴾ هُوَ اللَّهُ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْمَلِكُ الْقُدُّوسُ السَّلَامُ الْمُؤْمِنُ الْمُهَيْمِنُ الْعَزِيزُ الْجَبَّارُ الْمُتَكَبِّرُ سُبْحَانَ اللَّهِ عَمَّا يُشْرِكُونَ ﴿٢٣﴾ هُوَ اللَّهُ الْخَالِقُ الْبَارِئُ الْمُصَوِّرُ لَهُ الْأَسْمَاءُ الْحُسْنَى يُسَبِّحُ لَهُ مَا فِي السَّمَاوَاتِ وَالْأَرْضِ وَهُوَ الْعَزِيزُ الْحَكِيمُ ﴿٢٤﴾",
    "anlam": "O, kendisinden başka hiçbir ilah olmayan Allah’tır. Gaybı da, görünen âlemi de bilendir. O, Rahmân’dır, Rahîm’dir. O, kendisinden başka hiçbir ilah olmayan Allah’tır. Egemenliğin mutlak sahibidir, her türlü eksiklikten uzaktır, esenlik verendir, güven sağlayandır, her şeyi gözetip koruyandır, mutlak güç sahibidir, dilediğini zorla yaptıran ve büyüklükte eşi olmayandır. Allah, ortak koştuklarından uzaktır. O, yaratan, yoktan var eden, şekil veren Allah’tır. En güzel isimler O’nundur. Göklerdeki ve yerdeki her şey O’nu tesbih eder. O, mutlak güç sahibidir, hüküm ve hikmet sahibidir.",
    "okunus": "Huvallâhullezî lâ ilâhe illâ huve, ‘âlimul-gaybi veş-şehâdeti, huver-rahmânur-rahîm(u). Huvallâhullezî lâ ilâhe illâ huve, el-melikul-kuddûsus-selâmul-mu’minul-muheyminul-’azîzul-cebbârul-mutekebbir(u), subhânallâhi ‘ammâ yuşrikûn(e). Huvallâhul-hâlikul-bâriul-musavviru lehul-esmâul-husnâ, yusebbihu lehu mâ fis-semâvâti vel-ard(i), ve huvel-’azîzul-hakîm(u).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/059022.mp3"
  },

  // --- NAMAZ DUALARI (5) ---
  {
    "id": "kuran_7",
    "kategori": "namaz",
    "ad": "Rabbena Âtina – Dünya ve Ahiret Güzelliği",
    "sure": "Bakara Suresi, 201",
    "arapca": "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
    "anlam": "Rabbimiz! Bize dünyada da iyilik, güzellik ver, ahirette de iyilik, güzellik ver ve bizi cehennem azabından koru.",
    "okunus": "Rabbenâ âtinâ fi-ddunyâ haseneten ve fî-l-âḣirati haseneten vekınâ ‘ażâbe-nnâr(i).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/002201.mp3"
  },
  {
    "id": "kuran_8",
    "kategori": "namaz",
    "ad": "Fatiha Suresi – Namazın Temeli",
    "sure": "Fatiha Suresi, 1-7",
    "arapca": "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ ﴿١﴾ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿٢﴾ الرَّحْمَنِ الرَّحِيمِ ﴿٣﴾ مَالِكِ يَوْمِ الدِّينِ ﴿٤﴾ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿٥﴾ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ﴿٦﴾ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ﴿٧﴾",
    "anlam": "Rahman ve Rahim olan Allah'ın adıyla. Hamd, Alemlerin Rabbi Allah'a mahsustur. O, Rahman'dır, Rahim'dir. Din gününün (hesap gününün) malikidir. Ancak sana kulluk eder ve ancak senden yardım dileriz. Bizi dosdoğru yola ilet. Nimet verdiğin kimselerin yoluna ilet; gazaba uğramışların ve sapmışların yoluna değil.",
    "okunus": "Bismillâhi-rrahmâni-rrahîm(i). Elhamdu lillâhi rabbi-l'âlemîn(e). Errahmâni-rrahîm(i). Mâliki yevmi-ddîn(i). İyyâke na'budu ve iyyâke neste'în(u). İhdinâ-ssırâta-lmustekîm(e). Sırâtalleżîne en'amte 'aleyhim gayri-lmagdûbi 'aleyhim veladdâllîn(e).",
    "ses": "https://server8.mp3quran.net/afs/001.mp3"
  },
  {
    "id": "kuran_9",
    "kategori": "namaz",
    "ad": "Af ve Rahmet Duası",
    "sure": "Mü'minûn Suresi, 118",
    "arapca": "وَقُلْ رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ خَيْرُ الرَّاحِمِينَ",
    "anlam": "De ki: 'Rabbim! Bağışla, merhamet et. Sen merhamet edenlerin en hayırlısısın.'",
    "okunus": "Ve kul rabbi-gfir verham ve ente ḣayru-rrâhımîn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/023118.mp3"
  },
  {
    "id": "kuran_10",
    "kategori": "namaz",
    "ad": "Kâbe Duası – Hz. İbrahim ve İsmail'in Yakınışı",
    "sure": "Bakara Suresi, 127-128",
    "arapca": "رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ ﴿١٢٧﴾ رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِنْ ذُرِّيَّتِنَا أُمَّةً مُسْلِمَةً لَكَ وَأَرِنَا مَنَاسِكَنَا وَتُبْ عَلَيْنَا إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ ﴿١٢٨﴾",
    "anlam": "Rabbimiz! Bizden kabul buyur. Şüphesiz sen her şeyi işitensin, bilensin. Rabbimiz! Bizi sana teslim olmuş kimseler kıl. Neslimizden de sana teslim olmuş bir ümmet çıkar. Bize ibadet ibadet yerlerimizi göster, tövbemizi kabul et. Şüphesiz tövbeleri çok kabul eden, merhameti bol olan sensin.",
    "okunus": "Rabbenâ tekabbel minnâ, inneke ente-ssemî'u-l'alîm(u). Rabbenâ vec'alnâ muslimeyni leke ve min żurriyyetinâ ummeten muslimeten lek(e), ve erinâ menâsikenâ ve tub 'aleynâ, inneke ente-ttevvâbu-rrahîm(u).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/002127.mp3"
  },
  {
    "id": "kuran_11",
    "kategori": "namaz",
    "ad": "İbrahim Suresi – Namaz ve Anne-Baba Duası",
    "sure": "İbrahim Suresi, 40-41",
    "arapca": "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ ﴿٤٠﴾ رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمINِينَ يَوْمَ يَقُومُ الْحِسَابُ ﴿٤١﴾",
    "anlam": "Rabbim! Beni ve neslimden gelecek olanları namazı devamlı kılanlardan eyle. Rabbimiz! Duamı kabul et. Rabbimiz! Hesabın görüleceği gün beni, anne-babamı ve tüm inananları bağışla.",
    "okunus": "Rabbi-c'alnî mukîme-ssalâti ve min żurriyyetî, rabbenâ ve tekabbel du'â'(i). Rabbenâ-gfir lî velivâlideyye velilmû'minîne yevme yekûmu-lhisâb(u).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/014040.mp3"
  },

  // --- UYKU DUALARI (3) ---
  {
    "id": "kuran_12",
    "kategori": "uyku",
    "ad": "Kâfirûn Suresi – Yatmadan Önce Şirkten Uzaklaşma",
    "sure": "Kâfirûn Suresi, 1-6",
    "arapca": "قُلْ يَا أَيُّهَا الْكَافِرُونَ ﴿١﴾ لَا أَعْبُدُ مَا تَعْبُدُونَ ﴿٢﴾ وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ ﴿٣﴾ وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ ﴿٤﴾ وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ ﴿٥﴾ لَكُمْ دِينُكُمْ وَلِيَ دِينِ ﴿٦﴾",
    "anlam": "De ki: Ey inkârcılar! Ben sizin tapmakta olduğunuz şeylere tapmam. Siz de benim tapmakta olduğuma tapıcılar değilsiniz. Ben sizin taptıklarınıza tapacak değilim. Siz de benim tapmakta olduğuma tapacak değilsiniz. Sizin dininiz size, benim dinim banadır.",
    "okunus": "Kul yâ eyyuhe-lkâfirûn(e). Lâ a'budu mâ ta'budûn(e). Velâ entum 'âbidûne mâ a'bud(u). Velâ ene 'âbidun mâ 'abedtum. Velâ entum 'âbidûne mâ a'bud(u). Lekum dînukum veliye dîn(i).",
    "ses": "https://server8.mp3quran.net/afs/109.mp3"
  },
  {
    "id": "kuran_13",
    "kategori": "uyku",
    "ad": "Âmenerrasûlü – Bakara'nın Son İki Ayeti",
    "sure": "Bakara Suresi, 285",
    "arapca": "آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ وَقَالُوا سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْهِ الْمَصِيرُ",
    "anlam": "Peygamber, Rabbinden kendisine indirilene iman etti, müminler de. Her biri; Allah'a, meleklerine, kitaplarına ve peygamberlerine iman ettiler ve 'O'nun peygamberlerinden hiçbirini diğerinden ayırt etmeyiz' dediler. Şöyle de dediler: 'İşittik ve itaat ettik. Ey Rabbimiz! Bağışlamanı dileriz. Dönüş ancak sanadır.'",
    "okunus": "Âmene-rrasûlu bimâ unzile ileyhi min rabbihi velmû'minûn(e), kullun âmene billâhi ve melâiketihi ve kutubihi ve rusulih(i), lâ nuferriku beyne ehadin min rusulih(i), ve kâlû semi'nâ ve ata'nâ gufrâneke rabbenâ ve ileyke-lmasîr(u).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/002285.mp3"
  },
  {
    "id": "kuran_14",
    "kategori": "uyku",
    "ad": "Mülk Suresi – Kabir Azabından Korunma",
    "sure": "Mülk Suresi, 1",
    "arapca": "تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ ﴿١﴾",
    "anlam": "Hükümranlık elinde olan Allah yücedir. O, her şeye hakkıyla gücü yetendir.",
    "okunus": "Tebârakelleżî biyedihi-lmulku vehuve 'alâ kulli şey-in kadîr(un).",
    "ses": "https://server8.mp3quran.net/afs/067.mp3"
  },

  // --- YOLCULUK DUALARI (2) ---
  {
    "id": "kuran_15",
    "kategori": "yolculuk",
    "ad": "Yolculuk Bismillahı – Hz. Nuh'un Gemisindeki Zikir",
    "sure": "Hûd Suresi, 41",
    "arapca": "وَقَالَ ارْكَبُوا فِيهَا بِسْمِ اللَّهِ مَجْرَاهَا وَمُرْسَاهَا إِنَّ رَبِّي لَغَفُورٌ رَحِيمٌ",
    "anlam": "(Nuh) dedi ki: 'Ona binin. Onun yüzüp gitmesi de durması da Allah'ın adıyladır. Şüphesiz Rabbim çok bağışlayandır, çok merhamet edendir.'",
    "okunus": "Ve kâle-rkebû fîhâ bismillâhi mecrâhâ ve mursâhâ, inne rabbî legafûrun rahîm(un).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/011041.mp3"
  },
  {
    "id": "kuran_16",
    "kategori": "yolculuk",
    "ad": "Yolculuk Duası – Bineğe Binince Okunacak Ayet",
    "sure": "Zuhruf Suresi, 13-14",
    "arapca": "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ ﴿١٣﴾ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ ﴿١٤﴾",
    "anlam": "Bunu bizim hizmetimize veren Allah eksikliklerden uzaktır, yoksa bizim buna gücümüz yetmezdi. Biz şüphesiz Rabbimize döneceğiz.",
    "okunus": "Subhânelleżî sehhara lenâ hâżâ vemâ kunnâ lehu mukrinîn(e). Ve innâ ilâ rabbinâ lemunkalibûn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/043013.mp3"
  },

  // --- GENEL DUALAR (20) ---
  {
    "id": "kuran_17",
    "kategori": "genel",
    "ad": "Hz. Yunus Duası – Sıkıntıdan Kurtuluş Reçetesi",
    "sure": "Enbiya Suresi, 87",
    "arapca": "لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
    "anlam": "Senden başka hiçbir ilah yoktur. Seni eksikliklerden uzak tutarım. Ben gerçekten nefsine zulmedenlerden oldum.",
    "okunus": "Lâ ilâhe illâ ente subhâneke innî kuntu mine-ẓẓâlimîn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/021087.mp3"
  },
  {
    "id": "kuran_18",
    "kategori": "genel",
    "ad": "İnşirah Suresi – Zorlukla Beraber Kolaylık",
    "sure": "İnşirah Suresi, 1-8",
    "arapca": "أَلَمْ نَشْرَحْ لَكْ صَدْرَكْ ﴿١﴾ وَوَضَعْنَا عَنكَ وِزْرَكْ ﴿٢﴾ الَّذِي أَنقَضَ ظَهْرَكْ ﴿٣﴾ وَرَفَعْنَا لَكْ ذِكْرَكْ ﴿٤﴾ فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٥﴾ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٦﴾ فَإِذَا فَرَغْتَ فَانصَبْ ﴿٧﴾ وَإِلَىٰ رَبِّكَ فَارْغَب ﴿٨﴾",
    "anlam": "Senin göğsünü açıp genişletmedik mi? Belini büken yükünü üzerinden kaldırmadık mi? Senin şanını yüceltmedik mi? Şüphesiz zorlukla beraber bir kolaylık vardır. Gerçekten zorlukla beraber bir kolaylık vardır. Öyleyse, bir işi bitirince diğerine koyul. Ve ancak Rabbine yönel.",
    "okunus": "Elem neşrah leke sadrak(a). Ve veda'nâ 'anke vizrak(e). Elleżî enkada zahrak(e). Ve rafa'nâ leke żikrak(e). Fe-inne me'a-l'usri yusrâ(n). İnne me'a-l'usri yusrâ(n). Fe-iżâ feragte fensab. Ve ilâ rabbike fergab.",
    "ses": "https://server8.mp3quran.net/afs/094.mp3"
  },
  {
    "id": "kuran_19",
    "kategori": "genel",
    "ad": "Hz. Âdem Tövbe Duası",
    "sure": "A'râf Suresi, 23",
    "arapca": "رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنكُونَنَّ مِنَ الْخَاسِرِينَ",
    "anlam": "Rabbimiz! Biz kendimize zulmettik. Eğer bizi bağışlamaz ve bize merhamet etmezsen şüphesiz ziyana uğrayanlardan oluruz.",
    "okunus": "Rabbenâ zalemnâ enfusenâ ve in lem tegfir lenâ ve terhamnâ lenekûnenne mine-lḣâsirîn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/007023.mp3"
  },
  {
    "id": "kuran_20",
    "kategori": "genel",
    "ad": "Hz. Musa'nın Duası – İşlerin Kolaylaşması",
    "sure": "Tâhâ Suresi, 25-26",
    "arapca": "رَبِّ اشْرَحْ لِي صَدْرِي ﴿٢٥﴾ وَيَسِّرْ لِي أَمْرِي ﴿٢٦﴾",
    "anlam": "Rabbim! Göğsümü genişlet. İşimi bana kolaylaştır.",
    "okunus": "Rabbi-şrah lî sadrî. Ve yessir lî emrî.",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/020025.mp3"
  },
  {
    "id": "kuran_21",
    "kategori": "genel",
    "ad": "Al-i İmran – Hidayet ve Sebat Duası",
    "sure": "Al-i İmran Suresi, 8",
    "arapca": "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ",
    "anlam": "Rabbimiz! Bizi hidayete erdirdikten sonra kalplerimizi saptırma. Bize katından bir rahmet bağışla. Şüphesiz sen çok bağışlayansın.",
    "okunus": "Rabbenâ lâ tuziġ kulûbenâ ba'de iż hedeytenâ veheb lenâ min ledunke rahmet(en), inneke ente-lvehhab(u).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/003008.mp3"
  },
  {
    "id": "kuran_22",
    "kategori": "genel",
    "ad": "Furkan Suresi – Aile ve Nesil Duası",
    "sure": "Furkan Suresi, 74",
    "arapca": "رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا",
    "anlam": "Rabbimiz! Eşlerimizden ve çocuklarımızdan bize göz aydınlığı bağışla. Bizi takva sahiplerine önder kıl.",
    "okunus": "Rabbenâ heb lenâ min ezvâcinâ ve żurriyyâtinâ kurrate a'yunin vec'alnâ lilmuttekîne imâmâ(n).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/025074.mp3"
  },
  {
    "id": "kuran_23",
    "kategori": "genel",
    "ad": "İlim Duası – Rabbi Zidnî İlma",
    "sure": "Tâhâ Suresi, 114",
    "arapca": "رَبِّ زِدْنِي عِلْمًا",
    "anlam": "Rabbim! İlmimi artır.",
    "okunus": "Rabbi zidnî 'ilmâ(n).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/020114.mp3"
  },
  {
    "id": "kuran_24",
    "kategori": "genel",
    "ad": "Rızık Duası – Hz. Musa'nın Yakarışı",
    "sure": "Kasas Suresi, 24",
    "arapca": "رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ",
    "anlam": "Rabbim! Doğrusu bana indireceğin her hayra (rızka) muhtacım.",
    "okunus": "Rabbi innî limâ enzelte ileyye min ḣayrin fakîr(un).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/028024.mp3"
  },
  {
    "id": "kuran_25",
    "kategori": "genel",
    "ad": "Rahmet ve Hidayet Duası – Ashâb-ı Kehf'in Duası",
    "sure": "Kehf Suresi, 10",
    "arapca": "رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا",
    "anlam": "Rabbimiz! Bize katından bir rahmet ver ve şu işimizde doğruya ulaşmayı bize kolaylaştır.",
    "okunus": "Rabbenâ âtinâ min ledunke rahmeten veheyyi' lenâ min emrinâ raşedâ(n).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/018010.mp3"
  },
  {
    "id": "kuran_26",
    "kategori": "genel",
    "ad": "Kardeşlik ve Af Duası",
    "sure": "Haşr Suresi, 10",
    "arapca": "رَبَّنَا اغْفِرْ لَنَا وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا بِالْإِيمَانِ وَلَا تَجْعَلْ فِي قُلُوبَنَا غِلًّا لِلَّذِينَ آمَنُوا رَبَّنَا إِنَّكَ رَءُوفٌ رَحِيمٌ",
    "anlam": "Rabbimiz! Bizi ve bizden önce iman etmiş olan kardeşlerimizi bağışla. Kalplerimizde iman edenlere karşı hiçbir kin bırakma. Rabbimiz! Şüphesiz sen çok şefkatlisin, çok merhametlisin.",
    "okunus": "Rabbenâ-gfir lenâ veli-iḣvâninâ-lleżîne sebekûnâ bil-îmâni velâ tec'al fî kulûbinâ gıllan lilleżîne âmenû rabbenâ inneke raûfun rahîm(un).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/059010.mp3"
  },
  {
    "id": "kuran_27",
    "kategori": "genel",
    "ad": "Anne-Baba ve Müminler İçin Dua",
    "sure": "Nûh Suresi, 28",
    "arapca": "رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَنْ دَخَلَ بَيْتِيَ مُؤْمِنًا وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ",
    "anlam": "Rabbim! Beni, anne-babamı, evime inanmış olarak girenleri, inanan erkek ve kadınları bağışla.",
    "okunus": "Rabbi-gfir lî velivâlideyye velimen deḣale beyriye mû'minen velilmû'minîne velmû'minât(i).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/071028.mp3"
  },
  {
    "id": "kuran_28",
    "kategori": "genel",
    "ad": "Sabır ve Zafer Duası",
    "sure": "Bakara Suresi, 250",
    "arapca": "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
    "anlam": "Rabbimiz! Üzerimize sabır yağdır, adımlarımızı sağlam kıl ve inkârcı topluma karşı bize yardım et.",
    "okunus": "Rabbenâ efriġ 'aleynâ sabran veśebbit akdâmenâ vensurnâ 'alâ-lkavmi-lkâfirîn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/002250.mp3"
  },
  {
    "id": "kuran_29",
    "kategori": "genel",
    "ad": "Doğruluk Duası – Sıdk ile Giriş-Çıkış",
    "sure": "İsrâ Suresi, 80",
    "arapca": "رَبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَل| لِي مِنْ لَدُنْكَ سُلْطَانًا نَصِيرًا",
    "anlam": "Rabbim! Gireceğim yere doğrulukla girmemi sağla, çıkacağım yerden de doğrulukla çıkmamı sağla. Bana katından yardımcı bir güç ver.",
    "okunus": "Rabbi edḣilnî mudḣale sıdkın veeḣricnî muḣrace sıdkın vec'al lî min ledunke sultânen nasîrâ(n).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/017080.mp3"
  },
  {
    "id": "kuran_30",
    "kategori": "genel",
    "ad": "Hz. Süleyman'ın Şükür Duası",
    "sure": "Neml Suresi, 19",
    "arapca": "رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَدْخِلْنِي بِرَحْمَتِكَ فِي عِبَادِكَ الصَّالِحِينَ",
    "anlam": "Rabbim! Bana ve anne-babama verdiğin nimete şükretmemi ve razı olacağın iyi işler yapmamı bana ilham et. Rahmetinle beni salih kullarının arasına kat.",
    "okunus": "Rabbi evzi'nî en eşkura ni'meteke-lletî en'amte 'aleyye ve'alâ vâlideyye ve-en a'mele sâlihan terdâhu veedḣilnî birahmetike fî 'ibâdike-ssâlihîn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/027019.mp3"
  },
  {
    "id": "kuran_31",
    "kategori": "genel",
    "ad": "Hz. Eyyüb'ün Şifa Duası",
    "sure": "Enbiyâ Suresi, 83",
    "arapca": "أَنِّي مَسَّنِيَ الضُّرُّ وَأَنْتَ أَرْحَمُ الرَّاحِمِينَ",
    "anlam": "Şüphesiz bana bir zarar dokundu. Sen merhamet edenlerin en merhametlisin.",
    "okunus": "Ennî messeniyedu-ddurru ve ente erhamu-rrâhımîn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/021083.mp3"
  },
  {
    "id": "kuran_32",
    "kategori": "genel",
    "ad": "Nur Duası – Ahiret Aydınlığı",
    "sure": "Tahrîm Suresi, 8",
    "arapca": "رَبَّنَا أَتْمِمْ لَنَا نُورَنَا وَاغْفِرْ لَنَا إِنَّكَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
    "anlam": "Rabbimiz! Nurumuzu tamamla, bizi bağışla. Şüphesiz sen her şeye kadirsin.",
    "okunus": "Rabbenâ etmim lenâ nûrenâ vegfir lenâ, inneke 'alâ kulli şey-in kadîr(un).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/066008.mp3"
  },
  {
    "id": "kuran_33",
    "kategori": "genel",
    "ad": "Bakara'nın Son Ayeti – Af Duası",
    "sure": "Bakara Suresi, 286",
    "arapca": "رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْtَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
    "anlam": "Rabbimiz! Unutur veya yanılırsak bizi sorumlu tutma. Rabbimiz! Bize, bizden öncekilere yüklediğin gibi ağır bir yük yükleme. Rabbimiz! Bize gücümüzün yetmediği şeyleri de yükleme. Bizi affet, bizi bağışla, bize merhamet et. Sen bizim Mevlamızsın. İnkârcı topluma karşı bize yardım et.",
    "okunus": "Rabbenâ lâ tuâḣiżnâ in nesînâ ev aḣta’nâ, rabbenâ velâ tahmil ‘aleynâ ısran kemâ hameltehu ‘alâ-lleżîne min kablinâ, rabbenâ velâ tuhammilnâ mâ lâ tâkate lenâ bih(i), va’fu ‘annâ vegfir lenâ verhamnâ, ente mevlânâ fensurnâ ‘alâ-lkavmi-lkâfirîn(e).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/002286.mp3"
  },
  {
    "id": "kuran_34",
    "kategori": "genel",
    "ad": "Duha Suresi – Teselli ve Ümit",
    "sure": "Duha Suresi, 1-11",
    "arapca": "وَالضُّحَىٰ ﴿١﴾ وَاللَّيْلِ إِذَا سَجَىٰ ﴿٢﴾ مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ ﴿٣﴾ وَلَلْآخِرَةُ خَيْرٌ لَّكَ مِنَ الْأُولَىٰ ﴿٤﴾ وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ ﴿٥﴾ أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ ﴿٦﴾ وَوَجَدَكَ ضَالًّا فَهَدَىٰ ﴿٧﴾ وَوَجَدَكَ عَائِلًا فَأَغْنَىٰ ﴿٨﴾ فَأَمَّا الْيَتِيمَ فَلَا تَقْهَرْ ﴿٩﴾ وَأَمَّا السَّائِلَ فَلَا تَنْهَرْ ﴿١٠﴾ وَأَمَّا بِنِعْمَتِ رَبِّكَ فَحَدِّثْ ﴿١١﴾",
    "anlam": "Kuşluk vaktine ve sükuna erdiği zaman geceye andolsun ki, Rabbin seni terk etmedi ve sana darılmadı. Gerçekten senin için ahiret dünyadan daha hayırlıdır. Pek yakında Rabbin sana verecek de hoşnut olacaksın. O, seni yetim bulup barındırmadı mı? Seni yolunu kaybetmiş bulup doğru yola iletmedi mi? Seni muhtaç bulup zengin kılmadı mı? Öyleyse yetimi sakın ezme. İsteyeni sakın azarlama. Rabbinin nimetini minnetle an.",
    "okunus": "Vadduhà. Velleyli izâ secà. Mâ vedde'ake rabbuke vemâ kalà. Velel'âhiratu hayrun leke minel'ûlâ. Velesevfe yu'tîke rabbuke feterdà. Elem yecidke yetîmen feâvâ. Vevecedeke dâllen fehedâ. Vevecedeke 'âilen feagnâ. Feemmel yetîme felâ takhar. Veemmes sâile felâ tenhar. Veemmâ bini'meti rabbike fehaddis.",
    "ses": "https://server8.mp3quran.net/afs/093.mp3"
  },
  {
    "id": "kuran_35",
    "kategori": "genel",
    "ad": "Al-i Imran – Mülk ve Kudret Duası",
    "sure": "Al-i Imran Suresi, 26-27",
    "arapca": "قُلِ اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَنْ تَشَاءُ وَتَنْزِعُ الْمُلْكَ مِمَّنْ تَشَاءُ وَتُعِزُّ مَنْ تَشَاءُ وَتُذِلُّ مَنْ تَشَاءُ بِيَدِكَ الْخَيْرُ إِنَّكَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ ﴿٢٦﴾ تُولِجُ اللَّيْلَ فِي النَّهَارِ وَتُولِجُ النَّهَارَ فِي اللَّيْلِ وَتُخْرِجُ الْحَيِّ مِنَ الْمَيِّتِ وَتُخْرِجُ الْمَيِّتَ مِنَ الْحَيِّ وَتَرْزُقُ مَنْ تَشَاءُ بِغَيْرِ hِسَابٍ ﴿٢٧﴾",
    "anlam": "De ki: 'Mülkün sahibi olan Allah'ım! Dilediğine mülkü verirsin, dilediğinden mülkü çekip alırsın. Dilediğini aziz kılar, dilediğini zelil edersin. Hayır senin elindedir. Şüphesiz sen her şeye kadirsin. Geceyi gündüze katarsın, gündüzü geceye katarsın. Diriyi ölüden çıkarırsın, ölüyü diriden çıkarırsın. Dilediğine hesapsız rızık verirsin.'",
    "okunus": "Kuli-llâhumme mâlike-lmulki tu’ti-lmulke men teşâu vetenzi’u-lmulke mimmen teşâ(u), vetu’izzu men teşâu vetużillu men teşâ(u), biyedike-lḣayr(u), inneke ‘alâ kulli şey-in kadîr(un). Tûlicu-lleyle fî-nnehâri vetûlicu-nnehâra fî-lleyl(i), vetuḣriju-lhayye mine-lmeyyiti vetuḣriju-lmeyyite mine-lhayy(i), veterzuku men teşâu bigayri hısâb(in).",
    "ses": "https://www.everyayah.com/data/Alafasy_128kbps/003026.mp3"
  },
  {
    "id": "kuran_36",
    "kategori": "genel",
    "ad": "Asr Suresi – Kurtuluş Reçetesi",
    "sure": "Asr Suresi, 1-3",
    "arapca": "وَالْعَصْرِ ﴿١﴾ إِنَّ الْإِنسَانَ لَفِي خُسْرٍ ﴿٢﴾ إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ ﴿٣﴾",
    "anlam": "Zamana andolsun ki insan gerçekten ziyan içindedir. Ancak iman edip salih ameller işleyenler, birbirlerine hakkı tavsiye edenler ve birbirlerine sabrı tavsiye edenler müstesnadır.",
    "okunus": "Vel'asr(i). İnnel'insâne lefî husr(in). İllellezîne âmenû ve 'amilu-ssâlihâti vetevâsav bilhakkı vetevâsav bissabr(i).",
    "ses": "https://server8.mp3quran.net/afs/103.mp3"
  }
];

const List<Map<String, String>> HADIS_DUALARI = [
  // --- SABAH & AKŞAM EZKARI (4) ---
  {
    "id": "hadis_1",
    "kategori": "sabah_aksam",
    "ad": "Salavat-ı Şerife",
    "sure": "Buhârî, 3370",
    "arapca": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
    "anlam": "Allah'ım! İbrahim'e ve onun ailesine merhamet ettiğin gibi Muhammed'e ve ailesine de merhamet eyle. Şüphesiz sen övülmeye layıksın, şanı yücesin.",
    "okunus": "Allahümme salli alâ Muhammedin ve alâ âli Muhammed. Kemâ salleyte alâ İbrâhîme ve alâ âli İbrâhîm. İnneke hamîdün mecîd.",
    "ses": "https://www.hisnmuslim.com/audio/ar/122.mp3"
  },
  {
    "id": "hadis_2",
    "kategori": "sabah_aksam",
    "ad": "Sabah Zikri",
    "sure": "Müslim, 2723",
    "arapca": "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
    "anlam": "Sabaha erdik; mülk de Allah’ındır, hamd de Allah’ındır. Allah’tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O’nundur, hamd de O’na mahsustur. O her şeye kadirdir.",
    "okunus": "Asbahnâ ve asbahal-mülkü lillâhi, vel-hamdü lillâhi. Lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehul-mülkü ve lehul-hamdü ve hüve alâ külli şey'in kadîr.",
    "ses": "https://www.hisnmuslim.com/audio/ar/12.mp3"
  },
  {
    "id": "hadis_3",
    "kategori": "sabah_aksam",
    "ad": "Akşam Zikri",
    "sure": "Müslim, 2723",
    "arapca": "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
    "anlam": "Akşama erdik; mülk de Allah’ındır, hamd de Allah’ındır. Allah’tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O’nundur, hamd de O’na mahsustur. O her şeye kadirdir.",
    "okunus": "Emseynâ ve emsel-mülkü lillâhi, vel-hamdü lillâhi. Lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehul-mülkü ve lehul-hamdü ve hüve alâ külli şey'in kadîr.",
    "ses": "https://www.hisnmuslim.com/audio/ar/12.mp3"
  },
  {
    "id": "hadis_4",
    "kategori": "sabah_aksam",
    "ad": "Sübhanallahi ve Bihamdih",
    "sure": "Müslim, 2692",
    "arapca": "سُبْحَانَ اللهِ وَبِحَمْدِهِ",
    "anlam": "Allah'ı noksan sıfatlardan tenzih eder, O'na hamdederim.",
    "okunus": "Sübhânallâhi ve bihamdih.",
    "ses": "https://www.hisnmuslim.com/audio/ar/16.mp3"
  },

  // --- NAMAZ DUALARI (8) ---
  {
    "id": "hadis_5",
    "kategori": "namaz",
    "ad": "Tahiyyat (Ettehiyyatü)",
    "sure": "Buhârî, 831",
    "arapca": "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
    "anlam": "Her türlü hürmet, salat ve güzel şeyler Allah'a mahsustur. Ey Peygamber! Selam, Allah'ın rahmeti ve bereketleri senin üzerine olsun. Selam bizim üzerimize ve Allah'ın salih kullarının üzerine olsun. Şahitlik ederim ki Allah'tan başka ilah yoktur. Ve yine şahitlik ederim ki Muhammed O'nun kulu ve elçisidir.",
    "okunus": "Et-tahiyyâtü lillâhi ves-salevâtü vet-tayyibât. Es-selâmü aleyke eyyühen-nebiyyü ve rahmetullâhi ve berakâtüh. Es-selâmü aleynâ ve alâ ibâdillâhis-sâlihîn. Eşhedü en lâ ilâhe illallâh ve eşhedü enne Muhammeden abdühû ve resûlüh.",
    "ses": "https://www.hisnmuslim.com/audio/ar/122.mp3"
  },
  {
    "id": "hadis_6",
    "kategori": "namaz",
    "ad": "Rükû Tesbihi",
    "sure": "Ebû Dâvûd, 871",
    "arapca": "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
    "anlam": "Büyük olan Rabbimi noksan sıfatlardan tenzih ederim.",
    "okunus": "Subhâne rabbiyel-aẓîm.",
    "ses": "https://www.hisnmuslim.com/audio/ar/19.mp3"
  },
  {
    "id": "hadis_7",
    "kategori": "namaz",
    "ad": "Allahümme Bârik",
    "sure": "Buhârî, 3370",
    "arapca": "اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
    "anlam": "Allah'ım! İbrahim'i ve ailesini mübarek kıldığın gibi Muhammed'i ve ailesini de mübarek kıl. Şüphesiz sen övülmeye layıksın, şanı yücesin.",
    "okunus": "Allahümme bârik alâ Muhammedin ve alâ âli Muhammed. Kemâ bârekte alâ İbrâhîme ve alâ âli İbrâhîm. İnneke hamîdün mecîd.",
    "ses": "https://www.hisnmuslim.com/audio/ar/12.mp3"
  },
  {
    "id": "hadis_8",
    "kategori": "namaz",
    "ad": "Kunut Duası – Vitir Namazı",
    "sure": "Beyhakî, 2/210",
    "arapca": "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنَسْتَهْدِيكَ، وَنُؤْمِنُ بِكَ وَنَتُوبُ إِلَيْكَ، وَنَتَوَكَّلُ عَلَيْكَ وَنُثْنِي عَلَيْكَ الْخَيْرَ كُلَّهُ نَشْكُرُكَ وَلَا نَكْفُرُكَ، وَنَخْلَعُ وَنَتْرُكُ مَنْ يَفْجُرُكَ",
    "anlam": "Allah'ım! Biz senden yardım dileriz, günahlarimizi bağışlamanı isteriz, bizi doğru yola iletmeni dileriz. Sana iman ederiz, sana tövbe ederiz, sana tevekkül ederiz ve seni bütün hayırlarla överiz. Sana şükrederiz, nankörlük etmeyiz. Sana isyan edenleri bırakır ve onlardan uzaklaşırız.",
    "okunus": "Allahümme innâ nesteînüke ve nesteğfirüke ve nestehdîk. Ve nü'minü bike ve netûbü ileyk. Ve netevekkelü aleyke ve nüsnî aleykel-hayra küllehû neşkürük. Velâ nekfürük. Ve nahle'ü ve netrükü men yefcürük.",
    "ses": "https://www.hisnmuslim.com/audio/ar/122.mp3"
  },
  {
    "id": "hadis_9",
    "kategori": "namaz",
    "ad": "Sübhaneke – Namaz Açılış Duası",
    "sure": "Ebû Dâvûd, 775",
    "arapca": "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ",
    "anlam": "Allah'ım! Seni her türlü noksan sıfatlardan tenzih ederim ve sana hamdederim. Senin adın mübarektir. Senin şanın yücedir ve senden başka hiçbir ilah yoktur.",
    "okunus": "Sübhanekellahümme ve bihamdik. Ve tebârekesmük. Ve teâlâ ceddük. Velâ ilâhe gayrûk.",
    "ses": "https://www.hisnmuslim.com/audio/ar/19.mp3"
  },
  {
    "id": "hadis_10",
    "kategori": "namaz",
    "ad": "Secde Tesbihi",
    "sure": "Ebû Dâvûd, 871",
    "arapca": "سُبْحَانَ رَبِّيَ الْأَعْلَى",
    "anlam": "En yüce olan Rabbimi noksan sıfatlardan tenzih ederim.",
    "okunus": "Subhâne rabbiyel-a'lâ.",
    "ses": "https://www.hisnmuslim.com/audio/ar/19.mp3"
  },
  {
    "id": "hadis_11",
    "kategori": "namaz",
    "ad": "Allahümme Salli",
    "sure": "Buhârî, 3370",
    "arapca": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
    "anlam": "Allah'ım! İbrahim'e ve onun ailesine merhamet ettiğin gibi Muhammed'e ve ailesine de merhamet eyle. Şüphesiz sen övülmeye layıksın, şanı yücesin.",
    "okunus": "Allahümme salli alâ Muhammedin ve alâ âli Muhammed. Kemâ salleyte alâ İbrâhîme ve alâ âli İbrâhîm. İnneke hamîdün mecîd.",
    "ses": "https://www.hisnmuslim.com/audio/ar/12.mp3"
  },
  {
    "id": "hadis_12",
    "kategori": "namaz",
    "ad": "Namaz Sonrası Tesbihat",
    "sure": "Müslim, 597",
    "arapca": "أَسْتَغْفِرُ اللَّهَ (3 Defa) ، اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ ، سُبْحَانَ اللَّهِ (33) ، الْحَمْدُ لِلَّهِ (33) ، اللَّهُ أَكْبَرُ (33)",
    "anlam": "Allah'tan bağışlanma dilerim. Allah'ım! Sen esenlik verensin, selamet sendendir. Ey celal ve ikram sahibi! Sen ne yücesin. (Ardından 33 Sübhanallah, 33 Elhamdülillah, 33 Allahü Ekber söylenir.)",
    "okunus": "Estağfirullâh. Allahümme entes-selâmü ve minkes-selâm. Tebârekte yâ żel-celâli vel-ikrâm. Sübhânallâh, Elhamdülillâh, Allâhü Ekber.",
    "ses": "https://www.hisnmuslim.com/audio/ar/122.mp3"
  },
  {
    "id": "hadis_13",
    "kategori": "uyku",
    "ad": "Yatakta Sağ Tarafına Uzanıp Okunacak Dua",
    "sure": "Buhari, Vudu 75",
    "arapca": "اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ وَوَجَّهْتُ وَجْهِي إِلَيْكَ وَفَوَّضْتُ أَمْرِي إِلَيْكَ وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ رَغْبَةً وَرَهْبَةً إِلَيْكَ لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ",
    "anlam": "Allah'ım! Kendimi sana teslim ettim. Yüzümü sana çevirdim. İşimi sana havale ettim. Rızanı isteyerek ve azabından korkarak sırtımı sana dayadım. Senden başka sığınak ve kurtuluş yoktur. İndirdiğin kitabına ve gönderdiğin Peygamberine iman ettim.",
    "okunus": "Allahümme eslemtü nefsî ileyke ve veccehtü vechî ileyke ve fevveztü emrî ileyke ve elce'tü zahrî ileyke ragbeten ve rahbeten ileyke. Lâ melce-e velâ mencâ minke illâ ileyke. Âmentü bikitâbikelleżî enzelte ve binabiyyikelleżî erselte.",
    "ses": "https://www.hisnmuslim.com/audio/ar/122.mp3"
  },
  {
    "id": "hadis_14",
    "kategori": "uyku",
    "ad": "Gece Uyanınca Okunacak Zikir",
    "sure": "Buhari, Teheccüd 21",
    "arapca": "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
    "anlam": "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'na mahsustur. O'nun her şeye gücü yeter. Allah noksan sıfatlardan uzaktır, hamd Allah'adır, Allah'tan başka ilah yoktur, Allah en büyüktür, güç ve kuvvet ancak Allah'a aittir.",
    "okunus": "Lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehul-mulku ve lehul-hamdu ve huve alâ kulli şey'in kadîr. Sübhanallâhi velhamdü lillâhi velâ ilâhe illallâhu vallâhu ekber. Velâ havle velâ kuvvete illâ billâh.",
    "ses": "https://www.hisnmuslim.com/audio/ar/18.mp3"
  },

  // --- YOLCULUK DUALARI (3) ---
  {
    "id": "hadis_15",
    "kategori": "yolculuk",
    "ad": "Yolculuktan Dönerken Okunacak Dua",
    "sure": "Müslim, Hac 425",
    "arapca": "آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ",
    "anlam": "Bizler yolculuktan dönen, tövbe eden, kulluk eden ve Rabbimize hamdedenleriz.",
    "okunus": "Âyibûne tâ-ibûne âbidûne lirabbinâ hâmidûn.",
    "ses": "https://www.hisnmuslim.com/audio/ar/33.mp3"
  },
  {
    "id": "hadis_16",
    "kategori": "yolculuk",
    "ad": "Yolculuğa Çıkarken Okunacak Dua",
    "sure": "Müslim, Hac 425",
    "arapca": "اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى وَمِنَ الْعَمَلِ مَا تَرْضَى",
    "anlam": "Allah'ım! Bu yolculuğumuzda senden iyilik, takva ve razı olacağın ameller dileriz.",
    "okunus": "Allahümme innâ nes'elüke fî seferinâ hâżel-birra vettekva ve minel-ameli mâ terdâ.",
    "ses": "https://www.hisnmuslim.com/audio/ar/33.mp3"
  },
  {
    "id": "hadis_17",
    "kategori": "yolculuk",
    "ad": "Evden Çıkarken Okunacak Dua",
    "sure": "Ebu Davud, Edeb 102",
    "arapca": "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
    "anlam": "Allah'ın adıyla. Allah'a tevekkül ettim. Güç ve kuvvet ancak Allah'a aittir.",
    "okunus": "Bismillâhi tevekkeltü alallâh. Lâ havle velâ kuvvete illâ billâh.",
    "ses": "https://www.hisnmuslim.com/audio/ar/16.mp3"
  },

  // --- GENEL DUALAR (12) ---
  {
    "id": "hadis_18",
    "kategori": "genel",
    "ad": "Sıkıntı ve Keder Anında Okunacak Dua",
    "sure": "Buhari, Deavat 27",
    "arapca": "لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ",
    "anlam": "Yüce ve halim olan Allah'tan başka ilah yoktur. Büyük Arş'ın Rabbi Allah'tan başka ilah yoktur. Göklerin, yerin ve şerefli Arş'ın Rabbi Allah'tan başka ilah yoktur.",
    "okunus": "Lâ ilâhe illallâhul-azîmul-halîm. Lâ ilâhe illallâhu rabbul-arşil-azîm. Lâ ilâhe illallâhu rabbus-semâvâti ve rabbul-ardı ve rabbul-arşil-kerîm.",
    "ses": "https://www.hisnmuslim.com/audio/ar/142.mp3"
  },
  {
    "id": "hadis_19",
    "kategori": "genel",
    "ad": "Borçtan Kurtulma Duası",
    "sure": "Tirmizi, Deavat 111",
    "arapca": "اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ",
    "anlam": "Allah'ım! Beni helal rızıklarınla yetindirerek haramlardan koru. Lütfunla beni senden başkasına muhtaç etme.",
    "okunus": "Allahümmekfinî bi-helâlike an harâmike ve agninî bi-fadlike ammen sivâk.",
    "ses": "https://www.hisnmuslim.com/audio/ar/136.mp3"
  },
  {
    "id": "hadis_20",
    "kategori": "genel",
    "ad": "Şifa ve Rahmet Duası",
    "sure": "Buhari, Tıb 38",
    "arapca": "اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ شِفَاءً لَا يُغَادِرُ سَقَمًا",
    "anlam": "İnsanların Rabbi olan Allah'ım! Hastalığı gider, şifa ver. Şifa veren ancak sensin. Senin şifandan başka şifa yoktur. Öyle bir şifa ver ki hiçbir hastalık bırakmasın.",
    "okunus": "Allahümme rabben-nâsi eżhibil-be's. İşfi enteş-şâfî, lâ şifâ-e illâ şifâ-uke, şifâ-en lâ yugâdiru sekamâ.",
    "ses": "https://www.hisnmuslim.com/audio/ar/116.mp3"
  },
  {
    "id": "hadis_21",
    "kategori": "genel",
    "ad": "Yemekten Sonra Okunacak Dua",
    "sure": "Tirmizi, Deavat 55",
    "arapca": "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ",
    "anlam": "Bizi yediren, içiren ve Müslüman kılan Allah'a hamdolsun.",
    "okunus": "Elhamdü lillâhilleżî et'amenâ ve sekânâ ve ce'alenâ müslümîn.",
    "ses": "https://www.hisnmuslim.com/audio/ar/82.mp3"
  },
  {
    "id": "hadis_22",
    "kategori": "genel",
    "ad": "Yeni Elbise Giyerken Okunacak Dua",
    "sure": "Tirmizi, Libas 2",
    "arapca": "الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ",
    "anlam": "Benim bir gücüm ve kuvvetim olmaksızın bu elbiseyi bana giydiren ve beni bununla rızıklandıran Allah'a hamdolsun.",
    "okunus": "Elhamdü lillâhilleżî kesânî hâżeś-śevbe ve razakanîhi min gayri havlin minnî velâ kuvvetin.",
    "ses": "https://www.hisnmuslim.com/audio/ar/9.mp3"
  },
  {
    "id": "hadis_23",
    "kategori": "genel",
    "ad": "Aynaya Bakarken Okunacak Dua",
    "sure": "İbn es-Sünni, Amelul Yevm 161",
    "arapca": "اللَّهُمَّ كَمَا أَحْسَنْتَ خَلْقِي فَأَحْسِنْ خُلُقِي",
    "anlam": "Allah'ım! Yaratılışımı (fiziksel görünüşümü) güzel yaptığın gibi, ahlakımı da güzelleştir.",
    "okunus": "Allahümme kemâ ahsente halkî fe-ahsin hulukî.",
    "ses": "https://www.hisnmuslim.com/audio/ar/18.mp3"
  },
  {
    "id": "hadis_24",
    "kategori": "genel",
    "ad": "Camiye Giderken Okunacak Dua",
    "sure": "Müslim, Müsafirin 181",
    "arapca": "اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا وَفِي لِسَانِي نُورًا وَاجْعَلْ فِي سَمْعِي نُورًا وَاجْعَلْ فِي بَصَرِي نُورًا",
    "anlam": "Allah'ım! Kalbime bir nur, dilime bir nur, kulağıma bir nur, gözüme bir nur kıl.",
    "okunus": "Allahümme-c'al fî kalbî nûran ve fî lisânî nûran vec'al fî sem'î nûran vec'al fî basarî nûra.",
    "ses": "https://www.hisnmuslim.com/audio/ar/18.mp3"
  },
  {
    "id": "hadis_25",
    "kategori": "genel",
    "ad": "Camiye Girerken ve Çıkarken Okunacak Dua",
    "sure": "İbn Mace, Mesacid 13",
    "arapca": "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ",
    "anlam": "Allah'ım! Bana rahmet kapılarını aç. Allah'ım! Senin lütfundan isterim.",
    "okunus": "Allahümmeftah lî ebvâbe rahmetike. (Çıkarken): Allahümme innî es'elüke min fadlik.",
    "ses": "https://www.hisnmuslim.com/audio/ar/19.mp3"
  },
  {
    "id": "hadis_26",
    "kategori": "genel",
    "ad": "Öfkelenince Okunacak Sığınma",
    "sure": "Buhari, Edeb 76",
    "arapca": "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
    "anlam": "Kovulmuş şeytandan Allah'ma sığınırım.",
    "okunus": "Eûżu billâhi mineş-şeytânir-racîm.",
    "ses": "https://www.hisnmuslim.com/audio/ar/27.mp3"
  },
  {
    "id": "hadis_27",
    "kategori": "genel",
    "ad": "Doğru Yolda Kalma Duası",
    "sure": "Müslim, Zikir 78",
    "arapca": "اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي",
    "anlam": "Allah'ım! Beni doğru yola ilet ve o yolda kararlı/dosdoğru kıl.",
    "okunus": "Allahümmehdinî ve seddidnî.",
    "ses": "https://www.hisnmuslim.com/audio/ar/18.mp3"
  },
  {
    "id": "hadis_28",
    "kategori": "genel",
    "ad": "Kalpleri Sabitleyen Dua",
    "sure": "Tirmizi, Deavat 89",
    "arapca": "يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
    "anlam": "Ey kalpleri çekip çeviren Rabbim! Kalbimi dinin üzere sabit kıl.",
    "okunus": "Yâ mukallibel-kulûbi sebbit kalbî alâ dînik.",
    "ses": "https://www.hisnmuslim.com/audio/ar/18.mp3"
  },
  {
    "id": "hadis_29",
    "kategori": "genel",
    "ad": "Dünya ve Ahiret Afiyeti İçin Dua",
    "sure": "Tirmizi, Deavat 85",
    "arapca": "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ",
    "anlam": "Allah'ım! Dünyada ve ahirette senden affetmeni ve bana afiyet/sağlık vermeni dilerim.",
    "okunus": "Allahümme innî es'elükel-afve vel-âfiyete fid-dünyâ vel-âhirah.",
    "ses": "https://www.hisnmuslim.com/audio/ar/122.mp3"
  }
];

const List<Map<String, dynamic>> HADISLER_40 = [
  {
    "no": 1,
    "baslik": "Niyetlerin Önemi",
    "arapca": "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
    "metin": "Ameller ancak niyetlere göredir. Herkes için ancak niyet ettiği şey vardır.",
    "kaynak": "Buhârî, Bed'ü'l-Vahy, 1; Müslim, İmâret, 155",
    "ders": "Yaptığımız her hayırlı amelin Allah katında değer bulması samimi niyetimize bağlıdır. İhlas, amelin ruhudur."
  },
  {
    "no": 2,
    "baslik": "Din Nasihattir",
    "arapca": "الدِّينُ النَّصِيحَةُ",
    "metin": "Din nasihattir (samimiyettir, hayırhahlıktır).",
    "kaynak": "Müslim, Îmân, 95; Ebû Dâvûd, Edeb, 59",
    "ders": "Din, Allah'a, Kitabına, Resûlüne, Müslümanların yöneticilerine ve tüm müminlere karşı samimi ve dürüst olmaktır."
  },
  {
    "no": 3,
    "baslik": "Kardeşlik ve İman",
    "arapca": "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ",
    "metin": "Sizden biriniz, kendisi için istediğini din kardeşi için de istemedikçe tam iman etmiş olmaz.",
    "kaynak": "Buhârî, Îmân, 7; Müslim, Îmân, 71",
    "ders": "Gerçek mümin, bencil olmaz. Kardeşinin iyiliğini ve mutluluğunu en az kendisininki kadar arzular."
  },
  {
    "no": 4,
    "baslik": "Hayra Vesile Olmak",
    "arapca": "مَنْ دَلَّ عَلَى خَيْرٍ فَلَهُ مِثْلُ أَجْرِ فَاعِلِهِ",
    "metin": "Bir hayra vesile olan kimseye, onu yapanın ecri gibi sevap vardır.",
    "kaynak": "Müslim, İmâret, 133; Tirmizî, İlim, 14",
    "ders": "İyiliği yaymak, öğretmek ve insanları teşvik etmek de bizzat iyilik yapmak kadar değerlidir."
  },
  {
    "no": 5,
    "baslik": "Müslümanın Tanımı",
    "arapca": "الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ",
    "metin": "Müslüman, dilinden ve elinden Müslümanların güvende olduğu kimsedir.",
    "kaynak": "Buhârî, Îmân, 4; Müslim, Îmân, 64",
    "ders": "İslam barış dinidir. Gerçek bir Müslüman çevresine zarar vermez, güven verir; gıybet ve zulümden uzak durur."
  },
  {
    "no": 6,
    "baslik": "Kolaylaştırma Düsturu",
    "arapca": "يَسِّرُوا وَلاَ تُعَسِّرُوا وَبَشِّرُوا وَلاَ تُنَفِّرُوا",
    "metin": "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.",
    "kaynak": "Buhârî, İlim, 11; Müslim, Cihâd, 6",
    "ders": "İnsanlara dini sevdirerek anlatmalı, ibadetlerde ve günlük hayatta kolaylığı ve hoşgörüyü esas almalıyız."
  },
  {
    "no": 7,
    "baslik": "Faydalı İnsan Olmak",
    "arapca": "خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ",
    "metin": "İnsanların en hayırlısı, insanlara faydalı olanıdır.",
    "kaynak": "Taberânî, el-Mu'cemü'l-Evsat, VI, 58; Beyhakî, Şuabü'l-Îmân, VI, 117",
    "ders": "Hayatın gayesi bencil yaşamak değil, topluma, çevreye ve tüm yaratılmışlara merhametle fayda sağlamaktır."
  },
  {
    "no": 8,
    "baslik": "İki Büyük Nimet",
    "arapca": "نِعْمَتَانِ مَغْبُونٌ فِيهِمَا كَثِيرٌ مِنَ النَّاسِ: الصِّحَّةُ وَالْفَرَاغُ",
    "metin": "İki nimet vardır ki insanların çoğu bunları değerlendirmekte aldanmıştır: Sağlık ve boş vakit.",
    "kaynak": "Buhârî, Rikâk, 1; Tirmizî, Zühd, 1",
    "ders": "Sağlığın ve zamanın kıymetini elden gitmeden önce bilmeli, bunları salih amellerle ve ibadetle değerlendirmeliyiz."
  },
  {
    "no": 9,
    "baslik": "En Güzel Miras",
    "arapca": "مَا نَحَلَ وَالِدٌ وَلَدًا مِنْ نُحْلٍ أَفْضَلَ مِنْ أَدَبٍ حَسَنٍ",
    "metin": "Hiçbir anne baba, evladına güzel ahlaktan daha değerli bir miras bırakamaz.",
    "kaynak": "Tirmizî, Birr, 33; Ahmed b. Hanbel, Müsned, IV, 263",
    "ders": "Çocuklara bırakılacak en büyük servet, onları haramlardan koruyacak ve ahlaklı yapacak iyi bir eğitimdir."
  },
  {
    "no": 10,
    "baslik": "Temizlik ve İman",
    "arapca": "الطُّهُورُ شَطْرُ الإِيمَانِ",
    "metin": "Temizlik, imanın yarısıdır.",
    "kaynak": "Müslim, Tahâret, 1; Tirmizî, Daavât, 86",
    "ders": "İslam hem maddi beden, elbise ve çevre temizliğine hem de manevi olarak kalbin günahtan arınmasına büyük önem verir."
  },
  {
    "no": 11,
    "baslik": "Takva ve İyilik",
    "arapca": "إِنَّ التَّقْوَى هَاهُنَا",
    "icerik": "Peygamber Efendimiz (s.a.v.), Miladi 571 yılında Mekke'de doğdu. Babası Abdullah ve annesi Âmine henüz çocukken vefat etti; bu yüzden dedesi Abdülmuttalib ve ardından amcası Ebû Tâlib'in koruması altında büyüdü. Çocukluk yıllarında gösterdiği dürüstlük ve güvenilirlik, Mekke halkı arasında 'Muhammedü'l-Emîn' (Güvenilir Muhammed) unvanını kazanmasına yol açtı. Aile maddi zorluklar içinde olsa da, genç Muhammed'in ahlaki karakteri ve güzel huyları çevresinde büyük takdir topladı.","kaynak": "Tirmizî, Birr, 55; Ahmed b. Hanbel, Müsned, V, 153",
    "ders": "Takva, her an Allah'ın huzurunda olduğumuzu bilmektir. Hata yaptığımızda hemen tövbe ve iyilikle telafi etmeliyiz."
  },
  {
    "no": 12,
    "baslik": "Gerçek Zenginlik",
    "arapca": "لَيْسَ الْغِنَى عَنْ كَثْرَةِ الْعَرَضِ، وَلَكِنَّ الْغِنَى غِنَى النَّفْسِ",
    "metin": "Zenginlik mal çokluğu ile değildir. Gerçek zenginlik gönül zenginliğidir (kanaatkarlıktır).",
    "kaynak": "Buhârî, Rikâk, 15; Müslim, Zekât, 120",
    "ders": "Mal hırsı insanı huzursuz eder. Gerçek huzur ve zenginlik, Allah'ın verdiğine razı olup kanaat etmektir."
  },
  {
    "no": 13,
    "baslik": "Öfke Kontrolü",
    "arapca": "إِذَا غَضِبَ أَحَدُكُمْ فَلْيَسْكُتْ",
    "metin": "Sizden biriniz öfkelendiği zaman sussun.",
    "kaynak": "Ahmed b. Hanbel, Müsned, I, 239; Buhârî, el-Edebü'l-Müfred, s. 120",
    "ders": "Öfke şeytandandır ve akla zarar verir. Öfkelendiğimizde konuşup hata yapmaktansa susmak ve sakinleşmek en doğrusudur."
  },
  {
    "no": 14,
    "baslik": "Komşu Hakkı",
    "arapca": "مَا آمَنَ بِي مَنْ بَاتَ شَبْعَانًا وَجَارُهُ جَائِعٌ إِلَى جَنْبِهِ وَهُوَ يَعْلَمُ",
    "metin": "Yanı başındaki komşusu açken kendisi tok yatan kimse, bana (tam anlamıyla) iman etmemiştir.",
    "kaynak": "Taberânî, el-Mu'cemü'l-Kebîr, XII, 329; Hâkim, Müstedrek, II, 15",
    "ders": "Müslümanlar komşularının sıkıntılarına karşı duyarsız kalamazlar. Maddi ve manevi paylaşım imanın gereğidir."
  },
  {
    "no": 15,
    "baslik": "Güzel Söz Sadakadır",
    "arapca": "وَالْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ",
    "metin": "Güzel söz söylemek sadakadır.",
    "kaynak": "Buhârî, Cihâd, 128; Müslim, Zekât, 56",
    "ders": "Bir insana tebessüm etmek, moral vermek, güzel ve yumuşak dille hitap etmek de bir tür sadaka ve ibadettir."
  },
  {
    "no": 16,
    "baslik": "Dua ve İbadet",
    "arapca": "الدُّعَاءُ هُوَ الْعِبَادَةُ",
    "metin": "Dua, ibadetin ta kendisidir (özüdür).",
    "kaynak": "Tirmizî, Tefsîru Sûre, 40; Ebû Dâvûd, Vitr, 23",
    "ders": "Kul, acziyetini bilip yaratıcısına sığındığı zaman ibadetin en derin mertebesine ulaşmış olur."
  },
  {
    "no": 17,
    "baslik": "Dürüstlük ve Güven",
    "arapca": "مَنْ غَشَّنَا فَلَيْسَ مِنَّا",
    "metin": "Bizi aldatan, bizden değildir.",
    "kaynak": "Müslim, Îmân, 164; Tirmizî, Büyû', 72",
    "ders": "Ticarette, sosyal hayatta ve ilişkilerde yalan söylemek, hile yapmak Müslümana asla yakışmaz."
  },
  {
    "no": 18,
    "baslik": "Kolaylık Gösterene Kolaylık",
    "arapca": "مَنْ يَسَّرَ عَلَى مُعْسِرٍ يَسَّرَ اللَّهُ عَلَيْهِ فِي الدُّنْيَا وَالْآخِرَةِ",
    "metin": "Kim darda kalan bir borçluya kolaylık gösterirse, Allah da ona dünya ve ahirette kolaylık gösterir.",
    "kaynak": "Müslim, Zikir, 38; Ebû Dâvûd, Edeb, 60",
    "ders": "Maddi sıkıntıda olan din kardeşimizin borcunu ertelemek veya silmek, Allah katında çok büyük bir fazilettir."
  },
  {
    "no": 19,
    "baslik": "Merhamet ve Sevgi",
    "arapca": "لَيْسَ مِنَّا مَنْ لَمْ يَرْحَمْ صَغِيرَنَا وَيَعْرِفْ شَرَفَ كَبِيرِنَا",
    "metin": "Küçüklerimize merhamet etmeyen, büyüklerimizin şerefini (hakkını) tanımayan bizden değildir.",
    "kaynak": "Tirmizî, Birr, 15; Ebû Dâvûd, Edeb, 58",
    "ders": "Toplumda huzur, çocuklara şefkat ve sevgi göstermekle, yaşlılara ise hürmet ve itaat etmekle tesis edilir."
  },
  {
    "no": 20,
    "baslik": "Anne Hakkı",
    "arapca": "الْجَنَّةُ تَحْتَ أَقْدَامِ الأُمَّهَاتِ",
    "metin": "Cennet, annelerin ayakları altındadır.",
    "kaynak": "Nesâî, Cihâd, 6; Ahmed b. Hanbel, Müsned, III, 429",
    "ders": "Cennete giden yol, anneye hürmet etmekten, rızasını almaktan ve ona karşı her zaman iyi davranmaktan geçer."
  },
  {
    "no": 21,
    "baslik": "Haya ve Ahlak",
    "arapca": "إِذَا لَمْ تَسْتَحِ فَاصْنَعْ مَا شِئْتَ",
    "metin": "Haya etmedikten (utanmadıktan) sonra dilediğini yap!",
    "kaynak": "Buhârî, Enbiyâ, 54; Ebû Dâvûd, Edeb, 6",
    "ders": "Haya ve utanma duygusu, insanı kötülükten koruyan en güçlü kalkandır. Utanma duygusu yoksa her türlü kötülük yapılabilir."
  },
  {
    "no": 22,
    "baslik": "Rabba En Yakın An",
    "arapca": "أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ، فَأَكْثِرُوا الدُّعَاءَ",
    "metin": "Kulun Rabbine en yakın olduğu an secde anıdır; orada çokça dua ediniz.",
    "kaynak": "Müslim, Salât, 215; Nesâî, Tatbîk, 78",
    "ders": "Secde, kibrin yok olduğu, tevazuunun zirveye ulaştığı andır. Bu kıymetli anı dualarla süslemeliyiz."
  },
  {
    "no": 23,
    "baslik": "Allah Kalplere Bakar",
    "arapca": "إِنَّ اللَّهَ لَا يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ، وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ",
    "metin": "Şüphesiz Allah sizin suretlerinize ve mallarınıza bakmaz; ancak kalplerinize ve amellerinize bakar.",
    "kaynak": "Müslim, Birr, 34; İbn Mâce, Zühd, 9",
    "ders": "Dış görünüşümüzün, soyumuzun veya zenginliğimizin Allah katında değeri yoktur. Önemli olan kalbimizin temizliği ve samimi amelimizdir."
  },
  {
    "no": 24,
    "baslik": "Kur'an'ın Hayırlıları",
    "arapca": "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
    "metin": "Sizin en hayırlınız, Kur'an-ı Kerim'i öğrenen ve onu öğretendir.",
    "kaynak": "Buhârî, Fezâilü'l-Kur'ân, 21; Tirmizî, Fezâilü'l-Kur'ân, 15",
    "ders": "Kur'an Allah'ın kelamıdır. Onu okumak, anlamını öğrenmek ve başkalarına aktarmak en ulvi vazifedir."
  },
  {
    "no": 25,
    "baslik": "Müminlerin İlişkileri",
    "arapca": "لاَ تَحَاسَدُوا، وَلاَ تَنَاجَشُوا، وَلاَ تَبَاغَضُوا، وَلاَ تَدَابَرُوا",
    "metin": "Birbirinize haset etmeyin, (fiyat artırmak için) müşteri kızıştırmayın, birbirinize kin beslemeyin, birbirinize sırt çevirmeyin.",
    "kaynak": "Müslim, Birr, 32; Buhârî, Edeb, 57",
    "ders": "Müminler kardeştir. Kardeşlik bağını koparacak haset, nefret ve küslük gibi kötü hasletlerden titizlikle kaçınmalıyız."
  },
  {
    "no": 26,
    "baslik": "Bal Arısı Gibi Mümin",
    "arapca": "مَثَلُ الْمُؤْمِنِ كَمَثَلِ النَّحْلَةِ أَكَلَتْ طَيِّبًا وَوَضَعَتْ طَيِّبًا",
    "metin": "Mümin bal arısı gibidir; temiz olanı yer, temiz olanı üretir, konduğu dalı kırmaz.",
    "kaynak": "Ahmed b. Hanbel, Müsned, II, 199; Hâkim, Müstedrek, I, 147",
    "ders": "Mümin helal lokma yer, etrafına faydalı işler sunar, kimseyi incitmez ve yıkıcı değil her zaman yapıcı olur."
  },
  {
    "no": 27,
    "baslik": "Sabrın Hakikati",
    "arapca": "إِنَّمَا الصَّبْرُ عِنْدَ الصَّدْمَةِ الأُولَى",
    "metin": "Gerçek sabır, musibetle karşılaştığın ilk sarsıntı anında gösterilendir.",
    "kaynak": "Buhârî, Cenâiz, 32; Müslim, Cenâiz, 62",
    "ders": "Zorlukla karşılaşıldığı ilk an isyan etmeyip kadere rıza göstermek gerçek sabırdır. Zamanla sakinleşmek sabır değil kabullenmedir."
  },
  {
    "no": 28,
    "baslik": "Geleceğe Yatırım",
    "arapca": "إِنْ قَامَتِ السَّاعَةُ وَفِي يَدِ أَحَدِكُمْ فَسِيلَةٌ فَلْيَغْرِسْهَا",
    "metin": "Kıyamet kopuyor olsa bile, eğer birinizin elinde bir fidan varsa onu hemen diksin.",
    "kaynak": "Ahmed b. Hanbel, Müsned, III, 191; Buhârî, el-Edebü'l-Müfred, s. 168",
    "ders": "Ümitsizliğe yer yoktur. Müslüman son ana kadar çalışmalı, üretmeli ve dünyaya değer katmaya devam etmelidir."
  },
  {
    "no": 29,
    "baslik": "Doğruluk Cennete Götürür",
    "arapca": "إِنَّ الصِّدْقَ يَهْدِي إِلَى الْبِرِّ، وَإِنَّ الْبِرَّ يَهْدِي إِلَى الْجَنَّةِ",
    "metin": "Doğruluk iyiliğe (birr), iyilik de insanı cennete götürür. İnsan doğru söyledikçe Allah katında sıddık yazılır.",
    "kaynak": "Buhârî, Edeb, 69; Müslim, Birr, 103",
    "ders": "Yalan her kötülüğün anasıdır. Hayatımızın her alanında doğruluktan ayrılmamalıyız ki cennete layık olalım."
  },
  {
    "no": 30,
    "baslik": "Zulüm Karanlıktır",
    "arapca": "اتَّقُوا الظُّلْمَ، فَإِنَّ الظُّلْمَ ظُلُمَاتٌ يَوْمَ الْقِيَامَةِ",
    "metin": "Zulümden kaçının. Çünkü zulüm, kıyamet gününde katmerli karanlıklar (zulumat) olacaktır.",
    "kaynak": "Müslim, Birr, 56; Tirmizî, Birr, 83",
    "ders": "Haksızlık yapmak, başkalarının hakkını gasp etmek büyük günahtır. Mazlumun ahı ahirette sahibine azap olarak döner."
  },
  {
    "no": 31,
    "baslik": "Hasetten Kaçınmak",
    "arapca": "إِيَّاكُمْ وَالْحَسَدَ، فَإِنَّ الْحَسَدَ يَأْكُلُ الْحَسَنَاتِ كَمَا تَأْكُلُ النَّارُ الْحَطَبَ",
    "metin": "Haset etmekten sakınınız. Çünkü haset, ateşin odunu yakıp tükettiği gibi iyilikleri yer bitirir.",
    "kaynak": "Ebû Dâvûd, Edeb, 44; İbn Mâce, Zühd, 22",
    "ders": "Başkasına verilen nimeti çekememek manevi bir hastalıktır. Kazandığımız sevapların yok olmaması için kalbimizi hasetten arındırmalıyız."
  },
  {
    "no": 32,
    "baslik": "Adalet ve Rüşvet",
    "arapca": "لَعْنَةُ اللَّهِ عَلَى الرَّاشِي وَالْمُرْتَشِي",
    "metin": "Rüşvet veren de rüşvet alan da Allah'ın lanetine uğramıştır (zarardadır).",
    "kaynak": "Tirmizî, Ahkâm, 9; Ebû Dâvûd, Akdıye, 4",
    "ders": "Rüşvet adaleti yok eder, kul hakkına girmektir. Toplumu ifsada sürükleyen bu gayri meşru kazançtan uzak durulmalıdır."
  },
  {
    "no": 33,
    "baslik": "Sıla-i Rahim",
    "arapca": "لَا يَدْخُلُ الْجَنَّةَ قَاطِعُ رَحِمٍ",
    "metin": "Akrabalık bağlarını koparan (sıla-i rahmi kesen) kimse cennete giremez.",
    "kaynak": "Buhârî, Edeb, 11; Müslim, Birr, 18",
    "ders": "Aile ve akrabalarla bağları koparmamak, onları arayıp sormak ve zor zamanlarında destek olmak İslam'ın temel emirlerindendir."
  },
  {
    "no": 34,
    "baslik": "Dünya Bir Yolculuktur",
    "arapca": "كُنْ فِي الدُّنْيَا كَأَنَّكَ غَرِيبٌ أَوْ عَابِرُ سَبِيلٍ",
    "metin": "Dünyada bir garip veya bir yolcu gibi ol (geçici olduğunu unutma).",
    "kaynak": "Buhârî, Rikâk, 3; Tirmizî, Zühd, 14",
    "ders": "Dünya ebedi kalacağımız yurt değildir. Ahiret yurduna hazırlık yapan bir seyyah gibi yaşamalı, dünyaya aşırı bağlanmamalıyız."
  },
  {
    "no": 35,
    "baslik": "Mümin Müminin Aynasıdır",
    "arapca": "الْمُؤْمِنُ مِرْآةُ الْمُؤْمِنِ",
    "metin": "Mümin, müminin aynasıdır (kusurunu güzellikle gösterir ve onu korur).",
    "kaynak": "Ebû Dâvûd, Edeb, 49; Buhârî, el-Edebü'l-Müfred, s. 87",
    "ders": "Kardeşimizin kusurunu arkasından konuşmak yerine, ayna gibi kırmadan, dürüstçe yüzüne söylemeli ve onu düzeltmesine yardım etmeliyiz."
  },
  {
    "no": 36,
    "baslik": "Nezaket ve Yumuşak Huyluluk",
    "arapca": "إِنَّ الرِّفْقَ لَا يَكُونُ فِي شَيْءٍ إِلَّا زَانَهُ، وَلَا يُنْزَعُ مِنْ شَيْءٍ إِلَّا شَانَهُ",
    "metin": "Nezaket (rıfk) bir şeye girdi mi onu mutlaka süsler, bir şeyden çıkarıldı mı onu mutlaka çirkinleştirir.",
    "kaynak": "Müslim, Birr, 78; Ebû Dâvûd, Edeb, 10",
    "ders": "Sözlerimizde, davranışlarımızda kaba ve kırıcı olmamalı; nezaketi ve yumuşak başlılığı kendimize şiar edinmeliyiz."
  },
  {
    "no": 37,
    "baslik": "Söz Taşımamak",
    "arapca": "لَا يَدْخُلُ الْجَنَّةَ نَمَّامٌ",
    "metin": "Söz taşıyan (laf götürüp getiren, nemmam) cennete giremez.",
    "kaynak": "Buhârî, Edeb, 50; Müslim, Îmân, 168",
    "ders": "İki insanın veya topluluğun arasını bozmak için söz taşımak büyük günahtır. Toplum barışını baltalar."
  },
  {
    "no": 38,
    "baslik": "Mazlumun Duası",
    "arapca": "وَاتَّقِ دَعْوَةَ الْمَظْلُومِ، فَإِنَّهُ لَيْسَ بَيْنَهَا وَبَيْنَ اللَّهِ حِجَابٌ",
    "metin": "Mazlumun bedduasından sakın! Çünkü onun duası ile Allah arasında hiçbir perde yoktur.",
    "kaynak": "Buhârî, Zekât, 1; Müslim, Îmân, 29",
    "ders": "Hiç kimseye haksızlık yapmamalıyız. Çaresiz kalıp Allah'a sığınan mazlumun duası mutlaka kabul görür."
  },
  {
    "no": 39,
    "baslik": "İşçi ve Alın Teri",
    "arapca": "أَعْطُوا الْأَجِيرَ أَجْرَهُ قَبْلَ أَنْ يَجِفَّ عَرَقُهُ",
    "metin": "İşçiye ücretini alın teri kurumadan (geciktirmeden) veriniz.",
    "kaynak": "İbn Mâce, Rehin, 4; Taberânî, el-Mu'cemü'l-Kebîr, VI, 219",
    "ders": "Hak ve adalet esastır. Başkalarının emeğini sömürmek, hak ettiği ücreti geciktirmek kul hakkıdır ve haramdır."
  },
  {
    "no": 40,
    "baslik": "Amellerin Devamlılığı",
    "arapca": "أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ",
    "metin": "Allah katında amellerin en sevimlisi, az da olsa devamlı olanıdır.",
    "kaynak": "Buhârî, Rikâk, 18; Müslim, Müsâfirîn, 218",
    "ders": "İbadetlerde kararlılık önemlidir. Bir gün çok yapıp sonra terk etmek yerine, her gün düzenli olarak az da olsa ibadet etmek evladır."
  }
];

const List<Map<String, String>> PEYGAMBER_HAYATI = [
  {
    "baslik": "Doğumu ve Süt Anne Yanı (571-575)",
    "icerik": "Peygamber Efendimiz Hz. Muhammed (s.a.v.), 571 yılında Rebiülevvel ayının 12. gecesi (20 Nisan) Mekke'de doğdu. Babası Abdullah o doğmadan önce vefat etmişti. Annesi Âmine, onu sütannesi Halime hanıma verdi. 4 yaşına kadar çölün temiz havasında büyüdü. Bu dönemde fiziki ve ruhsal gelişimini tamamlayarak Mekke'ye annesinin yanına döndü."
  },
  {
    "baslik": "Öksüzlük ve Amca Himayesi (575-595)",
    "icerik": "Peygamberimiz 6 yaşında annesi Âmine'yi kaybetti ve öksüz kaldı. Dedesi Abdülmuttalib ona baktı. Ancak 2 yıl sonra dedesi de vefat etti. Dedesi vefatından önce onu amcası Ebu Talib'e emanet etti. Ebu Talib, kendi çocuklarından onu ayırmadı. Peygamberimiz amcasının yanında ticareti öğrendi, dürüstlüğüyle 'Muhammedü'l-Emin' lakabını aldı."
  },
  {
    "baslik": "Evlilik ve Hira Tefekkürü (595-610)",
    "icerik": "25 yaşında Hz. Hatice ile evlendi. Bu evlilikten 6 çocuğu oldu. Ticari hayatta örnek bir ahlak sergiledi. Mekke'de mazlumları korumak için kurulan Hilfü'l-Fudûl birliğinde aktif rol aldı. Otuzlu yaşlarının sonlarında, putperestlikten uzaklaşmak amacıyla sık saatler geçirdiği Nur Dağı'ndaki Hira Mağarası'na çekilip tefekküre daldı."
  },
  {
    "baslik": "İlk Vahiy ve Mekke Daveti (610-622)",
    "icerik": "40 yaşında Hira Mağarası'nda Cebrail (a.s.) vasıtasıyla ilk vahiy ('Oku!') geldi. Böylece peygamberlik başladı. İlk olarak en yakınlarını İslam'a davet etti. Davet halka açılınca Mekkeli müşrikler ağır baskı ve işkencelere başladılar. Bu zor dönemde Habeşistan'a hicret edildi. 619 yılında Ebu Talib ve Hz. Hatice vefat etti. Ardından İsra ve Miraç mucizeleri gerçekleşti."
  },
  {
    "baslik": "Büyük Hicret ve Medine Devri (622-630)",
    "icerik": "622 yılında Medine'ye hicret edildi. Medine'de Ensar ve Muhacir arasında kardeşlik ilan edildi. İslam devletinin anayasası niteliğindeki Medine Vesikası imzalandı. Kendilerini yok etmek isteyen Mekkelilere karşı Bedir (624), Uhud (625) ve Hendek (627) savaşları yapıldı. 628'de Hudeybiye Antlaşması imzalandı."
  },
  {
    "baslik": "Mekke'nin Fethi ve Vefat (630-632)",
    "icerik": "630 yılında kansız bir harekatla Mekke fethedildi. Peygamberimiz genel af ilan ederek herkesi affetti. 632 yılında yüz binden fazla Müslüman ile Veda Haccı'nı gerçekleştirdi ve Veda Hutbesi'ni okudu. Medine'ye döndükten kısa bir süre sonra 8 Haziran 632 tarihinde 63 yaşında vefat etti. Kabri, Mescid-i Nebevî'dedir."
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
  {
    "ad": "Hz. Ebû Bekir (r.a.)",
    "unvan": "es-Sıddîk (En Sadık Dost)",
    "ozet": "Peygamber Efendimiz'in en yakın dostu, hicret arkadaşı ve ilk halifesidir. Cömertliği, teslimiyeti ve sadakatiyle bilinir.",
    "hayat": "Hz. Ebû Bekir, Fil Vakası'ndan iki yıl kadar sonra Mekke'de doğdu. İslamiyet öncesinde de dürüstlüğü ve ticari ahlakıyla tanınan bir şahsiyetti. Hz. Muhammed (s.a.v.) peygamberliğini ilan ettiğinde, ona ilk iman eden hür erkek oldu. Ömrü boyunca malını ve canını İslam yoluna adadı. Peygamberimizin vefatından sonra Müslümanların ilk halifesi seçildi ve irtidat (dinden dönme) olaylarını bastırarak ümmetin birliğini korudu.",
    "fazilet": "Kur'an-ı Kerim'de 'mağaradaki iki kişinin ikincisi' (Tevbe, 40) olarak şereflendirilmiştir. Tebük Seferinde tüm malını orduya bağışlamış ve 'Ailene ne bıraktın?' sorusuna 'Allah ve Resûlünü bıraktım' demiştir.",
    "iliskisi": "Peygamberimiz ile çocukluktan beri dosttular. Hicrette can yoldaşı olmuş, kızı Hz. Âişe ile Peygamberimizin evlenmesiyle akrabalık bağı da tesis edilmiştir. Peygamberimiz onun hakkında 'Ebû Bekir'in dostluğundan ve malından gördüğüm yardımı kimseden görmedim' buyurmuştur."
  },
  {
    "ad": "Hz. Ömer (r.a.)",
    "unvan": "el-Fârûk (Adalet Timsali)",
    "ozet": "İslam'ın ikinci halifesidir. Adaleti, sarsılmaz cesareti ve hak ile batılı ayırt etmedeki hassasiyetiyle tanınır.",
    "hayat": "Hz. Ömer, Mekke'de Kureyş'in seçkin ailelerinden birine mensuptu. İslam'ın ilk yıllarında Müslümanlara karşı sert tavırlarıyla bilinirken, kız kardeşi ve eniştesinin okuduğu Tâhâ Suresi ayetlerinden etkilenerek hicretin 6. yılında Müslüman oldu. Müslüman olmasıyla birlikte Kabe'de açıkça namaz kılınmaya başlandı. Halifeliği döneminde Suriye, Filistin, Mısır, Irak ve İran fethedildi, adil devlet mekanizması ve kurumları kuruldu.",
    "fazilet": "Hz. Ömer, adaletli yönetimiyle tarihe geçmiştir. Adaleti mülkün temeli yapmış ve 'Kenar-ı Dicle'de bir kurt aşırsa koyunu, gelir de adl-i İlahi sorar Ömer'den onu' düsturuyla yaşamıştır. Kudüs'ün fethinde şehre kölesiyle nöbetleşe bindiği deve üzerinde girmiştir.",
    "iliskisi": "Peygamber Efendimiz'in en yakın müşavirlerinden ve kayınpederidir (kızı Hz. Hafsa Peygamberimizin eşidir). Resûlullah (s.a.v.) onun hakkında 'Eğer benden sonra bir peygamber gelecek olsaydı, o Ömer olurdu' buyurarak onun ferasetini ve imanını övmüştür."
  },
  {
    "ad": "Hz. Osman (r.a.)",
    "unvan": "Zinnûreyn (İki Nur Sahibi)",
    "ozet": "İslam'ın üçüncü halifesidir. Hayası, cömertliği ve Kur'an-ı Kerim'i çoğaltmasıyla İslam tarihine yön vermiştir.",
    "hayat": "Kureyş'in en zengin ve saygın kollarından Ümeyyeoğullarına mensuptu. Hz. Ebû Bekir vasıtasıyla İslam ile şereflendi. İlk Müslümanlardan olması sebebiyle akrabalarından büyük baskılar gördü. İki defa Habeşistan'a, ardından Medine'ye hicret etti. Cömertliğiyle tanınan Hz. Osman, kıtlık zamanlarında halka tonlarca buğdayı bedelsiz dağıtmış, Medine'deki Rûme kuyusunu satın alıp Müslümanların kullanımına sunmuştur. Halifeliği döneminde Kur'an-ı Kerim mushaf haline getirilerek çoğaltıldı.",
    "fazilet": "Haya ve edep abidesidir. Peygamber Efendimiz onun hakkında 'Meleklerin dahi kendisinden haya ettiği bir kimseden ben haya etmeyeyim mi?' buyurmuştur. Ayrıca ordunun donatılmasına yaptığı büyük maddi katkılardan ötürü cennetle müjdelenmiştir.",
    "iliskisi": "Peygamber Efendimiz'in iki kızıyla (önce Rukiye, vefatından sonra Ümmü Gülsüm) evlendiği için 'iki nur sahibi' manasına gelen 'Zinnûreyn' unvanını almıştır. Peygamberimizin en güvendiği damatlarındandır."
  },
  {
    "ad": "Hz. Ali (r.a.)",
    "unvan": "Esedullah (Allah'ın Aslanı) & Şah-ı Velayet",
    "ozet": "Dördüncü halifedir. Peygamber Efendimiz'in amcasının oğlu, damadı ve çocuk yaşta İslam'ı ilk kabul eden kahramandır.",
    "hayat": "Hz. Ali, Kabe'nin içinde doğan tek şahsiyettir. Babası Ebû Tâlib'in maddi durumu zayıf olduğu için küçük yaştan itibaren Peygamberimizin evinde, onun terbiyesinde büyüdü. Hicret gecesi canı pahasına Peygamberimizin yatağına yatarak müşrikleri oyaladı ve emanetleri sahiplerine teslim etti. Bedir, Uhud, Hendek ve Hayber başta olmak üzere neredeyse tüm savaşlarda sancağı taşıdı ve eşsiz kahramanlıklar gösterdi. Halifeliği döneminde ilim, adalet ve takva dersleri verdi.",
    "fazilet": "İlmin kapısı ve kahramanlık sembolüdür. Zülfikar isimli çatal uçlu kılıcıyla meşhurdur. Peygamberimiz onun hakkında 'Ben ilmin şehriyim, Ali ise onun kapısıdır. İlim isteyen kapıya gelsin' buyurmuştur.",
    "iliskisi": "Peygamber Efendimiz'in amcazadesi ve en sevdiği kızı Hz. Fâtıma'nın eşidir. Peygamberimizin soyu Hz. Ali ve Hz. Fâtıma'nın çocukları (Hz. Hasan ve Hz. Hüseyin) vasıtasıyla günümüze ulaşmıştır. Peygamberimiz ona 'Sen bana nispetle, Harun'un Musa'ya olan konumu gibisin' demiştir."
  },
  {
    "ad": "Hz. Hamza (r.a.)",
    "unvan": "Seyyidü'ş-Şühedâ (Şehitlerin Efendisi)",
    "ozet": "Peygamber Efendimiz'in amcası, sütkardeşi ve İslam ordusunun en cesur komutanlarındandır. Uhud'da şehit düşmüştür.",
    "hayat": "Hz. Hamza, heybetli duruşu, iyi ok atışı ve avcılığıyla Mekke'de saygı duyulan güçlü bir yiğitti. Müşriklerin Peygamberimize eziyet ettiğini duyduğunda öfkeyle Kabe'ye giderek Müslüman olduğunu ilan etti. Bu olay Müslümanlara büyük bir moral ve güç kaynağı oldu. Medine'ye hicret ettikten sonra Bedir Savaşı'nda müşriklerin ileri gelen liderlerini tek başına etkisiz hale getirdi. Uhud Savaşı'nda kahramanca çarpışırken Vahşi'nin mızrağıyla şehit edildi.",
    "fazilet": "Uhud'da şehit olduktan sonra bedenine müşrikler tarafından saygısızlık edilmiş (ciğeri sökülmüş) ve Peygamberimiz onun bu hali karşısında gözyaşı dökerek ona 'Şehitlerin Efendisi' unvanını vermiştir.",
    "iliskisi": "Peygamberimizin amcası olmakla birlikte yaşça birbirlerine yakındılar ve beraber büyümüşlerdi. Aynı zamanda sütkardeş idiler. Peygamberimiz onun vefatına ömrü boyunca derinden üzülmüştür."
  },
  {
    "ad": "Hz. Bilâl-i Habeşî (r.a.)",
    "unvan": "Müezzin-i Resûl (Peygamber'in Müezzini)",
    "ozet": "İslam'ın ilk müezzini, Habeşistan asıllı ilk Müslüman kölelerden biridir. İşkencelere karşı 'Ehad (Tek Allah)' haykırışıyla meşhurdur.",
    "hayat": "Habeşistan asıllı bir köle olarak Mekke'de doğdu. Efendisi Ümeyye b. Halef, onun Müslüman olduğunu öğrenince kızgın kumlara yatırıp üzerine ağır taşlar koyarak dininden dönmesi için işkenceler yaptı. O ise her acı karşısında 'Ehad! Ehad! (Allah tektir!)' diye haykırdı. Onun bu durumunu gören Hz. Ebû Bekir, büyük bir meblağ ödeyerek onu satın aldı ve özgür bıraktı. Medine'de ezan ibadeti başlayınca ilk ezanı okuma şerefine nail oldu.",
    "fazilet": "İslam'ın ırkçılığı yok eden eşitlik ilkesinin en büyük sembolüdür. Peygamberimiz onun hakkında 'Cennette önümde Bilâl'in ayak seslerini duydum' buyurarak onun manevi derecesini müjdelemiştir.",
    "iliskisi": "Peygamber Efendimiz'in en sadık dostlarından ve hizmetkarlarındandır. Peygamberimizin vefatından sonra duyduğu derin hüzün sebebiyle Medine'de ezan okuyamamış ve Şam taraflarına gitmiştir. Yıllar sonra Medine'yi ziyaretinde okuduğu ezan tüm Medine halkını gözyaşlarına boğmuştur."
  }
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


const Map<String, dynamic> PEYGAMBER_REHBERI = {
  "donemler": [
    {
      "baslik": "Doğumu ve Çocukluk Yılları (571 - 583)",
      "yil": "571 - 583",
      "icerik": "Peygamber Efendimiz Hz. Muhammed (s.a.v.), 571 yılında (12 Rebiülevvel) Mekke'de yetim olarak doğdu. Babası Abdullah o doğmadan önce vefat etmişti. Annesi Âmine, onu temiz çöl havasında büyümesi ve fasih Arapça öğrenmesi için sütanne Halime Hanım'a emanet etti. 4 yaşına kadar Taif bölgesindeki çöl ortamında sütannesi ve süt kardeşleriyle yaşadı. 6 yaşına geldiğinde, annesi Âmine ile babasının Medine'deki kabrini ziyaretten dönerken Ebva köyünde annesi vefat etti. Yanlarında bulunan sadık dadısı Ümmü Eymen onu Mekke'ye getirip dedesi Abdülmuttalib'e teslim etti. 8 yaşında dedesini de kaybeden Peygamberimiz, amcası Ebû Tâlib'in himayesine girdi ve onunla ticaret kervanlarına katılarak Şam ve Yemen bölgelerine seyahat etti.",
      "ayet": "O, seni bir yetim iken bulup barındırmadı mı? Seni yolunu kaybetmiş olarak bulup doğru yola iletmedi mi? Seni muhtaç bulup zengin etmedi mi? (Duha Suresi, 6-8)",
      "ek_bilgi": "Süt Anneleri: Süveybe Hanım, Halime-i Sa'diyye • Dedesi: Abdülmuttalib • Amcası: Ebû Tâlib • Dadısı: Ümmü Eymen"
    },
    {
      "baslik": "Gençliği, Ticaret Hayatı ve Evliliği (583 - 610)",
      "yil": "583 - 610",
      "icerik": "Gençlik yıllarında dürüstlüğü, haramlardan uzak duruşu ve güvenilirliği sebebiyle Mekkeliler ona 'Muhammedü'l-Emîn' (Güvenilir Muhammed) unvanını verdi. 20'li yaşlarında Mekke'de asayişi sağlamak, haksızlığa uğrayan yabancı tüccarları ve mazlumları korumak amacıyla kurulan Hilfü'l-Fudûl (Erdemliler Birliği) topluluğuna katıldı. 25 yaşında, ahlakı ve güvenirliğine hayran kalan Hz. Hatice validemiz ile evlendi. Bu evlilikten Kasım, Abdullah, Zeynep, Rukiyye, Ümmü Gülsüm ve Fatıma dünyaya geldi. 35 yaşında Kâbe'nin tamiri sırasında Hacerü'l-Esved taşının yerine konulması hususunda kabileler arasında çıkan büyük anlaşmazlığı, hırkasını yere serip taşı kabile reislerine taşıtarak Kâbe Hakemliğiyle barışçıl bir şekilde çözdü.",
      "ayet": "Rabbin sana verecek, sen de hoşnut kalacaksın. (Duha Suresi, 5)",
      "ek_bilgi": "İlk Eşi: Hz. Hatice-i Kübra • Katıldığı Kurul: Hilfü'l-Fudûl • Hakemlik Yaşı: 35 (Kâbe Hakemliği)"
    },
    {
      "baslik": "Peygamberliğin Başlangıcı ve Mekke Dönemi (610 - 622)",
      "yil": "610 - 622",
      "icerik": "40 yaşına yaklaştığında Mekke'deki putperestlikten ve ahlaki yozlaşmadan uzaklaşarak Nur Dağı'ndaki Hira Mağarası'nda tefekküre çekilmeye başladı. 610 yılı Ramazan ayında Hira'da tefekkürde iken vahiy meleği Cebrail (a.s.) gelerek Alak Suresi'nin ilk beş ayetini ('Oku!') ulaştırdı. Peygamberliğini ilan eden Efendimiz'e ilk olarak eşi Hz. Hatice, Hz. Ebu Bekir, Hz. Ali ve kölesi Hz. Zeyd iman etti. İlk üç yıl daveti gizli yürüttü, ardından açık tebliğ emri gelince Safa Tepesi'nden tüm Mekke halkına seslendi. Müşrikler, İslam'ın yayılmasını engellemek için Müslümanlara işkence, boykot ve sosyal tecrit uygulamaya başladılar. 615 ve 616 yıllarında bazı Müslümanlar Habeşistan'a hicret etti. 619 yılında koruyucusu Ebu Talib'i ve eşi Hz. Hatice'yi kaybetmesiyle bu yıla 'Hüzün Yılı' denildi. Taif'e giderek sığınacak yer aradı ancak taşlanarak şehirden çıkarıldı. Hemen ardından İsra ve Miraç mucizeleriyle teselli edildi.",
      "ayet": "Şüphesiz sen yüce bir ahlâk üzeresin. (Kalem Suresi, 4)",
      "ek_bilgi": "İlk Vahiy: Alak Suresi, 1-5 • Hüzün Yılı: Ebu Talib ve Hz. Hatice'nin vefatı (619) • Mucizeler: İsra ve Miraç (620)"
    },
    {
      "baslik": "Medine'ye Hicret ve Devletin Kuruluşu (622 - 624)",
      "yil": "622 - 624",
      "icerik": "Mekkeli müşriklerin Müslümanlar üzerindeki baskıları katlanılamaz boyuta ulaşınca ve Peygamberimiz'i öldürme planları yapınca, Medineli Müslümanlarla yapılan Akabe Biatları neticesinde hicret kararı alındı. Peygamberimiz, Hz. Ebu Bekir ile birlikte Sevr Mağarası'nda üç gün saklandıktan sonra mucizelerle dolu bir yolculuğun ardından Medine'ye ulaştı. Medine'ye girmeden önce Kuba'da ilk mescidi inşa etti. Medine'ye varınca Ensar (Medineli Müslümanlar) ile Muhacir (Mekke'den göç edenler) arasında sarsılmaz bir kardeşlik köprüsü kurdu (Muahat). Yahudiler, müşrikler ve Müslümanlar arasında barış içinde yaşama prensiplerini belirleyen, tarihin ilk yazılı anayasası niteliğindeki Medine Vesikası'nı imzaladı ve Mescid-i Nebevî'nin inşasını başlattı.",
      "ayet": "Eğer siz ona yardım etmezseniz, bilin ki inkâr edenler onu Mekke'den çıkardıklarında mağaradaki iki kişiden biri olarak Allah ona yardım etmişti. (Tevbe Suresi, 40)",
      "ek_bilgi": "Hicret Yılı: 622 • Yol Arkadaşı: Hz. Ebû Bekir (r.a.) • İlk İnşa Edilen Mescid: Kuba Mescidi • Kardeşlik: Muahat Anlaşması"
    },
    {
      "baslik": "Savunma Mücadeleleri ve Hudeybiye Barışı (624 - 628)",
      "yil": "624 - 628",
      "icerik": "Medine'de kurulan İslam Devleti'ni yok etmek isteyen Mekkeli müşriklerin saldırılarına karşı koymak için Bedir, Uhud ve Hendek savaşları yapıldı. 624 yılında yapılan Bedir Savaşı'nda Müslümanlar kendilerinden üç kat güçlü müşrik ordusunu mağlup etti. 625 yılındaki Uhud Savaşı'nda okçuların tepeyi izinsiz terk etmesi sonucu Müslümanlar kayıplar verdi, Peygamberimiz yaralandı ve Hz. Hamza şehit oldu. 627 yılındaki Hendek Savaşı'nda ise Medine çevresine büyük hendekler kazılarak başarılı bir savunma yapıldı. 628 yılında Müslümanlar Kabe'yi ziyaret etmek amacıyla Mekke'ye yürüdü. Yapılan müzakereler sonucu 10 yıllık bir barış süreci başlatan Hudeybiye Antlaşması imzalanarak barış sağlandı. Bu antlaşma sayesinde İslam barışçıl ortamda hızla yayıldı.",
      "ayet": "Şüphesiz biz sana apaçık bir fetih ihsan ettik. (Fetih Suresi, 1)",
      "ek_bilgi": "Bedir Savaşı: 624 • Uhud Savaşı: 625 • Hendek Savaşı: 627 • Hudeybiye Barış Antlaşması: 628"
    },
    {
      "baslik": "Mekke'nin Fethi, Veda Haccı ve Vefatı (630 - 632)",
      "yil": "630 - 632",
      "icerik": "Mekkeli müşriklerin Hudeybiye Barış Antlaşması'nı ihlal etmesi üzerine, Peygamber Efendimiz 630 yılında 10.000 kişilik muazzam bir ordu ile Mekke üzerine yürüdü. Şehir neredeyse hiç kan dökülmeden fethedildi. Peygamberimiz Kâbe'ye girerek tüm putları kırdı ve ardından kendisine 20 yıl boyunca zulmeden Mekkelileri genel af ilan ederek serbest bıraktı. 632 yılında yüz binden fazla Müslüman ile Veda Haccı'nı gerçekleştirdi ve Arafat'ta insan hakları, adalet, kadın hakları ve eşitlik esaslarını vurgulayan Veda Hutbesi'ni irat etti. Medine'ye döndükten sonra hastalanarak 8 Haziran 632 tarihinde vefat etti. Mübarek kabri, Medine'deki Mescid-i Nebevî'de, vefat ettiği Hz. Aişe validemizin odasındadır (Ravza-i Mutahhara).",
      "ayet": "Bugün sizin için dininizi kemale erdirdim. Üzerinizdeki nimetimi tamamladım ve sizin için din olarak İslam'dan razı oldum. (Maide Suresi, 3)",
      "ek_bilgi": "Mekke'nin Fethi: 630 • Veda Hutbesi Sahabe Sayısı: 100.000+ • Vefat Tarihi: 8 Haziran 632 • Defnedildiği Yer: Ravza-i Mutahhara"
    }
  ],
  "semail": [
    {
      "baslik": "Fiziki Görünüşü (Hilye-i Şerif)",
      "detay": "Peygamber Efendimiz'in (s.a.v.) mübarek hilyesini sahabiler şöyle tarif eder: Orta boyluydu; ne aşırı uzun ne de dikkat çekecek kadar kısaydı. Ten rengi ne kireç gibi beyaz ne de koyu esmerdi; beyazla kırmızının karışımı, parlak ve nurlu bir cilde sahipti. Gözleri siyah, son derece iri ve berraktı; kirpikleri uzun ve sıktı. Mübarek dişleri inci gibi parlar, konuştuğunda ön dişlerinin arasından nur süzülürdü. Saçları aşırı kıvırcık ya da dümdüz olmayıp dalgalıydı; sakalı gür ve heybetliydi. Alnı geniş, iki omuzu arası enliydi. Göğsünden göbeğine kadar ince bir kıl şeridi uzanırdı. İki omuzu arasında peygamberlik mührü (Nübüvvet Mührü) bulunmaktaydı."
    },
    {
      "baslik": "Yürüyüşü ve Duruşu",
      "detay": "Peygamberimiz yürürken adımlarını geniş atar, sanki yüksek bir yokuştan aşağı iniyormuş gibi hafifçe öne doğru eğilerek vakarlı ve hızlı adımlarla yürürdü. Arkasından seslenen birine sadece başını çevirerek değil, bütün vücuduyla yönelerek hitap ederdi. Bu duruşu muhatabına verdiği ehemmiyeti gösterirdi. Son derece heybetli bir duruşu vardı; ancak bu heybet korkutucu değil, saygı ve sevgi uyandırıcıydı. Oturduğu zaman mecliste en mütevazı köşeyi seçer, çevresindekileri rahatsız edecek şekilde kurulmazdı."
    },
    {
      "baslik": "Mübarek Kokusu ve Sesi",
      "detay": "Efendimiz'in teni ve teri son derece güzel kokardı. Sahabiler, onun geçtiği yolları mübarek kokusundan tanırlardı. Kendisiyle tokalaşan bir sahabi, gün boyu elinde o güzel kokuyu hissederdi. Bebekleri ve çocukları sevip başlarını okşadığında, o çocuklar arkadaşları arasında mis gibi kokularıyla fark edilirdi. Konuştuğunda sesi son derece gür, tatlı ve etkileyiciydi. Kelimeleri tane tane telaffuz eder, dinleyenler dilerse söylediklerini ezberleyebilirdi. Konuşurken gereksiz yere sözü uzatmaz, 'Cevâmiu'l-Kelim' (Az sözle çok mana ifade etme) yeteneğine sahipti."
    }
  ],
  "ahlak": [
    {
      "baslik": "Muhammedü'l-Emin (Güvenilirliği)",
      "detay": "Daha İslam tebliğ edilmeden önce Mekke halkı ona 'Emin' lakabını takmıştı. Hayatında bir kez olsun yalan söylememiş, şaka dahi olsa kimseyi aldatmamıştır. İslam'a en düşman olanlar bile dürüstlüğünü kabul ederdi. Hicret gecesi kendisini öldürmek için evini saran müşriklerin ona bıraktığı emanetleri, canını hiçe sayarak Hz. Ali'yi yatağında bırakmak suretiyle sahiplerine iade etmiştir. Düşmanının dahi emanetine hıyanet etmeyen bir ahlaka sahipti."
    },
    {
      "baslik": "Eşsiz Merhameti ve Taif Kıssası",
      "detay": "Mekke'de zulüm doruğa ulaştığında, destek bulmak için Taif şehrine gitti. Ancak Taif liderleri köleleri ve çocukları kışkırtarak Peygamberimiz'i taşlattılar. Ayakları kan içinde kalan Efendimiz, bir bağa sığındı. Cebrail (a.s.) gelerek dağlar meleğinin emrinde olduğunu ve dilerse Taif halkını iki dağ arasında helak edebileceğini söyledi. Ancak merhamet abidesi olan Efendimiz: 'Hayır, ben azap için değil, rahmet olarak gönderildim. Ben onların helak olmasını değil, nesillerinden Allah'a ibadet edecek muvahidlerin gelmesini dilerim' diyerek onlar için dua etti."
    },
    {
      "baslik": "Mekke'nin Fethi ve Genel Af Anekdotu",
      "detay": "630 yılında Mekke fethedildiğinde, Müslümanlara 20 yıl boyunca işkence etmiş, yurtlarından sürmüş ve savaş açmış olan Mekkeliler Kâbe'nin çevresinde korkuyla Efendimiz'in vereceği kararı bekliyordu. Peygamberimiz onlara: 'Şimdi benden size ne yapacağımı bekliyorsunuz?' diye sordu. Mekkeliler: 'Sen kerim bir kardeşsin, kerim bir kardeş oğlusun' dediler. Efendimiz, tarihte eşi benzeri görülmemiş bir kararla: 'Bugün size kınama yoktur. Gidiniz, hepiniz serbestsiniz!' buyurarak kendisine ve ashabına zulmeden azılı düşmanlarını tamamen affetti."
    },
    {
      "baslik": "Adaleti ve Kendi Üzerindeki Kısası",
      "detay": "Adalet konusunda asla taviz vermez, zengin-fakir ayrımı yapmazdı. Bir gün asil bir kabilenden hırsızlık yapan kadının affedilmesi için aracı olan Hz. Üsame'ye çok kızarak: 'Geçmiş milletler, aralarındaki soylular suç işleyince onları affedip fakirleri cezalandırdıkları için helak oldular. Allah'a yemin ederim ki, kızım Fatıma dahi hırsızlık yapsaydı elini keserdim' buyurdu. Vefatına yakın bir süre kala mescitte ashabını toplayarak: 'Kimin sırtına vurduysam işte sırtım, gelsin vursun. Kimin malını aldıysam işte malım, gelsin alsın' diyerek kul hakkına gösterdiği titizliği kısas hakkı vererek göstermiştir."
    },
    {
      "baslik": "Tevazuu ve Müşterek Hayat Kıssası",
      "detay": "Devlet başkanı ve peygamber olmasına rağmen ashabından ayırt edilmek istemezdi. Bir yolculuk sırasında ashabı yemek yapmak için iş bölümü yaptı. Biri koyunu kesmeyi, diğeri yüzmeyi üstlendi. Efendimiz de: 'Odun toplamayı da ben üstleniyorum' buyurdu. Sahabiler: 'Ey Allah'ın Resulü, biz o işi de yaparız, siz yorulmayın' deyince: 'Sizin benim işimi yapacağınızı biliyorum. Fakat ben sizden ayrıcalıklı bir konumda bulunmaktan hoşlanmam. Şüphesiz Allah, kulunun arkadaşları arasında ayrıcalıklı görünmesinden hoşlanmaz' buyurarak bizzat odun toplamıştır."
    }
  ],
  "aile": {
    "anne_baba": [
      {
        "ad": "Abdullah bin Abdulmuttalib",
        "rol": "Babası",
        "bilgi": "Kureyş'in en yakışıklı ve saygın gençlerinden biriydi. Ticaret için gittiği Şam yolculuğundan dönerken Medine'de hastalanarak genç yaşta vefat etti. Peygamberimiz henüz anne karnında iken yetim kaldı."
      },
      {
        "ad": "Âmine bint Vehb",
        "rol": "Annesi",
        "bilgi": "Zühreoğulları kabilesinin saygın bir hanımıydı. Peygamberimiz 6 yaşında iken Medine dönüşü Ebva köyünde vefat etti. Kabri Ebva'dadır."
      },
      {
        "ad": "Halime-i Sa'diyye",
        "rol": "Süt Annesi",
        "bilgi": "Sa'doğulları kabilesindendir. Peygamberimiz'i 4 yaşına kadar emzirip büyütmüştür. Evine Peygamberimiz'in gelişiyle büyük bir bereket yayılmıştır."
      },
      {
        "ad": "Ebû Tâlib",
        "rol": "Amcası",
        "bilgi": "Dedesi Abdülmuttalib'in vefatından sonra 8 yaşından itibaren Peygamberimiz'i evine almış, öz evladı gibi büyütmüş ve peygamberliği döneminde müşriklere karşı onu hep korumuştur."
      }
    ],
    "esleri": [
      {
        "ad": "Hz. Hatice-i Kübra (r.anha)",
        "bilgi": "Peygamberimiz'in ilk eşidir. 25 yıl evli kalmışlardır. İslam'ı kabul eden ilk kişidir. Peygamberimiz'e en zor zamanlarında canıyla ve malıyla en büyük desteği vermiştir. Efendimiz'in Hz. İbrahim dışındaki tüm çocuklarının annesidir."
      },
      {
        "ad": "Hz. Aişe-i Sıddıka (r.anha)",
        "bilgi": "Hz. Ebu Bekir'in kızıdır. İslam fıkhı, hadis ve tefsir ilminde sahabenin önde gelen alimlerindendir. Peygamberimiz'den 2000'den fazla hadis rivayet etmiştir."
      },
      {
        "ad": "Hz. Sevde bint Zema (r.anha)",
        "bilgi": "Hz. Hatice'nin vefatından sonra evlendiği ikinci eşidir. Yetimlerin bakımında ve ev işlerinde Peygamberimiz'e büyük destek olmuştur."
      },
      {
        "ad": "Hz. Hafsa bint Ömer (r.anha)",
        "bilgi": "Hz. Ömer'in kızıdır. Okuma yazma bilen, ibadete son derece düşkün bir hanımdı. Hz. Ebu Bekir döneminde mushaf haline getirilen Kur'an-ı Kerim nüshası ona emanet edilmiştir."
      },
      {
        "ad": "Hz. Ümmü Seleme (r.anha)",
        "bilgi": "Mekke'nin ilk Müslümanlarındandır. Eşi Uhud'da şehit düştükten sonra Efendimiz'in himayesine girmiştir. Son derece zeki ve ferasetli bir hanımdı; Hudeybiye antlaşmasında verdiği fikirle sahabenin kurban kesmesini sağlamıştır."
      },
      {
        "ad": "Hz. Zeynep bint Cahş (r.anha)",
        "bilgi": "Efendimiz'in halasının kızıdır. El işi yapar, kazandığını fakirlere ve yetimlere cömertçe dağıtırdı. Cömertliğiyle bilinirdi."
      },
      {
        "ad": "Hz. Safiyye bint Huyey (r.anha)",
        "bilgi": "Hayber fethi sonrası Müslüman olmuş ve Efendimiz ile evlenmiştir. İbadete, cömertliğe ve sadakate düşkünlüğüyle bilinirdi."
      },
      {
        "ad": "Hz. Mariye-i Kıbtiyye (r.anha)",
        "bilgi": "Mısır Mukavkısı tarafından hediye olarak gönderilmiş, Müslüman olduktan sonra Efendimiz ile evlenmiştir. Peygamberimiz'in en küçük oğlu Hz. İbrahim'in annesidir."
      }
    ],
    "cocuklari": [
      {
        "ad": "Kâsım",
        "bilgi": "Efendimiz'in ilk çocuğudur. Çok küçük yaşta Mekke'de vefat etmiştir. Peygamberimiz bu sebeple 'Ebu'l-Kasım' (Kasım'ın Babası) künyesini almıştır."
      },
      {
        "ad": "Hz. Zeynep (r.anha)",
        "bilgi": "Efendimiz'in en büyük kızıdır. Ebu'l-As ile evlenmiştir. Medine'ye hicret esnasında büyük zorluklar çekmiş, genç yaşta vefat etmiştir."
      },
      {
        "ad": "Hz. Rukiyye (r.anha)",
        "bilgi": "Hz. Osman ile evlenmiştir. Habeşistan'a ilk hicret eden grupta yer almıştır. Bedir Savaşı günlerinde Medine'de vefat etmiştir."
      },
      {
        "ad": "Hz. Ümmü Gülsüm (r.anha)",
        "bilgi": "Ablası Rukiyye'nin vefatından sonra Hz. Osman ile evlenmiştir. Hz. Osman'a bu evlilik sebebiyle 'Zinnûreyn' (İki nurlu) denmiştir."
      },
      {
        "ad": "Hz. Fâtımatü'z-Zehra (r.anha)",
        "bilgi": "Efendimiz'in en sevgili kızıdır. Hz. Ali ile evlenmiştir. Efendimiz'in soyu onun çocukları Hz. Hasan ve Hz. Hüseyin üzerinden devam etmiştir. Efendimiz'in vefatından 6 ay sonra vefat etmiştir."
      },
      {
        "ad": "Abdullah",
        "bilgi": "Mekke'de peygamberlik geldikten sonra doğmuş, 'Tayyib' ve 'Tahir' lakaplarıyla anılmıştır. Küçük yaşta vefat etmiştir."
      },
      {
        "ad": "İbrahim",
        "bilgi": "Peygamberimiz'in Hz. Mariye validemizden doğan en küçük oğludur. 1.5 yaşında Medine'de vefat etmiştir. Vefat ettiği gün güneş tutulması gerçekleşmiştir."
      }
    ]
  },
  "gazveler": [
    {
      "ad": "Bedir Savaşı (624 / Hicri 2)",
      "detay": "Müslümanlar ile Mekkeli müşrikler arasındaki ilk büyük savaştır. Müşriklerin Şam kervanından elde edilen ganimetleri korumak bahanesiyle 1000 kişilik bir orduyla çıkmasına karşın Müslümanlar 313 kişiyle karşı koydular. Allah'ın yardımıyla Müslümanlar zafer kazandı. Ebu Cehil dahil 70 müşrik öldürüldü, 70'i esir alındı. Esirlerden okuma-yazma bilenler, 10 Müslümana okuma-yazma öğretme karşılığında serbest bırakılarak okumaya verilen önem gösterildi.",
      "sonuc": "Müslümanlar kesin zafer kazandı. İslam Devleti'nin gücü kanıtlandı.",
      "ders": "Sayıca az olunsa bile inanç, istişare ve Allah'ın yardımıyla büyük zaferler kazanılabilir."
    },
    {
      "ad": "Uhud Savaşı (625 / Hicri 3)",
      "detay": "Mekkelilerin Bedir'in intikamını almak için 3000 kişilik orduyla Medine'ye saldırması üzerine yapıldı. Peygamberimiz Uhud Dağı'ndaki bir geçide kritik 50 okçu yerleştirdi ve 'Kuşların cesetlerimizi kapıştığını görseniz bile yerinizi terk etmeyiniz' talimatını verdi. Savaşın başında Müslümanlar üstün geldi. Ancak okçular savaşın kazanıldığını sanıp yerlerini terk edince, Halid bin Velid komutasındaki müşrik süvarileri arkadan saldırdı. Peygamberimiz yaralandı, Hz. Hamza dahil 70 sahabe şehit oldu.",
      "sonuc": "Müslümanlar disiplinsizlik sebebiyle büyük kayıplar verdi ve savaş berabere/müşrik üstünlüğüyle bitti.",
      "ders": "Peygamber'in (Liderin) emirlerine itaatin ve disiplinin ne kadar hayati olduğu acı bir tecrübeyle öğrenildi."
    },
    {
      "ad": "Hendek Savaşı (627 / Hicri 5)",
      "detay": "Yahudilerin kışkırtmasıyla müşrikler ve müttefik kabileler 10.000 kişilik dev bir orduyla Medine'yi kuşattı. Selman-ı Farisi'nin (r.a.) teklifi üzerine Medine'nin düzlük yerlerine atların ve insanların aşamayacağı genişlikte derin hendekler kazıldı. Kuşatma yaklaşık 1 ay sürdü. Müşrikler hendeği aşamadı. Çıkan şiddetli fırtına ve soğuk hava nedeniyle müşrik ordusu perişan oldu ve kuşatmayı kaldırıp Mekke'ye geri çekilmek zorunda kaldı.",
      "sonuc": "Müslümanlar başarılı bir stratejiyle Medine'yi korudu. Müşriklerin son taarruzu oldu, savunma sırası Müslümanlara geçti.",
      "ders": "Askeri stratejide yenilikçi fikirlere (Hendek kazma) ve sabra dayalı ortak akıl başarının anahtarıdır."
    },
    {
      "ad": "Mekke'nin Fethi (630 / Hicri 8)",
      "detay": "Kureyşlilerin Hudeybiye barış antlaşmasını bozmaları üzerine Efendimiz 10.000 kişilik muazzam bir orduyla Mekke'ye hareket etti. Kimsenin kanının dökülmesini istemeyen Efendimiz, orduyu gizli tutarak Mekke'ye ani giriş yaptı. Savaşsız ve kansız bir şekilde Mekke fethedildi. Efendimiz Kabe'yi putlardan temizledi ve Kabe'nin kapısında bekleyen Mekkelilere genel af ilan ederek İslam'ın merhamet dini olduğunu tüm dünyaya gösterdi.",
      "sonuc": "Mekke kan dökülmeden fethedildi. Hicaz bölgesinde putperestlik tamamen son buldu.",
      "ders": "Zafer anında kibirlenmeyip tevazu göstermek ve intikam yerine affetmeyi seçmek en büyük ahlaki zaferdir."
    }
  ],
  "hadis_sunnet": [
    {
      "kategori": "Yeme ve İçme Sünnetleri",
      "detaylar": [
        "Yemeğe mutlaka besmele ('Bismillahirrahmanirrahim') ile başlamak.",
        "Yemeği sağ el ile yemek ve önünden almak.",
        "Yemek kabına veya bardağa nefes vermemek, suyu üç yudumda dinlenerek içmek.",
        "Sofradan tam doymadan kalkmak (Midenin üçte birini yemeğe, üçte birini suya, üçte birini nefese ayırmak).",
        "Lokmaları küçük almak ve iyice çiğnemek.",
        "Yemekten sonra elhamdülillah diyerek şükretmek ve elleri yıkamak."
      ]
    },
    {
      "kategori": "Kişisel Temizlik Sünnetleri",
      "detaylar": [
        "Misvak kullanmak (Her abdestte ve namaz öncesinde dişleri temizlemek).",
        "Güzel koku (misk/amber) sürünmek.",
        "Tırnakları cuma günleri kesmek.",
        "Saç ve sakal bakımına özen göstermek, temiz tutup taramak.",
        "Kıyafet temizliğine dikkat etmek ve sade giyinmek.",
        "Abdest organlarını kurulamak ve temiz tutmak."
      ]
    },
    {
      "kategori": "Sosyal İlişkiler Sünnetleri",
      "detaylar": [
        "Selamlaşmayı yaymak (Tanıdığı ve tanımadığı herkese selam vermek).",
        "Konuşurken muhatabına doğru dönmek ve göz teması kurmak.",
        "İnsanlara tebessüm etmek (Tebessüm etmek sadakadır).",
        "Hediyeleşmek (Hediyeleşin ki birbirinize olan sevginiz artsın).",
        "Söz verildiğinde sözünde durmak.",
        "Gıybet yapmamak, başkalarının kusurlarını örtmek."
      ]
    },
    {
      "kategori": "Uyku ve Dinlenme Sünnetleri",
      "detaylar": [
        "Uyumadan önce abdest almak.",
        "Sağ taraf üzerine yatıp sağ eli yanağın altına koyarak uzanmak.",
        "Uyumadan önce İhlas, Felak ve Nas surelerini okuyup avuç içine üfleyerek vücudu mesh etmek.",
        "Yatsı namazından sonra gereksiz konuşmaları bırakıp erken uyumak.",
        "Sabah namazı vaktinde uyanık olmak, güneş doğana kadar uyumamak.",
        "Günün ortasında (Öğle sıcağında) 'Kaylule' uykusuyla kısa bir süre dinlenmek."
      ]
    }
  ],
  "zaman_cizelgesi": [
    {
      "yil": "571",
      "olay": "Peygamber Efendimiz'in Mekke'de Dünyaya Gelişi",
      "ikon": "👶"
    },
    {
      "yil": "577",
      "olay": "Annesi Âmine Hanım'ın vefatı (Ebvâ Köyü)",
      "ikon": "😢"
    },
    {
      "yil": "579",
      "olay": "Dedesi Abdülmuttalib'in vefatı",
      "ikon": "👴"
    },
    {
      "yil": "596",
      "olay": "Hz. Hatice validemiz ile evliliği ve ticari ortaklığı",
      "ikon": "💍"
    },
    {
      "yil": "605",
      "olay": "Kâbe Hakemliği (Hacerü'l-Esved'in yerine konması)",
      "ikon": "🕋"
    },
    {
      "yil": "610",
      "olay": "İlk Vahiy ve Peygamberlik Görevinin Başlaması (Cebrail ile Hira'da)",
      "ikon": "📖"
    },
    {
      "yil": "615",
      "olay": "Baskılar nedeniyle Habeşistan'a ilk hicretin gerçekleşmesi",
      "ikon": "⛵"
    },
    {
      "yil": "619",
      "olay": "Hüzün Yılı (Amcası Ebu Talib ve Eşi Hz. Hatice'nin vefatı)",
      "ikon": "🖤"
    },
    {
      "yil": "620",
      "olay": "İsra ve Miraç Mucizesi",
      "ikon": "✨"
    },
    {
      "yil": "622",
      "olay": "Akabe Biatları ve Medine'ye Büyük Hicret",
      "ikon": "🐫"
    },
    {
      "yil": "624",
      "olay": "Müşriklere karşı Bedir Savaşı Zaferi",
      "ikon": "⚔️"
    },
    {
      "yil": "625",
      "olay": "Uhud Savaşı ve Hz. Hamza'nın şehit edilişi",
      "ikon": "🛡️"
    },
    {
      "yil": "627",
      "olay": "Hendek Savaşı ve savunma hattının kurulması",
      "ikon": "🪵"
    },
    {
      "yil": "628",
      "olay": "Hudeybiye Barış Antlaşması ve Hayber Kalesi'nin Fethi",
      "ikon": "📜"
    },
    {
      "yil": "630",
      "olay": "Mekke'nin Fethi ve Kâbe'nin putlardan arındırılması",
      "ikon": "🔓"
    },
    {
      "yil": "632",
      "olay": "Veda Haccı, Veda Hutbesi ve Peygamberimiz'in vefatı",
      "ikon": "🕌"
    }
  ],
  "hadisler_secme": [
    {
      "no": 1,
      "metin": "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.",
      "kaynak": "Buhârî, İlim, 11"
    },
    {
      "no": 2,
      "metin": "İnsanların en hayırlısı, insanlara faydalı olanıdır.",
      "kaynak": "Taberânî, el-Mu'cemü'l-Evsat"
    },
    {
      "no": 3,
      "metin": "Müslüman, dilinden ve elinden Müslümanların güvende olduğu kimsedir.",
      "kaynak": "Buhârî, Îmân, 4"
    },
    {
      "no": 4,
      "metin": "Sizden biriniz, kendisi için istediğini din kardeşi için de istemedikçe tam iman etmiş olmaz.",
      "kaynak": "Buhârî, Îmân, 7"
    },
    {
      "no": 5,
      "metin": "Dua, ibadetin özüdür.",
      "kaynak": "Tirmizî, Tefsîru Sûre, 40"
    },
    {
      "no": 6,
      "metin": "Temizlik, imanın yarısıdır.",
      "kaynak": "Müslim, Tahâret, 1"
    },
    {
      "no": 7,
      "metin": "Hiçbir anne baba, evladına güzel ahlaktan daha değerli bir miras bırakamaz.",
      "kaynak": "Tirmizî, Birr, 33"
    },
    {
      "no": 8,
      "metin": "Gerçek zenginlik mal çokluğu ile değildir. Gerçek zenginlik gönül zenginliğidir.",
      "kaynak": "Buhârî, Rikâk, 15"
    },
    {
      "no": 9,
      "metin": "Güzel söz söylemek sadakadır.",
      "kaynak": "Buhârî, Cihâd, 128"
    },
    {
      "no": 10,
      "metin": "Allah katında amellerin en sevimlisi, az da olsa devamlı olanıdır.",
      "kaynak": "Buhârî, Rikâk, 18"
    }
  ]
};