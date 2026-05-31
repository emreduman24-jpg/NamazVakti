// İslami Rehber - Yönetim Paneli Mantığı

document.addEventListener('DOMContentLoaded', () => {
  // Elementleri Başlat
  initElements();

  // Session kontrolü
  checkSession();

  // Olay Dinleyicileri (Event Listeners)
  bindEvents();
});

// Küresel Durum (State)
let currentTab = 'dashboard';
let editingDuaId = null;
let editingStoryId = null;
let selectedQuestionId = null;
let chatInterval = null;
let dashboardInterval = null;

// DOM Element Referansları
let els = {};

function initElements() {
  els = {
    // Giriş
    loginContainer: document.getElementById('login-container'),
    adminContainer: document.getElementById('admin-container'),
    loginForm: document.getElementById('login-form'),
    usernameInput: document.getElementById('username'),
    passwordInput: document.getElementById('password'),
    loginError: document.getElementById('login-error-msg'),
    btnLogout: document.getElementById('btn-logout'),

    // Sayfa ve Sekmeler
    pageTitle: document.getElementById('page-title'),
    menuItems: document.querySelectorAll('.menu-item'),
    tabPanes: document.querySelectorAll('.tab-pane'),

    // Dashboard İstatistikleri
    statTotalUsers: document.getElementById('stat-total-users'),
    statTotalPrayers: document.getElementById('stat-total-prayers'),
    statPendingPrayers: document.getElementById('stat-pending-prayers'),
    statApprovedPrayers: document.getElementById('stat-approved-prayers'),
    recentPrayersTable: document.getElementById('dashboard-recent-prayers'),
    pendingPrayersQuickList: document.getElementById('dashboard-pending-prayers-list'),

    // Dua İstekleri
    summaryTotalPrayers: document.getElementById('summary-total-prayers'),
    summaryPendingPrayers: document.getElementById('summary-pending-prayers'),
    summaryApprovedPrayers: document.getElementById('summary-approved-prayers'),
    duaTableBody: document.getElementById('dua-istekleri-table-body'),
    filterBtns: document.querySelectorAll('.btn-filter'),
    searchDuaInput: document.getElementById('search-dua'),
    btnSearchDua: document.getElementById('btn-search-dua'),
    sidebarPendingPrayersBadge: document.getElementById('sidebar-pending-prayers-count'),

    // Günlük Dualar
    dailyDuaForm: document.getElementById('daily-dua-form'),
    dailyDuaFormTitle: document.getElementById('daily-dua-form-title'),
    dailyDuaId: document.getElementById('daily-dua-id'),
    dailyDuaTitle: document.getElementById('daily-dua-title'),
    dailyDuaText: document.getElementById('daily-dua-text'),
    dailyDuaBenefit: document.getElementById('daily-dua-benefit'),
    dailyDuaCategory: document.getElementById('daily-dua-category'),
    dailyDuaOrder: document.getElementById('daily-dua-order'),
    btnCancelDailyDua: document.getElementById('btn-cancel-daily-dua'),
    btnSaveDailyDua: document.getElementById('btn-save-daily-dua'),
    dailyDuasCount: document.getElementById('daily-duas-count'),
    dailyDuasList: document.getElementById('daily-duas-list'),

    // Hikayeler
    storyForm: document.getElementById('story-form'),
    storyFormTitle: document.getElementById('story-form-title'),
    storyId: document.getElementById('story-id'),
    storyTitle: document.getElementById('story-title'),
    storyImageFile: document.getElementById('story-image-file'),
    storyImageInfo: document.getElementById('story-image-info'),
    storyImageData: document.getElementById('story-image-data'),
    storyImagePreviewContainer: document.getElementById('story-image-preview-container'),
    storyImagePreview: document.getElementById('story-image-preview'),
    btnRemoveStoryImg: document.getElementById('btn-remove-story-img'),
    storyType: document.getElementById('story-type'),
    storyContent: document.getElementById('story-content'),
    storyOrder: document.getElementById('story-order'),
    btnCancelStory: document.getElementById('btn-cancel-story'),
    btnSaveStory: document.getElementById('btn-save-story'),
    storiesCount: document.getElementById('stories-count'),
    storiesList: document.getElementById('stories-list'),

    // Soru Cevap
    sidebarPendingQuestionsBadge: document.getElementById('sidebar-pending-questions-count'),
    qaQuestionsCount: document.getElementById('qa-questions-count'),
    qaQuestionsList: document.getElementById('qa-questions-list'),
    qaDetailEmpty: document.getElementById('qa-detail-empty'),
    qaDetailContainer: document.getElementById('qa-detail-container'),
    qaDetailAuthor: document.getElementById('qa-detail-author'),
    qaDetailDate: document.getElementById('qa-detail-date'),
    qaDetailText: document.getElementById('qa-detail-text'),
    qaReplyText: document.getElementById('qa-reply-text'),
    btnDeleteQuestion: document.getElementById('btn-delete-question'),
    btnSendAnswer: document.getElementById('btn-send-answer'),

    // Canlı Sohbet
    adminChatMessages: document.getElementById('admin-chat-messages'),
    adminChatInput: document.getElementById('admin-chat-input'),
    btnAdminChatSend: document.getElementById('btn-admin-chat-send'),

    // Kullanıcı Yönetimi
    chkGlobalUserBlock: document.getElementById('chk-global-user-block'),
    usersCount: document.getElementById('users-count'),
    usersTableBody: document.getElementById('users-table-body'),

    // Araçlar Yönetimi
    toolForm: document.getElementById('tool-form'),
    toolFormTitle: document.getElementById('tool-form-title'),
    toolFormId: document.getElementById('tool-form-id'),
    toolIdInput: document.getElementById('tool-id'),
    toolTitleInput: document.getElementById('tool-title-input'),
    toolDescInput: document.getElementById('tool-desc'),
    toolIconInput: document.getElementById('tool-icon'),
    toolColorInput: document.getElementById('tool-color'),
    toolOrderInput: document.getElementById('tool-order'),
    btnCancelTool: document.getElementById('btn-cancel-tool'),
    btnSaveTool: document.getElementById('btn-save-tool'),
    toolsCount: document.getElementById('tools-count'),
    toolsList: document.getElementById('tools-list')
  };
}

