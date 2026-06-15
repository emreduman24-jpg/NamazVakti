// Firebase Web SDK Modules
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { 
  getAuth, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  onAuthStateChanged, 
  signOut 
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
import { 
  getFirestore, 
  collection, 
  doc, 
  getDocs, 
  getDoc, 
  setDoc, 
  updateDoc, 
  deleteDoc, 
  query, 
  orderBy 
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

// Firebase Config Credentials
const firebaseConfig = {
  projectId: "namaz-vakti-app-2026",
  appId: "1:442515189721:web:e18fc8acf6aeff1b8633c8",
  storageBucket: "namaz-vakti-app-2026.firebasestorage.app",
  apiKey: "AIzaSyDQkgQ7N47JVnZ3kGmxDEwb2EvMj6CKdY4",
  authDomain: "namaz-vakti-app-2026.firebaseapp.com",
  messagingSenderId: "442515189721"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// 21 Default Tools definition for Seeding
const defaultTools = [
  { "id": "dini-gunler", "title": "Dini Günler", "desc": "Kandiller ve bayramlar", "icon": "📅", "color": "0xFFEAF7F1", "sira": 1, "aktif": true },
  { "id": "dua-iste", "title": "Dua İste", "desc": "Dualarınızı paylaşın", "icon": "🤲", "color": "0xFFEAF4FB", "sira": 2, "aktif": true },
  { "id": "soru-cevap", "title": "Soru Cevap", "desc": "Dini danışmana soru sorun", "icon": "💬", "color": "0xFFFFF7EA", "sira": 3, "aktif": true },
  { "id": "canli-sohbet", "title": "Canlı Kur'an Radyosu", "desc": "7/24 Kesintisiz Diyanet Kur'an Radyo", "icon": "🎧", "color": "0xFFFBEAEA", "sira": 4, "aktif": true },
  { "id": "peygamber-hayati", "title": "Peygamberin Hayatı", "desc": "Hz. Muhammed'in yaşamı", "icon": "📖", "color": "0xFFEAF7F1", "sira": 5, "aktif": true },
  { "id": "kuran-kerim", "title": "Kuran-ı Kerim", "desc": "30 cüz sesli okuma ve takip", "icon": "🕌", "color": "0xFFFFF7EA", "sira": 6, "aktif": true },
  { "id": "esmaul-husna", "title": "Esmaül Hüsna", "desc": "Allah'ın 99 ismi", "icon": "✨", "color": "0xFFEAF4FB", "sira": 7, "aktif": true },
  { "id": "kible-bulucu", "title": "Kıble Bulucu", "desc": "Dijital pusula ile yön", "icon": "🧭", "color": "0xFFFFF7EA", "sira": 8, "aktif": true },
  { "id": "zikirmatik", "title": "Zikirmatik", "desc": "Dijital tesbih sayacı", "icon": "📿", "color": "0xFFEAF4FB", "sira": 9, "aktif": true },
  { "id": "yakindaki-camiler", "title": "Yakındaki Camiler", "desc": "Konumunuza en yakın camiler", "icon": "📍", "color": "0xFFFFF7EA", "sira": 10, "aktif": true },
  { "id": "hadis-40", "title": "40 Hadis-i Şerif", "desc": "40 Hadis meali ve dersler", "icon": "📜", "color": "0xFFEAF4FB", "sira": 11, "aktif": true },
  { "id": "gunluk-dualar", "title": "Dualar", "desc": "Hayatın her anı için dualar", "icon": "🤲", "color": "0xFFEAF7F1", "sira": 12, "aktif": true },
  { "id": "zekat-hesaplama", "title": "Zekat Hesaplama", "desc": "Zekat miktarını hesaplayın", "icon": "💰", "color": "0xFFFFF7EA", "sira": 13, "aktif": true },
  { "id": "sahabe-hayatlari", "title": "Sahabe Hayatları", "desc": "Peygamberin ashabı", "icon": "👥", "color": "0xFFEAF4FB", "sira": 14, "aktif": true },
  { "id": "namaz-kilma", "title": "Namaz Kılma Rehberi", "desc": "Adım adım namaz öğrenin", "icon": "🚶", "color": "0xFFEAF7F1", "sira": 15, "aktif": true },
  { "id": "abdest-rehberi", "title": "Abdest Rehberi", "desc": "Adım adım abdest alınışı", "icon": "💧", "color": "0xFFEAF7F1", "sira": 16, "aktif": true },
  { "id": "gusul-abdesti", "title": "Gusül Abdesti", "desc": "Boy abdesti farz ve sünnetleri", "icon": "🚿", "color": "0xFFFFF7EA", "sira": 17, "aktif": true },
  { "id": "ezkar", "title": "Sabah Akşam Ezkarı", "desc": "Günlük sabah ve akşam zikirleri", "icon": "📿", "color": "0xFFEAF4FB", "sira": 18, "aktif": true },
  { "id": "kaza-namazlari", "title": "Kazaya Kalan Namazlar", "desc": "Kaza çetelesi ve takibi", "icon": "📊", "color": "0xFFFBEAEA", "sira": 19, "aktif": true },
  { "id": "islam-sartlari", "title": "İslam'ın Şartları", "desc": "İslam şartları rehberi", "icon": "⭐", "color": "0xFFEAF4FB", "sira": 20, "aktif": true },
  { "id": "dini-hoca", "title": "Dini Danışman", "desc": "Yapay zeka ile dini sohbet", "icon": "👳", "color": "0xFFFFF7EA", "sira": 21, "aktif": true }
];

// Global States
let currentTab = 'dashboard';
let cache = {
  duas: [],
  questions: [],
  tools: [],
  blockStatus: false,
  users: [],
  announcements: []
};
let activeQuestionDocId = null;

// DOM Elements
const els = {
  loginContainer: document.getElementById('login-container'),
  adminContainer: document.getElementById('admin-container'),
  loginForm: document.getElementById('login-form'),
  emailInput: document.getElementById('email'),
  passwordInput: document.getElementById('password'),
  loginError: document.getElementById('login-error-msg'),
  btnLogout: document.getElementById('btn-logout'),
  adminDisplayName: document.getElementById('admin-display-name'),
  pageTitle: document.getElementById('page-title'),
  menuItems: document.querySelectorAll('.sidebar-menu .menu-item'),
  tabPanes: document.querySelectorAll('.tab-pane'),

  // Sidebar Badges
  badgePendingPrayers: document.getElementById('sidebar-pending-prayers-count'),
  badgePendingQuestions: document.getElementById('sidebar-pending-questions-count'),
  badgeToolsCount: document.getElementById('sidebar-tools-count'),
  badgeBlockStatus: document.getElementById('sidebar-block-status'),
  badgeUsersCount: document.getElementById('sidebar-users-count'),

  // Dashboard Tab
  statTotalPrayers: document.getElementById('stat-total-prayers'),
  statPendingPrayers: document.getElementById('stat-pending-prayers'),
  statTotalQuestions: document.getElementById('stat-total-questions'),
  statPendingQuestions: document.getElementById('stat-pending-questions'),
  dashboardRecentPrayers: document.getElementById('dashboard-recent-prayers'),
  dashboardBlockStatusBadge: document.getElementById('dashboard-block-status-badge'),
  dashboardToolsCount: document.getElementById('dashboard-tools-count'),
  dashboardUsersCountBadge: document.getElementById('dashboard-users-count-badge'),
  btnQuickBlockNav: document.getElementById('btn-quick-block-nav'),

  // Dua İstekleri Tab
  duaTableBody: document.getElementById('dua-istekleri-table-body'),
  duaFilters: document.querySelectorAll('[data-filter]'),
  searchDuaInput: document.getElementById('search-dua'),

  // Soru & Cevap Tab
  qaFilterSelect: document.getElementById('qa-filter-select'),
  qaQuestionsList: document.getElementById('qa-questions-list'),
  qaDetailEmpty: document.getElementById('qa-detail-empty'),
  qaDetailContainer: document.getElementById('qa-detail-container'),
  qaDetailAuthor: document.getElementById('qa-detail-author'),
  qaDetailDate: document.getElementById('qa-detail-date'),
  qaDetailText: document.getElementById('qa-detail-text'),
  qaReplyText: document.getElementById('qa-reply-text'),
  btnDeleteQuestion: document.getElementById('btn-delete-question'),
  btnSendAnswer: document.getElementById('btn-send-answer'),

  // Araçlar Yönetimi Tab
  toolsTableBody: document.getElementById('tools-table-body'),

  // Kayıtlı Kullanıcılar Tab
  usersTableBody: document.getElementById('users-table-body'),
  userFilters: document.querySelectorAll('[data-user-filter]'),
  searchUserInput: document.getElementById('search-user'),

  // Erişim Kilidi Tab
  lockIconContainer: document.getElementById('lock-icon-container'),
  lockStatusIcon: document.getElementById('lock-status-icon'),
  lockStatusTitle: document.getElementById('lock-status-title'),
  chkGlobalUserBlock: document.getElementById('chk-global-user-block'),

  // Modals
  toolEditModal: document.getElementById('tool-edit-modal'),
  btnCancelToolEdit: document.getElementById('btn-cancel-tool-edit'),
  btnCloseToolModal: document.getElementById('btn-close-tool-modal'),
  toolEditForm: document.getElementById('tool-edit-form'),
  editToolDocId: document.getElementById('edit-tool-doc-id'),
  editToolId: document.getElementById('edit-tool-id'),
  editToolTitle: document.getElementById('edit-tool-title'),
  editToolDesc: document.getElementById('edit-tool-desc'),
  editToolIcon: document.getElementById('edit-tool-icon'),
  editToolColor: document.getElementById('edit-tool-color'),
  editToolOrder: document.getElementById('edit-tool-order'),
  editToolStatus: document.getElementById('edit-tool-status'),

  // User Inspect Modal
  userInspectModal: document.getElementById('user-inspect-modal'),
  btnCloseUserModal: document.getElementById('btn-close-user-modal'),
  btnCloseUserModalFooter: document.getElementById('btn-close-user-modal-footer'),
  inspectUserAvatar: document.getElementById('inspect-user-avatar'),
  inspectUserName: document.getElementById('inspect-user-name'),
  inspectUserEmail: document.getElementById('inspect-user-email'),
  inspectUserPremiumBadge: document.getElementById('inspect-user-premium-badge'),
  inspectUserGender: document.getElementById('inspect-user-gender'),
  inspectUserPlatform: document.getElementById('inspect-user-platform'),
  inspectUserCreatedDate: document.getElementById('inspect-user-created-date'),
  inspectUserLastActive: document.getElementById('inspect-user-last-active'),
  inspectUserIp: document.getElementById('inspect-user-ip'),
  inspectUserDuration: document.getElementById('inspect-user-duration'),
  inspectUserPremiumToggle: document.getElementById('inspect-user-premium-toggle'),
  inspectToggleStatusLabel: document.getElementById('inspect-toggle-status-label'),

  // Bildirim Gönder Tab
  notificationForm: document.getElementById('notification-form'),
  notifTitle: document.getElementById('notif-title'),
  notifBody: document.getElementById('notif-body'),
  notificationsTableBody: document.getElementById('notifications-table-body')
};

// ==================== INITIALIZATION & AUTH ====================
document.addEventListener('DOMContentLoaded', () => {
  bindEvents();
  checkSession();
});

// Setup Auth Watcher
onAuthStateChanged(auth, (user) => {
  if (user) {
    sessionStorage.setItem('admin_logged_in', 'true');
    sessionStorage.removeItem('admin_fallback');
    showAdminPanel(user.email);
  } else {
    if (sessionStorage.getItem('admin_fallback') !== 'true') {
      sessionStorage.removeItem('admin_logged_in');
      showLoginForm();
    } else {
      showAdminPanel("admin@namazvakti.com");
    }
  }
});

function checkSession() {
  const isLoggedIn = sessionStorage.getItem('admin_logged_in') === 'true';
  const isFallback = sessionStorage.getItem('admin_fallback') === 'true';
  if (isLoggedIn) {
    const email = isFallback ? "admin@namazvakti.com" : (auth.currentUser ? auth.currentUser.email : "Yönetici");
    showAdminPanel(email);
  } else {
    showLoginForm();
  }
}

function showAdminPanel(email) {
  els.loginContainer.style.opacity = '0';
  setTimeout(() => {
    els.loginContainer.style.display = 'none';
    els.adminContainer.style.display = 'flex';
    els.adminDisplayName.textContent = email;
    initializeData();
  }, 300);
}

function showLoginForm() {
  els.adminContainer.style.display = 'none';
  els.loginContainer.style.display = 'flex';
  els.loginContainer.style.opacity = '1';
}

// ==================== EVENT BINDING ====================
function bindEvents() {
  // Login Form Submit
  els.loginForm.addEventListener('submit', handleLogin);

  // Logout Click
  els.btnLogout.addEventListener('click', handleLogout);

  // Sidebar Tabs Switching
  els.menuItems.forEach(item => {
    item.addEventListener('click', () => {
      const tabName = item.getAttribute('data-tab');
      switchTab(tabName);
    });
  });

  // Dashboard Navigation Actions
  document.querySelectorAll('.btn-view-all-duas').forEach(btn => {
    btn.addEventListener('click', () => switchTab('dua-istekleri'));
  });
  els.btnQuickBlockNav.addEventListener('click', () => switchTab('erisim-kilidi'));

  // Dua İstekleri Filters
  els.duaFilters.forEach(btn => {
    btn.addEventListener('click', () => {
      els.duaFilters.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      renderDuaIstekleri();
    });
  });

  // Dua İstekleri Search
  els.searchDuaInput.addEventListener('input', renderDuaIstekleri);

  // Soru & Cevap Filter Select
  els.qaFilterSelect.addEventListener('change', renderQuestionsList);

  // Question Reply Submission
  els.btnSendAnswer.addEventListener('click', saveQuestionAnswer);
  els.btnDeleteQuestion.addEventListener('click', deleteSelectedQuestion);

  // Erişim Kilidi Toggle
  els.chkGlobalUserBlock.addEventListener('change', handleBlockStatusToggle);

  // Tool Edit Modal Closing
  els.btnCancelToolEdit.addEventListener('click', closeToolModal);
  els.btnCloseToolModal.addEventListener('click', closeToolModal);

  // Tool Edit Form Submit
  els.toolEditForm.addEventListener('submit', handleToolUpdate);

  // Kayıtlı Kullanıcılar Tab Filters
  els.userFilters.forEach(btn => {
    btn.addEventListener('click', () => {
      els.userFilters.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      renderUsersList();
    });
  });

  // Kayıtlı Kullanıcılar Search
  els.searchUserInput.addEventListener('input', renderUsersList);

  // User Inspect Modal Closing
  els.btnCloseUserModal.addEventListener('click', closeUserModal);
  els.btnCloseUserModalFooter.addEventListener('click', closeUserModal);

  // User Premium Toggle Action
  els.inspectUserPremiumToggle.addEventListener('change', handleUserPremiumToggle);

  // Notification Form Submit
  if (els.notificationForm) {
    els.notificationForm.addEventListener('submit', handleSendNotification);
  }
}

// ==================== AUTHENTICATION ACTIONS ====================
async function handleLogin(e) {
  e.preventDefault();
  const email = els.emailInput.value.trim();
  const password = els.passwordInput.value.trim();
  hideLoginError();

  try {
    await signInWithEmailAndPassword(auth, email, password);
    sessionStorage.setItem('admin_logged_in', 'true');
    sessionStorage.removeItem('admin_fallback');
  } catch (err) {
    console.warn("Firebase Auth sign-in failed. Testing local fallback...", err);
    // Secure Local Fallback in case Auth Provider is not enabled yet in Firebase Console
    if (email === "admin@namazvakti.com" && password === "admin123") {
      try {
        await createUserWithEmailAndPassword(auth, email, password);
        sessionStorage.setItem('admin_logged_in', 'true');
        sessionStorage.removeItem('admin_fallback');
        showToast("İlk giriş başarılı. Yönetici hesabı Firebase Authentication üzerinde otomatik oluşturuldu!", "success");
      } catch (createErr) {
        console.warn("Could not auto-create Firebase Auth user:", createErr);
        sessionStorage.setItem('admin_logged_in', 'true');
        sessionStorage.setItem('admin_fallback', 'true');
        showAdminPanel(email);
        showToast("Yerel yedek hesapla giriş yapıldı. (Firebase Auth bağlantı uyarısı)", "warning");
      }
    } else {
      showLoginError("Hatalı e-posta veya şifre!");
    }
  }
}

function handleLogout() {
  if (confirm("Yönetim panelinden çıkış yapmak istiyor musunuz?")) {
    if (sessionStorage.getItem('admin_fallback') === 'true') {
      sessionStorage.removeItem('admin_logged_in');
      sessionStorage.removeItem('admin_fallback');
      showLoginForm();
    } else {
      signOut(auth).then(() => {
        sessionStorage.removeItem('admin_logged_in');
        showLoginForm();
      });
    }
  }
}

function showLoginError(msg) {
  els.loginError.textContent = msg;
  els.loginError.style.display = 'block';
}

function hideLoginError() {
  els.loginError.style.display = 'none';
}

// ==================== DATA FETCHING & SYNCHRONIZATION ====================
async function initializeData() {
  // Seeding tools if empty
  await checkAndSeedTools();
  // Seeding global block status if empty
  await checkAndSeedBlockStatus();
  // Fetch lists
  await refreshAllData();
  // Set tab
  switchTab(currentTab);
}

async function refreshAllData() {
  try {
    // 1. Fetch block status
    const blockSnap = await getDoc(doc(db, "block_status", "global"));
    if (blockSnap.exists()) {
      cache.blockStatus = blockSnap.data().blocked || false;
    }

    // 2. Fetch tools
    const toolsSnap = await getDocs(query(collection(db, "tools"), orderBy("sira", "asc")));
    cache.tools = toolsSnap.docs.map(d => ({ docId: d.id, ...d.data() }));

    // 3. Fetch prayers (duas)
    const duasSnap = await getDocs(collection(db, "duas"));
    cache.duas = duasSnap.docs.map(d => ({ docId: d.id, ...d.data() }));
    // Sort duas: newest first by id field (timestamp)
    cache.duas.sort((a, b) => (b.id || 0) - (a.id || 0));

    // 4. Fetch Q&A questions
    const questionsSnap = await getDocs(collection(db, "questions"));
    cache.questions = questionsSnap.docs.map(d => ({ docId: d.id, ...d.data() }));
    // Sort questions: newest first by id field (timestamp)
    cache.questions.sort((a, b) => (b.id || 0) - (a.id || 0));

    // 5. Fetch registered users
    const usersSnap = await getDocs(collection(db, "users"));
    cache.users = usersSnap.docs.map(d => ({ docId: d.id, ...d.data() }));
    // Sort users: newest first by registration date (created)
    cache.users.sort((a, b) => {
      const aTime = a.created ? new Date(a.created).getTime() : 0;
      const bTime = b.created ? new Date(b.created).getTime() : 0;
      return bTime - aTime;
    });

    // 6. Fetch sent announcements
    const announcementsSnap = await getDocs(collection(db, "announcements"));
    cache.announcements = announcementsSnap.docs.map(d => ({ docId: d.id, ...d.data() }));
    cache.announcements.sort((a, b) => (b.id || 0) - (a.id || 0));

    updateSidebarBadges();
  } catch (err) {
    console.error("Data fetch error from Firestore:", err);
    showToast("Veriler yüklenirken hata oluştu!", "danger");
  }
}

async function checkAndSeedTools() {
  try {
    const snap = await getDocs(collection(db, "tools"));
    if (snap.empty) {
      console.log("Tools collection is empty. Auto-seeding default 21 tools...");
      for (const tool of defaultTools) {
        await setDoc(doc(db, "tools", tool.id), tool);
      }
    }
  } catch (err) {
    console.error("Tool seeding failed:", err);
  }
}

async function checkAndSeedBlockStatus() {
  try {
    const globalDocRef = doc(db, "block_status", "global");
    const docSnap = await getDoc(globalDocRef);
    if (!docSnap.exists()) {
      console.log("Global block status does not exist. Initializing to blocked = false...");
      await setDoc(globalDocRef, { blocked: false });
    }
  } catch (err) {
    console.error("Block status seeding failed:", err);
  }
}

function updateSidebarBadges() {
  // 1. Pending prayers count
  const pendingPrayers = cache.duas.filter(d => d.durum === 'bekliyor').length;
  if (pendingPrayers > 0) {
    els.badgePendingPrayers.textContent = pendingPrayers;
    els.badgePendingPrayers.style.display = 'inline-flex';
  } else {
    els.badgePendingPrayers.style.display = 'none';
  }

  // 2. Pending questions count
  const pendingQuestions = cache.questions.filter(q => !q.cevap || q.cevap.trim() === '').length;
  if (pendingQuestions > 0) {
    els.badgePendingQuestions.textContent = pendingQuestions;
    els.badgePendingQuestions.style.display = 'inline-flex';
  } else {
    els.badgePendingQuestions.style.display = 'none';
  }

  // 3. Tools count
  els.badgeToolsCount.textContent = cache.tools.length;

  // 4. Block status badge
  if (cache.blockStatus) {
    els.badgeBlockStatus.style.display = 'inline-flex';
  } else {
    els.badgeBlockStatus.style.display = 'none';
  }

  // 5. Users count badge
  if (cache.users.length > 0) {
    els.badgeUsersCount.textContent = cache.users.length;
    els.badgeUsersCount.style.display = 'inline-flex';
  } else {
    els.badgeUsersCount.style.display = 'none';
  }
}

// ==================== TABS NAVIGATION ====================
function switchTab(tabName) {
  currentTab = tabName;

  // Update active sidebar link
  els.menuItems.forEach(item => {
    if (item.getAttribute('data-tab') === tabName) {
      item.classList.add('active');
    } else {
      item.classList.remove('active');
    }
  });

  // Update Topbar page title
  const tabTitles = {
    'dashboard': 'Dashboard',
    'dua-istekleri': 'Dua İstekleri Yönetimi',
    'soru-cevap': 'Soru & Cevap Talepleri',
    'arac-yonetimi': 'Araçlar Yönetimi',
    'kullanicilar': 'Kayıtlı Kullanıcı Yönetimi',
    'bildirim-gonder': 'Bildirim & Günlük Ayet Gönder',
    'erisim-kilidi': 'Uygulama Erişim Kilidi'
  };
  els.pageTitle.textContent = tabTitles[tabName] || 'Yönetim Paneli';

  // Toggle Tab Sections
  els.tabPanes.forEach(pane => {
    if (pane.id === `tab-content-${tabName}`) {
      pane.classList.add('active');
    } else {
      pane.classList.remove('active');
    }
  });

  // Populate active tab content
  renderActiveTab();
}

function renderActiveTab() {
  switch (currentTab) {
    case 'dashboard':
      renderDashboard();
      break;
    case 'dua-istekleri':
      renderDuaIstekleri();
      break;
    case 'soru-cevap':
      renderSoruCevap();
      break;
    case 'arac-yonetimi':
      renderAraçYönetimi();
      break;
    case 'kullanicilar':
      renderUsersTab();
      break;
    case 'erisim-kilidi':
      renderErişimKilidi();
      break;
    case 'bildirim-gonder':
      renderBildirimGonder();
      break;
  }
}

// ==================== TAB 1: DASHBOARD ====================
function renderDashboard() {
  // Statistics values
  const totalPrayers = cache.duas.length;
  const pendingPrayers = cache.duas.filter(d => d.durum === 'bekliyor').length;
  const totalQuestions = cache.questions.length;
  const pendingQuestions = cache.questions.filter(q => !q.cevap || q.cevap.trim() === '').length;

  els.statTotalPrayers.textContent = totalPrayers;
  els.statPendingPrayers.textContent = pendingPrayers;
  els.statTotalQuestions.textContent = totalQuestions;
  els.statPendingQuestions.textContent = pendingQuestions;

  // App-wide Status boxes
  if (cache.blockStatus) {
    els.dashboardBlockStatusBadge.textContent = "Kilitli";
    els.dashboardBlockStatusBadge.className = "status-value-badge status-red";
  } else {
    els.dashboardBlockStatusBadge.textContent = "Aktif";
    els.dashboardBlockStatusBadge.className = "status-value-badge status-green";
  }
  els.dashboardToolsCount.textContent = `${cache.tools.length} Araç`;
  
  if (els.dashboardUsersCountBadge) {
    els.dashboardUsersCountBadge.textContent = `${cache.users.length} Kullanıcı`;
  }

  // Recent prayers list (take last 5)
  els.dashboardRecentPrayers.innerHTML = '';
  const recentPrayers = cache.duas.slice(0, 5);
  
  if (recentPrayers.length === 0) {
    els.dashboardRecentPrayers.innerHTML = `<tr><td colspan="4" style="text-align: center;" class="text-muted">Dua talebi bulunmuyor.</td></tr>`;
  } else {
    recentPrayers.forEach(dua => {
      const tr = document.createElement('tr');
      const badgeClass = dua.durum === 'yayinda' ? 'badge-success' : 'badge-warning';
      const badgeText = dua.durum === 'yayinda' ? 'Yayında' : 'Bekliyor';
      
      tr.innerHTML = `
        <td><strong>${escapeHTML(dua.yazar || 'Anonim')}</strong></td>
        <td><div class="dua-text-cell" style="max-width: 380px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${escapeHTML(dua.dua)}</div></td>
        <td><span class="badge ${badgeClass}">${badgeText}</span></td>
        <td><span class="text-muted" style="font-size:12px;">${dua.tarih || ''}</span></td>
      `;
      els.dashboardRecentPrayers.appendChild(tr);
    });
  }
}

// ==================== TAB 2: DUA İSTEKLERİ ====================
function renderDuaIstekleri() {
  const activeFilter = document.querySelector('.btn-filter.active').getAttribute('data-filter');
  const searchText = els.searchDuaInput.value.toLowerCase().trim();

  // Filter
  let list = cache.duas;
  if (activeFilter === 'pending') {
    list = cache.duas.filter(d => d.durum === 'bekliyor');
  } else if (activeFilter === 'approved') {
    list = cache.duas.filter(d => d.durum === 'yayinda');
  }

  // Search
  if (searchText) {
    list = list.filter(d => 
      (d.yazar || '').toLowerCase().includes(searchText) || 
      (d.dua || '').toLowerCase().includes(searchText)
    );
  }

  // Table Body
  els.duaTableBody.innerHTML = '';
  if (list.length === 0) {
    els.duaTableBody.innerHTML = `<tr><td colspan="6" style="text-align: center;" class="text-muted">Gösterilecek dua bulunamadı.</td></tr>`;
    return;
  }

  list.forEach(dua => {
    const tr = document.createElement('tr');
    const badgeClass = dua.durum === 'yayinda' ? 'badge-success' : 'badge-warning';
    const badgeText = dua.durum === 'yayinda' ? 'Yayında' : 'Bekliyor';

    let actionButtons = '';
    if (dua.durum === 'bekliyor') {
      actionButtons += `<button class="btn-approve-solid" data-doc-id="${dua.docId}" style="margin-right:8px;"><i class="fa-solid fa-check"></i> Onayla</button>`;
    }
    actionButtons += `<button class="btn-delete-solid" data-doc-id="${dua.docId}"><i class="fa-solid fa-trash-can"></i> Sil</button>`;

    tr.innerHTML = `
      <td><strong>${escapeHTML(dua.yazar || 'Anonim')}</strong></td>
      <td><div style="max-width: 450px; white-space: normal; word-break: break-all;">${escapeHTML(dua.dua)}</div></td>
      <td style="text-align: center;"><span class="amin-badge"><i class="fa-solid fa-heart"></i> ${dua.amin || 0}</span></td>
      <td><span class="badge ${badgeClass}">${badgeText}</span></td>
      <td><span class="text-muted" style="font-size:12px; white-space:nowrap;">${dua.tarih || ''}</span></td>
      <td style="text-align: right; white-space:nowrap;">${actionButtons}</td>
    `;
    els.duaTableBody.appendChild(tr);
  });

  // Bind buttons
  els.duaTableBody.querySelectorAll('.btn-approve-solid').forEach(btn => {
    btn.addEventListener('click', (e) => handleDuaApprove(e.currentTarget.getAttribute('data-doc-id')));
  });
  els.duaTableBody.querySelectorAll('.btn-delete-solid').forEach(btn => {
    btn.addEventListener('click', (e) => handleDuaDelete(e.currentTarget.getAttribute('data-doc-id')));
  });
}

async function handleDuaApprove(docId) {
  try {
    const docRef = doc(db, "duas", docId);
    await updateDoc(docRef, { durum: 'yayinda' });
    showToast("Dua başarıyla onaylandı ve yayına alındı.", "success");
    await refreshAllData();
    renderActiveTab();
  } catch (err) {
    console.error("Error approving dua:", err);
    showToast("Dua onaylanırken hata oluştu!", "danger");
  }
}

async function handleDuaDelete(docId) {
  if (confirm("Bu dua isteğini silmek istediğinizden emin misiniz?")) {
    try {
      await deleteDoc(doc(db, "duas", docId));
      showToast("Dua isteği silindi.", "success");
      await refreshAllData();
      renderActiveTab();
    } catch (err) {
      console.error("Error deleting dua:", err);
      showToast("Dua silinirken hata oluştu!", "danger");
    }
  }
}

// ==================== TAB 3: SORU & CEVAP ====================
function renderSoruCevap() {
  renderQuestionsList();
  
  // Reset Q&A Detail side
  activeQuestionDocId = null;
  els.qaDetailContainer.style.display = 'none';
  els.qaDetailEmpty.style.display = 'flex';
}

function renderQuestionsList() {
  const filter = els.qaFilterSelect.value;
  let list = cache.questions;

  if (filter === 'unanswered') {
    list = cache.questions.filter(q => !q.cevap || q.cevap.trim() === '');
  } else if (filter === 'answered') {
    list = cache.questions.filter(q => q.cevap && q.cevap.trim() !== '');
  }

  els.qaQuestionsList.innerHTML = '';
  if (list.length === 0) {
    els.qaQuestionsList.innerHTML = `<div style="text-align:center; padding: 20px;" class="text-muted">Soru bulunamadı.</div>`;
    return;
  }

  list.forEach(q => {
    const card = document.createElement('div');
    card.className = `qa-question-card ${activeQuestionDocId === q.docId ? 'active' : ''}`;
    card.setAttribute('data-doc-id', q.docId);

    const answeredBadge = q.cevap && q.cevap.trim() !== '' 
      ? '<span class="badge badge-success">Cevaplandı</span>' 
      : '<span class="badge badge-danger">Cevapsız</span>';

    card.innerHTML = `
      <div class="qa-meta">
        <span class="qa-author">${escapeHTML(q.yazar || 'Anonim')}</span>
        <span class="qa-date">${q.tarih || ''}</span>
      </div>
      <div class="qa-snippet">${escapeHTML(q.soru)}</div>
      <div style="display:flex; justify-content:space-between; align-items:center; margin-top:4px;">
        ${answeredBadge}
        <span style="font-size:10px; color:var(--text-muted);">ID: ${q.id || ''}</span>
      </div>
    `;

    card.addEventListener('click', () => selectQuestion(q));
    els.qaQuestionsList.appendChild(card);
  });
}

function selectQuestion(q) {
  activeQuestionDocId = q.docId;
  
  // Highlight active card
  document.querySelectorAll('.qa-question-card').forEach(card => {
    if (card.getAttribute('data-doc-id') === q.docId) {
      card.classList.add('active');
    } else {
      card.classList.remove('active');
    }
  });

  // Populate Details
  els.qaDetailAuthor.textContent = q.yazar || 'Anonim';
  els.qaDetailDate.textContent = q.tarih || '';
  els.qaDetailText.textContent = q.soru || '';
  els.qaReplyText.value = q.cevap || '';

  // Show container
  els.qaDetailEmpty.style.display = 'none';
  els.qaDetailContainer.style.display = 'block';
}

async function saveQuestionAnswer() {
  if (!activeQuestionDocId) return;
  const reply = els.qaReplyText.value.trim();

  if (!reply) {
    showToast("Lütfen bir cevap yazın!", "warning");
    return;
  }

  try {
    const docRef = doc(db, "questions", activeQuestionDocId);
    await updateDoc(docRef, { cevap: reply });
    showToast("Cevap başarıyla kaydedildi.", "success");
    await refreshAllData();
    renderQuestionsList();
    
    // Update currently selected object in memory
    const updated = cache.questions.find(q => q.docId === activeQuestionDocId);
    if (updated) {
      selectQuestion(updated);
    }
  } catch (err) {
    console.error("Error saving answer:", err);
    showToast("Yanıt kaydedilirken hata oluştu!", "danger");
  }
}

async function deleteSelectedQuestion() {
  if (!activeQuestionDocId) return;

  if (confirm("Bu soruyu kalıcı olarak silmek istediğinizden emin misiniz?")) {
    try {
      await deleteDoc(doc(db, "questions", activeQuestionDocId));
      showToast("Soru başarıyla silindi.", "success");
      await refreshAllData();
      renderSoruCevap();
    } catch (err) {
      console.error("Error deleting question:", err);
      showToast("Soru silinirken hata oluştu!", "danger");
    }
  }
}

// ==================== TAB 4: ARAÇLAR YÖNETİMİ ====================
function renderAraçYönetimi() {
  els.toolsTableBody.innerHTML = '';
  if (cache.tools.length === 0) {
    els.toolsTableBody.innerHTML = `<tr><td colspan="8" style="text-align: center;" class="text-muted">Araçlar yüklenemedi.</td></tr>`;
    return;
  }

  cache.tools.forEach(tool => {
    const tr = document.createElement('tr');
    const statusClass = tool.aktif ? 'badge-success' : 'badge-danger';
    const statusText = tool.aktif ? 'Aktif' : 'Pasif (Gizli)';

    tr.innerHTML = `
      <td style="text-align:center; font-size:20px;">${escapeHTML(tool.icon || '✨')}</td>
      <td><strong>${escapeHTML(tool.title || '')}</strong></td>
      <td><span style="font-size:13px; color:var(--text-secondary);">${escapeHTML(tool.desc || '')}</span></td>
      <td><code style="color:var(--accent-gold); font-size:12px;">${escapeHTML(tool.id || '')}</code></td>
      <td style="text-align:center; font-weight:700;">${tool.sira || 99}</td>
      <td>
        <div class="tool-color-indicator">
          <span class="color-dot" style="background-color: ${parseColor(tool.color)};"></span>
          <span>${escapeHTML(tool.color || '')}</span>
        </div>
      </td>
      <td><span class="badge ${statusClass}">${statusText}</span></td>
      <td style="text-align: right;">
        <button class="btn-edit-tool" data-doc-id="${tool.docId}"><i class="fa-solid fa-pen-to-square"></i> Düzenle</button>
      </td>
    `;

    els.toolsTableBody.appendChild(tr);
  });

  // Bind Edit buttons
  els.toolsTableBody.querySelectorAll('.btn-edit-tool').forEach(btn => {
    btn.addEventListener('click', (e) => openToolModal(e.currentTarget.getAttribute('data-doc-id')));
  });
}

function openToolModal(docId) {
  const tool = cache.tools.find(t => t.docId === docId);
  if (!tool) return;

  els.editToolDocId.value = tool.docId;
  els.editToolId.value = tool.id;
  els.editToolTitle.value = tool.title;
  els.editToolDesc.value = tool.desc;
  els.editToolIcon.value = tool.icon;
  els.editToolColor.value = tool.color;
  els.editToolOrder.value = tool.sira;
  els.editToolStatus.value = String(tool.aktif);

  els.toolEditModal.style.display = 'flex';
}

function closeToolModal() {
  els.toolEditModal.style.display = 'none';
  els.toolEditForm.reset();
}

async function handleToolUpdate(e) {
  e.preventDefault();
  const docId = els.editToolDocId.value;
  
  const updatedData = {
    title: els.editToolTitle.value.trim(),
    desc: els.editToolDesc.value.trim(),
    icon: els.editToolIcon.value.trim(),
    color: els.editToolColor.value.trim(),
    sira: parseInt(els.editToolOrder.value) || 1,
    aktif: els.editToolStatus.value === 'true'
  };

  try {
    const docRef = doc(db, "tools", docId);
    await updateDoc(docRef, updatedData);
    showToast("Araç güncellendi.", "success");
    closeToolModal();
    await refreshAllData();
    renderAraçYönetimi();
  } catch (err) {
    console.error("Error updating tool:", err);
    showToast("Araç güncellenirken hata oluştu!", "danger");
  }
}

// ==================== TAB 5: ERİŞİM KİLİDİ ====================
function renderErişimKilidi() {
  els.chkGlobalUserBlock.checked = cache.blockStatus;
  
  if (cache.blockStatus) {
    els.lockIconContainer.className = "lock-icon-wrapper locked";
    els.lockStatusIcon.className = "fa-solid fa-lock";
    els.lockStatusTitle.textContent = "Sistem Erişimi: ENGEL KİLİTLİ";
  } else {
    els.lockIconContainer.className = "lock-icon-wrapper";
    els.lockStatusIcon.className = "fa-solid fa-lock-open";
    els.lockStatusTitle.textContent = "Sistem Erişimi: AKTİF (AÇIK)";
  }
}

async function handleBlockStatusToggle(e) {
  const isBlocked = e.target.checked;
  try {
    const globalDocRef = doc(db, "block_status", "global");
    await updateDoc(globalDocRef, { blocked: isBlocked });
    
    cache.blockStatus = isBlocked;
    renderErişimKilidi();
    updateSidebarBadges();
    
    const message = isBlocked 
      ? "Erişim kilidi AKTİFLEŞTİRİLDİ. Tüm mobil kullanıcıların erişimi engellendi." 
      : "Erişim kilidi AÇILDI. Uygulamaya tekrar erişilebilir.";
    const statusType = isBlocked ? "warning" : "success";
    showToast(message, statusType);
  } catch (err) {
    console.error("Error toggling block status:", err);
    showToast("Erişim kilidi değiştirilirken hata oluştu!", "danger");
    e.target.checked = !isBlocked; // revert switch
  }
}

// ==================== HELPER UTILITIES ====================
function parseColor(hexStr) {
  if (!hexStr) return "transparent";
  // Parse colors like '0xFFEAF7F1' or '#EAF7F1' or 'EAF7F1'
  let clean = hexStr.replace('0x', '').replace('#', '');
  if (clean.length === 8) {
    // Has alpha channel, extract last 6 characters
    clean = clean.substring(2);
  }
  return '#' + clean;
}

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

// Custom Toast/Notification Utility
function showToast(message, type = "info") {
  // Create toast container if not exists
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    container.style.position = 'fixed';
    container.style.bottom = '24px';
    container.style.right = '24px';
    container.style.zIndex = '9999';
    container.style.display = 'flex';
    container.style.flexDirection = 'column';
    container.style.gap = '10px';
    document.body.appendChild(container);
  }

  // Create toast element
  const toast = document.createElement('div');
  toast.style.padding = '14px 20px';
  toast.style.borderRadius = '12px';
  toast.style.color = '#fff';
  toast.style.fontSize = '13px';
  toast.style.fontWeight = '600';
  toast.style.boxShadow = '0 10px 30px rgba(0,0,0,0.3)';
  toast.style.display = 'flex';
  toast.style.alignItems = 'center';
  toast.style.gap = '10px';
  toast.style.minWidth = '280px';
  toast.style.maxWidth = '400px';
  toast.style.animation = 'fadeIn 0.3s ease, slideInRight 0.3s ease';
  toast.style.borderLeft = '4px solid';
  
  // Style types
  let icon = 'fa-info-circle';
  if (type === 'success') {
    toast.style.backgroundColor = 'rgba(16, 185, 129, 0.95)';
    toast.style.borderLeftColor = '#34d399';
    icon = 'fa-circle-check';
  } else if (type === 'warning') {
    toast.style.backgroundColor = 'rgba(245, 158, 11, 0.95)';
    toast.style.borderLeftColor = '#fbbf24';
    icon = 'fa-triangle-exclamation';
  } else if (type === 'danger') {
    toast.style.backgroundColor = 'rgba(244, 63, 94, 0.95)';
    toast.style.borderLeftColor = '#fca5a5';
    icon = 'fa-circle-exclamation';
  } else {
    toast.style.backgroundColor = 'rgba(59, 130, 246, 0.95)';
    toast.style.borderLeftColor = '#60a5fa';
    icon = 'fa-circle-info';
  }

  toast.innerHTML = `<i class="fa-solid ${icon}" style="font-size:16px;"></i> <div>${escapeHTML(message)}</div>`;
  container.appendChild(toast);

  // Auto remove toast after 4 seconds
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    toast.style.transition = 'opacity 0.3s, transform 0.3s';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

// Add CSS keyframe for slide in to head
const styleSheet = document.createElement("style");
styleSheet.innerText = `
  @keyframes slideInRight {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
  }
`;
document.head.appendChild(styleSheet);

// ==================== TAB 6: REGISTERED USERS ====================
function renderUsersTab() {
  renderUsersList();
}

function renderUsersList() {
  const activeFilterBtn = document.querySelector('[data-user-filter].active');
  const activeFilter = activeFilterBtn ? activeFilterBtn.getAttribute('data-user-filter') : 'all';
  const searchText = els.searchUserInput.value.toLowerCase().trim();

  // Filter
  let list = cache.users;
  if (activeFilter === 'premium') {
    list = cache.users.filter(u => u.isPremium === true);
  } else if (activeFilter === 'free') {
    list = cache.users.filter(u => !u.isPremium);
  }

  // Search
  if (searchText) {
    list = list.filter(u => 
      (u.name || '').toLowerCase().includes(searchText) || 
      (u.email || '').toLowerCase().includes(searchText)
    );
  }

  // Table Body
  els.usersTableBody.innerHTML = '';
  if (list.length === 0) {
    els.usersTableBody.innerHTML = `<tr><td colspan="6" style="text-align: center;" class="text-muted">Gösterilecek kayıtlı kullanıcı bulunamadı.</td></tr>`;
    return;
  }

  list.forEach(user => {
    const tr = document.createElement('tr');
    
    // Gender Avatar
    const avatarEmoji = user.gender === 'kadin' ? '👩' : '👨';
    
    // Premium Badge
    const premiumClass = user.isPremium ? 'premium' : '';
    const premiumText = user.isPremium ? '<i class="fa-solid fa-crown" style="color:#fbbf24;"></i> PRO' : 'Standart';
    
    // Platform Badge
    const platform = (user.platform || 'android').toLowerCase();
    const platformIcon = platform === 'ios' ? 'fa-apple' : 'fa-android';
    const platformLabel = platform === 'ios' ? 'iOS' : 'Android';
    
    // Formatted Dates
    const createdDate = formatDate(user.created);
    const lastActiveDate = formatDate(user.lastActive);

    tr.innerHTML = `
      <td>
        <div class="user-info-cell">
          <div class="user-avatar-small">${avatarEmoji}</div>
          <div class="user-meta-info">
            <span class="user-meta-name">${escapeHTML(user.name || 'İsimsiz Kullanıcı')}</span>
            <span class="user-meta-email">${escapeHTML(user.email || '')}</span>
          </div>
        </div>
      </td>
      <td>
        <span class="platform-badge ${platform}">
          <i class="fa-brands ${platformIcon}"></i> ${platformLabel}
        </span>
      </td>
      <td>
        <span class="premium-badge-cell ${premiumClass}">${premiumText}</span>
      </td>
      <td><span class="text-muted" style="font-size:13px;">${createdDate}</span></td>
      <td><span class="text-muted" style="font-size:13px;">${lastActiveDate}</span></td>
      <td style="text-align: right; white-space:nowrap;">
        <button class="btn-inspect-user" data-doc-id="${user.docId}"><i class="fa-solid fa-address-card"></i> İncele</button>
      </td>
    `;
    els.usersTableBody.appendChild(tr);
  });

  // Bind Buttons
  els.usersTableBody.querySelectorAll('.btn-inspect-user').forEach(btn => {
    btn.addEventListener('click', (e) => openUserModal(e.currentTarget.getAttribute('data-doc-id')));
  });
}

function formatDate(dateStr) {
  if (!dateStr) return '-';
  try {
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) return dateStr;
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${day}.${month}.${year} ${hours}:${minutes}`;
  } catch (e) {
    return dateStr;
  }
}

// Global inspect state
let activeInspectUser = null;

function openUserModal(docId) {
  activeInspectUser = cache.users.find(u => u.docId === docId);
  if (!activeInspectUser) return;

  const user = activeInspectUser;

  els.inspectUserAvatar.textContent = user.gender === 'kadin' ? '👩' : '👨';
  els.inspectUserName.textContent = user.name || 'İsimsiz Kullanıcı';
  els.inspectUserEmail.textContent = user.email || '';
  
  if (user.isPremium) {
    els.inspectUserPremiumBadge.textContent = 'PREMIUM (PRO) ÜYE';
    els.inspectUserPremiumBadge.className = 'premium-badge-status premium';
    els.inspectUserPremiumToggle.checked = true;
    els.inspectToggleStatusLabel.textContent = 'Premium / Aktif';
    els.inspectToggleStatusLabel.className = 'toggle-status-label premium-active';
  } else {
    els.inspectUserPremiumBadge.textContent = 'STANDART ÜYE';
    els.inspectUserPremiumBadge.className = 'premium-badge-status';
    els.inspectUserPremiumToggle.checked = false;
    els.inspectToggleStatusLabel.textContent = 'Standart';
    els.inspectToggleStatusLabel.className = 'toggle-status-label';
  }

  els.inspectUserGender.textContent = user.gender === 'kadin' ? 'Kadın' : 'Erkek';
  
  const platform = (user.platform || 'android').toLowerCase();
  const platformIcon = platform === 'ios' ? 'fa-apple' : 'fa-android';
  els.inspectUserPlatform.innerHTML = `<i class="fa-brands ${platformIcon}"></i> ${platform === 'ios' ? 'iOS' : 'Android'}`;
  
  els.inspectUserCreatedDate.textContent = formatDate(user.created);
  els.inspectUserLastActive.textContent = formatDate(user.lastActive);
  els.inspectUserIp.textContent = user.ipAddress || user.ip || 'Bilinmiyor';
  
  // App usage duration format
  let durationText = '0 Dakika';
  if (user.usageDuration) {
    const minutes = Math.floor(user.usageDuration / 60);
    const seconds = user.usageDuration % 60;
    if (minutes > 0) {
      durationText = `${minutes} dk ${seconds} sn`;
    } else {
      durationText = `${seconds} saniye`;
    }
  }
  els.inspectUserDuration.textContent = durationText;

  els.userInspectModal.style.display = 'flex';
}

function closeUserModal() {
  els.userInspectModal.style.display = 'none';
  activeInspectUser = null;
}

async function handleUserPremiumToggle(e) {
  if (!activeInspectUser) {
    console.error("handleUserPremiumToggle: No activeInspectUser found!");
    return;
  }
  const isPremium = e.target.checked;
  const docId = activeInspectUser.docId || activeInspectUser.uid || activeInspectUser.email;
  console.log("handleUserPremiumToggle: Toggling premium to", isPremium, "for docId =", docId, "user =", activeInspectUser);

  if (!docId) {
    console.error("handleUserPremiumToggle: docId, uid, and email are all undefined!");
    showToast("Kullanıcı kimliği bulunamadı!", "danger");
    e.target.checked = !isPremium;
    return;
  }

  try {
    const docRef = doc(db, "users", docId);
    await updateDoc(docRef, { isPremium: isPremium });
    
    showToast(`Premium durum başarıyla güncellendi: ${isPremium ? 'PRO' : 'Standart'}`, "success");
    
    // Update local cache item
    activeInspectUser.isPremium = isPremium;
    
    // Update active modal indicators
    if (isPremium) {
      els.inspectUserPremiumBadge.textContent = 'PREMIUM (PRO) ÜYE';
      els.inspectUserPremiumBadge.className = 'premium-badge-status premium';
      els.inspectToggleStatusLabel.textContent = 'Premium / Aktif';
      els.inspectToggleStatusLabel.className = 'toggle-status-label premium-active';
    } else {
      els.inspectUserPremiumBadge.textContent = 'STANDART ÜYE';
      els.inspectUserPremiumBadge.className = 'premium-badge-status';
      els.inspectToggleStatusLabel.textContent = 'Standart';
      els.inspectToggleStatusLabel.className = 'toggle-status-label';
    }

    await refreshAllData();
    renderUsersList();
  } catch (err) {
    console.error("Error updating user premium status:", err);
    showToast("Premium durum güncellenirken hata oluştu!", "danger");
    e.target.checked = !isPremium; // Revert
  }
}


// ==================== TAB 7: BİLDİRİM GÖNDER ====================
function renderBildirimGonder() {
  renderNotificationsList();
}

function renderNotificationsList() {
  if (!els.notificationsTableBody) return;
  els.notificationsTableBody.innerHTML = '';
  const list = cache.announcements || [];

  if (list.length === 0) {
    els.notificationsTableBody.innerHTML = `<tr><td colspan="3" style="text-align: center;" class="text-muted">Henüz gönderilmiş bildirim bulunmuyor.</td></tr>`;
    return;
  }

  // Show last 5 notifications
  list.slice(0, 5).forEach(notif => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><strong>${escapeHTML(notif.title || '')}</strong></td>
      <td><div style="max-width: 300px; white-space: normal; word-break: break-all;">${escapeHTML(notif.body || '')}</div></td>
      <td><span class="text-muted" style="font-size:12px; white-space:nowrap;">${formatDate(notif.sentAt)}</span></td>
    `;
    els.notificationsTableBody.appendChild(tr);
  });
}

async function handleSendNotification(e) {
  e.preventDefault();
  const title = els.notifTitle.value.trim();
  const body = els.notifBody.value.trim();

  if (!title || !body) {
    showToast("Lütfen tüm alanları doldurun!", "warning");
    return;
  }

  // Confirmation dialog
  if (!confirm("Bu bildirimi tüm kullanıcılara göndermek istediğinizden emin misiniz?")) {
    return;
  }

  const btn = document.getElementById('btn-send-notification');
  const originalHtml = btn.innerHTML;
  btn.disabled = true;
  btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Gönderiliyor...`;

  const newId = Date.now();
  const announcementDoc = {
    id: newId,
    title: title,
    body: body,
    sentAt: new Date().toISOString()
  };

  try {
    // Save to Firestore 'announcements' using newId as document name
    await setDoc(doc(db, "announcements", newId.toString()), announcementDoc);
    
    showToast("Bildirim başarıyla gönderildi ve yayına alındı.", "success");
    els.notifTitle.value = '';
    els.notifBody.value = '';
    
    await refreshAllData();
    renderNotificationsList();
  } catch (err) {
    console.error("Error sending notification:", err);
    showToast("Bildirim gönderilirken hata oluştu!", "danger");
  } finally {
    btn.disabled = false;
    btn.innerHTML = originalHtml;
  }
}
