// Namaz Vakitleri & Dini Bilgiler - Araçlar Mantığı

import { 
  ESMAUL_HUSNA, DINI_GUNLER, DUALAR, HADISLER_40, KURAN_CUZLER,
  PEYGAMBER_HAYATI, RAMAZAN_HAKKINDA, ORUC_REHBERI, MOCK_CAMILER,
  TESBIHAT_STEPS, SAHABE_HAYATLARI, ISLAM_TARIHI, NAMAZ_KILMA_REHBERI,
  VITIR_NAMAZI 
} from './data.js';
import { ADDON_DATA } from './data_addon.js';

export async function setupTools(container, showNotification) {
  // Container clear
  container.innerHTML = '<div style="text-align:center; padding:50px; color:#27a770; font-weight:bold;">Yükleniyor...</div>';

  let toolsList = [];
  try {
    const res = await fetch('/api/tools');
    if (res.ok) {
      const data = await res.json();
      toolsList = data.filter(t => t.aktif);
    }
  } catch (e) {
    console.error('Failed to fetch tools from API:', e);
  }

  if (!toolsList || toolsList.length === 0) {
    // Fallback to hardcoded list
    toolsList = [
      { id: 'dini-gunler', title: 'Dini Günler', desc: 'Kandiller ve bayramlar', icon: '📅', color: '0xFFEAF7F1', sira: 1 },
      { id: 'dua-iste', title: 'Dua İste', desc: 'Dualarınızı paylaşın', icon: '🤲', color: '0xFFEAF4FB', sira: 2 },
      { id: 'soru-cevap', title: 'Soru Cevap', desc: 'Dini danışmana soru sorun', icon: '💬', color: '0xFFFFF7EA', sira: 3 },
      { id: 'canli-sohbet', title: 'Canlı Dini Sohbet', desc: 'Sohbete katılın', icon: '🎧', color: '0xFFFBEAEA', sira: 4 },
      { id: 'peygamber-hayati', title: 'Peygamberin Hayatı', desc: "Hz. Muhammed'in yaşamı", icon: '📖', color: '0xFFEAF7F1', sira: 5 },
      { id: 'kuran-kerim', title: 'Kuran-ı Kerim', desc: '30 cüz sesli okuma ve takip', icon: '🕌', color: '0xFFFFF7EA', sira: 6 },
      { id: 'esmaul-husna', title: 'Esmaül Hüsna', desc: "Allah'ın 99 ismi", icon: '✨', color: '0xFFEAF4FB', sira: 7 },
      { id: 'ramazan-hakkinda', title: 'Ramazan Hakkında', desc: 'Mübarek ayın önemi', icon: '🌙', color: '0xFFFBEAEA', sira: 8 },
      { id: 'oruc-rehberi', title: 'Oruç Rehberi', desc: 'Oruç ibadetinin detayları', icon: '🍽️', color: '0xFFEAF7F1', sira: 9 },
      { id: 'kible-bulucu', title: 'Kıble Bulucu', desc: 'Dijital pusula ile yön', icon: '🧭', color: '0xFFFFF7EA', sira: 10 },
      { id: 'zikirmatik', title: 'Zikirmatik', desc: 'Dijital tesbih sayacı', icon: '📿', color: '0xFFEAF4FB', sira: 11 },
      { id: 'miladi-hicri', title: 'Miladi - Hicri', desc: 'Tarih çevirici', icon: '🔄', color: '0xFFFBEAEA', sira: 12 },
      { id: 'yasin-suresi', title: 'Yasin Suresi', desc: "Kuran'ın kalbi", icon: '💚', color: '0xFFEAF7F1', sira: 13 },
      { id: 'yakindaki-camiler', title: 'Yakındaki Camiler', desc: 'Konumunuza en yakın camiler', icon: '📍', color: '0xFFFFF7EA', sira: 14 },
      { id: 'hadis-40', title: '40 Hadis-i Şerif', desc: 'İmam Nevevi koleksiyonu', icon: '📜', color: '0xFFEAF4FB', sira: 15 },
      { id: 'namaz-tesbihati', title: 'Namaz Tesbihatı', desc: 'Namaz sonrası dualar', icon: '📿', color: '0xFFFBEAEA', sira: 16 },
      { id: 'gunluk-dualar', title: 'Günlük Dualar', desc: 'Hayatın her anı için dualar', icon: '🤲', color: '0xFFEAF7F1', sira: 17 },
      { id: 'zekat-hesaplama', title: 'Zekat Hesaplama', desc: 'Zekat miktarını hesaplayın', icon: '💰', color: '0xFFFFF7EA', sira: 18 },
      { id: 'sahabe-hayatlari', title: 'Sahabe Hayatları', desc: 'Peygamberin ashabı', icon: '👥', color: '0xFFEAF4FB', sira: 19 },
      { id: 'islam-tarihi', title: 'İslam Tarihi', desc: 'Önemli olaylar ve dönemler', icon: '⏳', color: '0xFFFBEAEA', sira: 20 },
      { id: 'namaz-kilma', title: 'Namaz Kılma Rehberi', desc: 'Adım adım namaz öğrenin', icon: '🚶', color: '0xFFEAF7F1', sira: 21 },
      { id: 'vitir-namazi', title: 'Vitir Namazı', desc: 'Yatsı sonrası vacip namaz', icon: '🌟', color: '0xFFFFF7EA', sira: 22 }
    ];
  }

  // Sort tools by sira
  toolsList.sort((a, b) => a.sira - b.sira);

  container.innerHTML = '';

  // Create grid
  const grid = document.createElement('div');
  grid.className = 'tools-grid';

  toolsList.forEach(tool => {
    const card = document.createElement('div');
    card.className = 'tool-card ripple';
    const rawColor = tool.color || '0xFFEAF7F1';
    const cleanColor = rawColor.replace('0xFF', '#');
    card.style.backgroundColor = cleanColor;

    card.innerHTML = `
      <div class="tool-icon">${tool.icon}</div>
      <div class="tool-content">
        <div class="tool-title" style="color:#1e5e43; font-weight:bold;">${tool.title}</div>
        <div class="tool-desc" style="color:#555;">${tool.desc}</div>
      </div>
    `;
    card.addEventListener('click', () => openToolModal(tool.id, tool.title, showNotification));
    grid.appendChild(card);
  });

  container.appendChild(grid);
}

function openToolModal(id, title, showNotification) {
  // Create Modal Overlay
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay active';
  overlay.id = `modal-${id}`;

  const modal = document.createElement('div');
  modal.className = 'modal-content';
  
  modal.innerHTML = `
    <div class="modal-header">
      <h3>${title}</h3>
      <button class="modal-close-btn">&times;</button>
    </div>
    <div class="modal-body" id="modal-body-content"></div>
  `;

  overlay.appendChild(modal);
  document.body.appendChild(overlay);

  const closeBtn = modal.querySelector('.modal-close-btn');
  closeBtn.addEventListener('click', () => {
    overlay.classList.remove('active');
    setTimeout(() => overlay.remove(), 300);
  });

  const body = modal.querySelector('#modal-body-content');

  // Render specific tool
  switch (id) {
    case 'zikirmatik':
      renderZikirmatik(body, showNotification);
      break;
    case 'esmaul-husna':
      renderEsmaulHusna(body);
      break;
    case 'zekat-hesaplama':
      renderZekatCalculator(body);
      break;
    case 'kible-bulucu':
      renderQiblaFinder(body);
      break;
    case 'miladi-hicri':
      renderDateConverter(body);
      break;
    case 'dini-gunler':
      renderDiniGunler(body);
      break;
    case 'soru-cevap':
      renderSoruCevap(body);
      break;
    case 'dua-iste':
      renderDuaIste(body, showNotification);
      break;
    case 'kuran-kerim':
    case 'yasin-suresi':
      renderQuranPlayer(body, id === 'yasin-suresi');
      break;
    case 'canli-sohbet':
      renderCanliSohbet(body, showNotification);
      break;
    case 'peygamber-hayati':
      renderPeygamberHayati(body);
      break;
    case 'ramazan-hakkinda':
      renderRamazanHakkinda(body);
      break;
    case 'oruc-rehberi':
      renderOrucRehberi(body);
      break;
    case 'yakindaki-camiler':
      renderYakindakiCamiler(body);
      break;
    case 'hadis-40':
      renderHadis40(body);
      break;
    case 'namaz-tesbihati':
      renderNamazTesbihati(body, showNotification);
      break;
    case 'gunluk-dualar':
      renderGunlukDualar(body);
      break;
    case 'sahabe-hayatlari':
      renderSahabeHayatlari(body);
      break;
    case 'islam-tarihi':
      renderIslamTarihi(body);
      break;
    case 'namaz-kilma':
      renderNamazKilma(body);
      break;
    case 'vitir-namazi':
      renderVitirNamazi(body);
      break;
    case 'ezkar':
      renderSabahAksamEzkar(body, showNotification);
      break;
    case 'kaza-namazlari':
      renderKazaTracker(body, showNotification);
      break;
    case 'tevhid':
      renderKelimeiTevhid(body, showNotification);
      break;
    case 'tefriciye':
      renderSalatiTefriciye(body, showNotification);
      break;
    case 'ummiye':
      renderSalatiUmmiye(body, showNotification);
      break;
    case 'cevsen':
      renderCevsen(body);
      break;
    default:
      const key = id.replace(/-/g, '_');
      if (ADDON_DATA[key]) {
        renderAddonTool(body, id);
      } else {
        body.innerHTML = `
          <div class="info-card">
            <p>Bu bölüm çok yakında güncellenecektir. İlginiz için teşekkür ederiz.</p>
          </div>
        `;
      }
      break;
  }
}

// 1. ZIKIRMATIK
function renderZikirmatik(container, showNotification) {
  let count = parseInt(localStorage.getItem('zikir_count') || '0');
  let target = parseInt(localStorage.getItem('zikir_target') || '33');
  let selectedId = localStorage.getItem('zikir_selected_id') || 'subhanallah';

  const zikirData = {
    subhanallah: { ad: 'Sübhânallâh', arapca: 'سُبْحَانَ اللَّهِ', anlam: 'Allah noksan sıfatlardan uzaktır.', fazilet: 'Günde 100 defa okuyanın günahları deniz köpüğü kadar da olsa bağışlanır.' },
    elhamdulillah: { ad: 'Elhamdülillâh', arapca: 'الْحَمْدُ لِلَّهِ', anlam: 'Hamd Allah\'a mahsustur.', fazilet: 'Mizanı dolduran en hayırlı hamd cümlesidir.' },
    allahuekber: { ad: 'Allâhu Ekber', arapca: 'اللَّهُ أَكْبَرُ', anlam: 'Allah en büyüktür.', fazilet: 'Allah\'ın büyüklüğünü ve yüceliğini tefekkür zikridir.' },
    lailaheillallah: { ad: 'Lâ ilâhe illallâh', arapca: 'لَا إِلَٰهَ إِلَّا اللَّهُ', anlam: 'Allah\'tan başka ilah yoktur.', fazilet: 'Zikrin en faziletlisi kelime-i tevhiddir.' }
  };

  const renderContent = () => {
    const zikir = zikirData[selectedId];
    container.innerHTML = `
      <div class="zikirmatik-wrapper" style="text-align:center; padding:10px;">
        <div class="zikir-target-container" style="margin-bottom:15px; display:flex; justify-content:center; align-items:center; gap:8px;">
          <label style="font-weight:bold; font-size:13px; color:#1e5e43;">Zikir Seçin:</label>
          <select id="zikir-select" class="form-control-styled" style="padding:6px; font-size:13px;">
            <option value="subhanallah" ${selectedId === 'subhanallah' ? 'selected' : ''}>Sübhânallâh (33)</option>
            <option value="elhamdulillah" ${selectedId === 'elhamdulillah' ? 'selected' : ''}>Elhamdülillâh (33)</option>
            <option value="allahuekber" ${selectedId === 'allahuekber' ? 'selected' : ''}>Allâhu Ekber (34)</option>
            <option value="lailaheillallah" ${selectedId === 'lailaheillallah' ? 'selected' : ''}>Lâ ilâhe illallâh (Limitsiz)</option>
          </select>
        </div>

        <div style="background:#fff; border-radius:16px; border:1px solid #eee; padding:15px; margin-bottom:20px; box-shadow:0 2px 8px rgba(0,0,0,0.02);">
          <div style="font-size:24px; font-weight:bold; color:#27a770; margin-bottom:8px;">${zikir.ad}</div>
          <div style="font-size:28px; color:#1e5e43; font-family:'Traditional Arabic', serif; margin-bottom:10px; font-weight:bold;">${zikir.arapca}</div>
          <div style="font-size:12px; color:#777; font-style:italic; margin-bottom:6px;">"${zikir.anlam}"</div>
          <div style="font-size:11px; color:#e5a93b; background:#fffcf0; padding:6px; border-radius:8px; border:1px solid #f9edd4; font-weight:bold;">${zikir.fazilet}</div>
        </div>

        <div class="zikir-circle-button" id="zikir-btn" style="position:relative; width:160px; height:160px; margin:0 auto 20px auto; border-radius:50%; background:#fff; border:8px solid #27a770; box-shadow:0 8px 24px rgba(39,167,112,0.15); display:flex; flex-direction:column; align-items:center; justify-content:center; cursor:pointer; user-select:none;">
          <div class="zikir-counter-val" id="zikir-count-display" style="font-size:42px; font-weight:bold; color:#1e5e43;">${count}</div>
          <div class="zikir-target-val" style="font-size:12px; color:#888; margin-top:2px;">/ ${target === 9999 ? '∞' : target}</div>
        </div>

        <div class="zikir-actions" style="display:flex; justify-content:center; gap:12px;">
          <button class="btn btn-secondary ripple" id="zikir-reset" style="padding:8px 20px; font-size:13px; font-weight:bold;">Sıfırla</button>
          <button class="btn btn-primary ripple" id="zikir-sound-toggle" style="padding:8px 20px; font-size:13px; font-weight:bold;">Ses: Açık</button>
        </div>
      </div>
    `;

    const btn = container.querySelector('#zikir-btn');
    const countDisplay = container.querySelector('#zikir-count-display');
    const resetBtn = container.querySelector('#zikir-reset');
    const soundToggle = container.querySelector('#zikir-sound-toggle');
    const zikirSelect = container.querySelector('#zikir-select');

    let soundEnabled = true;

    const playClickSound = () => {
      if (!soundEnabled) return;
      try {
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const oscillator = audioCtx.createOscillator();
        const gainNode = audioCtx.createGain();
        oscillator.connect(gainNode);
        gainNode.connect(audioCtx.destination);
        oscillator.type = 'sine';
        oscillator.frequency.setValueAtTime(600, audioCtx.currentTime);
        gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.1);
        oscillator.start();
        oscillator.stop(audioCtx.currentTime + 0.1);
      } catch (e) {}
    };

    btn.addEventListener('click', () => {
      count++;
      localStorage.setItem('zikir_count', count);
      countDisplay.textContent = count;
      playClickSound();

      if (navigator.vibrate) {
        navigator.vibrate(35);
      }

      if (count >= target && target !== 9999) {
        if (navigator.vibrate) {
          navigator.vibrate([100, 50, 100]);
        }
        showNotification('Tebrikler!', `${zikir.ad} zikrini tamamladınız!`, 'default');
        count = 0;
        localStorage.setItem('zikir_count', count);
        setTimeout(() => {
          countDisplay.textContent = count;
        }, 400);
      }
    });

    resetBtn.addEventListener('click', () => {
      if (confirm('Sayacı sıfırlamak istediğinize emin misiniz?')) {
        count = 0;
        localStorage.setItem('zikir_count', count);
        countDisplay.textContent = count;
      }
    });

    soundToggle.addEventListener('click', () => {
      soundEnabled = !soundEnabled;
      soundToggle.textContent = `Ses: ${soundEnabled ? 'Açık' : 'Kapalı'}`;
      soundToggle.className = soundEnabled ? 'btn btn-primary ripple' : 'btn btn-secondary ripple';
    });

    zikirSelect.addEventListener('change', (e) => {
      selectedId = e.target.value;
      localStorage.setItem('zikir_selected_id', selectedId);
      
      const targets = { subhanallah: 33, elhamdulillah: 33, allahuekber: 34, lailaheillallah: 9999 };
      target = targets[selectedId] || 33;
      localStorage.setItem('zikir_target', target);
      
      count = 0;
      localStorage.setItem('zikir_count', count);
      renderContent();
    });
  };

  renderContent();
}

// 2. ESMAUL HUSNA
function renderEsmaulHusna(container) {
  container.innerHTML = `
    <div class="esmaul-husna-wrapper">
      <input type="text" placeholder="İsim ara (Örn: Rahman)..." class="form-control-styled" id="esma-search" style="margin-bottom:15px; width:100%;">
      <div class="esma-list" id="esma-list-container"></div>
    </div>
  `;

  const listContainer = container.querySelector('#esma-list-container');
  const searchInput = container.querySelector('#esma-search');

  const displayList = (query = '') => {
    listContainer.innerHTML = '';
    const filtered = ESMAUL_HUSNA.filter(item => 
      item.ad.toLowerCase().includes(query.toLowerCase()) || 
      item.anlam.toLowerCase().includes(query.toLowerCase())
    );

    if (filtered.length === 0) {
      listContainer.innerHTML = '<div style="text-align:center; padding:20px; color:#888;">İsim bulunamadı.</div>';
      return;
    }

    filtered.forEach(item => {
      const card = document.createElement('div');
      card.className = 'esma-item';
      card.innerHTML = `
        <div class="esma-top">
          <span class="esma-no">#${item.no}</span>
          <span class="esma-arabic">${item.arapca}</span>
        </div>
        <div class="esma-title">${item.ad}</div>
        <div class="esma-meaning"><strong>Anlamı:</strong> ${item.anlam}</div>
        <div class="esma-virtue"><strong>Fazileti:</strong> ${item.fazilet}</div>
        <div class="esma-count">📿 Zikir Sayısı: <strong>${item.zikir}</strong></div>
      `;
      listContainer.appendChild(card);
    });
  };

  searchInput.addEventListener('input', (e) => displayList(e.target.value));
  displayList();
}