// ==================== API ASYNC HELPER FUNCTIONS ====================
async function apiFetch(endpoint, defaultValue = []) {
  try {
    const res = await fetch(endpoint);
    if (res.ok) {
      const data = await res.json();
      const keyMap = {
        '/api/duas': 'dua_iste_list',
        '/api/questions': 'soru_cevap_list',
        '/api/stories': 'stories_list',
        '/api/chat': 'live_chat_list',
        '/api/users': 'users_list',
        '/api/tools': 'tools_list'
      };
      if (keyMap[endpoint]) {
        localStorage.setItem(keyMap[endpoint], JSON.stringify(data));
      }
      return data;
    }
  } catch (e) {
    console.warn(`API fetch error on ${endpoint}, loading from cache:`, e);
  }
  const keyMap = {
    '/api/duas': 'dua_iste_list',
    '/api/questions': 'soru_cevap_list',
    '/api/stories': 'stories_list',
    '/api/chat': 'live_chat_list',
    '/api/users': 'users_list',
    '/api/tools': 'tools_list'
  };
  const key = keyMap[endpoint];
  if (key) {
    return JSON.parse(localStorage.getItem(key) || JSON.stringify(defaultValue));
  }
  return defaultValue;
}

async function apiPost(endpoint, body) {
  try {
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });
    if (res.ok) {
      const data = await res.json();
      return data;
    }
  } catch (e) {
    console.error(`API post error on ${endpoint}:`, e);
  }
  return null;
}

function bindEvents() {
  // Giriş Formu Gönderimi
  els.loginForm.addEventListener('submit', handleLoginSubmit);

  // Çıkış
  els.btnLogout.addEventListener('click', handleLogout);

  // Sekmeler Arası Geçiş
  els.menuItems.forEach(item => {
    item.addEventListener('click', () => {
      const tabName = item.getAttribute('data-tab');
      switchTab(tabName);
    });
  });

  // Dua Filtreleme
  els.filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      els.filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      renderDuaIstekleri();
    });
  });

  // Dua Arama
  els.btnSearchDua.addEventListener('click', renderDuaIstekleri);
  els.searchDuaInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') renderDuaIstekleri();
  });

  // Günlük Dua CRUD
  els.dailyDuaForm.addEventListener('submit', saveDailyDua);
  els.btnCancelDailyDua.addEventListener('click', clearDailyDuaForm);

  // Hikaye Resim Değişimi & Yükleme
  els.storyImageFile.addEventListener('change', handleStoryImageUpload);
  els.btnRemoveStoryImg.addEventListener('click', clearStoryImagePreview);
  els.storyForm.addEventListener('submit', saveStory);
  els.btnCancelStory.addEventListener('click', clearStoryForm);

  // Soru Cevap
  els.btnSendAnswer.addEventListener('click', sendQuestionAnswer);
  els.btnDeleteQuestion.addEventListener('click', deleteQuestion);

  // Canlı Sohbet
  els.btnAdminChatSend.addEventListener('click', sendAdminChatMessage);
  els.adminChatInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') sendAdminChatMessage();
  });

  // Kullanıcı Yönetimi - Genel Engel Kilidi
  els.chkGlobalUserBlock.addEventListener('change', async (e) => {
    await apiPost('/api/block_status', { blocked: e.target.checked });
  });

  // Araçlar Yönetimi CRUD
  els.toolForm.addEventListener('submit', saveTool);
  els.btnCancelTool.addEventListener('click', clearToolForm);

  // Dashboard "Tümünü Gör" Yönlendirmesi
  document.querySelectorAll('.btn-view-all-duas').forEach(btn => {
    btn.addEventListener('click', () => switchTab('dua-istekleri'));
  });
}

// ==================== GİRİŞ & OTURUM KONTROLÜ ====================
function checkSession() {
  const isLoggedIn = sessionStorage.getItem('admin_logged_in') === 'true';
  if (isLoggedIn) {
    els.loginContainer.style.display = 'none';
    els.adminContainer.style.display = 'flex';
    startPanel();
  } else {
    els.loginContainer.style.display = 'flex';
    els.adminContainer.style.display = 'none';
  }
}

function handleLoginSubmit(e) {
  if (e) e.preventDefault();
  const username = els.usernameInput.value.trim();
  const password = els.passwordInput.value.trim();

  // Şifre: 123456 veya admin / kullanıcı adı: admin
  if (username === 'admin' && (password === '123456' || password === 'admin')) {
    sessionStorage.setItem('admin_logged_in', 'true');
    els.loginError.style.display = 'none';
    
    // Geçiş Animasyonu
    els.loginContainer.style.opacity = '0';
    setTimeout(() => {
      els.loginContainer.style.display = 'none';
      els.adminContainer.style.display = 'flex';
      checkSession();
    }, 400);
  } else {
    els.loginError.textContent = 'Kullanıcı adı veya şifre hatalı!';
    els.loginError.style.display = 'block';
  }
}

function handleLogout() {
  if (confirm('Yönetim panelinden çıkış yapmak istiyor musunuz?')) {
    sessionStorage.removeItem('admin_logged_in');
    clearIntervals();
    checkSession();
  }
}

