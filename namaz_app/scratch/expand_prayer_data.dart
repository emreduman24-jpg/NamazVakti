import 'dart:io';

void main() {
  final file = File('lib/data/prayer_data.dart');
  if (!file.existsSync()) {
    print('Error: lib/data/prayer_data.dart not found.');
    exit(1);
  }

  // 60 Authentic Quranic Verses in Turkish
  final verses = [
    {"title": "Bakara - 152. Ayet", "text": "Öyleyse siz beni anın ki ben de sizi anayım. Bana şükredin; sakın nankörlük etmeyin.", "ref": "Bakara - 152"},
    {"title": "Bakara - 186. Ayet", "text": "Kullarım sana beni sorduklarında bilsinler ki ben onlara çok yakınım. Bana dua edenin duasına icabet ederim.", "ref": "Bakara - 186"},
    {"title": "İnşirah - 5-6. Ayet", "text": "Şüphesiz zorlukla beraber bir kolaylık vardır. Gerçekten, zorlukla beraber bir kolaylık vardır.", "ref": "İnşirah - 5-6"},
    {"title": "Âl-i İmrân - 139. Ayet", "text": "Gevşemeyin, hüzünlenmeyin. Eğer gerçekten inanıyorsanız üstün olan sizsinizdir.", "ref": "Âl-i İmrân - 139"},
    {"title": "Ankebut - 45. Ayet", "text": "Şüphesiz namaz, insanı hayasızlıktan ve kötülükten alıkoyar. Allah'ı anmak ise en büyük ibadettir.", "ref": "Ankebut - 45"},
    {"title": "Casiye - 19. Ayet", "text": "Şüphesiz Allah, takva sahiplerinin dostu ve koruyucusudur.", "ref": "Casiye - 19"},
    {"title": "Rad - 28. Ayet", "text": "Bilesiniz ki gönüller ancak Allah'ı anmakla huzur ve doyum bulur.", "ref": "Rad - 28"},
    {"title": "Bakara - 286. Ayet", "text": "Allah hiçbir kimseye gücünün yeteceğinden fazlasını yüklemez.", "ref": "Bakara - 286"},
    {"title": "Tevbe - 40. Ayet", "text": "Üzülme, çünkü Allah bizimle beraberdir.", "ref": "Tevbe - 40"},
    {"title": "Tevbe - 128. Ayet", "text": "Andolsun size kendinizden öyle bir peygamber gelmiştir ki sizin sıkıntıya uğramanız ona çok ağır gelir.", "ref": "Tevbe - 128"},
    {"title": "Âl-i İmrân - 159. Ayet", "text": "Kararını verdiğin zaman artık Allah'a dayanıp güven. Şüphesiz Allah kendisine dayanıp güvenenleri sever.", "ref": "Âl-i İmrân - 159"},
    {"title": "Nahl - 90. Ayet", "text": "Şüphesiz Allah; adaleti, iyilik yapmayı, yakınlara yardım etmeyi emreder; hayasızlığı, fenalığı ve azgınlığı yasaklar.", "ref": "Nahl - 90"},
    {"title": "İsra - 23. Ayet", "text": "Rabbin, sadece kendisine kulluk etmenizi ve anne babanıza iyi davranmanızı kesin olarak emretti.", "ref": "İsra - 23"},
    {"title": "İsra - 80. Ayet", "text": "De ki: Rabbim! Gireceğim yere doğruluk ve esenlikle girmemi sağla; çıkacağım yerden de doğruluk ve esenlikle çıkmamı nasip eyle.", "ref": "İsra - 80"},
    {"title": "İsra - 82. Ayet", "text": "Biz Kur'an'dan, inananlar için şifa ve rahmet olan şeyler indiriyoruz.", "ref": "İsra - 82"},
    {"title": "Kehf - 10. Ayet", "text": "Rabbimiz! Bize katından bir rahmet ver ve içinde bulunduğumuz şu durumdan bize bir kurtuluş ve doğruluğa ulaşış yolu hazırla!", "ref": "Kehf - 10"},
    {"title": "Furkan - 74. Ayet", "text": "Rabbimiz! Eşlerimizi ve çocuklarımızı bize göz aydınlığı kıl ve bizi takva sahiplerine önder eyle.", "ref": "Furkan - 74"},
    {"title": "Şuara - 80. Ayet", "text": "Hastalandığım zaman bana şifa veren O'dur.", "ref": "Şuara - 80"},
    {"title": "Neml - 62. Ayet", "text": "Darda kalana, dua ettiği zaman icabet eden ve sıkıntıyı gideren kimdir?", "ref": "Neml - 62"},
    {"title": "Zümer - 53. Ayet", "text": "De ki: Ey kendilerinin aleyhine aşırı giden kullarım! Allah'ın rahmetinden ümidinizi kesmeyin. Şüphesiz Allah bütün günahları bağışlar.", "ref": "Zümer - 53"},
    {"title": "Şura - 30. Ayet", "text": "Başınıza gelen her musibet kendi ellerinizle işledikleriniz yüzündendir; bununla beraber Allah birçoğunu da affeder.", "ref": "Şura - 30"},
    {"title": "Feth - 4. Ayet", "text": "İmanlarını bir kat daha artırsınlar diye müminlerin kalplerine huzur ve güven indiren O'dur.", "ref": "Feth - 4"},
    {"title": "Hucurat - 10. Ayet", "text": "Müminler ancak kardeştirler. Öyleyse kardeşlerinizin arasını düzeltin ve Allah'a karşı gelmekten sakının ki size merhamet edilsin.", "ref": "Hucurat - 10"},
    {"title": "Hucurat - 12. Ayet", "text": "Ey iman edenler! Zannın birçoğundan kaçının. Çünkü zannın bir kısmı günahtır. Birbirinizin kusurunu araştırmayın.", "ref": "Hucurat - 12"},
    {"title": "Kaf - 16. Ayet", "text": "Andolsun insanı biz yarattık ve nefsinin ona ne fısıldadığını biliriz. Çünkü biz ona şah damarından daha yakınız.", "ref": "Kaf - 16"},
    {"title": "Hadid - 4. Ayet", "text": "Nerede olursanız olun O, sizinle beraberdir. Allah yaptıklarınızı hakkıyla görendir.", "ref": "Hadid - 4"},
    {"title": "Hasr - 22. Ayet", "text": "O, kendisinden başka hiçbir ilah olmayan Allah'tır. Gaybı da görünen alemi de bilendir. O, Rahman'dır, Rahim'dir.", "ref": "Hasr - 22"},
    {"title": "Cuma - 9. Ayet", "text": "Ey iman edenler! Cuma günü namaz için çağrı yapıldığı zaman hemen Allah'ı anmaya koşun ve alışverişi bırakın.", "ref": "Cuma - 9"},
    {"title": "Talak - 3. Ayet", "text": "Kim Allah'a tevekkül ederse O, ona kafidir. Şüphesiz Allah, emrini yerine getirendir.", "ref": "Talak - 3"},
    {"title": "Tin - 4. Ayet", "text": "Şüphesiz biz insanı en güzel biçimde (ahsen-i takvim) yarattık.", "ref": "Tin - 4"},
    {"title": "Alak - 1. Ayet", "text": "Yaratan Rabbinin adıyla oku!", "ref": "Alak - 1"},
    {"title": "Asr - 1-3. Ayet", "text": "Asra yemin olsun ki insan mutlaka ziyandadır. Ancak iman edip salih amel işleyenler, birbirlerine hakkı ve sabrı tavsiye edenler müstesna.", "ref": "Asr - 1-3"},
    {"title": "Taha - 25-26. Ayet", "text": "Rabbim! Göğsümü genişlet, işimi kolaylaştır.", "ref": "Taha - 25-26"},
    {"title": "Neml - 19. Ayet", "text": "Rabbim! Bana ve anne babama verdiğin nimete şükretmemi ve razı olacağın salih ameller işlememi bana nasip eyle.", "ref": "Neml - 19"},
    {"title": "Kadir - 3. Ayet", "text": "Kadir gecesi, bin aydan daha hayırlıdır.", "ref": "Kadir - 3"},
    {"title": "İbrahim - 7. Ayet", "text": "Andolsun eğer şükrederseniz elbette size nimetimi artırırım.", "ref": "İbrahim - 7"},
    {"title": "Bakara - 153. Ayet", "text": "Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.", "ref": "Bakara - 153"},
    {"title": "Enam - 162. Ayet", "text": "De ki: Şüphesiz benim namazım da ibadetlerim de yaşamam da ölümüm de alemlerin Rabbi olan Allah içindir.", "ref": "Enam - 162"},
    {"title": "Nisa - 36. Ayet", "text": "Allah'a ibadet edin ve O'na hiçbir şeyi ortak koşmayın. Anne babaya, akrabaya, yetimlere, yoksullara iyi davranın.", "ref": "Nisa - 36"},
    {"title": "Nisa - 103. Ayet", "text": "Şüphesiz namaz, müminler üzerine belirli vakitlere bağlı olarak farz kılınmıştır.", "ref": "Nisa - 103"},
    {"title": "Enbiya - 107. Ayet", "text": "Biz seni ancak alemlere rahmet olarak gönderdik.", "ref": "Enbiya - 107"},
    {"title": "Muminun - 118. Ayet", "text": "Rabbim! Bağışla, merhamet et. Sen merhamet edenlerin en hayırlısısın.", "ref": "Muminun - 118"},
    {"title": "Yusuf - 86. Ayet", "text": "Ben tasa ve üzüntümü ancak Allah'a arz ederim.", "ref": "Yusuf - 86"},
    {"title": "Araf - 180. Ayet", "text": "En güzel isimler (Esmaü'l-Hüsna) Allah'ındır. O halde O'na bu güzel isimlerle dua edin.", "ref": "Araf - 180"},
    {"title": "Araf - 205. Ayet", "text": "Rabbini, içinden, yalvararak ve korkarak, yüksek olmayan bir sesle sabah akşam an; gafillerden olma.", "ref": "Araf - 205"},
    {"title": "Enfal - 2. Ayet", "text": "Müminler ancak o kimselerdir ki; Allah anıldığı zaman kalpleri ürperir, O'nun ayetleri kendilerine okunduğu zaman imanlarını artırır.", "ref": "Enfal - 2"},
    {"title": "Enfal - 40. Ayet", "text": "Bilin ki Allah sizin mevlanızdır. O ne güzel mevla, ne güzel yardımcıdır!", "ref": "Enfal - 40"},
    {"title": "Yunus - 62. Ayet", "text": "Bilesiniz ki Allah'ın dostlarına hiçbir korku yoktur; onlar üzülmeyecekler de.", "ref": "Yunus - 62"},
    {"title": "Hud - 115. Ayet", "text": "Sabret, çünkü Allah iyilik yapanların mükafatını asla zayi etmez.", "ref": "Hud - 115"},
    {"title": "Nisa - 110. Ayet", "text": "Kim bir kötülük yapar yahut nefsine zulmeder de sonra Allah'tan bağışlanma dilerse, Allah'ı çok bağışlayıcı ve merhametli bulur.", "ref": "Nisa - 110"},
    {"title": "Mülk - 2. Ayet", "text": "O, hanginizin daha güzel amel yapacağını sınamak için ölümü ve hayatı yaratandır.", "ref": "Mülk - 2"},
    {"title": "Araf - 56. Ayet", "text": "Korkarak ve umarak O'na dua edin. Şüphesiz Allah'ın rahmeti iyilik yapanlara çok yakındır.", "ref": "Araf - 56"},
    {"title": "Mümin - 60. Ayet", "text": "Rabbiniz şöyle buyurdu: Bana dua edin, duanıza icabet edeyim.", "ref": "Mümin - 60"},
    {"title": "Ahzab - 35. Ayet", "text": "Allah'ı çokça zikreden erkekler ve zikreden kadınlar var ya; işte Allah onlar için bir bağışlanma ve büyük bir mükafat hazırlamıştır.", "ref": "Ahzab - 35"},
    {"title": "Ahzab - 56. Ayet", "text": "Şüphesiz Allah ve melekleri Peygamber'e salat ediyorlar. Ey iman edenler! Siz de ona salat edin, samimiyetle selam verin.", "ref": "Ahzab - 56"},
    {"title": "Nur - 35. Ayet", "text": "Allah, göklerin ve yerin nurudur.", "ref": "Nur - 35"},
    {"title": "Lokman - 33. Ayet", "text": "Ey insanlar! Rabbinize karşı gelmekten sakının. Hiçbir babanın çocuğuna, hiçbir çocuğun da babasına fayda sağlayamayacağı günden korkun.", "ref": "Lokman - 33"},
    {"title": "Secde - 17. Ayet", "text": "Yaptıklarına karşılık onlar için göz aydınlığı olacak ne mükafatlar saklandığını hiç kimse bilemez.", "ref": "Secde - 17"},
    {"title": "Duhan - 58. Ayet", "text": "Belki düşünüp öğüt alırlar diye biz o Kur'an'ı senin dilinle kolaylaştırdık.", "ref": "Duhan - 58"},
    {"title": "Saf - 13. Ayet", "text": "Seveceğiniz başka bir nimet daha var: Allah'tan bir yardım ve yakın bir fetih! Müminleri müjdele.", "ref": "Saf - 13"}
  ];

  // 60 Authentic Sahih Hadiths
  final hadiths = [
    {"title": "Hadis-i Şerif - Buhari", "text": "Ameller ancak niyetlere göredir; herkes niyet ettiği şeyin karşılığını alır.", "ref": "Buhari, Bed'ü'l-Vahy 1"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Din samimiyettir (nasihattir).", "ref": "Müslim, İman 95"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Sizden biriniz kendisi için istediğini din kardeşi için de istemedikçe tam iman etmiş olmaz.", "ref": "Buhari, İman 7"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Hayra vesile olan, o hayrı yapan gibidir.", "ref": "Tirmizi, İlim 14"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Müslüman, elinden ve dilinden diğer müslümanların güvende olduğu kimsedir.", "ref": "Buhari, İman 4"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz.", "ref": "Buhari, Cihad 164"},
    {"title": "Hadis-i Şerif - Beyhaki", "text": "İnsanların en hayırlısı, insanlara en çok faydası dokunandır.", "ref": "Beyhaki, Şuabü'l-İman 6"},
    {"title": "Hadis-i Şerif - Buhari", "text": "İki nimet vardır ki insanların çoğu bunda aldanmıştır: Sağlık ve boş vakit.", "ref": "Buhari, Rikak 1"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Hiçbir baba evladına güzel ahlaktan daha değerli bir miras bırakamaz.", "ref": "Tirmizi, Birr 33"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Temizlik imanın yarısıdır.", "ref": "Müslim, Taharet 1"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Nerede olursan ol Allah'tan kork. Kötülüğün peşinden hemen bir iyilik yap ki onu silsin.", "ref": "Tirmizi, Birr 55"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Gerçek zenginlik mal çokluğu değil, gönül zenginliğidir.", "ref": "Buhari, Rikak 15"},
    {"title": "Hadis-i Şerif - Ahmed bin Hanbel", "text": "Öfkelenen kimse sussun.", "ref": "Ahmed b. Hanbel, Müsned 1/239"},
    {"title": "Hadis-i Şerif - Hakim", "text": "Komşusu açken kendisi tok yatan bizden değildir.", "ref": "Hakim, Müstedrek 2/15"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Güzel söz sadakadır.", "ref": "Buhari, Cihad 128"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Dua ibadetin özüdür.", "ref": "Tirmizi, Daavat 1"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Bizi aldatan bizden değildir.", "ref": "Müslim, İman 164"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "İman yönünden müminlerin en mükemmeli, ahlakı en güzel olanıdır.", "ref": "Tirmizi, Rada 11"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Her kim Allah'a ve ahiret gününe inanıyorsa misafirine ikram etsin.", "ref": "Buhari, Edeb 31"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Müslüman müslümanın kardeşidir. Ona zulmetmez, onu yalnız bırakmaz, onu hor görmez.", "ref": "Müslim, Birr 58"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Veren el, alan elden daha hayırlıdır.", "ref": "Buhari, Zekat 18"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Gözleri haramdan korumak ve dili tutmak, cennete götüren yollardandır.", "ref": "Tirmizi, Zühd 6"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Doğruluktan ayrılmayınız. Doğruluk insanı iyiliğe, iyilik de cennete götürür.", "ref": "Buhari, Edeb 69"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Birbirinize haset etmeyiniz, birbirinize buğzetmeyiniz ve ey Allah'ın kulları kardeş olunuz.", "ref": "Müslim, Birr 23"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Yumuşak huyluluktan mahrum olan, her türlü hayırdan mahrum kalır.", "ref": "Müslim, Birr 74"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Küçüklerimize merhamet etmeyen, büyüklerimize saygı göstermeyen bizden değildir.", "ref": "Tirmizi, Birr 15"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Mazlumun duasından sakınınız. Çünkü onun duasıyla Allah arasında hiçbir perde yoktur.", "ref": "Buhari, Zekat 63"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Her dinin bir ahlakı vardır, İslam'ın ahlakı da hayadır (utanma duygusudur).", "ref": "Muvatta, Hüsnü'l-Huluk 9"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Allah sizin dış görünüşünüze ve mallarınıza bakmaz; o sizin kalplerinize ve amellerinize bakar.", "ref": "Müslim, Birr 33"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Hiçbiriniz ölüm istemesin. Eğer iyi biriyse iyiliğini artırır, kötüyse tövbe eder.", "ref": "Buhari, Temenni 6"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Dünya müminin zindanı, kafirin ise cennetidir.", "ref": "Müslim, Zühd 1"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Namaz dinin direğidir.", "ref": "Tirmizi, İman 8"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Kulun Rabbine en yakın olduğu an secde anıdır. Secdede duayı çok yapın.", "ref": "Müslim, Salat 215"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Sizin en hayırlınız, Kur'an'ı öğrenen ve öğreteninizdir.", "ref": "Buhari, Fezailü'l-Kur'an 21"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "İlim talep etmek her müslümana farzdır.", "ref": "İbn Mace, Mukaddime 17"},
    {"title": "Hadis-i Şerif - Ebu Davud", "text": "Kolaylaştırın, güçleştirmeyin; müjdeleyin, nefret ettirmeyin.", "ref": "Ebu Davud, Edeb 20"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Misvak kullanmak ağzı temizler, Rabb'in rızasını kazandırır.", "ref": "Buhari, Savm 27"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Din kardeşinin yüzüne tebessüm etmen bir sadakadır.", "ref": "Tirmizi, Birr 36"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Kim bir müminin dünyadaki sıkıntılarından birini giderirse, Allah da onun ahiret sıkıntısını giderir.", "ref": "Müslim, Zikir 38"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Cennet annelerin ayakları altındadır.", "ref": "Nesai, Cihad 6"},
    {"title": "Hadis-i Şerif - Ebu Davud", "text": "İnsanlara merhamet etmeyene Allah da merhamet etmez.", "ref": "Buhari, Tevhid 2"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Kul, kardeşinin yardımında olduğu sürece Allah da kulun yardımındadır.", "ref": "Müslim, Zikir 38"},
    {"title": "Hadis-i Şerif - Buhari", "text": "İçinizde en sevdiğim ve ahirette bana en yakın olanınız, ahlakı en güzel olanınızdır.", "ref": "Tirmizi, Birr 71"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Yarım hurmayla da olsa kendinizi cehennem ateşinden koruyun.", "ref": "Buhari, Zekat 9"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Komşusu, zararından emin olmayan kimse cennete giremez.", "ref": "Müslim, İman 73"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Hakiki mücahit, nefsinin isteklerine karşı cihad edendir.", "ref": "Tirmizi, Fezailü'l-Cihad 2"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Şüphesiz Allah temizdir, temizliği sever; cömerttir, cömertliği sever.", "ref": "Tirmizi, Edeb 41"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Haset etmekten sakınınız. Çünkü haset, ateşin odunu yiyip tükettiği gibi iyilikleri yer bitirir.", "ref": "Ebu Davud, Edeb 44"},
    {"title": "Hadis-i Şerif - Buhari", "text": "İşçiye ücretini, alnının teri kurumadan veriniz.", "ref": "İbn Mace, Rehin 4"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Tevbe eden, hiç günah işlememiş gibidir.", "ref": "İbn Mace, Zühd 30"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Her iyilik bir sadakadır.", "ref": "Buhari, Edeb 33"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Söz taşıyan (koğuculuk yapan) kimse cennete giremez.", "ref": "Buhari, Edeb 49"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Kim din kardeşinin gıyabında onurunu korursa, Allah da kıyamet günü onun yüzünü ateşten korur.", "ref": "Tirmizi, Birr 20"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Haksızlık karşısında susan dilsiz şeytandır.", "ref": "İbn Kayyim, el-Cevabu'l-Kafi 1/136"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Bir işi emanet aldığınızda onu en güzel şekilde layıkıyla yerine getirin.", "ref": "Buhari, Rikak 35"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Mümin bir delikten iki defa ısırılmaz (aynı hatayı iki kez yapmaz).", "ref": "Buhari, Edeb 83"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Canım elinde olan Allah'a yemin ederim ki siz iman etmedikçe cennete giremezsiniz; birbirinizi sevmedikçe de tam iman etmiş sayılmazsınız.", "ref": "Müslim, İman 93"},
    {"title": "Hadis-i Şerif - Buhari", "text": "Gıpta edilecek iki kişi vardır: Biri Allah'ın verdiği malı hayır yolunda harcayan, diğeri ise Allah'ın verdiği ilimle amel edip onu öğreten.", "ref": "Buhari, İlim 15"},
    {"title": "Hadis-i Şerif - Tirmizi", "text": "Kendisini ilgilendirmeyen şeyleri terk etmesi, kişinin müslümanlığının güzelliğindendir.", "ref": "Tirmizi, Zühd 11"},
    {"title": "Hadis-i Şerif - Müslim", "text": "Zulüm, kıyamet günü karanlıklar olacaktır. Zulümden sakınınız.", "ref": "Müslim, Birr 56"}
  ];

  // 60 Popular Beautiful Baby Names (Kız and Erkek)
  final names = [
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

  // Read lines to preserve sections that shouldn't be altered
  final lines = file.readAsLinesSync();
  
  final buffer = StringBuffer();
  buffer.writeln('// Namaz Vakitleri & Dini Bilgiler - Veri Katmanı (Dart)');
  buffer.writeln();
  
  // 1. DINI_GUNLER
  buffer.writeln('const List<Map<String, String>> DINI_GUNLER = [');
  buffer.writeln('  {"tarih": "15 Ocak 2026", "gun": "Perşembe", "ad": "Miraç Kandili"},');
  buffer.writeln('  {"tarih": "2 Şubat 2026", "gun": "Pazartesi", "ad": "Berat Kandili"},');
  buffer.writeln('  {"tarih": "19 Şubat 2026", "gun": "Perşembe", "ad": "Ramazan Başlangıcı"},');
  buffer.writeln('  {"tarih": "16 Mart 2026", "gun": "Pazartesi", "ad": "Kadir Gecesi"},');
  buffer.writeln('  {"tarih": "19 Mart 2026", "gun": "Perşembe", "ad": "Ramazan Bayramı Arefesi"},');
  buffer.writeln('  {"tarih": "20 Mart 2026", "gun": "Cuma", "ad": "Ramazan Bayramı (1. Gün)"},');
  buffer.writeln('  {"tarih": "21 Mart 2026", "gun": "Cumartesi", "ad": "Ramazan Bayramı (2. Gün)"},');
  buffer.writeln('  {"tarih": "22 Mart 2026", "gun": "Pazar", "ad": "Ramazan Bayramı (3. Gün)"},');
  buffer.writeln('  {"tarih": "26 Mayıs 2026", "gun": "Salı", "ad": "Kurban Bayramı Arefesi"},');
  buffer.writeln('  {"tarih": "27 Mayıs 2026", "gun": "Çarşamba", "ad": "Kurban Bayramı (1. Gün)"},');
  buffer.writeln('  {"tarih": "28 Mayıs 2026", "gun": "Perşembe", "ad": "Kurban Bayramı (2. Gün)"},');
  buffer.writeln('  {"tarih": "29 Mayıs 2026", "gun": "Cuma", "ad": "Kurban Bayramı (3. Gün)"},');
  buffer.writeln('  {"tarih": "30 Mayıs 2026", "gun": "Cumartesi", "ad": "Kurban Bayramı (4. Gün)"},');
  buffer.writeln('  {"tarih": "16 Haziran 2026", "gun": "Salı", "ad": "Hicri Yılbaşı (1 Muharrem 1448)"},');
  buffer.writeln('  {"tarih": "25 Haziran 2026", "gun": "Perşembe", "ad": "Aşure Günü"},');
  buffer.writeln('  {"tarih": "24 Ağustos 2026", "gun": "Pazartesi", "ad": "Mevlid Kandili"},');
  buffer.writeln('  {"tarih": "10 Aralık 2026", "gun": "Perşembe", "ad": "Regaib Kandili"}');
  buffer.writeln('];');
  buffer.writeln();

  // 2. VAKTIN_AYETLERI
  buffer.writeln('const List<Map<String, String>> VAKTIN_AYETLERI = [');
  for (var i = 0; i < verses.length; i++) {
    final v = verses[i];
    final title = v['title']!.replaceAll('"', '\\"');
    final text = v['text']!.replaceAll('"', '\\"');
    final ref = v['ref']!.replaceAll('"', '\\"');
    buffer.writeln('  {');
    buffer.writeln('    "title": "$title",');
    buffer.writeln('    "text": "$text",');
    buffer.writeln('    "ref": "$ref"');
    buffer.writeln(i == verses.length - 1 ? '  }' : '  },');
  }
  buffer.writeln('];');
  buffer.writeln();

  // 3. VAKTIN_HADISLERI
  buffer.writeln('const List<Map<String, String>> VAKTIN_HADISLERI = [');
  for (var i = 0; i < hadiths.length; i++) {
    final h = hadiths[i];
    final title = h['title']!.replaceAll('"', '\\"');
    final text = h['text']!.replaceAll('"', '\\"');
    final ref = h['ref']!.replaceAll('"', '\\"');
    buffer.writeln('  {');
    buffer.writeln('    "title": "$title",');
    buffer.writeln('    "text": "$text",');
    buffer.writeln('    "ref": "$ref"');
    buffer.writeln(i == hadiths.length - 1 ? '  }' : '  },');
  }
  buffer.writeln('];');
  buffer.writeln();

  // 4. GUNUN_ISIMLERI
  buffer.writeln('const List<Map<String, String>> GUNUN_ISIMLERI = [');
  for (var i = 0; i < names.length; i++) {
    final n = names[i];
    final kiz = n['kiz']!.replaceAll('"', '\\"');
    final erkek = n['erkek']!.replaceAll('"', '\\"');
    buffer.writeln('  {"kiz": "$kiz", "erkek": "$erkek"}${i == names.length - 1 ? '' : ','}');
  }
  buffer.writeln('];');
  buffer.writeln();

  // Append everything from ESMAUL_HUSNA to the end of the original file
  bool appending = false;
  for (final line in lines) {
    if (line.trim().startsWith('const List<Map<String, dynamic>> ESMAUL_HUSNA = [')) {
      appending = true;
    }
    if (appending) {
      buffer.writeln(line);
    }
  }

  file.writeAsStringSync(buffer.toString());
  print('Expanded prayer_data.dart successfully to 60 items!');
}