// 3. ZEKAT CALCULATOR
function renderZekatCalculator(container) {
  container.innerHTML = `
    <div class="zekat-wrapper">
      <p style="font-size:13px; color:#666; margin-bottom:15px;">Zekat, dinen zenginlik ölçüsü kabul edilen miktarda (Nisap: 80.18 gr altın veya eşdeğeri) mala sahip olan Müslümanların vermesi gereken farz bir ibadettir.</p>
      
      <div class="form-group">
        <label>Altın Değeri (Gram olarak):</label>
        <input type="number" id="zekat-gold" class="form-control-styled" placeholder="0" value="0">
      </div>

      <div class="form-group">
        <label>Nakit Para (TL):</label>
        <input type="number" id="zekat-cash" class="form-control-styled" placeholder="0" value="0">
      </div>

      <div class="form-group">
        <label>Ticari Mal ve Yatırımlar (TL):</label>
        <input type="number" id="zekat-business" class="form-control-styled" placeholder="0" value="0">
      </div>

      <div class="form-group">
        <label>Borçlarınız (Düşülecektir) (TL):</label>
        <input type="number" id="zekat-debts" class="form-control-styled" placeholder="0" value="0">
      </div>

      <button class="btn btn-primary ripple w-100" id="zekat-calculate" style="margin-top:15px; width:100%;">Hesapla</button>

      <div class="zekat-result-box" id="zekat-result" style="display:none; margin-top:20px; padding:15px; border-radius:12px; background:#f0fcf7; border:1px solid #c2f0d8; text-align:center;">
      </div>
    </div>
  `;

  const calculateBtn = container.querySelector('#zekat-calculate');
  const resultBox = container.querySelector('#zekat-result');

  calculateBtn.addEventListener('click', () => {
    const goldPrice = 3000; // Mock current gold price per gram in TL (adjust for 2026/realistic scale)
    const gold = parseFloat(container.querySelector('#zekat-gold').value) || 0;
    const cash = parseFloat(container.querySelector('#zekat-cash').value) || 0;
    const business = parseFloat(container.querySelector('#zekat-business').value) || 0;
    const debts = parseFloat(container.querySelector('#zekat-debts').value) || 0;

    const totalWealth = (gold * goldPrice) + cash + business - debts;
    const nisapLimit = 80.18 * goldPrice; // Nisap threshold

    resultBox.style.display = 'block';

    if (totalWealth <= 0) {
      resultBox.innerHTML = `
        <span style="color:#d9534f; font-weight:bold; font-size:16px;">Borçlar Varlığı Aşıyor</span>
        <p style="margin-top:5px; font-size:13px; color:#555;">Hesaplanan net varlığınız negatiftir. Zekat vermeniz gerekmemektedir.</p>
      `;
    } else if (totalWealth < nisapLimit) {
      resultBox.innerHTML = `
        <span style="color:#f0ad4e; font-weight:bold; font-size:16px;">Nisap Miktarına Ulaşılmadı</span>
        <p style="margin-top:5px; font-size:13px; color:#555;">Toplam varlığınız (${totalWealth.toLocaleString('tr-TR', { maximumFractionDigits: 0 })} TL), nisap miktarı olan <strong>${nisapLimit.toLocaleString('tr-TR', { maximumFractionDigits: 0 })} TL</strong> (80.18 gr altın) değerinin altındadır. Zekat mükellefi değilsiniz.</p>
      `;
    } else {
      const zekatAmount = totalWealth / 40; // 2.5%
      resultBox.innerHTML = `
        <span style="color:#27a770; font-weight:bold; font-size:18px;">Zekat Vermelisiniz!</span>
        <div style="margin-top:10px; font-size:14px; color:#333;">
          <p>Toplam Zekata Tabi Varlık: <strong>${totalWealth.toLocaleString('tr-TR', { maximumFractionDigits: 0 })} TL</strong></p>
          <p style="font-size:18px; color:#27a770; font-weight:bold; margin-top:8px;">Ödenmesi Gereken Zekat (%2.5): <br>${zekatAmount.toLocaleString('tr-TR', { maximumFractionDigits: 0 })} TL</p>
        </div>
      `;
    }
  });
}

// 4. KIBLE BULUCU (Compass overlay)
function renderQiblaFinder(container) {
  container.innerHTML = `
    <div class="qibla-wrapper" style="text-align:center; padding:10px;">
      <p style="font-size:12px; color:#888; margin-bottom:15px; text-align:center;">Telefonunuzu düz zeminde yatay tutun. Pusulayı döndürerek yeşil seccadeyi kabe yönüne (🕌) hizalayın.</p>
      
      <div class="compass-container" style="position:relative; width:220px; height:220px; margin:0 auto 20px auto; border-radius:50%; border:5px solid #27a770; background:#fff; box-shadow:0 8px 24px rgba(0,0,0,0.06); display:flex; align-items:center; justify-content:center; overflow:hidden;">
        <!-- Seccade dial which rotates with Heading -->
        <div class="compass-dial" id="compass-ring" style="position:absolute; width:100%; height:100%; border-radius:50%; background:url('data:image/svg+xml;utf8,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22220%22 height=%22220%22 viewBox=%220 0 220 220%22><text x=%22110%22 y=%2225%22 fill=%22%23d9534f%22 font-size=%2216%22 font-weight=%22bold%22 text-anchor=%22middle%22>K</text><text x=%22110%22 y=%22205%22 fill=%22%23555%22 font-size=%2214%22 text-anchor=%22middle%22>G</text><text x=%2220%22 y=%22115%22 fill=%22%23555%22 font-size=%2214%22 text-anchor=%22middle%22>B</text><text x=%22200%22 y=%22115%22 fill=%22%23555%22 font-size=%2214%22 text-anchor=%22middle%22>D</text><circle cx=%22110%22 cy=%22110%22 r=%2280%22 fill=%22none%22 stroke=%22%23eaf7f1%22 stroke-width=%222%22/></svg>') no-repeat center center; transition: transform 0.1s ease-out;"></div>
        
        <!-- Rotating prayer rug (seccade) needle pointing to Qibla -->
        <div class="qibla-needle" id="qibla-arrow" style="position:absolute; width:60px; height:150px; background:url('data:image/svg+xml;utf8,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2260%22 height=%22150%22 viewBox=%220 0 60 150%22><rect x=%2218%22 y=%2225%22 width=%2224%22 height=%2245%22 rx=%224%22 fill=%22%2327a770%22 stroke=%22%231e5e43%22 stroke-width=%221.5%22/><polygon points=%2230,10 24,25 36,25%22 fill=%22%2327a770%22/><text x=%2230%22 y=%2250%22 fill=%22%23fff%22 font-size=%2210%22 font-weight=%22bold%22 text-anchor=%22middle%22>🕌</text><circle cx=%2230%22 cy=%22110%22 r=%228%22 fill=%22%2327a770%22/></svg>') no-repeat center center; transition: transform 0.1s ease-out; transform: rotate(137deg);"></div>
      </div>
      
      <div style="font-weight:bold; color:#1e5e43; font-size:15px; margin-bottom:5px;" id="qibla-status">Kıble Açısı: 137° (İstanbul)</div>
      <div style="font-size:11px; color:#888;">(Ekranı sürükleyerek yönü test edebilirsiniz)</div>
    </div>
  `;

  const ring = container.querySelector('#compass-ring');
  const arrow = container.querySelector('#qibla-arrow');
  const status = container.querySelector('#qibla-status');

  const handleOrientation = (event) => {
    let heading = event.webkitCompassHeading || event.alpha;
    if (heading !== null && heading !== undefined) {
      const qiblaAngle = 137;
      ring.style.transform = `rotate(${-heading}deg)`;
      arrow.style.transform = `rotate(${qiblaAngle - heading}deg)`;
      status.textContent = `Pusula Yönü: ${Math.round(heading)}° | Kıble Açısı: ${qiblaAngle}°`;
    }
  };

  if (window.DeviceOrientationEvent) {
    window.addEventListener('deviceorientation', handleOrientation);
  }

  let isDragging = false;
  let startX = 0;
  let rotation = 0;

  ring.addEventListener('mousedown', (e) => {
    isDragging = true;
    startX = e.clientX;
  });

  window.addEventListener('mousemove', (e) => {
    if (!isDragging) return;
    const diff = e.clientX - startX;
    rotation += diff * 0.5;
    startX = e.clientX;
    ring.style.transform = `rotate(${rotation}deg)`;
    arrow.style.transform = `rotate(${137 + rotation}deg)`;
    status.textContent = `Simüle Yön: ${Math.round((360 - rotation) % 360)}° | Kıble Açısı: 137°`;
  });

  window.addEventListener('mouseup', () => {
    isDragging = false;
  });
}

// 5. DATE CONVERTER (Hicri <-> Miladi)
function renderDateConverter(container) {
  container.innerHTML = `
    <div class="converter-wrapper">
      <div class="form-group">
        <label>Dönüşüm Yönü:</label>
        <select class="form-control-styled" id="conv-direction" style="width:100%;">
          <option value="m2h">Miladi'den Hicri'ye</option>
          <option value="h2m">Hicri'den Miladi'ye</option>
        </select>
      </div>

      <div class="form-group" style="margin-top:10px;">
        <label>Tarih Seçin:</label>
        <input type="date" id="conv-date" class="form-control-styled" style="width:100%;">
      </div>

      <button class="btn btn-primary ripple w-100" id="conv-btn" style="margin-top:15px; width:100%;">Çevir</button>

      <div class="convert-result" id="conv-result" style="display:none; margin-top:20px; padding:15px; border-radius:12px; background:#f0f5fc; border:1px solid #c2d8f0; text-align:center; font-weight:bold; color:#1e4b85;">
      </div>
    </div>
  `;

  // Set today as default date input
  const dateInput = container.querySelector('#conv-date');
  const today = new Date().toISOString().split('T')[0];
  dateInput.value = today;

  const btn = container.querySelector('#conv-btn');
  const result = container.querySelector('#conv-result');
  const direction = container.querySelector('#conv-direction');

  btn.addEventListener('click', () => {
    const selectedDate = new Date(dateInput.value);
    if (isNaN(selectedDate.getTime())) {
      alert('Lütfen geçerli bir tarih seçiniz.');
      return;
    }

    result.style.display = 'block';

    if (direction.value === 'm2h') {
      // Approximation formula for Gregorian to Hijri
      const gYear = selectedDate.getFullYear();
      const gMonth = selectedDate.getMonth() + 1;
      const gDay = selectedDate.getDate();

      // Simple calculation: Hijri year = (Gregorian year - 622) * 1.0307
      const hYear = Math.floor((gYear - 622) * 1.0307);
      
      const hijriMonths = [
        "Muharrem", "Safer", "Rebiülevvel", "Rebiülahir", 
        "Cemaziyelevvel", "Cemaziyelahir", "Recep", "Şaban", 
        "Ramazan", "Şevval", "Zilkade", "Zilhicce"
      ];
      
      // Select month based on rough estimation
      const hMonthIndex = Math.floor((gMonth + 4) % 12);
      const hDay = Math.floor((gDay + 15) % 29) + 1;

      result.innerHTML = `
        <div style="font-size:13px; color:#555;">Hicri Tarih:</div>
        <div style="font-size:18px; margin-top:5px; color:#2c662d;">${hDay} ${hijriMonths[hMonthIndex]} ${hYear}</div>
      `;
    } else {
      // Hijri to Gregorian
      // Returns a static estimation for simulation
      const options = { year: 'numeric', month: 'long', day: 'numeric' };
      const convertedGregorian = new Date(selectedDate.getTime() + (30 * 24 * 60 * 60 * 1000));
      
      result.innerHTML = `
        <div style="font-size:13px; color:#555;">Miladi Tarih:</div>
        <div style="font-size:18px; margin-top:5px; color:#1e4b85;">${convertedGregorian.toLocaleDateString('tr-TR', options)}</div>
      `;
    }
  });
}

// 6. DINI GUNLER CALENDAR
function renderDiniGunler(container) {
  let selectedYear = "2026";
  
  const DINI_GUNLER_BY_YEAR = {
    "2026": [
      { ad: "Regaib Kandili", gun: "Pazartesi", tarih: "26 Ocak 2026", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Miraç Kandili", gun: "Cuma", tarih: "13 Şubat 2026", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Berat Kandili", gun: "Pazartesi", tarih: "2 Mart 2026", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Başlangıcı", gun: "Perşembe", tarih: "19 Mart 2026", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Kadir Gecesi", gun: "Salı", tarih: "14 Nisan 2026", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Bayramı Arefesi", gun: "Cuma", tarih: "17 Nisan 2026", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (1. Gün)", gun: "Cumartesi", tarih: "18 Nisan 2026", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (2. Gün)", gun: "Pazar", tarih: "19 Nisan 2026", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (3. Gün)", gun: "Pazartesi", tarih: "20 Nisan 2026", kat: "Ramazan Bayramı" },
      { ad: "Kurban Bayramı Arefesi", gun: "Pazartesi", tarih: "25 Mayıs 2026", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (1. Gün)", gun: "Salı", tarih: "26 Mayıs 2026", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (2. Gün)", gun: "Çarşamba", tarih: "27 Mayıs 2026", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (3. Gün)", gun: "Perşembe", tarih: "28 Mayıs 2026", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (4. Gün)", gun: "Cuma", tarih: "29 Mayıs 2026", kat: "Kurban Bayramı" },
      { ad: "Hicri Yılbaşı (1 Muharrem 1448)", gun: "Salı", tarih: "16 Haziran 2026", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Aşure Günü", gun: "Perşembe", tarih: "25 Haziran 2026", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Mevlid Kandili", gun: "Pazar", tarih: "23 Ağustos 2026", kat: "Kandil ve Mübarek Geceler" }
    ],
    "2027": [
      { ad: "Regaib Kandili", gun: "Perşembe", tarih: "14 Ocak 2027", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Miraç Kandili", gun: "Salı", tarih: "2 Şubat 2027", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Berat Kandili", gun: "Cuma", tarih: "19 Şubat 2027", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Başlangıcı", gun: "Pazartesi", tarih: "8 Mart 2027", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Kadir Gecesi", gun: "Cumartesi", tarih: "3 Nisan 2027", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Bayramı Arefesi", gun: "Salı", tarih: "6 Nisan 2027", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (1. Gün)", gun: "Çarşamba", tarih: "7 Nisan 2027", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (2. Gün)", gun: "Perşembe", tarih: "8 Nisan 2027", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (3. Gün)", gun: "Cuma", tarih: "9 Nisan 2027", kat: "Ramazan Bayramı" },
      { ad: "Kurban Bayramı Arefesi", gun: "Cuma", tarih: "14 Mayıs 2027", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (1. Gün)", gun: "Cumartesi", tarih: "15 Mayıs 2027", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (2. Gün)", gun: "Pazar", tarih: "16 Mayıs 2027", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (3. Gün)", gun: "Pazartesi", tarih: "17 Mayıs 2027", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (4. Gün)", gun: "Salı", tarih: "18 Mayıs 2027", kat: "Kurban Bayramı" },
      { ad: "Hicri Yılbaşı", gun: "Cumartesi", tarih: "5 Haziran 2027", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Aşure Günü", gun: "Pazartesi", tarih: "14 Haziran 2027", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Mevlid Kandili", gun: "Perşembe", tarih: "12 Ağustos 2027", kat: "Kandil ve Mübarek Geceler" }
    ],
    "2028": [
      { ad: "Regaib Kandili", gun: "Perşembe", tarih: "3 Ocak 2028", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Miraç Kandili", gun: "Pazartesi", tarih: "24 Ocak 2028", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Berat Kandili", gun: "Salı", tarih: "8 Şubat 2028", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Başlangıcı", gun: "Cumartesi", tarih: "26 Şubat 2028", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Kadir Gecesi", gun: "Çarşamba", tarih: "22 Mart 2028", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Bayramı Arefesi", gun: "Cumartesi", tarih: "25 Mart 2028", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (1. Gün)", gun: "Pazar", tarih: "26 Mart 2028", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (2. Gün)", gun: "Pazartesi", tarih: "27 Mart 2028", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (3. Gün)", gun: "Salı", tarih: "28 Mart 2028", kat: "Ramazan Bayramı" },
      { ad: "Kurban Bayramı Arefesi", gun: "Salı", tarih: "2 Mayıs 2028", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (1. Gün)", gun: "Çarşamba", tarih: "3 Mayıs 2028", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (2. Gün)", gun: "Perşembe", tarih: "4 Mayıs 2028", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (3. Gün)", gun: "Cuma", tarih: "5 Mayıs 2028", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (4. Gün)", gun: "Cumartesi", tarih: "6 Mayıs 2028", kat: "Kurban Bayramı" },
      { ad: "Hicri Yılbaşı", gun: "Çarşamba", tarih: "24 Mayıs 2028", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Aşure Günü", gun: "Cuma", tarih: "2 Haziran 2028", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Mevlid Kandili", gun: "Salı", tarih: "1 Ağustos 2028", kat: "Kandil ve Mübarek Geceler" }
    ],
    "2029": [
      { ad: "Regaib Kandili", gun: "Perşembe", tarih: "21 Aralık 2028", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Miraç Kandili", gun: "Cumartesi", tarih: "13 Ocak 2029", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Berat Kandili", gun: "Çarşamba", tarih: "31 Ocak 2029", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Başlangıcı", gun: "Çarşamba", tarih: "14 Şubat 2029", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Kadir Gecesi", gun: "Pazartesi", tarih: "12 Mart 2029", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Bayramı Arefesi", gun: "Perşembe", tarih: "15 Mart 2029", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (1. Gün)", gun: "Cuma", tarih: "16 Mart 2029", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (2. Gün)", gun: "Cumartesi", tarih: "17 Mart 2029", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (3. Gün)", gun: "Pazar", tarih: "18 Mart 2029", kat: "Ramazan Bayramı" },
      { ad: "Kurban Bayramı Arefesi", gun: "Cumartesi", tarih: "21 Nisan 2029", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (1. Gün)", gun: "Pazar", tarih: "22 Nisan 2029", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (2. Gün)", gun: "Pazartesi", tarih: "23 Nisan 2029", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (3. Gün)", gun: "Salı", tarih: "24 Nisan 2029", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (4. Gün)", gun: "Çarşamba", tarih: "25 Nisan 2029", kat: "Kurban Bayramı" },
      { ad: "Hicri Yılbaşı", gun: "Pazartesi", tarih: "14 Mayıs 2029", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Aşure Günü", gun: "Çarşamba", tarih: "23 Mayıs 2029", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Mevlid Kandili", gun: "Salı", tarih: "22 Temmuz 2029", kat: "Kandil ve Mübarek Geceler" }
    ],
    "2030": [
      { ad: "Regaib Kandili", gun: "Perşembe", tarih: "10 Ocak 2030", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Miraç Kandili", gun: "Salı", tarih: "29 Ocak 2030", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Berat Kandili", gun: "Cuma", tarih: "15 Şubat 2030", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Başlangıcı", gun: "Salı", tarih: "5 Mart 2030", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Kadir Gecesi", gun: "Pazar", tarih: "31 Mart 2030", kat: "Kandil ve Mübarek Geceler" },
      { ad: "Ramazan Bayramı Arefesi", gun: "Perşembe", tarih: "4 Nisan 2030", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (1. Gün)", gun: "Cuma", tarih: "5 Nisan 2030", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (2. Gün)", gun: "Cumartesi", tarih: "6 Nisan 2030", kat: "Ramazan Bayramı" },
      { ad: "Ramazan Bayramı (3. Gün)", gun: "Pazar", tarih: "7 Nisan 2030", kat: "Ramazan Bayramı" },
      { ad: "Kurban Bayramı Arefesi", gun: "Pazartesi", tarih: "11 Nisan 2030", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (1. Gün)", gun: "Salı", tarih: "12 Nisan 2030", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (2. Gün)", gun: "Çarşamba", tarih: "13 Nisan 2030", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (3. Gün)", gun: "Perşembe", tarih: "14 Nisan 2030", kat: "Kurban Bayramı" },
      { ad: "Kurban Bayramı (4. Gün)", gun: "Cuma", tarih: "15 Nisan 2030", kat: "Kurban Bayramı" },
      { ad: "Hicri Yılbaşı", gun: "Cuma", tarih: "3 Mayıs 2030", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Aşure Günü", gun: "Pazar", tarih: "12 Mayıs 2030", kat: "Hicri Yılbaşı ve Aşure" },
      { ad: "Mevlid Kandili", gun: "Salı", tarih: "11 Temmuz 2030", kat: "Kandil ve Mübarek Geceler" }
    ]
  };

  const drawList = () => {
    const list = DINI_GUNLER_BY_YEAR[selectedYear] || [];
    const grouped = {};
    list.forEach(item => {
      const kat = item.kat || 'Diğer';
      if (!grouped[kat]) grouped[kat] = [];
      grouped[kat].push(item);
    });

    const categoryOrder = [
      "Kandil ve Mübarek Geceler",
      "Ramazan Bayramı",
      "Kurban Bayramı",
      "Hicri Yılbaşı ve Aşure"
    ];

    let html = `
      <div class="calendar-wrapper" style="max-height:400px; overflow-y:auto;">
        <div class="year-tabs" style="display:flex; justify-content:center; gap:6px; margin-bottom:15px; position:sticky; top:0; background:#fff; padding:5px 0; z-index:10; border-bottom:1px solid #eee;">
          ${["2026", "2027", "2028", "2029", "2030"].map(yr => `
            <button class="btn ${yr === selectedYear ? 'btn-primary' : 'btn-secondary'} yr-btn ripple" data-year="${yr}" style="font-size:12px; padding:6px 12px; font-weight:bold;">${yr}</button>
          `).join('')}
        </div>
        <div class="dini-gunler-list">
    `;

    categoryOrder.forEach(catName => {
      const items = grouped[catName] || [];
      if (items.length > 0) {
        html += `
          <div style="font-weight:bold; color:#1e5e43; border-left:4px solid #27a770; padding-left:8px; margin:15px 0 10px 0; font-size:13.5px; background:#f4faf7; padding-top:6px; padding-bottom:6px;">${catName}</div>
        `;
        items.forEach(day => {
          html += `
            <div class="dini-gun-row" style="padding:10px 8px; border-bottom:1px solid #f5f5f5; display:flex; justify-content:space-between; align-items:center;">
              <div>
                <div style="font-weight:bold; color:#333; font-size:13px;">${day.ad}</div>
                <div style="font-size:11px; color:#888;">${day.gun}</div>
              </div>
              <div style="font-size:12px; background:#eaf7f1; color:#27a770; padding:4px 10px; border-radius:15px; font-weight:bold;">
                ${day.tarih}
              </div>
            </div>
          `;
        });
      }
    });

    html += `
        </div>
      </div>
    `;

    container.innerHTML = html;

    container.querySelectorAll('.yr-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        selectedYear = btn.getAttribute('data-year');
        drawList();
      });
    });
  };

  drawList();
}