// ==================== SEKME KONTROLÜ ====================
function switchTab(tabName) {
  currentTab = tabName;
  clearIntervals();

  // Sidebar aktif sınıfını güncelle
  els.menuItems.forEach(item => {
    if (item.getAttribute('data-tab') === tabName) {
      item.classList.add('active');
    } else {
      item.classList.remove('active');
    }
  });

  // Sayfa başlığını güncelle
  const tabTitles = {
    'dashboard': 'Dashboard',
    'dua-istekleri': 'Dua İstekleri',
    'gunluk-dualar': 'Günlük Dualar Yönetimi',
    'hikayeler': 'Hikaye Yönetimi',
    'soru-cevap': 'Soru & Cevap Talepleri',
    'canli-sohbet': 'Canlı Sohbet Odası',
    'kullanici-yonetimi': 'Kullanıcı Yönetimi',
    'arac-yonetimi': 'Araçlar Yönetimi'
  };
  els.pageTitle.textContent = tabTitles[tabName] || 'Yönetim Paneli';

  // İçerik panellerini göster/gizle
  els.tabPanes.forEach(pane => {
    if (pane.id === `tab-content-${tabName}`) {
      pane.classList.add('active');
    } else {
      pane.classList.remove('active');
    }
  });

  // Sekmeye özgü verileri yükle ve poller'ları başlat
  refreshActiveTabData();
}

function refreshActiveTabData() {
  switch (currentTab) {
    case 'dashboard':
      renderDashboard();
      dashboardInterval = setInterval(renderDashboard, 3000);
      break;
    case 'dua-istekleri':
      renderDuaIstekleri();
      break;
    case 'gunluk-dualar':
      renderGunlukDualar();
      break;
    case 'hikayeler':
      renderHikayeler();
      break;
    case 'soru-cevap':
      renderSoruCevap();
      break;
    case 'canli-sohbet':
      renderCanliSohbet();
      chatInterval = setInterval(renderCanliSohbet, 1500);
      break;
    case 'kullanici-yonetimi':
      renderKullaniciYonetimi();
      break;
    case 'arac-yonetimi':
      renderAracYonetimi();
      break;
  }
}

function clearIntervals() {
  if (chatInterval) clearInterval(chatInterval);
  if (dashboardInterval) clearInterval(dashboardInterval);
}

// ==================== PANEL BAŞLANGICI ====================
function startPanel() {
  // Sidebar rozetlerini güncelle
  updateSidebarBadges();
  // İlk sekmeyi yükle
  switchTab('dashboard');
}

async function updateSidebarBadges() {
  const duas = await apiFetch('/api/duas');
  const pendingDuas = duas.filter(d => d.durum === 'bekliyor').length;
  
  if (pendingDuas > 0) {
    els.sidebarPendingPrayersBadge.textContent = pendingDuas;
    els.sidebarPendingPrayersBadge.style.display = 'inline-flex';
  } else {
    els.sidebarPendingPrayersBadge.style.display = 'none';
  }

  const questions = await apiFetch('/api/questions');
  const pendingQuestions = questions.filter(q => !q.cevap).length;

  if (pendingQuestions > 0) {
    els.sidebarPendingQuestionsBadge.textContent = pendingQuestions;
    els.sidebarPendingQuestionsBadge.style.display = 'inline-flex';
  } else {
    els.sidebarPendingQuestionsBadge.style.display = 'none';
  }
}

// ==================== TAB 1: DASHBOARD ====================
async function renderDashboard() {
  const users = await apiFetch('/api/users');
  const duas = await apiFetch('/api/duas');
  
  const pendingDuas = duas.filter(d => d.durum === 'bekliyor');
  const approvedDuas = duas.filter(d => d.durum === 'yayinda');

  // Sayısal değerleri yaz
  els.statTotalUsers.textContent = (users.length + 245815).toLocaleString();
  els.statTotalPrayers.textContent = duas.length;
  els.statPendingPrayers.textContent = pendingDuas.length;
  els.statApprovedPrayers.textContent = approvedDuas.length;

  // Son Eklenen Dualar Tablosu (Son 5 dua)
  els.recentPrayersTable.innerHTML = '';
  const recentDuas = [...duas].slice(0, 5);
  
  if (recentDuas.length === 0) {
    els.recentPrayersTable.innerHTML = '<tr><td colspan="4" class="text-center text-secondary">Henüz dua eklenmemiş.</td></tr>';
  } else {
    recentDuas.forEach(d => {
      const tr = document.createElement('tr');
      const stateBadge = d.durum === 'yayinda' 
        ? '<span class="badge badge-success">Yayında</span>' 
        : '<span class="badge badge-warning">Bekliyor</span>';
      
      tr.innerHTML = `
        <td><strong>${escapeHTML(d.yazar || 'Anonim')}</strong></td>
        <td><div style="max-width: 320px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${escapeHTML(d.dua)}</div></td>
        <td>${stateBadge}</td>
        <td><span style="font-size: 11px; color:#888;">${d.tarih || 'Bilinmiyor'}</span></td>
      `;
      els.recentPrayersTable.appendChild(tr);
    });
  }

  // Dashboard Onay Bekleyenler Hızlı Listesi
  els.pendingPrayersQuickList.innerHTML = '';
  if (pendingDuas.length === 0) {
    els.pendingPrayersQuickList.innerHTML = `
      <div class="panel-empty-state" style="height: 150px;">
        <i class="fa-solid fa-circle-check text-success" style="font-size: 24px; opacity: 0.6;"></i>
        <p>Onay bekleyen dua bulunmuyor.</p>
      </div>
    `;
  } else {
    pendingDuas.slice(0, 4).forEach(d => {
      const card = document.createElement('div');
      card.className = 'quick-pending-card';
      card.innerHTML = `
        <div class="quick-pending-text"><strong>${escapeHTML(d.yazar)}</strong>: "${escapeHTML(d.dua)}"</div>
        <div class="quick-pending-meta">
          <span style="font-size: 10px; color:#888;">${d.tarih}</span>
          <div class="quick-pending-actions" style="display: flex; gap: 6px;">
            <button class="btn-approve-solid" onclick="approveDua(${d.id})">Onayla</button>
            <button class="btn-delete-solid" onclick="deleteDua(${d.id})">Sil</button>
          </div>
        </div>
      `;
      els.pendingPrayersQuickList.appendChild(card);
    });
  }
}