// 7. SORU CEVAP & DINI DANISMAN
function renderSoruCevap(container) {
  container.innerHTML = `
    <div class="chat-wrapper" style="display:flex; flex-direction:column; height:380px;">
      <div class="chat-messages" id="chat-box" style="flex:1; overflow-y:auto; padding:10px; background:#f9f9f9; border-radius:12px; border:1px solid #eee; margin-bottom:10px; display:flex; flex-direction:column;">
      </div>
      <div class="chat-input-area" style="display:flex; gap:8px;">
        <input type="text" id="chat-input" placeholder="Sorunuzu yazın..." class="form-control-styled" style="flex:1;">
        <button class="btn btn-primary ripple" id="chat-send" style="padding:0 15px;">Gönder</button>
      </div>
    </div>
  `;

  const chatBox = container.querySelector('#chat-box');
  const chatInput = container.querySelector('#chat-input');
  const chatSend = container.querySelector('#chat-send');

  const renderMessages = async () => {
    try {
      const res = await fetch('/api/questions');
      if (res.ok) {
        const qas = await res.json();
        chatBox.innerHTML = `
          <div class="chat-bubble bot" style="background:#eaf7f1; color:#222; align-self:flex-start; margin-bottom:8px; padding:10px 14px; border-radius:14px 14px 14px 0; max-width:80%; font-size:13px; line-height:1.4; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
            Selamün Aleyküm, ben dini danışmanınız. Merak ettiğiniz fıkhi veya dini konuları sorabilirsiniz. Sorularınız yöneticilerimize iletilecek ve en kısa sürede cevaplanacaktır.
          </div>
        `;

        qas.forEach(item => {
          const userBubble = document.createElement('div');
          userBubble.className = 'chat-bubble user';
          userBubble.style.cssText = "background:#27a770; color:#fff; align-self:flex-end; margin-left:auto; margin-bottom:8px; padding:10px 14px; border-radius:14px 14px 0 14px; max-width:80%; font-size:13px; line-height:1.4; box-shadow: 0 1px 2px rgba(0,0,0,0.05);";
          userBubble.textContent = item.soru;
          chatBox.appendChild(userBubble);

          const botBubble = document.createElement('div');
          botBubble.className = 'chat-bubble bot';
          botBubble.style.cssText = "background:#eaf7f1; color:#222; align-self:flex-start; margin-bottom:8px; padding:10px 14px; border-radius:14px 14px 14px 0; max-width:80%; font-size:13px; line-height:1.4; box-shadow: 0 1px 2px rgba(0,0,0,0.05);";
          
          if (item.cevap) {
            botBubble.innerHTML = `<strong style="color:#27a770; display:block; margin-bottom:4px; font-size:11px;">Müftü (Yönetici) Cevabı:</strong>${item.cevap}`;
          } else {
            botBubble.innerHTML = `<span style="font-style:italic; color:#888;">⏳ Cevap bekleniyor...</span>`;
          }
          chatBox.appendChild(botBubble);
        });

        chatBox.scrollTop = chatBox.scrollHeight;
      }
    } catch (e) {
      console.error(e);
    }
  };

  const handleSend = async () => {
    const text = chatInput.value.trim();
    if (!text) return;

    const newQA = {
      yazar: "Ahmet Yılmaz", 
      soru: text,
      cevap: null,
      tarih: new Date().toLocaleString('tr-TR')
    };

    try {
      const res = await fetch('/api/questions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newQA)
      });
      if (res.ok) {
        chatInput.value = '';
        renderMessages();
      }
    } catch (e) {
      console.error(e);
    }
  };

  chatSend.addEventListener('click', handleSend);
  chatInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') handleSend();
  });

  renderMessages();

  const pollInterval = setInterval(() => {
    if (!document.getElementById(`modal-soru-cevap`)) {
      clearInterval(pollInterval);
      return;
    }
    renderMessages();
  }, 3000);
}

// 8. DUA ISTE (Community Prayers simulation)
function renderDuaIste(container, showNotification) {
  container.innerHTML = `
    <div class="dua-iste-wrapper">
      <div class="dua-input-box" style="margin-bottom:20px; border-bottom:1px solid #eee; padding-bottom:15px;">
        <h5 style="margin-bottom:8px;">Dua Talebi Yazın</h5>
        <div class="form-group">
          <input type="text" id="dua-yazar" placeholder="Adınız (İsteğe bağlı)" class="form-control-styled" style="width:100%; margin-bottom:8px;">
          <textarea id="dua-text" placeholder="Dua talebinizi buraya yazın..." class="form-control-styled" style="width:100%; height:70px; resize:none; margin-bottom:8px;"></textarea>
          <button class="btn btn-primary ripple w-100" id="dua-post-btn" style="width:100%;">Dua İsteğini Paylaş</button>
        </div>
      </div>
      
      <h5>Dua Bekleyenler</h5>
      <div class="dua-list-container" id="dua-list" style="max-height:220px; overflow-y:auto; margin-top:10px;">Yükleniyor...</div>
    </div>
  `;

  const listDiv = container.querySelector('#dua-list');
  const postBtn = container.querySelector('#dua-post-btn');
  const authorInput = container.querySelector('#dua-yazar');
  const textInput = container.querySelector('#dua-text');

  const renderDuaList = async () => {
    try {
      const res = await fetch('/api/duas');
      if (res.ok) {
        const currentList = await res.json();
        const publishedList = currentList.filter(d => d.durum === 'yayinda');

        listDiv.innerHTML = '';
        if (publishedList.length === 0) {
          listDiv.innerHTML = '<div style="text-align:center; padding:20px; color:#888; font-size:12px;">Henüz yayınlanmış dua isteği bulunmamaktadır.</div>';
          return;
        }

        publishedList.forEach(item => {
          const card = document.createElement('div');
          card.className = 'dua-request-card';
          card.style.cssText = "background:#f9f9f9; padding:12px; border-radius:12px; margin-bottom:10px; border:1px solid #eee;";
          card.innerHTML = `
            <div style="font-weight:bold; font-size:13px; color:#27a770; margin-bottom:4px;">${item.yazar || 'Anonim'}</div>
            <p style="font-size:12px; color:#444; line-height:1.4; margin:0 0 8px 0;">${item.dua}</p>
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <span style="font-size:11px; color:#888;">${item.amin || 0} kişi Amin dedi</span>
              <button class="btn btn-secondary ripple amin-btn" data-id="${item.id}" style="padding:4px 10px; font-size:11px; border-radius:12px; display:flex; align-items:center; gap:4px;">
                ❤️ Amin de
              </button>
            </div>
          `;
          listDiv.appendChild(card);
        });

        const aminBtns = listDiv.querySelectorAll('.amin-btn');
        aminBtns.forEach(btn => {
          btn.addEventListener('click', async () => {
            const id = parseInt(btn.getAttribute('data-id'));
            try {
              const postRes = await fetch('/api/duas/amin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id })
              });
              if (postRes.ok) {
                renderDuaList();
                showNotification('Amin!', 'Duaya katıldınız, Allah kabul etsin.', 'default');
              }
            } catch (e) {
              console.error(e);
            }
          });
        });
      }
    } catch (e) {
      console.error(e);
    }
  };

  postBtn.addEventListener('click', async () => {
    const text = textInput.value.trim();
    if (!text) {
      alert('Lütfen dua metnini boş bırakmayın.');
      return;
    }

    const newDua = {
      yazar: authorInput.value.trim() || 'Anonim',
      dua: text,
      amin: 0,
      durum: 'bekliyor',
      tarih: new Date().toLocaleString('tr-TR')
    };

    try {
      const res = await fetch('/api/duas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newDua)
      });
      if (res.ok) {
        authorInput.value = '';
        textInput.value = '';
        renderDuaList();
        alert('Duanız onay için yöneticiye gönderildi. Onaylandıktan sonra yayınlanacaktır.');
        showNotification('Gönderildi', 'Dua talebiniz onay bekliyor.', 'default');
      }
    } catch (e) {
      console.error(e);
    }
  });

  renderDuaList();

  const pollInterval = setInterval(() => {
    if (!document.getElementById(`modal-dua-iste`)) {
      clearInterval(pollInterval);
      return;
    }
    renderDuaList();
  }, 3000);
}

// 9. QURAN AUDIO PLAYER & YASIN
function renderQuranPlayer(container, onlyYasin = false) {
  container.innerHTML = `
    <div class="quran-player-wrapper" style="text-align:center;">
      <div style="font-size:50px; margin-bottom:10px;">📖</div>
      <h4 style="margin-bottom:5px;">${onlyYasin ? 'Yasin Suresi' : 'Kur\'an-ı Kerim Dinle'}</h4>
      <p style="font-size:12px; color:#666; margin-bottom:20px;">
        ${onlyYasin ? 'Yasin-i Şerif okunuşunu dinleyin ve takip edin.' : 'Cüz cüz tilavetleri dinleyebilir, Kur\'an-ı Kerim takibi yapabilirsiniz.'}
      </p>
      
      <div class="audio-control-card" style="background:#eaf7f1; padding:15px; border-radius:15px; border:1px solid #c2f0d8; margin-bottom:20px;">
        <div style="font-weight:bold; color:#27a770; margin-bottom:10px;" id="track-name">
          ${onlyYasin ? 'Yasin Suresi - Meal ve Tilavet' : '1. Cüz - Fatih Çollak'}
        </div>
        <audio id="quran-audio" src="${onlyYasin ? 'https://server8.mp3quran.net/afs/036.mp3' : 'https://server8.mp3quran.net/afs/001.mp3'}" controls style="width:100%; border-radius:8px;"></audio>
      </div>

      ${onlyYasin ? `
        <div class="yasin-text" style="max-height:180px; overflow-y:auto; text-align:right; font-family:'Traditional Arabic', serif; font-size:18px; line-height:2.2; border:1px solid #eee; padding:15px; border-radius:12px; background:#fff; direction:rtl;">
          بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ <br>
          يس ﴿١﴾ وَالْقُرْآنِ الْحَكِيمِ ﴿٢﴾ إِنَّكَ لَمِنَ الْمُرْسَلِينَ ﴿٣﴾ عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ ﴿٤﴾ تَنْزِيلَ الْعَزِيزِ الرَّحِيمِ ﴿٥﴾ لِتُنْذِرَ قَوْمًا مَا أُنْذِرَ آبَاؤُهُمْ فَهُمْ غَافِلُونَ ﴿٦﴾ لَقَدْ حَقَّ الْقَوْلُ عَلَىٰ أَكْثَرِهِمْ فَهُمْ لَا يُؤْمِنُونَ ﴿٧﴾
        </div>
      ` : `
        <div class="cuz-selector-grid" style="display:grid; grid-template-columns: repeat(3, 1fr); gap:8px; max-height:180px; overflow-y:auto;">
          ${KURAN_CUZLER.map(item => `
            <button class="btn btn-secondary cuz-btn ripple" data-url="https://server8.mp3quran.net/afs/${String(item.cuz).padStart(3, '0')}.mp3" data-name="${item.cuz}. Cüz Tilaveti" style="font-size:12px; padding:8px 5px;">
              ${item.cuz}. Cüz
            </button>
          `).join('')}
        </div>
      `}
    </div>
  `;

  if (!onlyYasin) {
    const audio = container.querySelector('#quran-audio');
    const trackName = container.querySelector('#track-name');
    const cuzBtns = container.querySelectorAll('.cuz-btn');

    cuzBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const url = btn.getAttribute('data-url');
        const name = btn.getAttribute('data-name');
        
        audio.src = url;
        trackName.textContent = name;
        audio.play();

        // Highlight selected
        cuzBtns.forEach(b => b.className = 'btn btn-secondary cuz-btn ripple');
        btn.className = 'btn btn-primary cuz-btn ripple';
      });
    });
  }
}

// 10. CANLI SOHBET
function renderCanliSohbet(container, showNotification) {
  container.innerHTML = `
    <div style="text-align:center; padding:40px 20px; font-family:sans-serif;">
      <div style="font-size:60px; margin-bottom:15px;">🎧</div>
      <h3 style="color:#1e5e43; margin-bottom:10px; font-weight:bold;">Canlı Dini Sohbet</h3>
      <p style="color:#666; font-size:13px; line-height:1.5; max-width:300px; margin:0 auto 20px auto;">Değerli hocalarımızın canlı dini sohbet yayınları çok yakında bu ekranda sizlerle olacaktır.</p>
      <div style="display:inline-block; background:#27a770; color:#fff; padding:8px 20px; border-radius:20px; font-weight:bold; font-size:13px; box-shadow:0 4px 10px rgba(39,167,112,0.2);">Yakında</div>
    </div>
  `;
}

// 11. PEYGAMBER HAYATI
function renderPeygamberHayati(container) {
  let tabsHtml = PEYGAMBER_HAYATI.map((item, index) => `
    <button class="tab-btn ${index === 0 ? 'active' : ''}" data-index="${index}">${item.baslik.split(' ')[0]}</button>
  `).join('');

  container.innerHTML = `
    <div class="peygamber-hayati-wrapper">
      <div class="tab-bar">
        ${tabsHtml}
      </div>
      <div class="peygamber-content info-card" style="min-height: 200px; padding: 20px;">
        <h4 style="color: var(--primary-color); margin-bottom: 10px;" id="peygamber-title">${PEYGAMBER_HAYATI[0].baslik}</h4>
        <p style="font-size: 13px; line-height: 1.6; color: var(--text-primary);" id="peygamber-text">${PEYGAMBER_HAYATI[0].icerik}</p>
      </div>
    </div>
  `;

  const tabs = container.querySelectorAll('.tab-btn');
  const titleEl = container.querySelector('#peygamber-title');
  const textEl = container.querySelector('#peygamber-text');

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      const index = parseInt(tab.getAttribute('data-index'));
      titleEl.textContent = PEYGAMBER_HAYATI[index].baslik;
      textEl.textContent = PEYGAMBER_HAYATI[index].icerik;
    });
  });
}

// 12. RAMAZAN HAKKINDA
function renderRamazanHakkinda(container) {
  container.innerHTML = `
    <div class="ramazan-hakkinda-wrapper" style="display:flex; flex-direction:column; gap:12px;">
      ${RAMAZAN_HAKKINDA.map(item => `
        <div class="info-card ornamental">
          <div class="info-card-header">
            <span class="info-card-icon">🌙</span>
            <span class="info-card-title">${item.baslik}</span>
          </div>
          <div class="info-card-body" style="font-size: 12px; line-height: 1.5; color: var(--text-secondary);">
            ${item.icerik}
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

// 13. ORUC REHBERI
function renderOrucRehberi(container) {
  container.innerHTML = `
    <div class="oruc-rehberi-wrapper">
      <div class="accordion-list">
        
        <div class="accordion-item active">
          <div class="accordion-header">Orucu Bozan Durumlar</div>
          <div class="accordion-body">
            <ul style="padding-left: 20px; display: flex; flex-direction: column; gap: 8px;">
              ${ORUC_REHBERI.bozanlar.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>

        <div class="accordion-item">
          <div class="accordion-header">Orucu Bozmayan Durumlar</div>
          <div class="accordion-body">
            <ul style="padding-left: 20px; display: flex; flex-direction: column; gap: 8px;">
              ${ORUC_REHBERI.bozmayanlar.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>

        <div class="accordion-item">
          <div class="accordion-header">Oruç Çeşitleri</div>
          <div class="accordion-body">
            <div style="display: flex; flex-direction: column; gap: 10px;">
              ${ORUC_REHBERI.cesitler.map(item => `
                <div>
                  <strong style="color: var(--primary-color);">${item.ad}:</strong>
                  <p style="margin-top: 2px; color: var(--text-secondary);">${item.aciklama}</p>
                </div>
              `).join('')}
            </div>
          </div>
        </div>

      </div>
    </div>
  `;

  const items = container.querySelectorAll('.accordion-item');
  items.forEach(item => {
    const header = item.querySelector('.accordion-header');
    header.addEventListener('click', () => {
      const isActive = item.classList.contains('active');
      items.forEach(i => i.classList.remove('active'));
      if (!isActive) {
        item.classList.add('active');
      }
    });
  });
}

// 14. YAKINDAKI CAMILER
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const dist = R * c;
  return dist; // raw km as float
}

const CITY_COORDINATES = {
  "adana": { lat: 36.9914, lon: 35.3308 },
  "adiyaman": { lat: 37.7648, lon: 38.2786 },
  "afyonkarahisar": { lat: 38.7507, lon: 30.5567 },
  "afyon": { lat: 38.7507, lon: 30.5567 },
  "agri": { lat: 39.7191, lon: 43.0503 },
  "amasya": { lat: 40.6499, lon: 35.8353 },
  "ankara": { lat: 39.9334, lon: 32.8597 },
  "antalya": { lat: 36.8969, lon: 30.7133 },
  "artvin": { lat: 41.1828, lon: 41.8183 },
  "aydin": { lat: 37.8444, lon: 27.8458 },
  "balikesir": { lat: 39.6484, lon: 27.8826 },
  "bilecik": { lat: 40.1451, lon: 29.9799 },
  "bingol": { lat: 38.8847, lon: 40.4939 },
  "bitlis": { lat: 38.4006, lon: 42.1095 },
  "bolu": { lat: 40.7316, lon: 31.5898 },
  "burdur": { lat: 37.7203, lon: 30.2908 },
  "bursa": { lat: 40.1885, lon: 29.0610 },
  "canakkale": { lat: 40.1553, lon: 26.4142 },
  "cankiri": { lat: 40.6013, lon: 33.6134 },
  "corum": { lat: 40.5506, lon: 34.9556 },
  "denizli": { lat: 37.7765, lon: 29.0864 },
  "diyarbakir": { lat: 37.9144, lon: 40.2306 },
  "edirne": { lat: 41.6818, lon: 26.5623 },
  "elazig": { lat: 38.6810, lon: 39.2230 },
  "erzincan": { lat: 39.7500, lon: 39.5000 },
  "erzurum": { lat: 39.9000, lon: 41.2700 },
  "eskisehir": { lat: 39.7767, lon: 30.5206 },
  "gaziantep": { lat: 37.0662, lon: 37.3833 },
  "giresun": { lat: 40.9128, lon: 38.3895 },
  "gumushane": { lat: 40.4600, lon: 39.4817 },
  "hakkari": { lat: 37.5833, lon: 43.7333 },
  "hatay": { lat: 36.4018, lon: 36.3498 },
  "isparta": { lat: 37.7648, lon: 30.5566 },
  "mersin": { lat: 36.8000, lon: 34.6333 },
  "icel": { lat: 36.8000, lon: 34.6333 },
  "istanbul": { lat: 41.0082, lon: 28.9784 },
  "izmir": { lat: 38.4192, lon: 27.1287 },
  "kars": { lat: 40.6013, lon: 43.0949 },
  "kastamonu": { lat: 41.3887, lon: 33.7827 },
  "kayseri": { lat: 38.7312, lon: 35.4787 },
  "kirklareli": { lat: 41.7333, lon: 27.2167 },
  "kirsehir": { lat: 39.1425, lon: 34.1709 },
  "kocaeli": { lat: 40.8533, lon: 29.8815 },
  "konya": { lat: 37.8714, lon: 32.4847 },
  "kutahya": { lat: 39.4167, lon: 29.9833 },
  "malatya": { lat: 38.3552, lon: 38.3095 },
  "manisa": { lat: 38.6191, lon: 27.4287 },
  "kahramanmaras": { lat: 37.5858, lon: 36.9371 },
  "maras": { lat: 37.5858, lon: 36.9371 },
  "kmaras": { lat: 37.5858, lon: 36.9371 },
  "mardin": { lat: 37.3122, lon: 40.7339 },
  "mugla": { lat: 37.2153, lon: 28.3636 },
  "mus": { lat: 38.7432, lon: 41.5064 },
  "nevsehir": { lat: 38.6244, lon: 34.7144 },
  "nigde": { lat: 37.9667, lon: 34.6833 },
  "ordu": { lat: 40.9839, lon: 37.8764 },
  "rize": { lat: 41.0201, lon: 40.5234 },
  "sakarya": { lat: 40.7569, lon: 30.3789 },
  "samsun": { lat: 41.2928, lon: 36.3313 },
  "siirt": { lat: 37.9333, lon: 41.9500 },
  "sinop": { lat: 42.0264, lon: 35.1628 },
  "sivas": { lat: 39.7477, lon: 37.0179 },
  "tekirdag": { lat: 40.9833, lon: 27.5167 },
  "tokat": { lat: 40.3167, lon: 36.5500 },
  "trabzon": { lat: 41.0027, lon: 39.7168 },
  "tunceli": { lat: 39.1079, lon: 39.5401 },
  "sanliurfa": { lat: 37.1591, lon: 38.7969 },
  "urfa": { lat: 37.1591, lon: 38.7969 },
  "surfa": { lat: 37.1591, lon: 38.7969 },
  "usak": { lat: 38.6823, lon: 29.4082 },
  "van": { lat: 38.5012, lon: 43.3730 },
  "yozgat": { lat: 39.8181, lon: 34.8147 },
  "zonguldak": { lat: 41.4564, lon: 31.7987 },
  "aksaray": { lat: 38.3687, lon: 34.0370 },
  "bayburt": { lat: 40.2561, lon: 40.2249 },
  "karaman": { lat: 37.1759, lon: 33.2287 },
  "kirikkale": { lat: 39.8468, lon: 33.5153 },
  "batman": { lat: 37.8874, lon: 41.1322 },
  "sirnak": { lat: 37.5164, lon: 42.4594 },
  "bartin": { lat: 41.6376, lon: 32.3338 },
  "ardahan": { lat: 41.1105, lon: 42.7022 },
  "igdir": { lat: 39.9167, lon: 44.0333 },
  "yalova": { lat: 40.6551, lon: 29.2769 },
  "karabuk": { lat: 41.2061, lon: 32.6204 },
  "kilis": { lat: 36.7161, lon: 37.1150 },
  "osmaniye": { lat: 37.0742, lon: 36.2467 },
  "duzce": { lat: 40.8438, lon: 31.1565 }
};

function normalizeCityName(str) {
  if (!str) return '';
  return str.toString()
    .replace(/İ/g, 'i')
    .replace(/I/g, 'ı')
    .toLowerCase()
    .replace(/ı/g, 'i')
    .replace(/ğ/g, 'g')
    .replace(/ü/g, 'u')
    .replace(/ş/g, 's')
    .replace(/ö/g, 'o')
    .replace(/ç/g, 'c')
    .replace(/[^a-z0-9]/g, '');
}

function renderYakindakiCamiler(container) {
  container.innerHTML = `
    <div class="camiler-wrapper" style="max-height: 400px; overflow-y: auto; text-align:center; padding: 20px 10px;">
      <div class="spinner" style="margin:20px auto;"></div>
      <div style="font-weight:bold; color:var(--primary-color); font-size:14px; margin-bottom:8px;">🛰️ Konum Bilginiz Alınıyor...</div>
      <div style="font-size:12px; color:var(--text-secondary); line-height:1.5;">Çevrenizdeki en yakın camileri tespit edebilmek için konum bilgisi sorgulanıyor. Lütfen bekleyin.</div>
    </div>
  `;

  // Fallback rendering function using historical Fatih/Istanbul mosques
  const renderFallback = (coords = null) => {
    let titleMsg = "Fatih/İstanbul bölgesindeki camiler listelenmektedir.";
    let updatedCamiler = MOCK_CAMILER.map(c => ({
      ad: c.ad,
      adres: c.adres,
      mesafeStr: c.mesafe,
      harita: c.harita,
      distanceVal: parseFloat(c.mesafe)
    }));

    if (coords) {
      titleMsg = "En yakın camiler (Konumunuza göre hesaplandı):";
      // Coordinates of the mock historical mosques
      const mosqueCoords = [
        { lat: 41.0196, lon: 28.9498 }, // Fatih Camii
        { lat: 41.0162, lon: 28.9639 }, // Süleymaniye Camii
        { lat: 41.0064, lon: 28.9760 }, // Sultanahmet Camii
        { lat: 41.0269, lon: 28.9511 }, // Yavuz Selim Camii
        { lat: 41.0101, lon: 28.9702 }  // Nuruosmaniye Camii
      ];

      updatedCamiler = MOCK_CAMILER.map((c, idx) => {
        const mc = mosqueCoords[idx];
        const dist = calculateDistance(coords.lat, coords.lon, mc.lat, mc.lon);
        return {
          ad: c.ad,
          adres: c.adres,
          mesafeStr: `${dist.toFixed(1)} km`,
          harita: `https://www.google.com/maps/dir/?api=1&destination=${mc.lat},${mc.lon}`,
          distanceVal: dist
        };
      }).sort((a, b) => a.distanceVal - b.distanceVal);
    }

    container.innerHTML = `
      <div class="camiler-wrapper" style="max-height: 400px; overflow-y: auto;">
        <p style="font-size:12px; color:#888; margin-bottom:15px; text-align:center;">${titleMsg}</p>
        ${updatedCamiler.map(camii => `
          <div class="mosque-card" onclick="window.open('${camii.harita}', '_blank')">
            <div class="mosque-info">
              <div class="mosque-name">${camii.ad}</div>
              <div class="mosque-address">📍 ${camii.adres}</div>
              <span class="directions-btn">🗺️ Yol Tarifi Al</span>
            </div>
            <div class="distance-badge">${camii.mesafeStr}</div>
          </div>
        `).join('')}
      </div>
    `;
  };

  const runQuery = async (lat, lon, isGps = false) => {
    try {
      // Fetch real mosques within 3km (3000m) using OpenStreetMap's Overpass API
      const overpassUrl = `https://overpass-api.de/api/interpreter?data=[out:json][timeout:12];nwr["amenity"="place_of_worship"]["religion"="muslim"](around:3000,${lat},${lon});out geom;`;
      const response = await fetch(overpassUrl);
      
      if (!response.ok) throw new Error('Overpass API error');
      const data = await response.json();
      
      if (data && data.elements && data.elements.length > 0) {
        // Map OSM elements to mosque cards
        const mosques = data.elements.map(el => {
          const name = el.tags.name || el.tags["name:tr"] || "Camii";
          const street = el.tags["addr:street"] || "";
          const suburb = el.tags["addr:suburb"] || "";
          const city = el.tags["addr:city"] || "";
          const fullAddress = `${street} ${suburb} ${city}`.trim() || "Yakınlarda";
          
          const mosqueLat = el.lat || (el.center ? el.center.lat : lat);
          const mosqueLon = el.lon || (el.center ? el.center.lon : lon);
          
          const distance = calculateDistance(lat, lon, mosqueLat, mosqueLon);
          
          return {
            ad: name,
            adres: fullAddress,
            mesafeStr: `${distance.toFixed(1)} km`,
            harita: `https://www.google.com/maps/dir/?api=1&destination=${mosqueLat},${mosqueLon}`,
            distanceVal: distance
          };
        });

        // Sort mosques by distance
        mosques.sort((a, b) => a.distanceVal - b.distanceVal);

        const locationSourceMsg = isGps ? "Bulunduğunuz konuma en yakın camiler (Canlı GPS verisi):" : `Seçtiğiniz şehir merkezine en yakın camiler:`;

        container.innerHTML = `
          <div class="camiler-wrapper" style="max-height: 400px; overflow-y: auto;">
            <p style="font-size:12px; color:#888; margin-bottom:15px; text-align:center;">${locationSourceMsg}</p>
            ${mosques.map(camii => `
              <div class="mosque-card" onclick="window.open('${camii.harita}', '_blank')">
                <div class="mosque-info">
                  <div class="mosque-name" style="font-weight:700;">${camii.ad}</div>
                  <div class="mosque-address">📍 ${camii.adres}</div>
                  <span class="directions-btn">🗺️ Yol Tarifi Al</span>
                </div>
                <div class="distance-badge">${camii.mesafeStr}</div>
              </div>
            `).join('')}
          </div>
        `;
      } else {
        // No elements returned, use fallback coordinates
        renderFallback({ lat, lon });
      }
    } catch (e) {
      console.warn('Overpass API error, falling back to historical list.', e);
      renderFallback({ lat, lon });
    }
  };

  // Check if there is a saved manual location in localStorage
  const savedLocStr = localStorage.getItem('user_location');
  let savedLoc = null;
  try {
    if (savedLocStr) {
      savedLoc = JSON.parse(savedLocStr);
    }
  } catch (e) {}

  let useSavedCityCoords = false;
  let savedCoords = null;

  if (savedLoc && savedLoc.city) {
    const normCity = normalizeCityName(savedLoc.city);
    if (CITY_COORDINATES[normCity]) {
      savedCoords = CITY_COORDINATES[normCity];
      useSavedCityCoords = true;
    }
  }

  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        runQuery(pos.coords.latitude, pos.coords.longitude, true);
      },
      (err) => {
        console.warn('Geolocation failed, falling back to manual city coordinates:', err.code);
        if (useSavedCityCoords) {
          runQuery(savedCoords.lat, savedCoords.lon, false);
        } else {
          renderFallback();
        }
      },
      { 
        enableHighAccuracy: true, 
        timeout: 10000, 
        maximumAge: 0 
      }
    );
  } else if (useSavedCityCoords) {
    runQuery(savedCoords.lat, savedCoords.lon, false);
  } else {
    renderFallback();
  }
}