// ==================== TAB 2: DUA İSTEKLERİ ====================
async function renderDuaIstekleri() {
  const filterBtn = document.querySelector('.btn-filter.active');
  const filter = filterBtn ? filterBtn.getAttribute('data-filter') : 'all';
  const searchVal = els.searchDuaInput.value.toLowerCase().trim();
  const duas = await apiFetch('/api/duas');

  // İstatistikleri güncelle
  const pendingCount = duas.filter(d => d.durum === 'bekliyor').length;
  const approvedCount = duas.filter(d => d.durum === 'yayinda').length;
  els.summaryTotalPrayers.textContent = duas.length;
  els.summaryPendingPrayers.textContent = pendingCount;
  els.summaryApprovedPrayers.textContent = approvedCount;

  // Filtreleme
  let filteredDuas = duas;
  if (filter === 'pending') {
    filteredDuas = duas.filter(d => d.durum === 'bekliyor');
  } else if (filter === 'approved') {
    filteredDuas = duas.filter(d => d.durum === 'yayinda');
  }

  // Arama
  if (searchVal) {
    filteredDuas = filteredDuas.filter(d => 
      d.yazar.toLowerCase().includes(searchVal) || 
      d.dua.toLowerCase().includes(searchVal)
    );
  }

  // Tablo Çıktısı
  els.duaTableBody.innerHTML = '';
  if (filteredDuas.length === 0) {
    els.duaTableBody.innerHTML = '<tr><td colspan="6" class="text-center text-secondary">Aramaya uygun dua talebi bulunamadı.</td></tr>';
    return;
  }

  filteredDuas.forEach(d => {
    const tr = document.createElement('tr');
    const stateBadge = d.durum === 'yayinda' 
      ? '<span class="badge badge-success">Yayında</span>' 
      : '<span class="badge badge-warning">Bekliyor</span>';
    
    // İşlem Butonları (Onay bekleyende onaylama butonu ekle)
    let actionsHtml = `<button class="btn-delete-solid" onclick="deleteDua(${d.id})">Sil</button>`;
    if (d.durum === 'bekliyor') {
      actionsHtml = `
        <button class="btn-approve-solid" onclick="approveDua(${d.id})" style="margin-right: 6px;">Onayla</button>
        ${actionsHtml}
      `;
    }

    tr.innerHTML = `
      <td><strong>${escapeHTML(d.yazar || 'Anonim')}</strong></td>
      <td><div style="max-width: 400px; word-wrap: break-word; white-space: pre-wrap;">${escapeHTML(d.dua)}</div></td>
      <td style="text-align: center;"><span class="amin-badge"><i class="fa-solid fa-heart"></i> ${d.amin}</span></td>
      <td>${stateBadge}</td>
      <td><span style="font-size: 11px; color:#888;">${d.tarih || 'Bilinmiyor'}</span></td>
      <td style="text-align: right; white-space: nowrap;">${actionsHtml}</td>
    `;
    els.duaTableBody.appendChild(tr);
  });
}

// Global olarak tetiklenebilmesi için window nesnesine atıyoruz
window.approveDua = async function(id) {
  await apiPost('/api/duas/approve', { id });
  await updateSidebarBadges();
  refreshActiveTabData();
};

window.deleteDua = async function(id) {
  if (confirm('Bu dua isteğini silmek istediğinizden emin misiniz?')) {
    await apiPost('/api/duas/delete', { id });
    await updateSidebarBadges();
    refreshActiveTabData();
  }
};

// ==================== TAB 3: GÜNLÜK DUALAR ====================
function renderGunlukDualar() {
  const list = JSON.parse(localStorage.getItem('gunluk_dualar_list') || '[]');
  els.dailyDuasCount.textContent = list.length;

  els.dailyDuasList.innerHTML = '';
  if (list.length === 0) {
    els.dailyDuasList.innerHTML = '<div class="panel-empty-state"><p>Kayıtlı günlük dua bulunmuyor.</p></div>';
    return;
  }

  // Sıralamaya göre diz
  const sortedList = [...list].sort((a, b) => a.sira - b.sira);

  sortedList.forEach(dua => {
    const card = document.createElement('div');
    card.className = 'editor-card';
    const activeBadge = dua.aktif 
      ? '<span class="badge badge-success">Aktif</span>' 
      : '<span class="badge badge-danger">Pasif</span>';
    const categoryBadge = `<span class="badge badge-primary">${escapeHTML(dua.kategori || 'Genel')}</span>`;

    card.innerHTML = `
      <div class="editor-card-header">
        <h4>${escapeHTML(dua.baslik)}</h4>
        <div class="editor-card-actions">
          <button class="btn btn-icon btn-icon-edit" onclick="editDailyDua(${dua.id})" title="Düzenle"><i class="fa-solid fa-pen"></i></button>
          <button class="btn btn-icon btn-icon-toggle" onclick="toggleDailyDua(${dua.id})" title="Aktif/Pasif Yap"><i class="fa-solid fa-eye-slash"></i></button>
          <button class="btn btn-icon btn-icon-delete" onclick="deleteDailyDua(${dua.id})" title="Sil"><i class="fa-solid fa-trash"></i></button>
        </div>
      </div>
      <div class="editor-card-badges">
        ${categoryBadge}
        <span class="badge badge-info">Sıra: ${dua.sira}</span>
        ${activeBadge}
      </div>
      <div class="editor-card-body" style="font-family: 'Traditional Arabic', serif; font-size: 16px; text-align: right; direction: rtl; font-weight: bold;">${escapeHTML(dua.dua_metni)}</div>
      <div class="editor-card-footer"><strong>Meal/Fazilet:</strong> ${escapeHTML(dua.fazilet)}</div>
    `;
    els.dailyDuasList.appendChild(card);
  });
}