// 15. 40 HADIS
function renderHadis40(container) {
  const hadisler = ADDON_DATA.hadis_40 || [];

  container.innerHTML = `
    <div class="hadis-wrapper" style="text-align: center;">
      <input type="text" placeholder="Hadislerde veya kaynaklarda ara..." class="form-control-styled" id="hadis-search" style="margin-bottom:15px; width:100%;">
      
      <div class="hadis-card info-card ornamental" style="min-height: 200px; display: flex; flex-direction: column; justify-content: center; padding: 20px; text-align: left; background: var(--card-bg); border: 1.5px solid var(--border-color); border-radius: 16px; box-shadow: var(--shadow-sm);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
          <span style="font-weight: 800; color: var(--primary-color); font-size: 14px;" id="hadis-no">Hadis #1</span>
          <span style="font-size: 11px; font-weight: 700; background: var(--primary-light); color: var(--primary-color); padding: 2px 8px; border-radius: 10px;" id="hadis-source">Buhari</span>
        </div>
        <div id="hadis-content-body">
          <!-- Populated dynamically -->
        </div>
      </div>

      <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 15px;">
        <button class="btn btn-secondary ripple" id="hadis-prev" style="padding: 8px 16px;">◀ Geri</button>
        <span style="font-size: 12px; color: var(--text-secondary); font-weight: 700;" id="hadis-counter">1 / 40</span>
        <button class="btn btn-primary ripple" id="hadis-next" style="padding: 8px 16px;">İleri ▶</button>
      </div>
    </div>
  `;

  let currentIndex = 0;
  let filteredHadisler = [...hadisler];

  const hadisNo = container.querySelector('#hadis-no');
  const hadisSource = container.querySelector('#hadis-source');
  const contentBody = container.querySelector('#hadis-content-body');
  const hadisCounter = container.querySelector('#hadis-counter');
  const prevBtn = container.querySelector('#hadis-prev');
  const nextBtn = container.querySelector('#hadis-next');
  const searchInput = container.querySelector('#hadis-search');

  const updateHadis = () => {
    if (filteredHadisler.length === 0) {
      hadisNo.textContent = "Sonuç Yok";
      hadisSource.textContent = "";
      contentBody.innerHTML = `<p style="text-align: center; color: var(--text-secondary); margin-top: 20px;">Aramanızla eşleşen hadis-i şerif bulunamadı.</p>`;
      hadisCounter.textContent = "0 / 0";
      prevBtn.disabled = true;
      nextBtn.disabled = true;
      return;
    }

    prevBtn.disabled = false;
    nextBtn.disabled = false;

    const hadis = filteredHadisler[currentIndex];
    hadisNo.textContent = hadis.title || `Hadis #${currentIndex + 1}`;
    hadisSource.textContent = hadis.badge || "Hadis-i Şerif";
    
    let html = '';
    if (hadis.arabic) {
      html += `<div class="arabic-text" style="font-size: 22px; text-align: right; direction: rtl; margin-bottom: 12px; font-family: 'Traditional Arabic', serif; color: var(--primary-color);">${hadis.arabic}</div>`;
    }
    if (hadis.meaning) {
      html += `<div class="meaning-text" style="font-size: 13px; font-weight: 600; color: var(--text-primary); line-height: 1.5; border-left: 3px solid var(--accent-orange); padding-left: 8px; margin-bottom: 10px; background: none; padding-top: 0; padding-bottom: 0;">"${hadis.meaning}"</div>`;
    }
    if (hadis.content && hadis.content.length > 0) {
      html += `<div class="explanation-text" style="font-size: 12px; color: var(--text-secondary); line-height: 1.5; background: var(--bg-color); padding: 10px; border-radius: 10px;">${hadis.content.map(p => p.replace(/\n/g, '<br>')).join('<br>')}</div>`;
    }

    contentBody.innerHTML = html;
    hadisCounter.textContent = `${currentIndex + 1} / ${filteredHadisler.length}`;
  };

  prevBtn.addEventListener('click', () => {
    if (filteredHadisler.length === 0) return;
    currentIndex = (currentIndex - 1 + filteredHadisler.length) % filteredHadisler.length;
    updateHadis();
  });

  nextBtn.addEventListener('click', () => {
    if (filteredHadisler.length === 0) return;
    currentIndex = (currentIndex + 1) % filteredHadisler.length;
    updateHadis();
  });

  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();
    filteredHadisler = hadisler.filter(h => 
      (h.title && h.title.toLowerCase().includes(query)) ||
      (h.arabic && h.arabic.toLowerCase().includes(query)) ||
      (h.meaning && h.meaning.toLowerCase().includes(query)) ||
      (h.badge && h.badge.toLowerCase().includes(query)) ||
      (h.content && h.content.some(p => p.toLowerCase().includes(query)))
    );
    currentIndex = 0;
    updateHadis();
  });

  updateHadis();
}

// 16. NAMAZ TESBIHATI
function renderNamazTesbihati(container, showNotification) {
  const allSteps = ADDON_DATA.namaz_tesbihati || [];

  const vakitGroups = [
    { key: 'sabah', name: 'Sabah', start: 51, end: 70 },
    { key: 'ogle', name: 'Öğle', start: 37, end: 50 },
    { key: 'ikindi', name: 'İkindi', start: 23, end: 36 },
    { key: 'aksam', name: 'Akşam', start: 0, end: 22 },
    { key: 'yatsi', name: 'Yatsı', start: 71, end: 86 }
  ];

  let activeVakitIndex = 0;
  let currentStepIndex = 0;
  let subCount = 0;

  const playClickSound = () => {
    try {
      const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const oscillator = audioCtx.createOscillator();
      const gainNode = audioCtx.createGain();
      oscillator.connect(gainNode);
      gainNode.connect(audioCtx.destination);
      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(800, audioCtx.currentTime);
      gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.08);
      oscillator.start();
      oscillator.stop(audioCtx.currentTime + 0.08);
    } catch (e) {
      console.log(e);
    }
  };

  const renderUI = () => {
    container.innerHTML = `
      <div class="tesbihat-wrapper">
        <div class="tab-bar" style="margin-bottom: 12px; display:flex; justify-content:center; gap:4px; padding: 4px; background: var(--bg-color); border-radius: 12px;">
          ${vakitGroups.map((vg, idx) => `
            <button class="tab-btn ${idx === activeVakitIndex ? 'active' : ''}" data-vakit="${idx}" style="flex:1; padding: 6px 4px; font-size:11px; font-weight:700;">${vg.name}</button>
          `).join('')}
        </div>

        <div class="tab-bar" id="tesbihat-steps-tabs" style="overflow-x: auto; white-space: nowrap; display: block; padding: 6px; margin-bottom: 12px;">
        </div>

        <div class="tesbih-counter-container" id="tesbih-content" style="min-height: 240px; background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 16px; padding: 15px; margin-bottom: 15px; text-align: center; display: flex; flex-direction: column; justify-content: center;">
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center;">
          <button class="btn btn-secondary ripple" id="tesbih-prev-step">Önceki</button>
          <button class="btn btn-primary ripple" id="tesbih-next-step">Sonraki</button>
        </div>
      </div>
    `;

    const vakitTabs = container.querySelectorAll('[data-vakit]');
    vakitTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        activeVakitIndex = parseInt(tab.getAttribute('data-vakit'));
        currentStepIndex = 0;
        subCount = 0;
        renderUI();
      });
    });

    const stepTabsBar = container.querySelector('#tesbihat-steps-tabs');
    const activeGroup = vakitGroups[activeVakitIndex];
    const activeSteps = allSteps.slice(activeGroup.start, activeGroup.end + 1);

    stepTabsBar.innerHTML = activeSteps.map((step, index) => `
      <button class="tab-btn ${index === currentStepIndex ? 'active' : ''}" data-step="${index}" style="display: inline-block; width: auto; margin-right: 5px; font-size: 11px; padding: 4px 10px;">Adım ${index + 1}</button>
    `).join('');

    const stepTabs = stepTabsBar.querySelectorAll('[data-step]');
    stepTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        currentStepIndex = parseInt(tab.getAttribute('data-step'));
        subCount = 0;
        updateStep();
      });
    });

    const contentEl = container.querySelector('#tesbih-content');
    const prevStepBtn = container.querySelector('#tesbih-prev-step');
    const nextStepBtn = container.querySelector('#tesbih-next-step');

    const updateStep = () => {
      const step = activeSteps[currentStepIndex];
      if (!step) return;

      let target = 1;
      let is333333 = false;
      if (step.badge === "33-33-33 defa") {
        target = 99;
        is333333 = true;
      } else {
        const match = step.badge.match(/(\d+)\.?\s*defa/);
        if (match) {
          target = parseInt(match[1]);
        }
      }

      let stepArabic = step.arabic || "";
      let stepLatin = step.latin || "";
      let stepMeaning = step.meaning || "";
      let clickerLabel = `${subCount} / ${target}`;

      if (is333333) {
        if (subCount < 33) {
          stepArabic = "سُبْحَانَ اللّٰهِ";
          stepLatin = "Sübḥânallâh";
          stepMeaning = "Allah noksan sıfatlardan münezzehtir";
          clickerLabel = `${subCount + 1} / 33 (Sübhanallah)`;
        } else if (subCount < 66) {
          stepArabic = "اَلْحَمْدُ لِلّٰهِ";
          stepLatin = "Elḥamdülillâh";
          stepMeaning = "Hamd Allah'a mahsustur";
          clickerLabel = `${subCount - 33 + 1} / 33 (Elhamdülillah)`;
        } else {
          stepArabic = "اَللّٰهُ اَكْبَرُ";
          stepLatin = "Allâhü Ekber";
          stepMeaning = "Allah en büyüktür";
          clickerLabel = `${subCount - 66 + 1} / 33 (Allahu Ekber)`;
        }
      }

      let html = `<h4 style="color: var(--primary-color); margin-bottom: 12px; font-weight:700; font-size:14px;">${step.title}</h4>`;
      if (stepArabic) {
        html += `<div class="arabic-text" style="font-size:24px; text-align:center; direction:rtl; margin-bottom:12px; font-family:'Traditional Arabic', serif;">${stepArabic}</div>`;
      }
      if (stepLatin) {
        html += `<div class="latin-text" style="font-size:12px; font-weight:600; color:var(--text-primary); text-align:center; border:none; padding:0; margin-bottom:8px;">${stepLatin}</div>`;
      }
      if (stepMeaning) {
        html += `<div class="meaning-text" style="font-size:11px; color:var(--text-secondary); text-align:center; margin-bottom:12px; background:none; padding:0;">${stepMeaning}</div>`;
      }
      if (step.content && step.content.length > 0) {
        html += `<div style="font-size:11.5px; color:var(--text-secondary); font-style:italic; margin-bottom:12px;">${step.content.join('<br>')}</div>`;
      }

      html += `<div class="tesbih-counter-btn" id="tesbih-clicker" style="width: 140px; height: 44px; margin: 10px auto; background: var(--primary-color); color: #fff; border-radius: 22px; display: flex; align-items: center; justify-content: center; font-weight: bold; cursor: pointer; font-size: 14px; box-shadow: var(--shadow-sm); user-select:none;">${clickerLabel}</div>`;

      contentEl.innerHTML = html;

      stepTabs.forEach((tab, idx) => {
        if (idx === currentStepIndex) {
          tab.classList.add('active');
          tab.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
        } else {
          tab.classList.remove('active');
        }
      });

      const clicker = contentEl.querySelector('#tesbih-clicker');
      clicker.addEventListener('click', () => {
        subCount++;
        playClickSound();

        if (navigator.vibrate) {
          navigator.vibrate(30);
        }

        if (subCount >= target) {
          clicker.textContent = is333333 ? "33 / 33 (Allahu Ekber)" : `${subCount} / ${target}`;
          if (navigator.vibrate) {
            navigator.vibrate([100, 50, 100]);
          }
          showNotification("Adım Tamamlandı", `"${step.title}" tamamlandı. Sonraki adıma geçebilirsiniz.`, "default");
          
          setTimeout(() => {
            if (currentStepIndex < activeSteps.length - 1) {
              currentStepIndex++;
              subCount = 0;
              updateStep();
            } else {
              alert(`${activeGroup.name} namazı tesbihatı başarıyla tamamlandı. Rabbim kabul eylesin.`);
            }
          }, 800);
        } else {
          if (is333333) {
            if (subCount < 33) {
              clicker.textContent = `${subCount + 1} / 33 (Sübhanallah)`;
            } else if (subCount === 33) {
              showNotification("Elhamdülillah", "Sübhanallah bitti, Elhamdülillah'a geçiliyor.", "default");
              updateStep();
            } else if (subCount < 66) {
              clicker.textContent = `${subCount - 33 + 1} / 33 (Elhamdülillah)`;
            } else if (subCount === 66) {
              showNotification("Allahu Ekber", "Elhamdülillah bitti, Allahu Ekber'e geçiliyor.", "default");
              updateStep();
            } else {
              clicker.textContent = `${subCount - 66 + 1} / 33 (Allahu Ekber)`;
            }
          } else {
            clicker.textContent = `${subCount} / ${target}`;
          }
        }
      });

      prevStepBtn.disabled = currentStepIndex === 0;
      nextStepBtn.disabled = currentStepIndex === activeSteps.length - 1;
    };

    prevStepBtn.addEventListener('click', () => {
      if (currentStepIndex > 0) {
        currentStepIndex--;
        subCount = 0;
        updateStep();
      }
    });

    nextStepBtn.addEventListener('click', () => {
      if (currentStepIndex < activeSteps.length - 1) {
        currentStepIndex++;
        subCount = 0;
        updateStep();
      }
    });

    updateStep();
  };

  renderUI();
}

// 17. GUNLUK DUALAR
function renderGunlukDualar(container) {
  let list = JSON.parse(localStorage.getItem('gunluk_dualar_list') || '[]');
  if (list.length === 0) {
    list = DUALAR.map((d, index) => ({
      id: index + 1,
      baslik: d.ad,
      dua_metni: d.arapca,
      fazilet: d.anlam,
      sira: index + 1,
      aktif: true
    }));
    localStorage.setItem('gunluk_dualar_list', JSON.stringify(list));
  }

  const activeDualar = list.filter(dua => dua.aktif).sort((a, b) => a.sira - b.sira);

  container.innerHTML = `
    <div class="dualar-wrapper">
      <div style="font-size:12px; color:#888; margin-bottom:12px; text-align:center;">Günlük hayatta karşılaştığımız durumlar için tavsiye edilen dualar.</div>
      <div class="dualar-list" style="max-height: 380px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px;">
        ${activeDualar.map(dua => `
          <div class="info-card" style="margin-bottom: 8px;">
            <h4 style="color: var(--primary-color); margin-bottom: 8px; font-weight:700;">${dua.baslik}</h4>
            <div style="font-size: 20px; font-family: 'Traditional Arabic', serif; text-align: right; margin-bottom: 8px; font-weight: bold; direction: rtl; line-height: 1.6;">${dua.dua_metni}</div>
            <div style="font-size: 12px; color: var(--text-secondary); line-height: 1.5; border-top: 1px solid #eee; padding-top: 8px; margin-top: 8px;"><strong>Fazileti / Meali:</strong> ${dua.fazilet}</div>
          </div>
        `).join('')}
      </div>
    </div>
  `;
}

// 18. SAHABE HAYATLARI
function renderSahabeHayatlari(container) {
  const sahabeList = ADDON_DATA.sahabe_hayatlari || [];

  container.innerHTML = `
    <div class="sahabe-wrapper">
      <input type="text" placeholder="Sahabe ara (Örn: Hz. Ömer)..." class="form-control-styled" id="sahabe-search" style="margin-bottom:15px; width:100%;">
      <div class="sahabe-list" id="sahabe-list-container" style="max-height:385px; overflow-y:auto; display:flex; flex-direction:column; gap:10px; padding:2px;">
      </div>
    </div>
  `;

  const listContainer = container.querySelector('#sahabe-list-container');
  const searchInput = container.querySelector('#sahabe-search');

  const displayList = (query = '') => {
    listContainer.innerHTML = '';
    const filtered = sahabeList.filter(item => 
      item.title.toLowerCase().includes(query.toLowerCase()) || 
      (item.badge && item.badge.toLowerCase().includes(query.toLowerCase())) ||
      (item.content && item.content.some(p => p.toLowerCase().includes(query.toLowerCase())))
    );

    if (filtered.length === 0) {
      listContainer.innerHTML = '<div style="text-align:center; padding:20px; color:var(--text-secondary);">Sahabe bulunamadı.</div>';
      return;
    }

    filtered.forEach((item, idx) => {
      let birthStr = "";
      let deathStr = "";
      let bioStr = "";
      let virtuesStr = "";
      const otherParagraphs = [];

      if (item.content) {
        item.content.forEach(paragraph => {
          if (paragraph.startsWith("Doğum Yılı:")) {
            birthStr = paragraph.replace("Doğum Yılı:", "").trim();
          } else if (paragraph.startsWith("Vefat Yılı:")) {
            deathStr = paragraph.replace("Vefat Yılı:", "").trim();
          } else if (paragraph.startsWith("Biyografi:")) {
            bioStr = paragraph.replace("Biyografi:", "").trim();
          } else if (paragraph.startsWith("Faziletleri:")) {
            virtuesStr = paragraph.replace("Faziletleri:", "").trim();
          } else {
            otherParagraphs.push(paragraph);
          }
        });
      }

      const card = document.createElement('div');
      card.className = 'accordion-item';
      card.id = `sahabe-item-${idx}`;
      
      const badgeClass = item.badge ? 'badge-sunnet' : '';

      let detailedHtml = `<div style="display:flex; gap:8px; flex-wrap:wrap; margin-bottom:10px;">`;
      if (birthStr) {
        detailedHtml += `<span style="font-size:10px; font-weight:800; background:#eaf7f1; color:#27a770; padding:3px 8px; border-radius:8px;">Doğum: ${birthStr}</span>`;
      }
      if (deathStr) {
        detailedHtml += `<span style="font-size:10px; font-weight:800; background:#ffebeb; color:#d9534f; padding:3px 8px; border-radius:8px;">Vefat: ${deathStr}</span>`;
      }
      detailedHtml += `</div>`;

      if (bioStr) {
        detailedHtml += `
          <div style="margin-bottom:12px;">
            <strong style="color:var(--primary-color); font-size:11.5px; display:block; margin-bottom:4px;">Biyografi</strong>
            <p style="font-size:12px; line-height:1.5; color:var(--text-primary); margin:0;">${bioStr}</p>
          </div>
        `;
      }

      if (virtuesStr) {
        const formattedVirtues = virtuesStr.split('\n').map(line => {
          const trimmed = line.trim();
          if (trimmed.startsWith('•') || trimmed.startsWith('-')) {
            return `<li class="bullet-item" style="font-size:11.5px; line-height:1.4; color:var(--text-primary); margin-bottom:4px;">${trimmed.substring(1).trim()}</li>`;
          }
          return `<p style="font-size:12px; color:var(--text-primary); margin:0 0 6px 0;">${trimmed}</p>`;
        }).join('');
        
        detailedHtml += `
          <div style="margin-bottom:10px;">
            <strong style="color:var(--primary-color); font-size:11.5px; display:block; margin-bottom:4px;">Öne Çıkan Özellikleri & Faziletleri</strong>
            <ul class="bullet-list" style="margin-top:4px;">${formattedVirtues}</ul>
          </div>
        `;
      }

      if (otherParagraphs.length > 0) {
        detailedHtml += `
          <div style="margin-top:10px; border-top: 1px dashed var(--border-color); padding-top:8px;">
            ${otherParagraphs.map(p => `<p style="font-size:11.5px; line-height:1.4; color:var(--text-secondary); margin-bottom:6px;">${p}</p>`).join('')}
          </div>
        `;
      }

      card.innerHTML = `
        <div class="accordion-header" style="padding: 12px 14px;">
          <div class="accordion-title-container" style="display:flex; justify-content:space-between; align-items:center; width:100%; padding-right:8px;">
            <span class="accordion-title" style="font-size:13px; font-weight:700; color:var(--text-primary);">${item.title}</span>
            ${item.badge ? `<span class="accordion-badge ${badgeClass}" style="font-size:9px; background:var(--primary-light); color:var(--primary-color); font-weight:700; padding:2px 8px; border-radius:10px; text-transform:none;">${item.badge}</span>` : ''}
          </div>
          <span class="accordion-arrow" style="font-size:10px;">▼</span>
        </div>
        <div class="accordion-content" style="padding: 0 14px;">
          ${detailedHtml}
        </div>
      `;

      listContainer.appendChild(card);
    });

    const items = listContainer.querySelectorAll('.accordion-item');
    items.forEach(item => {
      const header = item.querySelector('.accordion-header');
      header.addEventListener('click', () => {
        const isActive = item.classList.contains('active');
        items.forEach(i => i.classList.remove('active'));
        if (!isActive) {
          item.classList.add('active');
        }
      });
    });
  };

  searchInput.addEventListener('input', (e) => displayList(e.target.value));
  displayList();
}

// 19. ISLAM TARIHI
function renderIslamTarihi(container) {
  const timelineEvents = ADDON_DATA.islam_tarihi || [];

  container.innerHTML = `
    <div class="islam-tarihi-wrapper" style="max-height: 400px; overflow-y: auto; padding: 10px 5px;">
      <h4 style="margin-bottom:15px; color: var(--primary-color); text-align:center; font-weight:800;">İslam Tarihi Önemli Dönemeçleri</h4>
      <div class="timeline-container" style="position: relative; padding-left: 24px; margin: 10px 5px; border-left: 2px solid var(--primary-light);">
        ${timelineEvents.map(item => {
          let descHtml = '';
          if (item.content) {
            descHtml = item.content.map(p => {
              if (p.startsWith("Dönem:") || p.startsWith("Tarih:")) {
                return `<div style="font-weight: 700; color: var(--primary-color); margin-bottom: 4px; font-size: 11px;">${p}</div>`;
              }
              return `<p style="margin-bottom: 6px;">${p.replace(/\n/g, '<br>')}</p>`;
            }).join('');
          }
          return `
            <div class="timeline-item" style="position: relative; margin-bottom: 24px;">
              <div class="timeline-badge" style="position: absolute; left: -35px; top: 2px; width: 20px; height: 20px; border-radius: 50%; background: var(--primary-color); border: 4px solid var(--card-bg); box-shadow: var(--shadow-sm);"></div>
              <div class="timeline-year" style="font-weight: 800; font-size: 15px; color: var(--primary-color); margin-bottom: 4px;">${item.badge || ""}</div>
              <div class="timeline-title" style="font-weight: 700; font-size: 13px; color: var(--text-primary); margin-bottom: 6px;">${item.title}</div>
              <div class="timeline-desc" style="font-size: 12px; color: var(--text-secondary); line-height: 1.4; background: var(--card-bg); border: 1px solid var(--border-color); padding: 12px; border-radius: 12px;">
                ${descHtml}
              </div>
            </div>
          `;
        }).join('')}
      </div>
    </div>
  `;
}

// 20. NAMAZ KILMA
function renderNamazKilma(container) {
  const stepsData = ADDON_DATA.namaz_kilma || {};

  container.innerHTML = `
    <div class="namaz-kilma-wrapper">
      <div class="tab-bar" style="margin-bottom: 12px; display:flex; justify-content:center; gap:8px;">
        <button class="tab-btn active" id="gender-erkek" style="flex:1;">Erkek Kılınış Farkları</button>
        <button class="tab-btn" id="gender-kadin" style="flex:1;">Kadın Kılınış Farkları</button>
      </div>

      <div class="steps-list" id="namaz-steps-container" style="max-height: 350px; overflow-y: auto; padding: 2px;">
      </div>
    </div>
  `;

  const erkekBtn = container.querySelector('#gender-erkek');
  const kadinBtn = container.querySelector('#gender-kadin');
  const stepsContainer = container.querySelector('#namaz-steps-container');

  const renderSteps = (gender) => {
    stepsContainer.innerHTML = '';
    const stepKeys = Object.keys(stepsData).sort((a, b) => parseInt(a) - parseInt(b));

    stepKeys.forEach((key, index) => {
      const step = stepsData[key];
      const card = document.createElement('div');
      card.className = 'step-card';
      
      let stepDesc = '';
      if (step.content) {
        stepDesc = step.content.map(p => {
          let processed = p.replace(/\n/g, '<br>');
          if (gender === 'erkek') {
            processed = processed.replace(/(Erkekler[^<.]*)/g, '<strong style="color:var(--primary-color);">$1</strong>');
          } else {
            processed = processed.replace(/(Kadınlar[^<.]*)/g, '<strong style="color:var(--accent-orange);">$1</strong>');
          }
          return `<p style="margin-bottom: 6px;">${processed}</p>`;
        }).join('');
      }

      card.innerHTML = `
        <div class="step-badge">${index + 1}</div>
        <div class="step-content">
          <div class="step-name">${step.ad}</div>
          <div class="step-desc">${step.aciklama}</div>
        </div>
      `;
      stepsContainer.appendChild(card);
    });
  };

  const savedGender = localStorage.getItem('user_gender') || 'erkek';

  erkekBtn.addEventListener('click', () => {
    erkekBtn.classList.add('active');
    kadinBtn.classList.remove('active');
    renderSteps('erkek');
  });

  kadinBtn.addEventListener('click', () => {
    kadinBtn.classList.add('active');
    erkekBtn.classList.remove('active');
    renderSteps('kadin');
  });

  if (savedGender === 'kadin') {
    kadinBtn.classList.add('active');
    erkekBtn.classList.remove('active');
    renderSteps('kadin');
  } else {
    erkekBtn.classList.add('active');
    kadinBtn.classList.remove('active');
    renderSteps('erkek');
  }
}

// 21. VITIR NAMAZI
function renderVitirNamazi(container) {
  container.innerHTML = `
    <div class="vitir-wrapper" style="max-height: 400px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px;">
      <div class="info-card ornamental">
        <h4 style="color: var(--primary-color); margin-bottom: 6px; font-weight:700;">Vitir Namazı Nedir?</h4>
        <p style="font-size:12px; line-height: 1.5; color: var(--text-primary);">${VITIR_NAMAZI.aciklama}</p>
      </div>

      <div class="info-card">
        <h4 style="color: var(--primary-color); margin-bottom: 8px; font-weight:700;">Kunut Duası - 1</h4>
        <div style="font-size: 20px; font-family: 'Traditional Arabic', serif; text-align: right; margin-bottom: 8px; font-weight: bold; direction: rtl;">${VITIR_NAMAZI.kunut1.arapca}</div>
        <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); margin-bottom: 6px;">${VITIR_NAMAZI.kunut1.okunus}</div>
        <div style="font-size: 12px; color: var(--text-secondary); line-height: 1.5;"><strong>Meali:</strong> ${VITIR_NAMAZI.kunut1.anlam}</div>
      </div>

      <div class="info-card">
        <h4 style="color: var(--primary-color); margin-bottom: 8px; font-weight:700;">Kunut Duası - 2</h4>
        <div style="font-size: 20px; font-family: 'Traditional Arabic', serif; text-align: right; margin-bottom: 8px; font-weight: bold; direction: rtl;">${VITIR_NAMAZI.kunut2.arapca}</div>
        <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); margin-bottom: 6px;">${VITIR_NAMAZI.kunut2.okunus}</div>
        <div style="font-size: 12px; color: var(--text-secondary); line-height: 1.5;"><strong>Meali:</strong> ${VITIR_NAMAZI.kunut2.anlam}</div>
      </div>
    </div>
  `;
}

// Real-time synchronization for daily prayers list when modified in Admin Panel
window.addEventListener('storage', (e) => {
  if (e.key === 'gunluk_dualar_list') {
    const modalGunluk = document.getElementById('modal-gunluk-dualar');
    if (modalGunluk) {
      const modalBody = modalGunluk.querySelector('#modal-body-content');
      if (modalBody) {
        renderGunlukDualar(modalBody);
      }
    }
  }
});

// Generic Addon Info Tool Accordion Renderer
function renderAddonTool(container, id) {
  const key = id.replace(/-/g, '_');
  const sections = ADDON_DATA[key];
  if (!sections || sections.length === 0) {
    container.innerHTML = `<div style="text-align:center; padding:20px; color:#888;">İçerik bulunamadı.</div>`;
    return;
  }

  let accordionHtml = `<div class="addon-accordion">`;
  sections.forEach((sec, idx) => {
    const badgeClass = `badge-${sec.badge.toLowerCase().replace(/ü/g, 'u').replace(/ö/g, 'o').replace(/ı/g, 'i').replace(/ş/g, 's').replace(/ğ/g, 'g').replace(/ç/g, 'c')}`;
    
    let contentHtml = '';
    if (sec.arabic) {
      contentHtml += `<div class="arabic-text">${sec.arabic}</div>`;
    }
    if (sec.latin) {
      contentHtml += `<div class="latin-text">${sec.latin}</div>`;
    }
    if (sec.meaning) {
      contentHtml += `<div class="meaning-text">${sec.meaning}</div>`;
    }
    if (sec.content && sec.content.length > 0) {
      contentHtml += `<ul class="bullet-list">`;
      sec.content.forEach(bullet => {
        contentHtml += `<li class="bullet-item">${bullet}</li>`;
      });
      contentHtml += `</ul>`;
    }

    accordionHtml += `
      <div class="accordion-item ${idx === 0 ? 'active' : ''}">
        <div class="accordion-header">
          <div class="accordion-title-container">
            <span class="accordion-title">${sec.title}</span>
            <span class="accordion-badge ${badgeClass}">${sec.badge}</span>
          </div>
          <span class="accordion-arrow">▼</span>
        </div>
        <div class="accordion-content">
          ${contentHtml}
        </div>
      </div>
    `;
  });
  accordionHtml += `</div>`;

  container.innerHTML = accordionHtml;

  // Add click handlers for accordion toggle
  const items = container.querySelectorAll('.accordion-item');
  items.forEach(item => {
    const header = item.querySelector('.accordion-header');
    header.addEventListener('click', () => {
      const isActive = item.classList.contains('active');
      items.forEach(i => i.classList.remove('active'));
      if (!isActive) {
        item.classList.add('active');
      }
    });
  });
}

// Special Tool: Cevsen Dualari
function renderCevsen(container) {
  const cevsenBabs = [
    {
      no: 1,
      title: "Bab 1 - İsimlerin Sırrı",
      arabic: "اَللّٰهُمَّ اِنّ۪ي اَسْئَلُكَ بِاَسْمَٓائكَ يَا اَللّٰهُ، يَا رَحْمٰنُ، يَا رَح۪يمُ، يَا كَر۪يمُ، يَا مُق۪يمُ، يَا عَظ۪يمُ، يَا قَد۪يمُ، يَا عَل۪يمُ، يَا حَل۪يمُ، يَا حَك۪يمُ",
      latin: "Allahümme innî es’elüke biesmâike: Yâ Allah, Yâ Rahmân, Yâ Rahîm, Yâ Kerîm, Yâ Mukîm, Yâ Azîm, Yâ Kadîm, Yâ Alîm, Yâ Halîm, Yâ Hakîm.",
      meaning: "Allah'ım! Senin isimlerin hürmetine Sana yalvarıyorum: Ey her şeyin gerçek mabudu olan Allah, Ey dünyada dost ve düşman ayırt etmeden bütün mahlukatını rızıklandıran Rahman, Ey ahirette yalnız dostlarına rahmet edecek olan Rahim, Ey lütuf ve keremi bol olan Kerim, Ey her şeyi ayakta tutan Mukim, Ey azamet ve büyüklüğü sonsuz olan Azim, Ey varlığının başlangıcı olmayan Kadim, Ey her şeyi hakkıyla bilen Alim, Ey cezalandırmada acele etmeyen Halim, Ey her işi hikmetle yapan Hakim."
    },
    {
      no: 2,
      title: "Bab 2 - Sığınma ve Kurtuluş",
      arabic: "يَا سَيِّدَ السَّادَاتِ، يَا مُجِيبَ الدَّعَوَاتِ، يَا رَافِيعَ الدَّرَجَاتِ، يَا وَلِيَّ الْحَسَنَاتِ، يَا غَافِرَ الْخَطِيئَاتِ، يَا مُعْطِيَ الْمَسْئَلاَتِ، يَا قَابِلَ التَّوْبَاتِ، يَا سَامِعَ الأَصْوَاتِ، يَا عَالِمَ الْخَفِيَّاتِ، يَا دَافِعَ الْبَلِيَّاتِ",
      latin: "Yâ seyyide's-sâdât, Yâ mucîbe'd-da'vât, Yâ râfia'd-deracât, Yâ veliyye'l-hasenât, Yâ gâfire'l-hatîât, Yâ mu'tiye'l-mes'elât, Yâ kâbile't-tevbât, Yâ sâmia'l-asvât, Yâ âlime'l-hafiyyât, Yâ dâfia'l-beliyyât.",
      meaning: "Ey efendilerin Efendisi, Ey dualara cevap veren, Ey dereceleri yükselten, Ey iyiliklerin sahibi, Ey hataları bağışlayan, Ey istekleri veren, Ey tövbeleri kabul eden, Ey sesleri işiten, Ey gizlilikleri bilen, Ey belaları defeden."
    },
    {
      no: 3,
      title: "Bab 3 - Hayırlı İsimler",
      arabic: "يَا خَيْرَ الْغَافِرِينَ، يَا خَيْرَ الْفَاتِحِينَ، يَا خَيْرَ النَّاصِرِينَ، يَا خَيْرَ الْحَاكِمِينَ، يَا خَيْرَ الرَّازِقِينَ، يَا خَيْرَ الْوَارِثِينَ، يَا خَيْرَ الْحَامِدِينَ، يَا خَيْرَ الذَّاكِرِينَ، يَا خَيْرَ الْمُنْZِيلِينَ، يَا خَيْرَ الْمُحْسِنِينَ",
      latin: "Yâ hayra'l-gâfirîn, Yâ hayra'l-fâtihîn, Yâ hayra'l-nâsirîn, Yâ hayra'l-hâkimîn, Yâ hayra'l-râzikîn, Yâ hayra'l-vârisîn, Yâ hayra'l-hâmidîn, Yâ hayra'l-zâkirîn, Yâ hayra'l-münzilîn, Yâ hayra'l-muhsinîn.",
      meaning: "Ey bağışlayanların en hayırlısı, Ey fethedenlerin en hayırlısı, Ey yardım edenlerin en hayırlısı, Ey hükmedenlerin en hayırlısı, Ey rızık verenlerin en hayırlısı, Ey varislerin en hayırlısı, Ey hamdedenlerin en hayırlısı, Ey zikredenlerin en hayırlısı, Ey indirenlerin en hayırlısı, Ey ihsan edenlerin en hayırlısı."
    },
    {
      no: 4,
      title: "Bab 4 - Yücelik ve Büyüklük",
      arabic: "يَا مَنْ لَهُ الْعِزَّةُ وَالْجَمَالُ، يَا مَنْ لَهُ الْقُدْرَةُ وَالْكَمَالُ، يَا مَنْ لَهُ الْمُلْكُ وَالْجَلاَلُ، يَا مَنْ هُوَ الْكَبِيرُ الْمُتَعَالِ، يَا مُنْشِئَ السَّحَابِ الثِّقَالِ، يَا مَنْ هُوَ شَدِيدُ الْمِحَالِ، يَا مَنْ هُوَ سَرِيعُ الْحِسَابِ... ",
      latin: "Yâ men lehü'l-izzetü ve'l-cemâl, Yâ men lehü'l-kudretü ve'l-kemâl, Yâ men lehü'l-mülkü ve'l-celâl...",
      meaning: "Ey izzet ve cemalin sahibi, Ey kudret ve kemalin sahibi, Ey mülk ve celalin sahibi..."
    },
    {
      no: 5,
      title: "Bab 5 - İhsan ve Lütuf",
      arabic: "اَللّٰهُمَّ اِنّ۪ي اَسْئَلُكَ بِاسْمِكَ يَا حَنَّانُ، يَا مَنَّانُ، يَا دَيَّANُ، يَا غُفْرَانُ، يَا بُرْهَانُ، يَا سُلْطَانُ، يَا سُبْحَانُ، يَا مُسْتَعَانُ",
      latin: "Allahümme innî es’elüke bismike: Yâ Hannân, Yâ Mennân, Yâ Deyyân, Yâ Gufrân, Yâ Bürhân, Yâ Sultân, Yâ Sübhân, Yâ Müsteân.",
      meaning: "Allah'ım! Senin ismin hürmetine Sana yalvarıyorum: Ey sonsuz merhamet sahibi Hannan, Ey hesapsız lütufta bulunan Mennan, Ey kullarının amellerini hak ettikleri şekilde karşılayan Deyyan..."
    }
  ];

  container.innerHTML = `
    <div class="cevsen-wrapper">
      <div class="tab-bar" style="margin-bottom: 12px; display:flex; justify-content:center; gap:8px;">
        <button class="tab-btn active" id="cevsen-read-tab" style="flex:1;">Cevşen Oku</button>
        <button class="tab-btn" id="cevsen-info-tab" style="flex:1;">Cevşen Bilgileri</button>
      </div>
      
      <div id="cevsen-read-content">
        <div class="form-group">
          <label>Bab Seçiniz:</label>
          <select id="cevsen-bab-select" class="form-control-styled" style="width:100%;">
            ${cevsenBabs.map(b => `<option value="${b.no}">${b.title}</option>`).join('')}
            <option value="6" disabled>Bab 6 - 100 (Yakında eklenecek)</option>
          </select>
        </div>
        
        <div class="info-card" id="cevsen-display" style="min-height: 220px;">
          <!-- Populated dynamically -->
        </div>
      </div>
      
      <div id="cevsen-info-content" style="display:none;">
        <!-- Populated dynamically from ADDON_DATA -->
      </div>
    </div>
  `;

  const readTabBtn = container.querySelector('#cevsen-read-tab');
  const infoTabBtn = container.querySelector('#cevsen-info-tab');
  const readContent = container.querySelector('#cevsen-read-content');
  const infoContent = container.querySelector('#cevsen-info-content');
  const babSelect = container.querySelector('#cevsen-bab-select');
  const displayBox = container.querySelector('#cevsen-display');

  const showBab = (babNo) => {
    const bab = cevsenBabs.find(b => b.no === parseInt(babNo));
    if (bab) {
      displayBox.innerHTML = `
        <h4 style="color:var(--primary-color); font-weight:700; margin-bottom:12px; border-bottom:1px solid #eee; padding-bottom:6px;">${bab.title}</h4>
        <div class="arabic-text" style="font-size:24px; text-align:right; direction:rtl; margin-bottom:12px; font-family:'Traditional Arabic', serif;">${bab.arabic}</div>
        <div class="latin-text" style="font-size:13px; font-weight:600; line-height:1.4; color:var(--text-primary); margin-bottom:10px; border-left:3px solid var(--accent-orange); padding-left:8px;">${bab.latin}</div>
        <div class="meaning-text" style="font-size:12px; color:var(--text-secondary); line-height:1.4; background:var(--bg-color); padding:8px; border-radius:8px;"><strong>Anlamı:</strong> ${bab.meaning}</div>
      `;
    }
  };

  readTabBtn.addEventListener('click', () => {
    readTabBtn.classList.add('active');
    infoTabBtn.classList.remove('active');
    readContent.style.display = 'block';
    infoContent.style.display = 'none';
  });

  infoTabBtn.addEventListener('click', () => {
    infoTabBtn.classList.add('active');
    readTabBtn.classList.remove('active');
    readContent.style.display = 'none';
    infoContent.style.display = 'block';
    renderAddonTool(infoContent, 'cevsen');
  });

  babSelect.addEventListener('change', (e) => showBab(e.target.value));
  showBab(1);
}