function saveDailyDua() {
  const baslik = els.dailyDuaTitle.value.trim();
  const dua_metni = els.dailyDuaText.value.trim();
  const fazilet = els.dailyDuaBenefit.value.trim();
  const kategori = els.dailyDuaCategory.value;
  const sira = parseInt(els.dailyDuaOrder.value) || 0;

  if (!baslik || !dua_metni || !fazilet) return;

  const list = JSON.parse(localStorage.getItem('gunluk_dualar_list') || '[]');

  if (editingDuaId) {
    const target = list.find(d => d.id === editingDuaId);
    if (target) {
      target.baslik = baslik;
      target.dua_metni = dua_metni;
      target.fazilet = fazilet;
      target.kategori = kategori;
      target.sira = sira;
    }
    editingDuaId = null;
  } else {
    const newDua = {
      id: Date.now(),
      baslik,
      dua_metni,
      fazilet,
      kategori,
      sira,
      aktif: true
    };
    list.push(newDua);
  }

  localStorage.setItem('gunluk_dualar_list', JSON.stringify(list));
  clearDailyDuaForm();
  renderGunlukDualar();
}

window.editDailyDua = function(id) {
  const list = JSON.parse(localStorage.getItem('gunluk_dualar_list') || '[]');
  const target = list.find(d => d.id === id);
  if (target) {
    editingDuaId = id;
    els.dailyDuaFormTitle.textContent = 'Duayı Düzenle';
    els.dailyDuaTitle.value = target.baslik;
    els.dailyDuaText.value = target.dua_metni;
    els.dailyDuaBenefit.value = target.fazilet;
    els.dailyDuaCategory.value = target.kategori || 'Genel';
    els.dailyDuaOrder.value = target.sira;
    els.btnCancelDailyDua.style.display = 'inline-flex';
    els.btnSaveDailyDua.textContent = 'Güncelle';
    els.dailyDuaForm.scrollIntoView({ behavior: 'smooth' });
  }
};

window.toggleDailyDua = function(id) {
  const list = JSON.parse(localStorage.getItem('gunluk_dualar_list') || '[]');
  const target = list.find(d => d.id === id);
  if (target) {
    target.aktif = !target.aktif;
    localStorage.setItem('gunluk_dualar_list', JSON.stringify(list));
    renderGunlukDualar();
  }
};

window.deleteDailyDua = function(id) {
  if (confirm('Bu günlük duayı kalıcı olarak silmek istediğinizden emin misiniz?')) {
    let list = JSON.parse(localStorage.getItem('gunluk_dualar_list') || '[]');
    list = list.filter(d => d.id !== id);
    localStorage.setItem('gunluk_dualar_list', JSON.stringify(list));
    renderGunlukDualar();
  }
};

function clearDailyDuaForm() {
  editingDuaId = null;
  els.dailyDuaFormTitle.textContent = 'Yeni Dua Ekle';
  els.dailyDuaForm.reset();
  els.dailyDuaOrder.value = 0;
  els.btnCancelDailyDua.style.display = 'none';
  els.btnSaveDailyDua.textContent = 'Dua Ekle';
}

// ==================== TAB 4: HİKAYELER ====================
async function renderHikayeler() {
  const list = await apiFetch('/api/stories');
  els.storiesCount.textContent = list.length;

  els.storiesList.innerHTML = '';
  if (list.length === 0) {
    els.storiesList.innerHTML = '<div class="panel-empty-state"><p>Kayıtlı hikaye bulunmuyor.</p></div>';
    return;
  }

  const sortedList = [...list].sort((a, b) => a.sira - b.sira);

  sortedList.forEach(story => {
    const card = document.createElement('div');
    card.className = 'editor-card';
    const activeBadge = story.aktif 
      ? '<span class="badge badge-success">Aktif</span>' 
      : '<span class="badge badge-danger">Pasif</span>';
    const typeBadge = `<span class="badge badge-info">${escapeHTML(story.kategori || 'Özel')}</span>`;

    let imgHtml = '';
    if (story.resim) {
      imgHtml = `<img src="${story.resim}" alt="${escapeHTML(story.baslik)}" style="width: 44px; height: 44px; object-fit: cover; border-radius: 8px; border: 1px solid var(--border-color); margin-right: 12px;">`;
    } else {
      const initials = story.baslik.substring(0, 2).toUpperCase();
      imgHtml = `<div style="width: 44px; height: 44px; display:flex; justify-content:center; align-items:center; background:var(--primary-color); color:white; font-weight:bold; font-size:14px; border-radius:8px; margin-right: 12px;">${initials}</div>`;
    }

    const isSystem = ['dini-danisman', 'mekke', 'ramazan', 'tebrik'].includes(story.id);
    const deleteBtn = isSystem 
      ? `<button class="btn btn-icon btn-icon-delete" style="opacity: 0.3; cursor: not-allowed;" title="Sistem hikayeleri silinemez" disabled><i class="fa-solid fa-lock"></i></button>`
      : `<button class="btn btn-icon btn-icon-delete" onclick="deleteStory('${story.id}')" title="Sil"><i class="fa-solid fa-trash"></i></button>`;

    card.innerHTML = `
      <div style="display: flex; align-items: center; margin-bottom: 8px;">
        ${imgHtml}
        <div style="flex: 1;">
          <div class="editor-card-header" style="margin-bottom: 0;">
            <h4 style="max-width: 90%;">${escapeHTML(story.baslik)}</h4>
            <div class="editor-card-actions">
              <button class="btn btn-icon btn-icon-edit" onclick="editStory('${story.id}')" title="Düzenle"><i class="fa-solid fa-pen"></i></button>
              <button class="btn btn-icon btn-icon-toggle" onclick="toggleStory('${story.id}')" title="Aktif/Pasif Yap"><i class="fa-solid fa-eye-slash"></i></button>
              ${deleteBtn}
            </div>
          </div>
        </div>
      </div>
      <div class="editor-card-badges" style="margin-left: 56px;">
        ${typeBadge}
        <span class="badge badge-info">Sıra: ${story.sira}</span>
        ${activeBadge}
      </div>
      <div class="editor-card-body" style="margin-left: 56px; max-width: calc(100% - 56px);">${escapeHTML(story.icerik || '')}</div>
      <div class="editor-card-footer" style="margin-left: 56px;">Oluşturan: ${story.olusturan || 'Sistem'} | Sıra: ${story.sira}</div>
    `;
    els.storiesList.appendChild(card);
  });
}