// Special Tool: Missed Prayers (Kaza) Tracker
function renderKazaTracker(container, showNotification) {
  let counts = JSON.parse(localStorage.getItem('kaza_counts') || '{}');
  const defaultKeys = ['sabah', 'ogle', 'ikindi', 'aksam', 'yatsi', 'vitir'];
  defaultKeys.forEach(k => {
    if (counts[k] === undefined) counts[k] = 0;
  });

  const names = {
    sabah: 'Sabah',
    ogle: 'Öğle',
    ikindi: 'İkindi',
    aksam: 'Akşam',
    yatsi: 'Yatsı',
    vitir: 'Vitir'
  };

  const updateTable = () => {
    container.innerHTML = `
      <div class="kaza-wrapper">
        <p style="font-size:11px; color:#718096; margin-bottom:12px; text-align:center;">Kazaya kalan namazlarınızı takip edin. Kaza namazı kıldıkça ilgili namazın sayısını azaltın.</p>
        
        <table class="kaza-table" style="width:100%; border-collapse:collapse; margin-bottom:15px;">
          <thead>
            <tr style="border-bottom: 2px solid var(--border-color); text-align: left;">
              <th style="padding: 8px; font-size:12px; font-weight:700; color:var(--text-secondary);">Namaz</th>
              <th style="padding: 8px; font-size:12px; font-weight:700; color:var(--text-secondary); text-align:center;">Kaza Sayısı</th>
              <th style="padding: 8px; font-size:12px; font-weight:700; color:var(--text-secondary); text-align:right;">İşlemler</th>
            </tr>
          </thead>
          <tbody>
            ${defaultKeys.map(k => `
              <tr style="border-bottom: 1px solid var(--border-color);">
                <td style="padding: 10px 8px; font-weight:700; font-size:13px; color:var(--text-primary);">${names[k]}</td>
                <td style="padding: 10px 8px; text-align:center;">
                  <input type="number" data-key="${k}" class="kaza-input" value="${counts[k]}" style="width: 60px; text-align:center; border: 1px solid var(--border-color); border-radius: 8px; padding: 4px; font-weight:700; font-size:13px; color:var(--primary-color);">
                </td>
                <td style="padding: 10px 8px; text-align:right;">
                  <button class="kaza-btn btn-minus" data-key="${k}" style="width: 28px; height: 28px; border-radius:50%; border:1px solid #ff4d4d; background:#ffebeb; color:#ff4d4d; font-weight:bold; cursor:pointer;">-</button>
                  <button class="kaza-btn btn-plus" data-key="${k}" style="width: 28px; height: 28px; border-radius:50%; border:1px solid var(--primary-color); background:var(--primary-light); color:var(--primary-color); font-weight:bold; cursor:pointer; margin-left:4px;">+</button>
                  <button class="kaza-btn btn-done" data-key="${k}" style="border: 1px solid var(--primary-color); background:var(--primary-color); color:#fff; border-radius:8px; padding:4px 8px; font-size:11px; font-weight:600; cursor:pointer; margin-left:6px;">Kıl</button>
                </td>
              </tr>
            `).join('')}
          </tbody>
        </table>
        
        <button class="btn btn-secondary ripple w-100" id="kaza-reset" style="width:100%; padding:10px; border-radius:12px;">Tümünü Sıfırla</button>
      </div>
    `;

    // Add listeners
    container.querySelectorAll('.kaza-input').forEach(input => {
      input.addEventListener('change', (e) => {
        const val = parseInt(e.target.value) || 0;
        const k = e.target.getAttribute('data-key');
        counts[k] = val >= 0 ? val : 0;
        e.target.value = counts[k];
        localStorage.setItem('kaza_counts', JSON.stringify(counts));
      });
    });

    container.querySelectorAll('.btn-minus').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const k = e.target.getAttribute('data-key');
        if (counts[k] > 0) {
          counts[k]--;
          localStorage.setItem('kaza_counts', JSON.stringify(counts));
          updateTable();
        }
      });
    });

    container.querySelectorAll('.btn-plus').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const k = e.target.getAttribute('data-key');
        counts[k]++;
        localStorage.setItem('kaza_counts', JSON.stringify(counts));
        updateTable();
      });
    });

    container.querySelectorAll('.btn-done').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const k = e.target.getAttribute('data-key');
        if (counts[k] > 0) {
          counts[k]--;
          localStorage.setItem('kaza_counts', JSON.stringify(counts));
          showNotification('Rabbim Kabul Etsin!', `1 vakit kaza ${names[k]} namazını kıldınız. Kalan kaza: ${counts[k]}`, 'default');
          updateTable();
        } else {
          showNotification('Kaza Namazınız Yok', `${names[k]} namazı için kaza borcunuz bulunmamaktadır.`, 'info');
        }
      });
    });

    container.querySelector('#kaza-reset').addEventListener('click', () => {
      if (confirm('Tüm kaza çetelenizi sıfırlamak istediğinize emin misiniz?')) {
        defaultKeys.forEach(k => counts[k] = 0);
        localStorage.setItem('kaza_counts', JSON.stringify(counts));
        updateTable();
      }
    });
  };

  updateTable();
}

// Special Tool: Morning/Evening Dhikrs
function renderSabahAksamEzkar(container, showNotification) {
  const sabahEzkarList = [
    {
      id: 'sabah-1',
      title: "Allahümme bike asbahnâ",
      arabic: "اَللّٰهُمَّ بِكَ اَصْبَحْنَا وَبِكَ اَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَاِلَيْكَ النُّشُورُ",
      latin: "Allâhumme bike asbahnâ ve bike emseynâ ve bike nehyâ ve bike nemûtu ve ileyke'n-nuşûr.",
      meaning: "Allah'ım! Senin yardımınla sabaha erdik, Senin yardımınla akşama kavuştuk. Seninle yaşar, Seninle ölürüz. Dönüş de ancak Sanadır.",
      target: 1
    },
    {
      id: 'sabah-2',
      title: "Bismillahillezi la yedurru",
      arabic: "بِسْمِ اللّٰهِ الَّذ۪ي لَا يَضُرُّ مَعَ اسْمِه۪ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّمَٓاءِ وَهُوَ السَّم۪يعُ الْعَل۪يمُ",
      latin: "Bismillâhillezî lâ yedurru me’asmihî şey’ün fil-ardı velâ fis-semâi ve hüves-semî’ul-alîm.",
      meaning: "O Allah’ın adıyla ki, O’nun adı sayesinde yeryüzünde ve gökyüzünde hiçbir şey zarar veremez. O, her şeyi işiten ve bilendir.",
      target: 3
    },
    {
      id: 'sabah-3',
      title: "Âyetel Kürsi",
      arabic: "اَللّٰهُ لَٓا اِلٰهَ اِلَّا هُوَۚ اَلْحَيُّ الْقَيُّومُۚ...",
      latin: "Allâhü lâ ilâhe illâ hüvel hayyül kayyûm...",
      meaning: "Allah, O'ndan başka ilah yoktur. Hayy'dır, Kayyum'dur...",
      target: 1
    },
    {
      id: 'sabah-4',
      title: "Sübhanallahi ve bihamdihi",
      arabic: "سُبْحَانَ اللّٰهِ وَبِحَمْدِه۪",
      latin: "Sübhânallâhi ve bi-hamdihî.",
      meaning: "Allah'ı noksan sıfatlardan tenzih eder, O'na hamd ederim. (Günde 100 defa okuyanın günahları deniz köpüğü kadar da olsa bağışlanır)",
      target: 100
    },
    {
      id: 'sabah-5',
      title: "Lâ ilâhe illallâhü vahdehû",
      arabic: "لَا اِلٰهَ اِلَّا اللّٰهُ وَحْدَهُ لَا شَر۪يكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَد۪يرٌ",
      latin: "Lâ ilâhe illallâhü vahdehû lâ şerîke leh, lehül mülkü ve lehül hamdü ve hüve alâ külli şey’in kadîr.",
      meaning: "Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'nundur. O, her şeye kadirdir.",
      target: 10
    },
    {
      id: 'sabah-6',
      title: "Seyyidü'l İstiğfar",
      arabic: "اَللّٰهُمَّ اَنْتَ رَبّ۪ي لَٓا اِلٰهَ اِلَّٓا اَنْتَۚ خَلَقْتَن۪ي وَاَنَا عَبْدُكَۚ وَاَنَا عَلٰى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُۚ",
      latin: "Allâhumme ente Rabbî lâ ilâhe illâ ente halaktenî ve ene abdüke ve ene alâ ahdike ve va'dike mesteta'tü.",
      meaning: "Allah'ım! Sen benim Rabbimsin. Senden başka ilah yoktur. Beni Sen yarattın, ben Senin kulunum. Gücüm yettiğince ahdine ve vadine bağlıyım...",
      target: 1
    }
  ];

  const aksamEzkarList = [
    {
      id: 'aksam-1',
      title: "Allahümme bike emseynâ",
      arabic: "اَللّٰهُمَّ بِكَ اَمْسَيْنَا وَبِكَ اَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَاِلَيْكَ الْمَص۪يرُ",
      latin: "Allâhumme bike emseynâ ve bike asbahnâ ve bike nehyâ ve bike nemûtu ve ileyke'l-masîr.",
      meaning: "Allah'ım! Senin yardımınla akşama erdik, Senin yardımınla sabaha kavuştuk. Seninle yaşar, Seninle ölürüz. Dönüş de Sanadır.",
      target: 1
    },
    {
      id: 'aksam-2',
      title: "Bismillahillezi la yedurru",
      arabic: "بِسْمِ اللّٰهِ الَّذ۪ي لَا يَضُرُّ مَعَ اسْمِه۪ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّMَٓاءِ وَهُوَ السَّم۪يعُ الْعَل۪يمُ",
      latin: "Bismillâhillezî lâ yedurru me’asmihî şey’ün fil-ardı velâ fis-semâi...",
      meaning: "O Allah’ın adıyla ki, O’nun adı sayesinde yeryüzünde ve gökyüzünde hiçbir şey zarar veremez...",
      target: 3
    },
    {
      id: 'aksam-3',
      title: "Eûzü bi-kelimâtillâhi't-tâmmâti",
      arabic: "اَعُوذُ بِكَلِمَاتِ اللّٰهِ التَّٓامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
      latin: "Eûzü bi-kelimâtillâhi't-tâmmâti min şerri mâ halak.",
      meaning: "Yarattıklarının şerrinden Allah'ın mükemmel kelimelerine sığınırım. (Akşam 3 kere okuyana o gece hiçbir zehirli hayvan zarar vermez)",
      target: 3
    },
    {
      id: 'aksam-4',
      title: "Âyetel Kürsi",
      arabic: "اَللّٰهُ لَٓا اِلٰهَ اِلَّا هُوَۚ اَلْحَيُّ الْقَيُّومُۚ...",
      latin: "Allâhü lâ ilâhe illâ hüvel hayyül kayyûm...",
      meaning: "Allah, O'ndan başka ilah yoktur. Hayy'dır, Kayyum'dur...",
      target: 1
    },
    {
      id: 'aksam-5',
      title: "Sübhanallahi ve bihamdihi",
      arabic: "سُبْحَانَ اللّٰهِ وَبِحَمْدِه۪",
      latin: "Sübhânallâhi ve bi-hamdihî.",
      meaning: "Allah'ı noksan sıfatlardan tenzih eder, O'na hamd ederim. (Günde 100 defa)",
      target: 100
    },
    {
      id: 'aksam-6',
      title: "Seyyidü'l İstiğfar",
      arabic: "اَللّٰهُمَّ اَنْتَ رَبّ۪ي لَٓا اِلٰهَ اِلَّٓا اَنْتَۚ خَلَقْتَن۪ي وَاَنَا عَبْدُكَۚ...",
      latin: "Allâhumme ente Rabbî lâ ilâhe illâ ente halaktenî...",
      meaning: "Allah'ım! Sen benim Rabbimsin. Senden başka ilah yoktur...",
      target: 1
    }
  ];

  let ezkarCounts = JSON.parse(localStorage.getItem('ezkar_counts') || '{}');

  container.innerHTML = `
    <div class="ezkar-wrapper">
      <div class="tab-bar" style="margin-bottom: 12px; display:flex; justify-content:center; gap:8px;">
        <button class="tab-btn active" id="ezkar-sabah-tab" style="flex:1;">Sabah Ezkarı</button>
        <button class="tab-btn" id="ezkar-aksam-tab" style="flex:1;">Akşam Ezkarı</button>
        <button class="tab-btn" id="ezkar-info-tab" style="flex:1;">Ezkar Bilgileri</button>
      </div>
      
      <div id="ezkar-list-container" style="max-height: 380px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; padding: 5px;">
        <!-- Dynamically rendered -->
      </div>
    </div>
  `;

  const sabahTabBtn = container.querySelector('#ezkar-sabah-tab');
  const aksamTabBtn = container.querySelector('#ezkar-aksam-tab');
  const infoTabBtn = container.querySelector('#ezkar-info-tab');
  const listContainer = container.querySelector('#ezkar-list-container');

  let currentTab = 'sabah';

  const renderCurrentTab = () => {
    listContainer.innerHTML = '';
    
    if (currentTab === 'info') {
      renderAddonTool(listContainer, 'ezkar');
      return;
    }

    const items = currentTab === 'sabah' ? sabahEzkarList : aksamEzkarList;

    items.forEach(item => {
      const countKey = item.id;
      let count = ezkarCounts[countKey] || 0;
      const isCompleted = count >= item.target;

      const card = document.createElement('div');
      card.className = `info-card ${isCompleted ? 'completed-dhikr' : ''}`;
      card.style.cssText = `margin-bottom: 8px; border-left: 4px solid ${isCompleted ? '#27a770' : '#ffa200'}; transition: all 0.3s ease;`;
      
      card.innerHTML = `
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
          <h4 style="color:var(--primary-color); font-weight:700; margin:0; font-size:13px;">${item.title}</h4>
          <span style="font-size:10px; font-weight:700; background:${isCompleted ? '#eaf7f1' : '#fef9e7'}; color:${isCompleted ? '#27a770' : '#ffa200'}; padding:2px 8px; border-radius:10px;">
            ${isCompleted ? '✓ Tamamlandı' : `Hedef: ${item.target}`}
          </span>
        </div>
        <div class="arabic-text" style="font-size:20px; font-family:'Traditional Arabic', serif; text-align:right; direction:rtl; margin-bottom:8px;">${item.arabic}</div>
        <div style="font-size:11px; font-weight:600; color:var(--text-primary); margin-bottom:6px;">${item.latin}</div>
        <div style="font-size:10px; color:var(--text-secondary); line-height:1.4; margin-bottom:10px;">${item.meaning}</div>
        
        <div style="display:flex; justify-content:space-between; align-items:center; border-top:1px solid #eee; padding-top:8px;">
          <span style="font-size:12px; font-weight:700; color:var(--text-secondary);">Sayaç: <strong style="color:var(--primary-color); font-size:14px;" id="count-${item.id}">${count}</strong> / ${item.target}</span>
          <div style="display:flex; gap:6px;">
            <button class="btn-minus" data-id="${item.id}" style="width:28px; height:28px; border-radius:50%; border:1px solid #ff4d4d; background:#ffebeb; color:#ff4d4d; font-weight:bold; cursor:pointer;">-</button>
            <button class="btn-reset" data-id="${item.id}" style="width:28px; height:28px; border-radius:50%; border:1px solid #718096; background:#f7fafc; color:#718096; font-size:11px; cursor:pointer;">↺</button>
            <button class="btn-plus" data-id="${item.id}" style="border:1px solid var(--primary-color); background:var(--primary-color); color:#fff; border-radius:8px; padding:4px 12px; font-size:12px; font-weight:600; cursor:pointer;">Oku</button>
          </div>
        </div>
      `;

      const countEl = card.querySelector(`#count-${item.id}`);
      
      card.querySelector('.btn-plus').addEventListener('click', () => {
        let c = ezkarCounts[countKey] || 0;
        if (c < item.target) {
          c++;
          ezkarCounts[countKey] = c;
          localStorage.setItem('ezkar_counts', JSON.stringify(ezkarCounts));
          countEl.textContent = c;
          if (c >= item.target) {
            showNotification('Maşallah!', `${item.title} zikrini tamamladınız.`, 'default');
            renderCurrentTab();
          }
        }
      });

      card.querySelector('.btn-minus').addEventListener('click', () => {
        let c = ezkarCounts[countKey] || 0;
        if (c > 0) {
          c--;
          ezkarCounts[countKey] = c;
          localStorage.setItem('ezkar_counts', JSON.stringify(ezkarCounts));
          countEl.textContent = c;
          renderCurrentTab();
        }
      });

      card.querySelector('.btn-reset').addEventListener('click', () => {
        ezkarCounts[countKey] = 0;
        localStorage.setItem('ezkar_counts', JSON.stringify(ezkarCounts));
        countEl.textContent = 0;
        renderCurrentTab();
      });

      listContainer.appendChild(card);
    });
  };

  sabahTabBtn.addEventListener('click', () => {
    currentTab = 'sabah';
    sabahTabBtn.classList.add('active');
    aksamTabBtn.classList.remove('active');
    infoTabBtn.classList.remove('active');
    renderCurrentTab();
  });

  aksamTabBtn.addEventListener('click', () => {
    currentTab = 'aksam';
    aksamTabBtn.classList.add('active');
    sabahTabBtn.classList.remove('active');
    infoTabBtn.classList.remove('active');
    renderCurrentTab();
  });

  infoTabBtn.addEventListener('click', () => {
    currentTab = 'info';
    infoTabBtn.classList.add('active');
    sabahTabBtn.classList.remove('active');
    aksamTabBtn.classList.remove('active');
    renderCurrentTab();
  });

  renderCurrentTab();
}