function handleStoryImageUpload(e) {
  const file = e.target.files[0];
  if (!file) return;

  if (file.size > 5 * 1024 * 1024) {
    alert('Dosya boyutu çok büyük! Maksimum 5MB yüklenebilir.');
    els.storyImageFile.value = '';
    return;
  }

  const reader = new FileReader();
  reader.onload = function(evt) {
    const base64 = evt.target.result;
    els.storyImageData.value = base64;
    els.storyImagePreview.src = base64;
    els.storyImagePreviewContainer.style.display = 'block';
    els.storyImageInfo.textContent = `${file.name} (${(file.size / 1024).toFixed(1)} KB)`;
  };
  reader.readAsDataURL(file);
}

function clearStoryImagePreview() {
  els.storyImageFile.value = '';
  els.storyImageData.value = '';
  els.storyImagePreview.src = '';
  els.storyImagePreviewContainer.style.display = 'none';
  els.storyImageInfo.textContent = 'Maksimum 5MB (JPG, PNG, WEBP)';
}

async function saveStory() {
  const baslik = els.storyTitle.value.trim();
  const kategori = els.storyType.value;
  const icerik = els.storyContent.value.trim();
  const sira = parseInt(els.storyOrder.value) || 0;
  const resim = els.storyImageData.value; // base64

  if (!baslik || !icerik) return;

  const newStory = {
    id: editingStoryId || ('story-' + Date.now()),
    baslik,
    kategori,
    sira,
    aktif: true,
    resim: resim || null,
    icerik,
    olusturan: editingStoryId ? 'system/admin' : 'admin'
  };

  await apiPost('/api/stories', newStory);
  clearStoryForm();
  renderHikayeler();
}

window.editStory = async function(id) {
  const list = await apiFetch('/api/stories');
  const target = list.find(s => s.id === id);
  if (target) {
    editingStoryId = id;
    els.storyFormTitle.textContent = 'Hikayeyi Düzenle';
    els.storyTitle.value = target.baslik;
    els.storyType.value = target.kategori === 'Sistem' ? 'Dua' : (target.kategori || 'Dua');
    els.storyContent.value = target.icerik || '';
    els.storyOrder.value = target.sira;
    
    if (target.resim) {
      els.storyImageData.value = target.resim;
      els.storyImagePreview.src = target.resim;
      els.storyImagePreviewContainer.style.display = 'block';
    } else {
      clearStoryImagePreview();
    }

    els.btnCancelStory.style.display = 'inline-flex';
    els.btnSaveStory.textContent = 'Güncelle';
    els.storyForm.scrollIntoView({ behavior: 'smooth' });
  }
};

window.toggleStory = async function(id) {
  const list = await apiFetch('/api/stories');
  const target = list.find(s => s.id === id);
  if (target) {
    target.aktif = !target.aktif;
    await apiPost('/api/stories', target);
    renderHikayeler();
  }
};

window.deleteStory = async function(id) {
  if (confirm('Bu özel hikayeyi kalıcı olarak silmek istediğinizden emin misiniz?')) {
    await apiPost('/api/stories/delete', { id });
    renderHikayeler();
  }
};

function clearStoryForm() {
  editingStoryId = null;
  els.storyFormTitle.textContent = 'Yeni Hikaye Ekle';
  els.storyForm.reset();
  els.storyOrder.value = 0;
  clearStoryImagePreview();
  els.btnCancelStory.style.display = 'none';
  els.btnSaveStory.textContent = 'Hikaye Ekle';
}

// ==================== TAB 5: SORU CEVAP ====================
async function renderSoruCevap() {
  const list = await apiFetch('/api/questions');
  els.qaQuestionsCount.textContent = list.length;

  els.qaQuestionsList.innerHTML = '';
  if (list.length === 0) {
    els.qaQuestionsList.innerHTML = '<div class="panel-empty-state" style="height: 200px;"><p>Soru talebi bulunmuyor.</p></div>';
    els.qaDetailEmpty.style.display = 'flex';
    els.qaDetailContainer.style.display = 'none';
    return;
  }

  const sortedList = [...list].sort((a, b) => b.id - a.id);

  sortedList.forEach(qa => {
    const card = document.createElement('div');
    card.className = `qa-question-card ${selectedQuestionId === qa.id ? 'active' : ''}`;
    
    const replyBadge = qa.cevap 
      ? '<span class="badge badge-success" style="margin-left:auto;">Cevaplandı</span>' 
      : '<span class="badge badge-warning" style="margin-left:auto;">Cevap Bekliyor</span>';

    card.innerHTML = `
      <div class="qa-meta">
        <span class="qa-author">${escapeHTML(qa.yazar || 'Kullanıcı')}</span>
        <span class="qa-date">${qa.tarih || ''}</span>
      </div>
      <div class="qa-snippet">${escapeHTML(qa.soru)}</div>
      <div style="display:flex; align-items:center; margin-top: 4px;">
        ${replyBadge}
      </div>
    `;

    card.onclick = () => selectQuestion(qa.id);
    els.qaQuestionsList.appendChild(card);
  });

  if (selectedQuestionId) {
    const activeQA = list.find(q => q.id === selectedQuestionId);
    if (activeQA) {
      els.qaDetailAuthor.textContent = activeQA.yazar || 'Kullanıcı';
      els.qaDetailDate.textContent = activeQA.tarih || '';
      els.qaDetailText.textContent = activeQA.soru || '';
      els.qaReplyText.value = activeQA.cevap || '';
      els.qaDetailEmpty.style.display = 'none';
      els.qaDetailContainer.style.display = 'block';
    } else {
      selectedQuestionId = null;
      els.qaDetailEmpty.style.display = 'flex';
      els.qaDetailContainer.style.display = 'none';
    }
  } else {
    els.qaDetailEmpty.style.display = 'flex';
    els.qaDetailContainer.style.display = 'none';
  }
}

function selectQuestion(id) {
  selectedQuestionId = id;
  renderSoruCevap();
}

async function sendQuestionAnswer() {
  if (!selectedQuestionId) return;

  const replyText = els.qaReplyText.value.trim();
  if (!replyText) {
    alert('Lütfen boş bir cevap göndermeyin.');
    return;
  }

  await apiPost('/api/questions/answer', { id: selectedQuestionId, cevap: replyText });
  await updateSidebarBadges();
  renderSoruCevap();
  alert('Cevabınız başarıyla iletildi.');
}

async function deleteQuestion() {
  if (!selectedQuestionId) return;

  if (confirm('Bu soruyu kalıcı olarak silmek istediğinizden emin misiniz?')) {
    await apiPost('/api/questions/delete', { id: selectedQuestionId });
    selectedQuestionId = null;
    await updateSidebarBadges();
    renderSoruCevap();
  }
}

// ==================== TAB 6: CANLI SOHBET ====================
async function renderCanliSohbet() {
  const messages = await apiFetch('/api/chat');
  
  const currentMsgCount = els.adminChatMessages.children.length;
  if (currentMsgCount === messages.length) return; 

  els.adminChatMessages.innerHTML = '';
  
  if (messages.length === 0) {
    els.adminChatMessages.innerHTML = '<div class="panel-empty-state"><p>Sohbette mesaj bulunmuyor.</p></div>';
    return;
  }

  messages.forEach(msg => {
    const bubble = document.createElement('div');
    bubble.className = 'chat-bubble';

    if (msg.isAdmin) {
      bubble.className += ' user'; 
      bubble.innerHTML = `<span class="chat-user-label" style="color: rgba(255,255,255,0.85);">🕌 Yönetici (Admin) - ${msg.tarih || ''}</span>${escapeHTML(msg.metin)}`;
    } else {
      bubble.className += ' other'; 
      if (msg.isAdminStyle) {
        bubble.className += ' admin';
      }
      bubble.innerHTML = `<span class="chat-user-label">${escapeHTML(msg.yazar)} - ${msg.tarih || ''}</span>${escapeHTML(msg.metin)}`;
    }
    
    els.adminChatMessages.appendChild(bubble);
  });

  els.adminChatMessages.scrollTop = els.adminChatMessages.scrollHeight;
}

async function sendAdminChatMessage() {
  const metin = els.adminChatInput.value.trim();
  if (!metin) return;

  const timeStr = new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });

  const newMsg = {
    id: Date.now(),
    yazar: 'Admin',
    metin: metin,
    tarih: timeStr,
    isAdmin: true
  };

  await apiPost('/api/chat', newMsg);
  els.adminChatInput.value = '';
  renderCanliSohbet();
}

// ==================== TAB 7: KULLANICI YÖNETİMİ ====================
async function renderKullaniciYonetimi() {
  const users = await apiFetch('/api/users');
  els.usersCount.textContent = users.length;

  // Global engelleme durumunu API'den çek
  const blockStatus = await apiFetch('/api/block_status', { blocked: false });
  els.chkGlobalUserBlock.checked = blockStatus.blocked;

  els.usersTableBody.innerHTML = '';
  if (users.length === 0) {
    els.usersTableBody.innerHTML = '<tr><td colspan="5" class="text-center text-secondary">Kayıtlı kullanıcı simülasyonu bulunmamaktadır.</td></tr>';
    return;
  }

  users.forEach(user => {
    const tr = document.createElement('tr');
    
    const stateBadge = user.engelli 
      ? '<span class="badge badge-danger">Engelli</span>' 
      : '<span class="badge badge-success">Aktif</span>';

    const actionBtn = user.engelli
      ? `<button class="btn btn-secondary ripple btn-sm" onclick="toggleUserBlock('${escapeJSString(user.eposta)}')" style="padding: 6px 12px; font-size: 11px;"><i class="fa-solid fa-user-check"></i> Engeli Kaldır</button>`
      : `<button class="btn btn-logout ripple btn-sm" onclick="toggleUserBlock('${escapeJSString(user.eposta)}')" style="padding: 6px 12px; font-size: 11px; color:#fff;"><i class="fa-solid fa-user-slash"></i> Engelle</button>`;

    tr.innerHTML = `
      <td><strong>${escapeHTML(user.adSoyad)}</strong></td>
      <td>${escapeHTML(user.eposta)}</td>
      <td><span style="font-size: 11px; color:#888;">${user.kayitTarihi || 'Bilinmiyor'}</span></td>
      <td>${stateBadge}</td>
      <td style="text-align: right;">${actionBtn}</td>
    `;
    els.usersTableBody.appendChild(tr);
  });
}

window.toggleUserBlock = async function(email) {
  const users = await apiFetch('/api/users');
  const target = users.find(u => u.eposta === email);
  if (target) {
    target.engelli = !target.engelli;
    await apiPost('/api/users', target);
    
    if (email === 'ahmet@gmail.com') {
      await apiPost('/api/block_status', { blocked: target.engelli });
    }
    
    renderKullaniciYonetimi();
  }
};

// ==================== TAB 8: ARAÇLAR YÖNETİMİ ====================
let editingToolId = null;