// Special Tool: Kelime-i Tevhid
function renderKelimeiTevhid(container, showNotification) {
  let count = parseInt(localStorage.getItem('tevhid_count') || '0');
  let target = parseInt(localStorage.getItem('tevhid_target') || '100');

  container.innerHTML = `
    <div class="zikirmatik-wrapper">
      <div class="info-card ornamental" style="width:100%; text-align:center; margin-bottom:15px; padding:15px;">
        <h4 style="color:var(--primary-color); font-weight:700; margin-bottom:8px;">Kelime-i Tevhid</h4>
        <div class="arabic-text" style="font-size:26px; text-align:center; font-family:'Traditional Arabic', serif; margin-bottom:6px;">لَا اِلٰهَ اِلَّا اللّٰهُ</div>
        <div class="latin-text" style="font-size:14px; font-weight:700; color:var(--text-primary); text-align:center; border:none; padding:0;">Lâ ilâhe illallâh</div>
        <div class="meaning-text" style="font-size:11px; color:var(--text-secondary); text-align:center; margin:0;">Allah'tan başka ilah yoktur.</div>
      </div>
      
      <div class="zikir-target-container">
        <label>Hedef:</label>
        <select id="tevhid-target-select" class="form-control-styled">
          <option value="33" ${target === 33 ? 'selected' : ''}>33</option>
          <option value="99" ${target === 99 ? 'selected' : ''}>99</option>
          <option value="100" ${target === 100 ? 'selected' : ''}>100</option>
          <option value="1000" ${target === 1000 ? 'selected' : ''}>1000</option>
          <option value="9999" ${target === 9999 ? 'selected' : ''}>Sınırsız</option>
        </select>
      </div>
      <div class="zikir-circle-button" id="tevhid-btn">
        <div class="zikir-progress-ring"></div>
        <div class="zikir-counter-val" id="tevhid-count-display">${count}</div>
        <div class="zikir-target-val">Hedef: ${target === 9999 ? '∞' : target}</div>
      </div>
      <div class="zikir-actions">
        <button class="btn btn-secondary ripple" id="tevhid-reset">Sıfırla</button>
        <button class="btn btn-primary ripple" id="tevhid-sound-toggle">Ses: Açık</button>
      </div>
    </div>
  `;

  const btn = container.querySelector('#tevhid-btn');
  const countDisplay = container.querySelector('#tevhid-count-display');
  const resetBtn = container.querySelector('#tevhid-reset');
  const soundToggle = container.querySelector('#tevhid-sound-toggle');
  const targetSelect = container.querySelector('#tevhid-target-select');

  let soundEnabled = true;

  const playClickSound = () => {
    if (!soundEnabled) return;
    try {
      const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const oscillator = audioCtx.createOscillator();
      const gainNode = audioCtx.createGain();
      oscillator.connect(gainNode);
      gainNode.connect(audioCtx.destination);
      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(600, audioCtx.currentTime);
      gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.1);
      oscillator.start();
      oscillator.stop(audioCtx.currentTime + 0.1);
    } catch (e) {
      console.log('Audio error: ', e);
    }
  };

  btn.addEventListener('click', () => {
    count++;
    localStorage.setItem('tevhid_count', count);
    countDisplay.textContent = count;
    playClickSound();

    if (navigator.vibrate) navigator.vibrate(30);

    if (count >= target && target !== 9999) {
      if (navigator.vibrate) navigator.vibrate([100, 50, 100]);
      showNotification('Tebrikler!', 'Hedeflenen Kelime-i Tevhid zikrini tamamladınız!', 'default');
      count = 0;
      localStorage.setItem('tevhid_count', count);
      setTimeout(() => { countDisplay.textContent = count; }, 500);
    }
  });

  resetBtn.addEventListener('click', () => {
    if (confirm('Kelime-i Tevhid sayacını sıfırlamak istediğinize emin misiniz?')) {
      count = 0;
      localStorage.setItem('tevhid_count', count);
      countDisplay.textContent = count;
    }
  });

  soundToggle.addEventListener('click', () => {
    soundEnabled = !soundEnabled;
    soundToggle.textContent = `Ses: ${soundEnabled ? 'Açık' : 'Kapalı'}`;
    soundToggle.className = soundEnabled ? 'btn btn-primary ripple' : 'btn btn-secondary ripple';
  });

  targetSelect.addEventListener('change', (e) => {
    target = parseInt(e.target.value);
    localStorage.setItem('tevhid_target', target);
    container.querySelector('.zikir-target-val').textContent = `Hedef: ${target === 9999 ? '∞' : target}`;
  });
}

// Special Tool: Salat-i Tefriciye (4444)
function renderSalatiTefriciye(container, showNotification) {
  let count = parseInt(localStorage.getItem('tefriciye_count') || '0');
  let target = parseInt(localStorage.getItem('tefriciye_target') || '4444');

  container.innerHTML = `
    <div class="zikirmatik-wrapper" style="padding-top:10px;">
      <div class="info-card ornamental" style="width:100%; text-align:center; margin-bottom:12px; padding:12px; max-height:220px; overflow-y:auto;">
        <h4 style="color:var(--primary-color); font-weight:700; margin-bottom:6px; font-size:14px;">Salat-ı Tefriciye</h4>
        <div class="arabic-text" style="font-size:18px; text-align:center; font-family:'Traditional Arabic', serif; margin-bottom:6px; line-height:1.4;">اَللّٰهُمَّ سَلِّ سَلَاماً تٓامّاً وَسَلِّمْ سَلَاماً سَامّاً عَلٰى سَيِّدِنَا مُحَمَّDِنيِ الَّذِي تَنْحَلُّ بِهِ الْعُقَدُ...</div>
        <div class="latin-text" style="font-size:11px; font-weight:600; color:var(--text-primary); text-align:left; border:none; padding:0; line-height:1.3;">Allahümme salli salâten kâmileten ve sellim selâmen tâmmen alâ Seyyidinâ Muhammedinillezî tenhallü bihi'l-ukadü...</div>
        <div class="meaning-text" style="font-size:10px; color:var(--text-secondary); text-align:left; margin-top:6px; line-height:1.3; background:none; padding:0;"><strong>Anlamı:</strong> Allah'ım! Efendimiz Muhammed'e kâmil bir salât ile salât et, mükemmel bir selâm ile selâm et ki, onun hürmetine düğümler çözülsün...</div>
      </div>
      
      <div class="zikir-target-container">
        <label>Hedef:</label>
        <select id="tefriciye-target-select" class="form-control-styled">
          <option value="4444" ${target === 4444 ? 'selected' : ''}>4444</option>
          <option value="100" ${target === 100 ? 'selected' : ''}>100</option>
          <option value="9999" ${target === 9999 ? 'selected' : ''}>Sınırsız</option>
        </select>
      </div>
      <div class="zikir-circle-button" id="tefriciye-btn" style="width:130px; height:130px;">
        <div class="zikir-progress-ring"></div>
        <div class="zikir-counter-val" id="tefriciye-count-display" style="font-size:32px;">${count}</div>
        <div class="zikir-target-val">Hedef: ${target === 9999 ? '∞' : target}</div>
      </div>
      
      <div class="progress-container" style="width:80%; height:8px; margin: 10px auto;">
        <div class="progress-bar" id="tefriciye-progress" style="width: ${(count/target)*100}%;"></div>
      </div>
      
      <div class="zikir-actions" style="margin-top:10px;">
        <button class="btn btn-secondary ripple" id="tefriciye-reset">Sıfırla</button>
        <button class="btn btn-primary ripple" id="tefriciye-sound-toggle">Ses: Açık</button>
      </div>
    </div>
  `;

  const btn = container.querySelector('#tefriciye-btn');
  const countDisplay = container.querySelector('#tefriciye-count-display');
  const resetBtn = container.querySelector('#tefriciye-reset');
  const soundToggle = container.querySelector('#tefriciye-sound-toggle');
  const targetSelect = container.querySelector('#tefriciye-target-select');
  const progressBar = container.querySelector('#tefriciye-progress');

  let soundEnabled = true;

  const playClickSound = () => {
    if (!soundEnabled) return;
    try {
      const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const oscillator = audioCtx.createOscillator();
      const gainNode = audioCtx.createGain();
      oscillator.connect(gainNode);
      gainNode.connect(audioCtx.destination);
      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(600, audioCtx.currentTime);
      gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.1);
      oscillator.start();
      oscillator.stop(audioCtx.currentTime + 0.1);
    } catch (e) {
      console.log('Audio error: ', e);
    }
  };

  btn.addEventListener('click', () => {
    count++;
    localStorage.setItem('tefriciye_count', count);
    countDisplay.textContent = count;
    progressBar.style.width = `${Math.min(100, (count / target) * 100)}%`;
    playClickSound();

    if (navigator.vibrate) navigator.vibrate(30);

    if (count >= target && target !== 9999) {
      if (navigator.vibrate) navigator.vibrate([100, 50, 100]);
      showNotification('Tebrikler!', 'Hedeflenen Salat-ı Tefriciye zikrini (4444) tamamladınız!', 'default');
      count = 0;
      localStorage.setItem('tefriciye_count', count);
      setTimeout(() => { 
        countDisplay.textContent = count; 
        progressBar.style.width = '0%';
      }, 500);
    }
  });

  resetBtn.addEventListener('click', () => {
    if (confirm('Salat-ı Tefriciye sayacını sıfırlamak istediğinize emin misiniz?')) {
      count = 0;
      localStorage.setItem('tefriciye_count', count);
      countDisplay.textContent = count;
      progressBar.style.width = '0%';
    }
  });

  soundToggle.addEventListener('click', () => {
    soundEnabled = !soundEnabled;
    soundToggle.textContent = `Ses: ${soundEnabled ? 'Açık' : 'Kapalı'}`;
    soundToggle.className = soundEnabled ? 'btn btn-primary ripple' : 'btn btn-secondary ripple';
  });

  targetSelect.addEventListener('change', (e) => {
    target = parseInt(e.target.value);
    localStorage.setItem('tefriciye_target', target);
    container.querySelector('.zikir-target-val').textContent = `Hedef: ${target === 9999 ? '∞' : target}`;
    progressBar.style.width = `${Math.min(100, (count / target) * 100)}%`;
  });
}

// Special Tool: Salat-i Ummiye
function renderSalatiUmmiye(container, showNotification) {
  let count = parseInt(localStorage.getItem('ummiye_count') || '0');
  let target = parseInt(localStorage.getItem('ummiye_target') || '100');

  container.innerHTML = `
    <div class="zikirmatik-wrapper">
      <div class="info-card ornamental" style="width:100%; text-align:center; margin-bottom:15px; padding:15px;">
        <h4 style="color:var(--primary-color); font-weight:700; margin-bottom:8px;">Salat-ı Ümmiye</h4>
        <div class="arabic-text" style="font-size:22px; text-align:center; font-family:'Traditional Arabic', serif; margin-bottom:6px; line-height:1.4;">اَللّٰهُمَّ صَلِّ عَلٰى سَيِّدِنَا مُحَمَّدِنِ النَّبِيِّ الْاُمِّيِّ وَعَلٰى اٰلِه۪ وَصَحْبِه۪ وَسَلِّمْ</div>
        <div class="latin-text" style="font-size:13px; font-weight:700; color:var(--text-primary); text-align:center; border:none; padding:0; line-height:1.4;">Allahümme salli alâ seyyidinâ Muhammedinin-nebiyyil-ummiyyi ve alâ âlihî ve sahbihî ve sellim</div>
        <div class="meaning-text" style="font-size:11px; color:var(--text-secondary); text-align:center; margin:0;">Allah'ım! Efendimiz ümmi peygamber Muhammed'e, onun aline ve ashabına salat ve selam eyle.</div>
      </div>
      
      <div class="zikir-target-container">
        <label>Hedef:</label>
        <select id="ummiye-target-select" class="form-control-styled">
          <option value="33" ${target === 33 ? 'selected' : ''}>33</option>
          <option value="99" ${target === 99 ? 'selected' : ''}>99</option>
          <option value="100" ${target === 100 ? 'selected' : ''}>100</option>
          <option value="9999" ${target === 9999 ? 'selected' : ''}>Sınırsız</option>
        </select>
      </div>
      <div class="zikir-circle-button" id="ummiye-btn">
        <div class="zikir-progress-ring"></div>
        <div class="zikir-counter-val" id="ummiye-count-display">${count}</div>
        <div class="zikir-target-val">Hedef: ${target === 9999 ? '∞' : target}</div>
      </div>
      <div class="zikir-actions">
        <button class="btn btn-secondary ripple" id="ummiye-reset">Sıfırla</button>
        <button class="btn btn-primary ripple" id="ummiye-sound-toggle">Ses: Açık</button>
      </div>
    </div>
  `;

  const btn = container.querySelector('#ummiye-btn');
  const countDisplay = container.querySelector('#ummiye-count-display');
  const resetBtn = container.querySelector('#ummiye-reset');
  const soundToggle = container.querySelector('#ummiye-sound-toggle');
  const targetSelect = container.querySelector('#ummiye-target-select');

  let soundEnabled = true;

  const playClickSound = () => {
    if (!soundEnabled) return;
    try {
      const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const oscillator = audioCtx.createOscillator();
      const gainNode = audioCtx.createGain();
      oscillator.connect(gainNode);
      gainNode.connect(audioCtx.destination);
      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(600, audioCtx.currentTime);
      gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.1);
      oscillator.start();
      oscillator.stop(audioCtx.currentTime + 0.1);
    } catch (e) {
      console.log('Audio error: ', e);
    }
  };

  btn.addEventListener('click', () => {
    count++;
    localStorage.setItem('ummiye_count', count);
    countDisplay.textContent = count;
    playClickSound();

    if (navigator.vibrate) navigator.vibrate(30);

    if (count >= target && target !== 9999) {
      if (navigator.vibrate) navigator.vibrate([100, 50, 100]);
      showNotification('Tebrikler!', 'Hedeflenen Salat-ı Ümmiye zikrini tamamladınız!', 'default');
      count = 0;
      localStorage.setItem('ummiye_count', count);
      setTimeout(() => { countDisplay.textContent = count; }, 500);
    }
  });

  resetBtn.addEventListener('click', () => {
    if (confirm('Salat-ı Ümmiye sayacını sıfırlamak istediğinize emin misiniz?')) {
      count = 0;
      localStorage.setItem('ummiye_count', count);
      countDisplay.textContent = count;
    }
  });

  soundToggle.addEventListener('click', () => {
    soundEnabled = !soundEnabled;
    soundToggle.textContent = `Ses: ${soundEnabled ? 'Açık' : 'Kapalı'}`;
    soundToggle.className = soundEnabled ? 'btn btn-primary ripple' : 'btn btn-secondary ripple';
  });

  targetSelect.addEventListener('change', (e) => {
    target = parseInt(e.target.value);
    localStorage.setItem('ummiye_target', target);
    container.querySelector('.zikir-target-val').textContent = `Hedef: ${target === 9999 ? '∞' : target}`;
  });
}