async function renderAracYonetimi() {
  const list = await apiFetch('/api/tools');
  els.toolsCount.textContent = list.length;
  els.toolsList.innerHTML = '';

  if (list.length === 0) {
    els.toolsList.innerHTML = '<div class="panel-empty-state"><p>Kayıtlı araç bulunmuyor.</p></div>';
    return;
  }

  // Sort by sira ascending
  const sortedList = [...list].sort((a, b) => a.sira - b.sira);

  sortedList.forEach((tool, index) => {
    const card = document.createElement('div');
    card.className = 'editor-card';
    const activeBadge = tool.aktif 
      ? '<span class="badge badge-success">Aktif</span>' 
      : '<span class="badge badge-danger">Pasif</span>';

    card.innerHTML = `
      <div class="editor-card-header">
        <h4>${escapeHTML(tool.title)} <span style="font-size:12px; color:#888;">(${tool.id})</span></h4>
        <div class="editor-card-actions">
          <button class="btn btn-icon btn-icon-edit" onclick="editTool('${tool.id}')" title="Düzenle"><i class="fa-solid fa-pen"></i></button>
          <button class="btn btn-icon btn-icon-toggle" onclick="toggleTool('${tool.id}')" title="Aktif/Pasif Yap"><i class="fa-solid fa-eye-slash"></i></button>
          <button class="btn btn-icon btn-icon-delete" onclick="deleteTool('${tool.id}')" title="Sil"><i class="fa-solid fa-trash"></i></button>
          <button class="btn btn-icon" onclick="moveTool('${tool.id}', -1)" title="Yukarı Taşı" ${index === 0 ? 'disabled style="opacity:0.3;"' : ''}><i class="fa-solid fa-arrow-up"></i></button>
          <button class="btn btn-icon" onclick="moveTool('${tool.id}', 1)" title="Aşağı Taşı" ${index === sortedList.length - 1 ? 'disabled style="opacity:0.3;"' : ''}><i class="fa-solid fa-arrow-down"></i></button>
        </div>
      </div>
      <div class="editor-card-badges">
        <span class="badge badge-info">Sıra: ${tool.sira}</span>
        <span class="badge" style="background-color: ${tool.color.replace('0xFF', '#')}; color: #333;">Renk: ${tool.color}</span>
        <span class="badge" style="background:#eee; color:#333;">İkon: ${tool.icon}</span>
        ${activeBadge}
      </div>
      <div class="editor-card-body">${escapeHTML(tool.desc)}</div>
    `;
    els.toolsList.appendChild(card);
  });
}

async function saveTool() {
  const id = els.toolIdInput.value.trim();
  const title = els.toolTitleInput.value.trim();
  const desc = els.toolDescInput.value.trim();
  const icon = els.toolIconInput.value.trim();
  const color = els.toolColorInput.value.trim();
  const sira = parseInt(els.toolOrderInput.value) || 0;

  if (!id || !title || !desc || !icon || !color) return;

  const list = await apiFetch('/api/tools');

  if (editingToolId) {
    const target = list.find(t => t.id === editingToolId);
    if (target) {
      target.title = title;
      target.desc = desc;
      target.icon = icon;
      target.color = color;
      target.sira = sira;
    }
    editingToolId = null;
  } else {
    if (list.some(t => t.id === id)) {
      alert('Bu araç ID zaten kullanılmaktadır!');
      return;
    }
    const newTool = {
      id,
      title,
      desc,
      icon,
      color,
      sira,
      aktif: true
    };
    list.push(newTool);
  }

  await apiPost('/api/tools', list);
  clearToolForm();
  await renderAracYonetimi();
}

window.editTool = async function(id) {
  const list = await apiFetch('/api/tools');
  const target = list.find(t => t.id === id);
  if (target) {
    editingToolId = id;
    els.toolFormTitle.textContent = 'Aracı Düzenle';
    els.toolIdInput.value = target.id;
    els.toolIdInput.disabled = true;
    els.toolTitleInput.value = target.title;
    els.toolDescInput.value = target.desc;
    els.toolIconInput.value = target.icon;
    els.toolColorInput.value = target.color;
    els.toolOrderInput.value = target.sira;
    els.btnCancelTool.style.display = 'inline-flex';
    els.btnSaveTool.textContent = 'Güncelle';
    els.toolForm.scrollIntoView({ behavior: 'smooth' });
  }
};

window.toggleTool = async function(id) {
  const list = await apiFetch('/api/tools');
  const target = list.find(t => t.id === id);
  if (target) {
    target.aktif = !target.aktif;
    await apiPost('/api/tools', list);
    await renderAracYonetimi();
  }
};

window.deleteTool = async function(id) {
  if (confirm('Bu aracı kalıcı olarak silmek istediğinizden emin misiniz?')) {
    let list = await apiFetch('/api/tools');
    list = list.filter(t => t.id !== id);
    await apiPost('/api/tools', list);
    await renderAracYonetimi();
  }
};

window.moveTool = async function(id, direction) {
  const list = await apiFetch('/api/tools');
  const sortedList = [...list].sort((a, b) => a.sira - b.sira);
  const index = sortedList.findIndex(t => t.id === id);
  if (index === -1) return;

  const newIndex = index + direction;
  if (newIndex < 0 || newIndex >= sortedList.length) return;

  const temp = sortedList[index].sira;
  sortedList[index].sira = sortedList[newIndex].sira;
  sortedList[newIndex].sira = temp;

  if (sortedList[index].sira === sortedList[newIndex].sira) {
    sortedList.forEach((t, i) => t.sira = i + 1);
  }

  await apiPost('/api/tools', sortedList);
  await renderAracYonetimi();
};

function clearToolForm() {
  editingToolId = null;
  els.toolFormTitle.textContent = 'Yeni Araç Ekle';
  els.toolIdInput.disabled = false;
  els.toolForm.reset();
  els.toolOrderInput.value = 0;
  els.btnCancelTool.style.display = 'none';
  els.btnSaveTool.textContent = 'Araç Ekle';
}

// ==================== YARDIMCI ARAÇLAR (UTILITIES) ====================
function escapeHTML(str) {
  if (!str) return '';
  return str.replace(/[&<>'"]/g, 
    tag => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      "'": '&#39;',
      '"': '&quot;'
    }[tag] || tag)
  );
}

function escapeJSString(str) {
  if (!str) return '';
  return str.replace(/'/g, "\\'");
}
