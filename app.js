// Namaz Vakitleri & Dini Bilgiler - Ana Uygulama Kontrolörü

import { VAKTIN_AYETLERI, VAKTIN_HADISLERI, GUNUN_ISIMLERI, OFFLINE_VAKITLER } from './data.js';
import { setupTools } from './tools.js';

function normalizeString(str) {
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
    .replace(/[^a-z0-9]/g, '')
    .trim();
}

class NamazApp {
  constructor() {
    this.initDatabase();
    // Real-time synchronization
    this.initSync();
    if (this.checkUserBlock()) return;
    this.currentTab = 'vakitler';
    this.selectedLocation = JSON.parse(localStorage.getItem('user_location') || 'null');
    this.prayerTimes = JSON.parse(localStorage.getItem('prayer_times') || 'null');
    this.timerInterval = null;
    this.theme = localStorage.getItem('theme') || 'system';

    // Dom elements
    this.initDOMElements();
    this.initTheme();
    this.bindEvents();

    // Check onboarding
    if (!this.selectedLocation) {
      this.showOnboarding();
    } else {
      this.startApp();
    }
  }

  initDOMElements() {
    this.tabVakitler = document.getElementById('tab-vakitler');
    this.tabAraclar = document.getElementById('tab-araclar');
    this.tabAyarlar = document.getElementById('tab-ayarlar');

    this.navVakitler = document.getElementById('nav-vakitler');
    this.navAraclar = document.getElementById('nav-araclar');
    this.navAyarlar = document.getElementById('nav-ayarlar');

    this.loader = document.getElementById('app-loader');
  }

  initTheme() {
    if (this.theme === 'dark' || (this.theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.body.classList.add('dark-mode');
    } else {
      document.body.classList.remove('dark-mode');
    }
  }

  bindEvents() {
    // Navigation events
    this.navVakitler.addEventListener('click', () => this.switchTab('vakitler'));
    this.navAraclar.addEventListener('click', () => this.switchTab('araclar'));
    this.navAyarlar.addEventListener('click', () => this.switchTab('ayarlar'));

    // Developer message banner redirect
    const devBanner = document.getElementById('dev-message-banner');
    if (devBanner) {
      devBanner.addEventListener('click', () => {
        this.switchTab('ayarlar');
        setTimeout(() => {
          this.openPremiumModal();
        }, 100);
      });
    }
  }

  showLoader(show) {
    if (show) {
      this.loader.classList.add('active');
    } else {
      this.loader.classList.remove('active');
    }
  }

  switchTab(tab) {
    this.currentTab = tab;
    
    // Active navigation style
    this.navVakitler.classList.remove('active');
    this.navAraclar.classList.remove('active');
    this.navAyarlar.classList.remove('active');

    this.tabVakitler.style.display = 'none';
    this.tabAraclar.style.display = 'none';
    this.tabAyarlar.style.display = 'none';

    if (tab === 'vakitler') {
      this.navVakitler.classList.add('active');
      this.tabVakitler.style.display = 'block';
      this.renderVakitlerScreen();
    } else if (tab === 'araclar') {
      this.navAraclar.classList.add('active');
      this.tabAraclar.style.display = 'block';
      setupTools(this.tabAraclar, (title, body, type) => this.showNotification(title, body, type));
    } else if (tab === 'ayarlar') {
      this.navAyarlar.classList.add('active');
      this.tabAyarlar.style.display = 'block';
      this.renderAyarlarScreen();
    }
  }

  async startApp() {
    this.showLoader(true);
    // Try refreshing prayer times if they are old
    await this.loadPrayerTimes();
    this.showLoader(false);
    this.switchTab('vakitler');
    this.startCountdown();
  }

  async loadPrayerTimes() {
    if (!this.selectedLocation) return;
    const { ilceId } = this.selectedLocation;

    // Check cache
    const cachedDate = localStorage.getItem('prayer_times_fetch_date');
    const todayStr = new Date().toISOString().split('T')[0];

    if (this.prayerTimes && cachedDate === todayStr) {
      return; // Loaded from cache
    }

    try {
      // API call to ezanvakti API
      const res = await fetch(`https://ezanvakti.emushaf.net/vakitler/${ilceId}`);
      if (!res.ok) throw new Error('API error');
      const data = await res.json();
      if (Array.isArray(data) && data.length > 0) {
        this.prayerTimes = data;
        localStorage.setItem('prayer_times', JSON.stringify(data));
        localStorage.setItem('prayer_times_fetch_date', todayStr);
      }
    } catch (e) {
      console.warn('API error, falling back to offline or cached data', e);
      // Fallback
      if (!this.prayerTimes) {
        this.prayerTimes = OFFLINE_VAKITLER["9541"] || [];
      }
    }
  }

  // ONBOARDING (WELCOME & LOCATION SELECTOR & PROFILE SETUP)
  async showOnboarding() {
    const overlay = document.createElement('div');
    overlay.className = 'onboarding-overlay active';
    
    // Check existing values for profile/onboarding fields
    const existingName = localStorage.getItem('user_name') || '';
    const existingGender = localStorage.getItem('user_gender') || 'erkek';
    const hasProfile = existingName !== '';

    overlay.innerHTML = `
      <div class="onboarding-card">
        <!-- STEP 1: WELCOME & PROFILE -->
        <div id="onboarding-step-1" style="display: ${hasProfile ? 'none' : 'block'};">
          <div class="onboarding-header">
            <div style="font-size: 50px; margin-bottom: 10px;">🕌</div>
            <h2>Ezan Vakitleri</h2>
            <p>Uygulamamıza hoş geldiniz! Size özel bir deneyim sunabilmemiz için lütfen profil bilgilerinizi giriniz.</p>
          </div>
          
          <div class="onboarding-body">
            <div class="form-group">
              <label>Adınız Soyadınız:</label>
              <input type="text" id="onb-name" class="form-control-styled" style="width: 100%;" placeholder="Örn: Ahmet Yılmaz" value="${existingName}">
            </div>
            
            <div class="form-group" style="margin-top: 15px;">
              <label>Cinsiyetiniz (Rehber uyumu için):</label>
              <div class="gender-selector">
                <button type="button" class="gender-option ${existingGender === 'erkek' ? 'active' : ''}" id="onb-gender-male">
                  👨 Erkek
                </button>
                <button type="button" class="gender-option ${existingGender === 'kadin' ? 'active' : ''} kadin" id="onb-gender-female">
                  👩 Kadın
                </button>
              </div>
            </div>

            <div class="onboarding-steps" style="margin-top: 30px;">
              <span class="onboarding-step-dot active"></span>
              <span class="onboarding-step-dot"></span>
              <span class="onboarding-step-dot"></span>
            </div>

            <button class="btn btn-primary ripple w-100" id="btn-step1-next" style="margin-top:10px; width:100%;">
              Sonraki Adım ➡️
            </button>
          </div>
        </div>

        <!-- STEP 2: PERMISSIONS -->
        <div id="onboarding-step-2" style="display: none;">
          <div class="onboarding-header">
            <div style="font-size: 50px; margin-bottom: 10px;">🛡️</div>
            <h2>İzinleri Yapılandır</h2>
            <p>Uygulamanın tam işlevsel çalışabilmesi için lütfen aşağıdaki izinleri etkinleştirin.</p>
          </div>
          
          <div class="onboarding-body" style="text-align: left;">
            <div class="permission-box" id="perm-box-gps">
              <div class="permission-icon">🛰️</div>
              <div class="permission-info">
                <div class="permission-title">Konum İzni</div>
                <div class="permission-desc">Bulunduğunuz konuma en yakın camileri tespit etmek ve namaz vakitlerini milisaniyelik doğrulukla hesaplamak için kullanılır.</div>
              </div>
              <button class="permission-action-btn" id="btn-perm-gps">İzin Ver</button>
            </div>

            <div class="permission-box" id="perm-box-notify">
              <div class="permission-icon">🔔</div>
              <div class="permission-info">
                <div class="permission-title">Bildirim İzni</div>
                <div class="permission-desc">Ezan vakitlerinde ezan sesi/alarm çalmak, günlük hadis, ayet ve günün tebrik kartı bildirimlerini göndermek için kullanılır.</div>
              </div>
              <button class="permission-action-btn" id="btn-perm-notify">İzin Ver</button>
            </div>

            <div class="onboarding-steps" style="margin-top: 30px;">
              <span class="onboarding-step-dot"></span>
              <span class="onboarding-step-dot active"></span>
              <span class="onboarding-step-dot"></span>
            </div>

            <button class="btn btn-primary ripple w-100" id="btn-step2-next" style="margin-top:10px; width:100%;">
              Sonraki Adım ➡️
            </button>
          </div>
        </div>

        <!-- STEP 3: LOCATION SELECTION -->
        <div id="onboarding-step-3" style="display: ${hasProfile ? 'block' : 'none'};">
          <div class="onboarding-header">
            <div style="font-size: 50px; margin-bottom: 10px;">📍</div>
            <h2>Konum Seçimi</h2>
            <p>Ezan vakitlerini Diyanet İşleri Başkanlığı'ndan doğru çekebilmemiz için bulunduğunuz konumu seçin.</p>
          </div>
          
          <div class="onboarding-body">
            <div class="form-group">
              <button class="btn btn-primary ripple w-100" id="btn-gps" style="width:100%; display:flex; justify-content:center; align-items:center; gap:8px; background-color:#27a770;">
                🛰️ Konumumu Otomatik Bul (GPS)
              </button>
              <div style="text-align:center; font-size:12px; color:#888; margin:12px 0;">veya listeden manuel seçin:</div>
            </div>

            <div class="form-group">
              <label>Şehir (İl):</label>
              <select class="form-control-styled" id="select-city" style="width:100%;">
                <option value="">Şehir Seçin...</option>
              </select>
            </div>

            <div class="form-group" style="margin-top:12px;">
              <label>İlçe:</label>
              <select class="form-control-styled" id="select-district" style="width:100%;" disabled>
                <option value="">Önce Şehir Seçin...</option>
              </select>
            </div>

            <div class="onboarding-steps" style="margin-top: 30px;">
              <span class="onboarding-step-dot"></span>
              <span class="onboarding-step-dot"></span>
              <span class="onboarding-step-dot active"></span>
            </div>

            <div style="display: flex; gap: 8px;">
              <button class="btn btn-secondary ripple" id="btn-step3-back" style="flex: 1; padding: 12px 10px;">⬅ Geri</button>
              <button class="btn btn-primary ripple" id="btn-onboarding-save" style="flex: 2;" disabled>
                Uygulamaya Giriş Yap 🕋
              </button>
            </div>
          </div>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);

    // Step DOM elements
    const step1 = overlay.querySelector('#onboarding-step-1');
    const step2 = overlay.querySelector('#onboarding-step-2');
    const step3 = overlay.querySelector('#onboarding-step-3');

    const nameInput = overlay.querySelector('#onb-name');
    const maleBtn = overlay.querySelector('#onb-gender-male');
    const femaleBtn = overlay.querySelector('#onb-gender-female');
    const step1Next = overlay.querySelector('#btn-step1-next');

    const permGpsBtn = overlay.querySelector('#btn-perm-gps');
    const permNotifyBtn = overlay.querySelector('#btn-perm-notify');
    const step2Next = overlay.querySelector('#btn-step2-next');

    const selectCity = overlay.querySelector('#select-city');
    const selectDistrict = overlay.querySelector('#select-district');
    const saveBtn = overlay.querySelector('#btn-onboarding-save');
    const gpsBtn = overlay.querySelector('#btn-gps');
    const step3Back = overlay.querySelector('#btn-step3-back');

    // Onboarding State
    let selectedGender = existingGender;

    // STEP 1 EVENTS
    maleBtn.addEventListener('click', () => {
      selectedGender = 'erkek';
      maleBtn.classList.add('active');
      femaleBtn.classList.remove('active');
    });

    femaleBtn.addEventListener('click', () => {
      selectedGender = 'kadin';
      femaleBtn.classList.add('active');
      maleBtn.classList.remove('active');
    });

    step1Next.addEventListener('click', () => {
      const name = nameInput.value.trim();
      if (!name) {
        alert('Lütfen adınızı giriniz.');
        return;
      }
      localStorage.setItem('user_name', name);
      localStorage.setItem('user_gender', selectedGender);
      
      step1.style.display = 'none';
      step2.style.display = 'block';
    });

    // STEP 2 EVENTS
    // Check existing permissions and style accordingly
    if (Notification.permission === 'granted') {
      permNotifyBtn.textContent = '✓ Etkin';
      permNotifyBtn.className = 'permission-action-btn granted';
      overlay.querySelector('#perm-box-notify').classList.add('granted');
    }
    
    permNotifyBtn.addEventListener('click', () => {
      if (Notification.permission === 'default') {
        Notification.requestPermission().then(permission => {
          if (permission === 'granted') {
            permNotifyBtn.textContent = '✓ Etkin';
            permNotifyBtn.className = 'permission-action-btn granted';
            overlay.querySelector('#perm-box-notify').classList.add('granted');
          }
        });
      } else if (Notification.permission === 'granted') {
        alert('Bildirim izni zaten etkinleştirilmiş.');
      } else {
        alert('Bildirim izni tarayıcı ayarlarından engellenmiş. Lütfen tarayıcı ayarlarınızdan izin verin.');
      }
    });

    permGpsBtn.addEventListener('click', () => {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (pos) => {
            permGpsBtn.textContent = '✓ Etkin';
            permGpsBtn.className = 'permission-action-btn granted';
            overlay.querySelector('#perm-box-gps').classList.add('granted');
          },
          (err) => {
            alert('Konum izni alınamadı. Manuel olarak listeden konum seçebilirsiniz.');
          },
          { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
        );
      } else {
        alert('Cihazınızda GPS desteği bulunmuyor.');
      }
    });

    step2Next.addEventListener('click', () => {
      step2.style.display = 'none';
      step3.style.display = 'block';
    });

    // STEP 3 EVENTS
    step3Back.addEventListener('click', () => {
      step3.style.display = 'none';
      step2.style.display = 'block';
    });

    this.showLoader(true);

    try {
      // Load Cities of Turkey (UlkeID = 2)
      const res = await fetch('https://ezanvakti.emushaf.net/sehirler/2');
      if (!res.ok) throw new Error();
      const cities = await res.json();
      cities.forEach(city => {
        const opt = document.createElement('option');
        opt.value = city.SehirID;
        opt.textContent = city.SehirAdi;
        selectCity.appendChild(opt);
      });
    } catch (e) {
      // Offline cities fallback
      const offlineCities = [
        { SehirID: "539", SehirAdi: "İSTANBUL" },
        { SehirID: "506", SehirAdi: "ANKARA" },
        { SehirID: "540", SehirAdi: "İZMİR" },
        { SehirID: "520", SehirAdi: "BURSA" },
        { SehirID: "507", SehirAdi: "ANTALYA" }
      ];
      offlineCities.forEach(city => {
        const opt = document.createElement('option');
        opt.value = city.SehirID;
        opt.textContent = city.SehirAdi;
        selectCity.appendChild(opt);
      });
    }

    this.showLoader(false);

    // City change event
    selectCity.addEventListener('change', async (e) => {
      const cityId = e.target.value;
      if (!cityId) {
        selectDistrict.disabled = true;
        selectDistrict.innerHTML = '<option value="">Önce Şehir Seçin...</option>';
        saveBtn.disabled = true;
        return;
      }

      this.showLoader(true);
      selectDistrict.disabled = false;
      selectDistrict.innerHTML = '<option value="">Yükleniyor...</option>';

      try {
        const res = await fetch(`https://ezanvakti.emushaf.net/ilceler/${cityId}`);
        if (!res.ok) throw new Error();
        const districts = await res.json();
        selectDistrict.innerHTML = '<option value="">İlçe Seçin...</option>';
        districts.forEach(d => {
          const opt = document.createElement('option');
          opt.value = d.IlceID;
          opt.textContent = d.IlceAdi;
          selectDistrict.appendChild(opt);
        });
      } catch (err) {
        // Fallback
        selectDistrict.innerHTML = `
          <option value="">İlçe Seçin...</option>
          <option value="9541">MERKEZ</option>
        `;
      }
      this.showLoader(false);
    });

    selectDistrict.addEventListener('change', (e) => {
      saveBtn.disabled = !e.target.value;
    });

    // Save location configuration
    const saveLocation = async (cityText, districtText, ilceId) => {
      this.selectedLocation = {
        city: cityText,
        district: districtText,
        ilceId: ilceId
      };
      localStorage.setItem('user_location', JSON.stringify(this.selectedLocation));
      overlay.classList.remove('active');
      setTimeout(() => overlay.remove(), 300);
      await this.startApp();
    };

    saveBtn.addEventListener('click', () => {
      const cityText = selectCity.options[selectCity.selectedIndex].text;
      const districtText = selectDistrict.options[selectDistrict.selectedIndex].text;
      const ilceId = selectDistrict.value;
      saveLocation(cityText, districtText, ilceId);
    });

    // Geolocation trigger with smart Diyanet matching using BigDataCloud Geocoding
    gpsBtn.addEventListener('click', () => {
      if (navigator.geolocation) {
        this.showLoader(true);
        navigator.geolocation.getCurrentPosition(
          async (pos) => {
            const lat = pos.coords.latitude;
            const lon = pos.coords.longitude;
            
            try {
              // Call free BigDataCloud reverse geocoding API in Turkish
              const geoRes = await fetch(`https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lon}&localityLanguage=tr`);
              if (!geoRes.ok) throw new Error('Geocoding API error');
              
              const geoData = await geoRes.json();
              
              // Extract all administrative levels and normalize names
              const adminList = geoData.localityInfo?.administrative || [];
              const normalizedGeoNames = adminList.map(item => normalizeString(item.name));
              
              // Add other generic subdivision and city fields
              if (geoData.city) normalizedGeoNames.push(normalizeString(geoData.city));
              if (geoData.locality) normalizedGeoNames.push(normalizeString(geoData.locality));
              if (geoData.principalSubdivision) normalizedGeoNames.push(normalizeString(geoData.principalSubdivision));
              
              // Load cities list
              const citiesRes = await fetch('https://ezanvakti.emushaf.net/sehirler/2');
              if (!citiesRes.ok) throw new Error();
              const cities = await citiesRes.json();
              
              // Find matching city
              let matchedCity = cities.find(city => {
                const normCity = normalizeString(city.SehirAdi);
                return normalizedGeoNames.includes(normCity);
              });
              
              if (!matchedCity && geoData.principalSubdivision) {
                // Fallback to strict principal subdivision check
                const normSub = normalizeString(geoData.principalSubdivision);
                matchedCity = cities.find(city => normalizeString(city.SehirAdi).includes(normSub) || normSub.includes(normalizeString(city.SehirAdi)));
              }
              
              if (!matchedCity) {
                // Fallback to Istanbul if not resolved
                matchedCity = { SehirID: "539", SehirAdi: "İSTANBUL" };
              }
              
              // Load districts for matching city
              const districtsRes = await fetch(`https://ezanvakti.emushaf.net/ilceler/${matchedCity.SehirID}`);
              if (!districtsRes.ok) throw new Error();
              const districts = await districtsRes.json();
              
              // Find matching district
              let matchedDistrict = districts.find(d => {
                const normDist = normalizeString(d.IlceAdi);
                return normalizedGeoNames.includes(normDist);
              });
              
              if (!matchedDistrict) {
                // If not found, use first district (usually "MERKEZ")
                matchedDistrict = districts[0] || { IlceID: "9541", IlceAdi: "MERKEZ" };
              }
              
              this.showLoader(false);
              await saveLocation(matchedCity.SehirAdi, matchedDistrict.IlceAdi, matchedDistrict.IlceID);
              this.showNotification("Konum Belirlendi", `GPS ile konumunuz ${matchedCity.SehirAdi}/${matchedDistrict.IlceAdi} olarak ayarlandı.`, "default");
            } catch (err) {
              console.error(err);
              this.showLoader(false);
              // Fallback to Fatih/Istanbul on error
              await saveLocation("İSTANBUL", "İSTANBUL", "9541");
              this.showNotification("Konum Belirlendi", "GPS konumunuza göre İstanbul/Fatih vakitleri yüklendi.", "default");
            }
          },
          (err) => {
            this.showLoader(false);
            alert("Konum izni reddedildi veya konum alınamadı. Lütfen listeden manuel olarak seçin.");
          },
          { 
            enableHighAccuracy: true, 
            timeout: 10000, 
            maximumAge: 0 
          }
        );
      } else {
        alert("Cihazınızda GPS desteği bulunmuyor.");
      }
    });
  }

  // SCREEN 1: VAKITLER (MAIN SCREEN)
  renderVakitlerScreen() {
    if (!this.prayerTimes) return;

    // Get current day vakitler
    const today = new Date();
    const todayStr = this.getFormattedDate(today);

    // Find in prayer times list
    let todayTimes = this.prayerTimes.find(t => t.MiladiTarihKisa === todayStr);
    
    // If not found, use first element as mock
    if (!todayTimes && this.prayerTimes.length > 0) {
      todayTimes = this.prayerTimes[0];
    }

    if (!todayTimes) return;

    // Dates
    const gregDateEl = document.getElementById('vakitler-gregorian-date');
    const hijriDateEl = document.getElementById('vakitler-hijri-date');
    const locationEl = document.getElementById('vakitler-location');

    locationEl.textContent = `${this.selectedLocation.city}/${this.selectedLocation.district}`;
    gregDateEl.textContent = todayTimes.MiladiTarihUzun.split(' ')[0] + ' ' + todayTimes.MiladiTarihUzun.split(' ')[1] + ' ' + todayTimes.MiladiTarihUzun.split(' ')[2]; // e.g. "21 Mayıs 2026"
    hijriDateEl.textContent = todayTimes.HicriTarihUzun;

    // Change Location Clickable Text
    const changeLocBtn = document.getElementById('vakitler-change-location');
    changeLocBtn.onclick = () => {
      if (confirm('Konumunuzu değiştirmek istiyor musunuz?')) {
        this.showOnboarding();
      }
    };

    // Render horizontal prayer times grid
    const items = [
      { name: 'İmsak', key: 'Imsak', time: todayTimes.Imsak, color: '#333' },
      { name: 'Güneş', key: 'Gunes', time: todayTimes.Gunes, color: '#f57c00' },
      { name: 'Öğle', key: 'Ogle', time: todayTimes.Ogle, color: '#333' },
      { name: 'İkindi', key: 'Ikindi', time: todayTimes.Ikindi, color: '#333' },
      { name: 'Akşam', key: 'Aksam', time: todayTimes.Aksam, color: '#333' },
      { name: 'Yatsı', key: 'Yatsi', time: todayTimes.Yatsi, color: '#333' }
    ];

    const prayerTimesGrid = document.getElementById('vakitler-times-grid');
    prayerTimesGrid.innerHTML = '';

    // Determine current/next prayer to highlight
    const now = new Date();
    const nowTimeStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    let nextIndex = 0;

    for (let i = 0; i < items.length; i++) {
      if (nowTimeStr < items[i].time) {
        nextIndex = i;
        break;
      }
      if (i === items.length - 1) {
        nextIndex = 0; // After Isha, next is Imsak
      }
    }

    items.forEach((item, index) => {
      const isCurrent = index === (nextIndex === 0 ? 5 : nextIndex - 1);
      const card = document.createElement('div');
      card.className = `vakit-time-card ${isCurrent ? 'active' : ''}`;
      
      card.innerHTML = `
        <div class="vakit-name" style="color: ${isCurrent ? '#27a770' : item.name === 'Güneş' ? '#f57c00' : '#888'}">${item.name}</div>
        <div class="vakit-time-val">${item.time}</div>
      `;
      prayerTimesGrid.appendChild(card);
    });

    // Content cards
    // 1. Vaktin Ayeti (using index of date to rotate)
    const dayOfMonth = today.getDate();
    const ayet = VAKTIN_AYETLERI[dayOfMonth % VAKTIN_AYETLERI.length];
    document.getElementById('ayet-title').textContent = ayet.title;
    document.getElementById('ayet-text').textContent = ayet.text;

    // 2. Vaktin Hadisi
    const hadis = VAKTIN_HADISLERI[dayOfMonth % VAKTIN_HADISLERI.length];
    document.getElementById('hadis-title').textContent = hadis.title;
    document.getElementById('hadis-text').textContent = hadis.text;

    // 3. Günün İsimleri
    const isimler = GUNUN_ISIMLERI[dayOfMonth % GUNUN_ISIMLERI.length];
    document.getElementById('isimler-kiz').textContent = isimler.kiz;
    document.getElementById('isimler-erkek').textContent = isimler.erkek;

    // Interactive Buttons in main screen
    const monthlyCalendarBtn = document.getElementById('btn-monthly-calendar');
    monthlyCalendarBtn.onclick = () => {
      this.openMonthlyCalendarModal();
    };

    const adhanNotificationsBtn = document.getElementById('btn-adhan-notifications');
    adhanNotificationsBtn.onclick = () => {
      this.openNotificationSettingsModal();
    };

    // Render dynamic stories/actions row
    const storiesRow = document.querySelector('.circular-actions-row');
    if (storiesRow) {
      storiesRow.innerHTML = '';
      const stories = JSON.parse(localStorage.getItem('stories_list') || '[]');
      const activeStories = stories.filter(s => s.aktif).sort((a, b) => a.sira - b.sira);
      
      activeStories.forEach(story => {
        const item = document.createElement('div');
        item.className = 'circle-action-item';
        item.id = `action-${story.id}`;
        
        // Handle images/SVGs or simple initials
        let imgTag = '';
        if (story.resim) {
          imgTag = `<img src="${story.resim}" alt="${story.baslik}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">`;
        } else {
          // Initials fallback
          const initials = story.baslik.substring(0, 2).toUpperCase();
          imgTag = `<div style="width:100%; height:100%; display:flex; justify-content:center; align-items:center; background:#27a770; color:#fff; font-weight:bold; font-size:16px; border-radius:50%;">${initials}</div>`;
        }

        item.innerHTML = `
          <div class="circle-action-img" style="width: 56px; height: 56px; border-radius: 50%; overflow: hidden; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 10px rgba(0,0,0,0.1); border: 2px solid #fff;">
            ${imgTag}
          </div>
          <div class="circle-action-text" style="font-size: 11px; margin-top: 6px; text-align: center; color: var(--text-primary); font-weight: 500;">${story.baslik}</div>
        `;
        
        item.onclick = () => {
          if (story.id === 'dini-danisman') {
            this.switchTab('araclar');
            setTimeout(() => {
              const card = document.querySelector('.tool-card[id*="soru-cevap"]');
              if (card) card.click();
            }, 100);
          } else if (story.id === 'mekke') {
            this.openKaabaCamModal();
          } else if (story.id === 'ramazan') {
            this.switchTab('araclar');
            setTimeout(() => {
              const card = document.querySelector('.tool-card[id*="ramazan"]');
              if (card) card.click();
            }, 100);
          } else if (story.id === 'tebrik') {
            this.openTebrikModal();
          } else {
            // Custom admin-created story
            this.openCustomStoryModal(story);
          }
        };
        
        storiesRow.appendChild(item);
      });
    }
  }

  // CLOCK COUNTDOWN
  startCountdown() {
    if (this.timerInterval) clearInterval(this.timerInterval);

    const updateTimer = () => {
      if (!this.prayerTimes) return;

      const today = new Date();
      const todayStr = this.getFormattedDate(today);

      let todayTimes = this.prayerTimes.find(t => t.MiladiTarihKisa === todayStr);
      if (!todayTimes && this.prayerTimes.length > 0) {
        todayTimes = this.prayerTimes[0];
      }

      if (!todayTimes) return;

      const times = [
        { name: 'İmsak', time: todayTimes.Imsak },
        { name: 'Güneş', time: todayTimes.Gunes },
        { name: 'Öğle', time: todayTimes.Ogle },
        { name: 'İkindi', time: todayTimes.Ikindi },
        { name: 'Akşam', time: todayTimes.Aksam },
        { name: 'Yatsı', time: todayTimes.Yatsi }
      ];

      const now = new Date();
      const currentSeconds = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds();
      
      let nextVakit = null;
      let diffSeconds = 0;
      let prevVakitTime = 0;

      for (let i = 0; i < times.length; i++) {
        const [h, m] = times[i].time.split(':').map(Number);
        const vakitSeconds = h * 3600 + m * 60;
        
        if (currentSeconds < vakitSeconds) {
          nextVakit = times[i];
          diffSeconds = vakitSeconds - currentSeconds;
          
          if (i > 0) {
            const [ph, pm] = times[i-1].time.split(':').map(Number);
            prevVakitTime = ph * 3600 + pm * 60;
          } else {
            // Previous was Isha of yesterday
            const [ph, pm] = times[5].time.split(':').map(Number);
            prevVakitTime = ph * 3600 + pm * 60 - 86400; // negative seconds representing yesterday
          }
          break;
        }
      }

      // If no next vakit found today, next is tomorrow's Imsak
      if (!nextVakit) {
        nextVakit = { name: 'İmsak', time: times[0].time };
        const [h, m] = times[0].time.split(':').map(Number);
        const vakitSeconds = h * 3600 + m * 60 + 86400; // tomorrow
        diffSeconds = vakitSeconds - currentSeconds;
        
        const [ph, pm] = times[5].time.split(':').map(Number);
        prevVakitTime = ph * 3600 + pm * 60;
      }

      // Format Countdown string
      const hrs = Math.floor(diffSeconds / 3600);
      const mins = Math.floor((diffSeconds % 3600) / 60);
      const secs = diffSeconds % 60;

      const countdownText = `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
      
      // Update UI elements
      document.getElementById('timer-vakit-name').textContent = `${nextVakit.name} Vaktine`;
      document.getElementById('timer-countdown').textContent = countdownText;

      // Update linear progress bar
      const totalInterval = (nextVakit.name === 'İmsak' && prevVakitTime > currentSeconds) 
        ? (nextVakit.time.split(':').map(Number)[0]*3600 + nextVakit.time.split(':').map(Number)[1]*60 + 86400) - prevVakitTime
        : (nextVakit.name === 'İmsak' ? (times[0].time.split(':').map(Number)[0]*3600 + times[0].time.split(':').map(Number)[1]*60 + 86400) : (nextVakit.time.split(':').map(Number)[0]*3600 + nextVakit.time.split(':').map(Number)[1]*60)) - prevVakitTime;
      
      const elapsed = totalInterval - diffSeconds;
      const pct = Math.min(100, Math.max(0, (elapsed / totalInterval) * 100));
      document.getElementById('timer-progress-bar').style.width = `${pct}%`;

      // Check for Azan Alert trigger (when countdown hits 0)
      if (diffSeconds === 0) {
        this.triggerAdhanAlert(nextVakit.name);
      }
    };

    updateTimer();
    this.timerInterval = setInterval(updateTimer, 1000);
  }

  triggerAdhanAlert(vakitName) {
    this.showNotification("Ezan Vakti!", `${vakitName} vakti girdi. Namazınızı kılmayı unutmayın.`, "adhan");
    
    // Play sound notification if settings allowed
    if (localStorage.getItem('adhan_sound_enabled') !== 'false') {
      try {
        const audio = new Audio('https://www.soundjay.com/buttons/sounds/beep-07a.mp3'); // Fallback test beep
        audio.play();
      } catch (e) {
        console.log("Audio play error", e);
      }
    }
  }

  showNotification(title, body, type = 'default') {
    if (Notification.permission === 'granted') {
      new Notification(title, { body, icon: 'assets/dini_danisman.png' });
    } else {
      // In-app premium toast notification fallback
      const toast = document.createElement('div');
      toast.className = `app-toast ${type}`;
      toast.innerHTML = `
        <div style="font-weight:bold; font-size:14px; margin-bottom:4px;">${title}</div>
        <div style="font-size:12px;">${body}</div>
      `;
      document.body.appendChild(toast);
      setTimeout(() => toast.classList.add('active'), 100);
      setTimeout(() => {
        toast.classList.remove('active');
        setTimeout(() => toast.remove(), 400);
      }, 4000);
    }
  }

  // MONTHLY PRAYER CALENDAR MODAL
  openMonthlyCalendarModal() {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.innerHTML = `
      <div class="modal-content" style="max-width: 95%;">
        <div class="modal-header">
          <h3>Aylık Namaz Vakitleri</h3>
          <button class="modal-close-btn">&times;</button>
        </div>
        <div class="modal-body">
          <div style="overflow-x:auto;">
            <table class="table-styled">
              <thead>
                <tr>
                  <th>Tarih</th>
                  <th>İmsak</th>
                  <th>Güneş</th>
                  <th>Öğle</th>
                  <th>İkindi</th>
                  <th>Akşam</th>
                  <th>Yatsı</th>
                </tr>
              </thead>
              <tbody>
                ${this.prayerTimes.slice(0, 30).map(t => `
                  <tr>
                    <td>${t.MiladiTarihKisa}</td>
                    <td>${t.Imsak}</td>
                    <td>${t.Gunes}</td>
                    <td>${t.Ogle}</td>
                    <td>${t.Ikindi}</td>
                    <td>${t.Aksam}</td>
                    <td>${t.Yatsi}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);
    overlay.querySelector('.modal-close-btn').onclick = () => {
      overlay.classList.remove('active');
      setTimeout(() => overlay.remove(), 300);
    };
  }

  // MEKKE MODAL
  openKaabaCamModal() {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.innerHTML = `
      <div class="modal-content">
        <div class="modal-header">
          <h3>Mekke Canlı Yayını</h3>
          <button class="modal-close-btn">&times;</button>
        </div>
        <div class="modal-body" style="text-align:center;">
          <div style="position:relative; padding-bottom:56.25%; height:0; border-radius:12px; overflow:hidden; background:#000;">
            <iframe src="https://www.youtube.com/embed/g2J1rF0jB0k" style="position:absolute; top:0; left:0; width:100%; height:100%;" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
          </div>
          <p style="font-size:12px; color:#666; margin-top:10px;">Mekke-i Mükerreme Kabe-i Muazzama canlı yayın bağlantısı.</p>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);
    overlay.querySelector('.modal-close-btn').onclick = () => {
      overlay.classList.remove('active');
      setTimeout(() => overlay.remove(), 300);
    };
  }

  // TEBRIK MODAL
  openTebrikModal() {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.innerHTML = `
      <div class="modal-content">
        <div class="modal-header">
          <h3>Hayırlı Cumalar Tebriği</h3>
          <button class="modal-close-btn">&times;</button>
        </div>
        <div class="modal-body" style="text-align:center; padding:20px;">
          <img src="assets/tebrik.png" style="width:180px; border-radius:50%; box-shadow:0 8px 24px rgba(0,0,0,0.1); margin-bottom:15px;" alt="Tebrik">
          <div style="font-size:18px; font-weight:bold; color:#27a770; margin-bottom:10px;">Cumanız Mübarek Olsun</div>
          <p style="font-style:italic; font-size:14px; color:#555; line-height:1.5; padding:0 15px;">
            "Ey iman edenler! Cuma günü namaz için çağrı yapıldığı zaman hemen Allah'ı anmaya koşun ve alışverişi bırakın. Eğer bilirseniz bu sizin için daha hayırlıdır." (Cuma Suresi - 9)
          </p>
          <button class="btn btn-primary ripple" style="margin-top:20px;" id="btn-share-tebrik">Tebrik Kartını Paylaş</button>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);
    overlay.querySelector('.modal-close-btn').onclick = () => {
      overlay.classList.remove('active');
      setTimeout(() => overlay.remove(), 300);
    };

    overlay.querySelector('#btn-share-tebrik').onclick = () => {
      if (navigator.share) {
        navigator.share({
          title: 'Hayırlı Cumalar',
          text: 'Cumanız Mübarek Olsun!',
          url: window.location.href
        }).then(() => {
          this.showNotification("Paylaşıldı", "Tebrik mesajı başarıyla paylaşıldı.", "default");
        });
      } else {
        alert("Tarayıcınız paylaşım API'sini desteklemiyor. Tebrik kartını kopyalayabilirsiniz.");
      }
    };
  }

  // SCREEN 5: AYARLAR (SETTINGS SCREEN)
  renderAyarlarScreen() {
    const isPremium = localStorage.getItem('is_premium') === 'true';

    this.tabAyarlar.innerHTML = `
      <div class="ayarlar-header" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; border-bottom:1px solid #eee; padding-bottom:15px;">
        <h2 style="color:#27a770; margin:0;">Ayarlar</h2>
        <button class="modal-close-btn" id="btn-close-settings" style="font-size:24px; color:#27a770; border:none; background:none;">&times;</button>
      </div>

      <div class="settings-list">
        <div class="settings-card ripple" id="sett-profile">
          <div class="settings-card-icon" style="background:#eaf7f1; color:#27a770;">👤</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Profilim</div>
          </div>
        </div>

        <div class="settings-card ripple" id="sett-logout">
          <div class="settings-card-icon" style="background:#fde8e8; color:#e53e3e;">🚪</div>
          <div class="settings-card-content">
            <div class="settings-card-title" style="color:#e53e3e;">Çıkış Yap</div>
          </div>
        </div>

        ${isPremium ? `
        <div class="settings-card premium ripple" id="sett-premium" style="border: 2px solid #d4af37; background: linear-gradient(135deg, #fffdf5 0%, #fff9e6 100%);">
          <div class="settings-card-icon" style="background: #fff0b3; color: #d4af37;">👑</div>
          <div class="settings-card-content">
            <div class="settings-card-title" style="color: #b28900; font-weight: 800; display: flex; align-items: center; gap: 6px;">
              Premium Üye <span style="background: #d4af37; color: white; font-size: 9px; padding: 2px 6px; border-radius: 10px; font-weight: 800;">AKTİF</span>
            </div>
            <div class="settings-card-subtitle" style="color: #7a651a;">Geliştiriciye verdiğiniz destek için teşekkür ederiz!</div>
          </div>
        </div>
        ` : `
        <div class="settings-card premium ripple" id="sett-premium">
          <div class="settings-card-icon">⭐</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Premium Ol</div>
            <div class="settings-card-subtitle">Tüm özelliklere erişim, daha fazla müslümana ulaşmamıza yardım et!</div>
          </div>
        </div>

        <div class="settings-card premium-sec ripple" id="sett-noads">
          <div class="settings-card-icon">🚫</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Reklamlardan ücretsiz kurtul!</div>
            <div class="settings-card-subtitle">Sadece 30 saniyenizi ayırın.</div>
          </div>
        </div>
        `}

        <div class="settings-card ripple" id="sett-language">
          <div class="settings-card-icon" style="background:#eef2f6; color:#475569;">🌐</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Uygulama Dili</div>
          </div>
          <span class="settings-badge" style="color:#ffa200;">Türkçe</span>
        </div>

        <div class="settings-card ripple" id="sett-notifications">
          <div class="settings-card-icon" style="background:#eaf7f1; color:#27a770;">🔔</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Bildirim Ayarları</div>
            <div class="settings-card-subtitle" style="color:#27a770;">Ezan vakti bildirimlerini yönet</div>
          </div>
          <span class="settings-arrow">▶️</span>
        </div>

        <div class="settings-card ripple" id="sett-locations">
          <div class="settings-card-icon" style="background:#eaf7f1; color:#27a770;">📍</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Lokasyonlarım</div>
          </div>
        </div>

        <div class="settings-card ripple" id="sett-theme">
          <div class="settings-card-icon" style="background:#eef2f6; color:#475569;">🎨</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Tema Ayarları</div>
          </div>
          <span class="settings-badge" style="color:#ffa200;" id="theme-badge-text">${this.theme === 'system' ? 'Sistem' : this.theme === 'dark' ? 'Karanlık' : 'Aydınlık'}</span>
        </div>

        <div class="settings-card ripple" id="sett-kerahat">
          <div class="settings-card-icon" style="background:#eaf7f1; color:#27a770;">⏳</div>
          <div class="settings-card-content">
            <div class="settings-card-title">Kerahat Vakti</div>
          </div>
          <span class="settings-badge" style="color:#ffa200;">45 dk</span>
        </div>
      </div>

      <div style="text-align:center; padding:30px 10px 15px 10px; font-size:12px; color:#888;">
        <a href="#" style="color:#27a770; text-decoration:none; font-weight:bold; display:block; margin-bottom:8px;">Gizlilik Politikası</a>
        v4.7.4
      </div>
    `;

    // Hook settings events
    const closeBtn = this.tabAyarlar.querySelector('#btn-close-settings');
    closeBtn.onclick = () => this.switchTab('vakitler');

    const profileBtn = this.tabAyarlar.querySelector('#sett-profile');
    profileBtn.onclick = () => {
      const currentName = localStorage.getItem('user_name') || '';
      const currentGender = localStorage.getItem('user_gender') || 'erkek';
      
      const overlay = document.createElement('div');
      overlay.className = 'modal-overlay active';
      overlay.innerHTML = `
        <div class="modal-content">
          <div class="modal-header">
            <h3>Profilimi Düzenle</h3>
            <button class="modal-close-btn">&times;</button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label>Adınız:</label>
              <input type="text" id="edit-profile-name" class="form-control-styled" value="${currentName}" style="width:100%;">
            </div>
            <div class="form-group" style="margin-top:12px;">
              <label>Cinsiyetiniz (Rehber uyumu için):</label>
              <div class="gender-selector" style="margin-top:5px;">
                <button class="gender-option ${currentGender === 'erkek' ? 'active' : ''}" id="edit-gender-erkek">
                  👨 Erkek
                </button>
                <button class="gender-option ${currentGender === 'kadin' ? 'active' : ''} kadin" id="edit-gender-kadin">
                  👩 Kadın
                </button>
              </div>
            </div>
            <button class="btn btn-primary ripple w-100" id="btn-save-profile" style="margin-top:20px; width:100%;">
              Değişiklikleri Kaydet
            </button>
          </div>
        </div>
      `;
      document.body.appendChild(overlay);
      
      let selectedGender = currentGender;
      const maleBtn = overlay.querySelector('#edit-gender-erkek');
      const femaleBtn = overlay.querySelector('#edit-gender-kadin');
      
      maleBtn.onclick = () => {
        selectedGender = 'erkek';
        maleBtn.classList.add('active');
        femaleBtn.classList.remove('active');
      };
      
      femaleBtn.onclick = () => {
        selectedGender = 'kadin';
        femaleBtn.classList.add('active');
        maleBtn.classList.remove('active');
      };
      
      overlay.querySelector('.modal-close-btn').onclick = () => {
        overlay.classList.remove('active');
        setTimeout(() => overlay.remove(), 300);
      };
      
      overlay.querySelector('#btn-save-profile').onclick = () => {
        const name = overlay.querySelector('#edit-profile-name').value.trim();
        if (!name) {
          alert('Lütfen adınızı boş bırakmayın.');
          return;
        }
        localStorage.setItem('user_name', name);
        localStorage.setItem('user_gender', selectedGender);
        this.showNotification("Profil Güncellendi", "Değişiklikler başarıyla kaydedildi.", "default");
        overlay.classList.remove('active');
        setTimeout(() => overlay.remove(), 300);
        this.renderAyarlarScreen();
      };
    };

    const logoutBtn = this.tabAyarlar.querySelector('#sett-logout');
    logoutBtn.onclick = () => {
      if (confirm('Uygulamadan çıkış yapmak ve verilerinizi sıfırlamak istiyor musunuz?')) {
        localStorage.clear();
        window.location.reload();
      }
    };

    const premiumBtn = this.tabAyarlar.querySelector('#sett-premium');
    premiumBtn.onclick = () => {
      if (isPremium) {
        this.showNotification("Premium Üyelik Aktif", "Geliştiriciye verdiğiniz destek için teşekkür ederiz!", "default");
      } else {
        this.openPremiumModal();
      }
    };

    const noAdsBtn = this.tabAyarlar.querySelector('#sett-noads');
    if (noAdsBtn) {
      noAdsBtn.onclick = () => {
        this.openPremiumModal();
      };
    }

    const notificationBtn = this.tabAyarlar.querySelector('#sett-notifications');
    notificationBtn.onclick = () => this.openNotificationSettingsModal();

    const locationBtn = this.tabAyarlar.querySelector('#sett-locations');
    locationBtn.onclick = () => this.showOnboarding();

    const themeBtn = this.tabAyarlar.querySelector('#sett-theme');
    themeBtn.onclick = () => {
      // Toggle theme (system -> light -> dark -> system)
      if (this.theme === 'system') {
        this.theme = 'light';
      } else if (this.theme === 'light') {
        this.theme = 'dark';
      } else {
        this.theme = 'system';
      }
      localStorage.setItem('theme', this.theme);
      this.initTheme();
      this.tabAyarlar.querySelector('#theme-badge-text').textContent = this.theme === 'system' ? 'Sistem' : this.theme === 'dark' ? 'Karanlık' : 'Aydınlık';
      this.showNotification("Tema Değiştirildi", `Uygulama teması ${this.theme === 'system' ? 'sistem ayarlarına' : this.theme} olarak ayarlandı.`, "default");
    };
  }

  // NOTIFICATION SETTINGS MODAL
  openNotificationSettingsModal() {
    // Request permission if not allowed yet
    if (Notification.permission === 'default') {
      Notification.requestPermission();
    }

    const adhanSound = localStorage.getItem('adhan_sound_enabled') !== 'false';

    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.innerHTML = `
      <div class="modal-content">
        <div class="modal-header">
          <h3>Ezan Bildirim Ayarları</h3>
          <button class="modal-close-btn">&times;</button>
        </div>
        <div class="modal-body">
          <div class="info-card" style="margin-bottom:15px; font-size:13px; color:#555;">
            Bildirimlerin zamanında gelmesi için tarayıcınızın arka planda çalışma ve bildirim izinlerinin açık olduğundan emin olun.
          </div>
          
          <div style="display:flex; justify-content:space-between; align-items:center; padding:12px 0; border-bottom:1px solid #eee;">
            <div>
              <div style="font-weight:bold; font-size:14px;">Tarayıcı Bildirim İzni</div>
              <div style="font-size:12px; color:#888;">İzin durumu: ${Notification.permission}</div>
            </div>
            <button class="btn btn-secondary ripple" id="btn-req-notify-perm" style="font-size:12px; padding:6px 12px;">İzin İste</button>
          </div>

          <div style="display:flex; justify-content:space-between; align-items:center; padding:12px 0; border-bottom:1px solid #eee;">
            <div>
              <div style="font-weight:bold; font-size:14px;">Ezan Sesi / Alarm</div>
              <div style="font-size:12px; color:#888;">Vakit girdiğinde sesli uyarı çal</div>
            </div>
            <input type="checkbox" id="chk-sound-notify" ${adhanSound ? 'checked' : ''} style="width:20px; height:20px; cursor:pointer;">
          </div>

          <button class="btn btn-primary ripple w-100" id="btn-test-notify" style="margin-top:20px; width:100%;">
            🔔 Test Bildirimi Gönder
          </button>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);

    overlay.querySelector('.modal-close-btn').onclick = () => {
      overlay.classList.remove('active');
      setTimeout(() => overlay.remove(), 300);
    };

    overlay.querySelector('#btn-req-notify-perm').onclick = () => {
      Notification.requestPermission().then(permission => {
        alert(`Bildirim izni: ${permission}`);
        overlay.remove();
        this.openNotificationSettingsModal();
      });
    };

    const soundChk = overlay.querySelector('#chk-sound-notify');
    soundChk.onchange = (e) => {
      localStorage.setItem('adhan_sound_enabled', e.target.checked);
    };

    overlay.querySelector('#btn-test-notify').onclick = () => {
      this.showNotification("Deneme Bildirimi", "Ezan vakti bildirim sisteminiz aktif ve sorunsuz çalışıyor!", "default");
    };
  }

  initDatabase() {
    // 1. Initialise Dua İste List
    if (!localStorage.getItem('dua_iste_list')) {
      const defaultDuas = [
        { id: 1, yazar: "Ahmet Y.", dua: "Hastalarımız için şifa, dertlerimiz için deva istiyoruz...", amin: 45, durum: "yayinda", tarih: "17.05.2026 01:10" },
        { id: 2, yazar: "Fatma K.", dua: "Evlatlarımızın sınavlarında başarılar dileriz, dualarınızı bekliyoruz.", amin: 12, durum: "yayinda", tarih: "17.05.2026 01:10" },
        { id: 3, yazar: "Mehmet A.", dua: "Tüm Müslümanlar için hayırlı işler diliyoruz.", amin: 28, durum: "yayinda", tarih: "17.05.2026 01:10" }
      ];
      localStorage.setItem('dua_iste_list', JSON.stringify(defaultDuas));
    }

    // 2. Initialise Günlük Dualar List
    if (!localStorage.getItem('gunluk_dualar_list')) {
      const defaultDailyDuas = [
        {
          id: 1,
          baslik: "Sabah Duası",
          kategori: "Sabah",
          sira: 1,
          aktif: true,
          dua_metni: "Allah'ım! Sabahladık ve mülk Senindir. Hamd Sana mahsustur. Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'na mahsustur. O her şeye kadirdir. Rabbim! Senden bu günün ve sonrasının hayrını dilerim. Bu günün ve sonrasının şerrinden Sana sığınırım...",
          fazilet: "Sabah namazından sonra okunması tavsiye edilir. Günün bereketli geçmesi, kötülüklerden korunma ve Allah'ın rızasını kazanmak için çok önemli bir duadır."
        },
        {
          id: 2,
          baslik: "Akşam Duası",
          kategori: "Akşam",
          sira: 2,
          aktif: true,
          dua_metni: "Allah'ım! Akşamladık ve mülk Senindir. Hamd Sana mahsustur. Allah'tan başka ilah yoktur, O tektir, ortağı yoktur. Mülk O'nundur, hamd O'na mahsustur. O her şeye kadirdir. Rabbim! Senden bu gecenin ve sonrasının hayrını dilerim. Bu gecenin ve sonrasının şerrinden Sana sığınırım...",
          fazilet: "Akşam namazından sonra okunması tavsiye edilir. Gecenin huzurlu geçmesi, kötülüklerden korunma ve Allah'ın koruması altında olmak için önemli bir duadır."
        },
        {
          id: 3,
          baslik: "Yemek Öncesi Duası",
          kategori: "Yemek",
          sira: 3,
          aktif: true,
          dua_metni: "Bismillah ve ala bereketillah. (Allah'ın adıyla ve Allah'ın bereketi üzerine)",
          fazilet: "Her yemekten önce okunması sünnettir. Yemeğin bereketli olması, harama bulaşmamış helal lokma olması için dua edilir. Peygamber Efendimiz (s.a.v) her yemekte besmele çekerdi."
        },
        {
          id: 4,
          baslik: "Yemek Sonrası Duası",
          kategori: "Yemek",
          sira: 4,
          aktif: true,
          dua_metni: "Elhamdülillahillezi et'amena ve sakana ve cealena müslimin. (Bize yedirip içiren ve bizi Müslüman kılan Allah'a hamd olsun)",
          fazilet: "Yemek sonrası şükür ifadesidir. Nimete şükretmek, nimetin devamı için çok önemlidir. Allah'ın verdiği rızka şükretmek imanın gereğidir."
        },
        {
          id: 5,
          baslik: "Uyku Öncesi Duası",
          kategori: "Uyku",
          sira: 5,
          aktif: true,
          dua_metni: "Bismike Allahümme emütü ve ahya. (Senin adınla Allah'ım, ölür ve dirilirim - uyur ve uyanırım)",
          fazilet: "Uykudan önce okunması sünnettir. Geceyi emniyet içinde geçirmek ve ruhunu Allah'a teslim ederken imanla uyumak için tavsiye edilir."
        },
        {
          id: 6,
          baslik: "Nazar Duası (Kalem 51-52)",
          kategori: "Genel",
          sira: 6,
          aktif: true,
          dua_metni: "Ve in yekâdullezîne keferû leyuzlikûneke bi ebsârihim lemmâ semiûz zikra ve yekûlûne innehu le mecnûn. Ve mâ huve illâ zikrun lil âlemîn.",
          fazilet: "Şüphesiz inkâr edenler Zikr’i (Kur’an’ı) duydukları zaman neredeyse seni gözleriyle devireceklerdi. 'O mutlaka bir delidir' diyorlar. Oysa Kur'an âlemler için bir öğüttür."
        },
        {
          id: 7,
          baslik: "Eve Girerken Okunacak Dua",
          kategori: "Genel",
          sira: 7,
          aktif: true,
          dua_metni: "Allahümme inni es'elüke hayral mevleci ve hayral mahreci bismillahi velecna.",
          fazilet: "Allah'ım! Senden hayırlı giriş ve hayırlı çıkış dilerim. Allah'ın adıyla girdik, Allah'ın adıyla çıktık."
        },
        {
          id: 8,
          baslik: "Sınava Girerken Okunacak Dua",
          kategori: "Genel",
          sira: 8,
          aktif: true,
          dua_metni: "Rabbişrah li sadri ve yessir li emri vahlul ukdeten min lisani yefkahu kavli.",
          fazilet: "Rabbim! Göğsümü genişlet, işimi kolaylaştır, dilimin düğümünü çöz ki sözümü anlasınlar."
        }
      ];
      localStorage.setItem('gunluk_dualar_list', JSON.stringify(defaultDailyDuas));
    }

    // 3. Initialise Stories List
    if (!localStorage.getItem('stories_list')) {
      const defaultStories = [
        { id: 'dini-danisman', baslik: "Dini Danışman", kategori: "Sistem", sira: 1, aktif: true, resim: "assets/dini_danisman.png", icerik: "Yapay zeka dini danışmanlık hizmeti." },
        { id: 'mekke', baslik: "Mekke", kategori: "Sistem", sira: 2, aktif: true, resim: "assets/mekke.png", icerik: "Kabe-i Muazzama canlı yayını." },
        { id: 'ramazan', baslik: "Ramazan", kategori: "Sistem", sira: 3, aktif: true, resim: "assets/ramazan.png", icerik: "Ramazan ayı oruç rehberi ve duaları." },
        { id: 'tebrik', baslik: "Tebrik", kategori: "Sistem", sira: 4, aktif: true, resim: "assets/tebrik.png", icerik: "Hayırlı Cumalar tebrik kartı paylaşımı." }
      ];
      localStorage.setItem('stories_list', JSON.stringify(defaultStories));
    }

    // 4. Initialise Users List
    if (!localStorage.getItem('users_list')) {
      const defaultUsers = [
        { adSoyad: "Ahmet Yılmaz", eposta: "ahmet@gmail.com", kayitTarihi: "12.03.2026", engelli: false },
        { adSoyad: "Fatma Kaya", eposta: "fatma.k@outlook.com", kayitTarihi: "15.03.2026", engelli: false },
        { adSoyad: "Mehmet Demir", eposta: "mehmet.d@gmail.com", kayitTarihi: "17.03.2026", engelli: false },
        { adSoyad: "Zeynep Çelik", eposta: "zeynep@hotmail.com", kayitTarihi: "18.03.2026", engelli: false },
        { adSoyad: "Ömer Şahin", eposta: "omer.s@gmail.com", kayitTarihi: "20.03.2026", engelli: false }
      ];
      localStorage.setItem('users_list', JSON.stringify(defaultUsers));
    }

    // 5. Initialise Live Chat List
    if (!localStorage.getItem('live_chat_list')) {
      const defaultChat = [
        { id: 1, yazar: "Mehmet Kaya", metin: "Selamün Aleyküm muhterem kardeşlerim, gününüz hayırlı ve bereketli geçsin inşallah.", tarih: "17.03.2026 01:10", isAdmin: false },
        { id: 2, yazar: "Fatma Şahin", metin: "Ve Aleyküm Selam Mehmet bey. Amin, cümlemizin inşallah.", tarih: "17.03.2026 01:10", isAdmin: false },
        { id: 3, yazar: "Ömer Faruk", metin: "Hayırlı akşamlar. Akşam namazını cemaatle kılan var mı aramızda? Rabbim ibadetlerimizi kabul etsin.", tarih: "17.03.2026 01:10", isAdmin: false }
      ];
      localStorage.setItem('live_chat_list', JSON.stringify(defaultChat));
    }

    // 6. Initialise Soru & Cevap List
    if (!localStorage.getItem('soru_cevap_list')) {
      const defaultQAs = [
        { id: 1, soru: "Oruçlu iken diş fırçalamak orucu bozar mı?", cevap: "Diyanet İşleri Başkanlığı'nın fetvasına göre, boğaza su kaçırmamak şartıyla macunlu veya macunsuz diş fırçalamak orucu bozmaz. Ancak macunun yutulması durumunda oruç bozulur ve kaza gerekir.", tarih: "20.05.2026 14:32", yazar: "Ahmet Yılmaz" },
        { id: 2, soru: "Kerahat vakitlerinde namaz kılınabilir mi?", cevap: "Güneşin doğuşundan sonraki ilk 45-50 dakika, güneşin tam tepede olduğu vakit ve güneş batmadan önceki 45 dakikalık sürede farz namaz kılınması mekruhtur.", tarih: "21.05.2026 10:15", yazar: "Fatma Kaya" }
      ];
      localStorage.setItem('soru_cevap_list', JSON.stringify(defaultQAs));
    }
  }

  checkUserBlock() {
    const isBlocked = localStorage.getItem('user_blocked') === 'true';
    if (isBlocked) {
      document.body.innerHTML = `
        <div style="display:flex; flex-direction:column; justify-content:center; align-items:center; height:100vh; background:#fff; color:#e53e3e; text-align:center; padding:20px; font-family:sans-serif;">
          <div style="font-size:70px; margin-bottom:20px;">🚫</div>
          <h2 style="margin-bottom:10px;">Erişiminiz Engellendi</h2>
          <p style="color:#555; font-size:14px; max-width:300px; line-height:1.5;">Kullanım şartlarını ihlal ettiğiniz için İslami Rehber uygulamasına erişiminiz yönetici tarafından engellenmiştir.</p>
        </div>
      `;
      return true;
    }
    return false;
  }

  initSync() {
    window.addEventListener('storage', (e) => {
      if (e.key === 'user_blocked') {
        const isBlocked = localStorage.getItem('user_blocked') === 'true';
        if (isBlocked) {
          this.checkUserBlock();
        } else {
          window.location.reload();
        }
      }
      
      // Guard to prevent errors if blocked screen is active
      if (localStorage.getItem('user_blocked') === 'true') return;
      
      if (e.key === 'stories_list') {
        this.renderVakitlerScreen();
      }

      if (e.key === 'is_premium') {
        if (this.currentTab === 'ayarlar') {
          this.renderAyarlarScreen();
        }
      }
    });

    // Poll global block status from server every 3 seconds
    setInterval(async () => {
      try {
        const res = await fetch('/api/block_status');
        if (res.ok) {
          const status = await res.json();
          const currentlyBlocked = localStorage.getItem('user_blocked') === 'true';
          if (status.blocked !== currentlyBlocked) {
            localStorage.setItem('user_blocked', status.blocked ? 'true' : 'false');
            if (status.blocked) {
              this.checkUserBlock();
            } else {
              window.location.reload();
            }
          }
        }
      } catch (e) {
        console.warn('Error fetching block status from server:', e);
      }
    }, 3000);
  }

  openPremiumModal() {
    const isPremium = localStorage.getItem('is_premium') === 'true';
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.id = 'modal-premium-purchase';
    overlay.style.zIndex = '2000';
    overlay.innerHTML = `
      <div class="modal-content premium-modal-content" style="max-height: 92%; overflow-y: auto; display: flex; flex-direction: column;">
        <div class="modal-header premium-modal-header" style="position: sticky; top: 0; background: var(--card-bg); z-index: 10;">
          <h3 style="color: var(--primary-color); font-weight: 800; display: flex; align-items: center; gap: 8px;">
            👑 Namaz Vakitleri Premium
          </h3>
          <button class="modal-close-btn">&times;</button>
        </div>
        
        <div class="modal-body premium-modal-body" style="padding: 15px; overflow-y: auto; flex: 1;">
          <!-- Developer Message -->
          <div class="premium-dev-message">
            <div class="premium-dev-avatar">
              <img src="assets/gelistirici.png" alt="Geliştirici">
            </div>
            <div class="premium-dev-bubble">
              <strong>Esselâmü Aleyküm Sevgili Kardeşim,</strong>
              Uygulamamızı tamamen reklamlar ve bağışlarınızla ayakta tutmaya çalışıyoruz. Premium üye olarak hem bizlere destek olabilir, hem de ibadetlerinizi daha huzurlu, reklamsız bir şekilde eda edebilirsiniz. Dualarınızda bizleri de eksik etmeyin inşallah.
              <span class="dev-sign">Geliştirici Ekip</span>
            </div>
          </div>

          <!-- Feature Comparison -->
          <div class="premium-section-title">Neler Kazanacaksınız?</div>
          <div class="premium-features-grid">
            <div class="premium-feature-item">
              <div class="feature-icon">🚫</div>
              <div class="feature-info">
                <strong>%100 Reklamsız Deneyim</strong>
                <p>Uygulama genelindeki tüm reklam banner'ları ve geçiş reklamları tamamen kaldırılır.</p>
              </div>
            </div>
            <div class="premium-feature-item">
              <div class="feature-icon">🔔</div>
              <div class="feature-info">
                <strong>Gelişmiş Vakit Bildirimleri</strong>
                <p>Ezan vakitlerinden önce hatırlatıcı alarmlar ve özelleştirilebilir ezan sesleri.</p>
              </div>
            </div>
            <div class="premium-feature-item">
              <div class="feature-icon">🤲</div>
              <div class="feature-info">
                <strong>Kişisel Dualar & Zikirler</strong>
                <p>Kendi özel dualarınızı ekleyip zikirlerinizi dilediğiniz gibi takip edebilirsiniz.</p>
              </div>
            </div>
            <div class="premium-feature-item">
              <div class="feature-icon">💬</div>
              <div class="feature-info">
                <strong>Öncelikli Soru & Cevap</strong>
                <p>Dini danışmanlık sorularınız hocalarımız tarafından en kısa sürede yanıtlanır.</p>
              </div>
            </div>
          </div>

          <!-- Plans -->
          ${isPremium ? '' : `
          <div class="premium-section-title">Bir Plan Seçin</div>
          <div class="premium-plans">
            <div class="plan-card" data-plan="monthly">
              <div class="plan-badge">Aylık</div>
              <div class="plan-price">₺24,99</div>
              <div class="plan-period">/ ay</div>
            </div>
            <div class="plan-card recommended active" data-plan="yearly">
              <div class="plan-popular-tag">EN POPÜLER</div>
              <div class="plan-badge">Yıllık</div>
              <div class="plan-price">₺149,99</div>
              <div class="plan-period">/ yıl (₺12,50/ay)</div>
            </div>
            <div class="plan-card" data-plan="lifetime">
              <div class="plan-badge">Ömür Boyu</div>
              <div class="plan-price">₺249,99</div>
              <div class="plan-period">Tek Seferlik</div>
            </div>
          </div>
          `}

          <!-- Reviews -->
          <div class="premium-section-title">Kullanıcı Yorumları</div>
          <div class="premium-reviews-container">
            <div class="premium-review-card">
              <div class="review-header">
                <strong>Ahmet T.</strong>
                <span class="review-stars">⭐⭐⭐⭐⭐</span>
              </div>
              <p>Reklamsız olması çok güzel, hem de bu güzel uygulamaya destek olabildiğim için mutluyum. Allah razı olsun.</p>
            </div>
            <div class="premium-review-card">
              <div class="review-header">
                <strong>Merve G.</strong>
                <span class="review-stars">⭐⭐⭐⭐⭐</span>
              </div>
              <p>Yıllık planı aldım, bildirim sesleri ve gelişmiş zikirmatik özellikleri çok işime yarıyor. Herkese tavsiye ederim.</p>
            </div>
          </div>

          <!-- Checkout Action Button -->
          <button class="btn btn-primary ripple w-100 premium-checkout-btn" style="margin-top: 10px; width: 100%; font-size: 16px; padding: 14px 20px; background: ${isPremium ? 'var(--primary-color)' : 'linear-gradient(135deg, #d4af37 0%, #b28900 100%)'}; color: #fff; font-weight: 800; border-radius: 16px; border: none; box-shadow: ${isPremium ? 'none' : '0 4px 15px rgba(212, 175, 55, 0.3)'};" ${isPremium ? 'disabled' : ''}>
            ${isPremium ? 'Premium Üyelik Aktif' : 'Ödemeyi Tamamla ve Premium Ol'}
          </button>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);

    overlay.querySelector('.modal-close-btn').onclick = () => {
      overlay.classList.remove('active');
      setTimeout(() => overlay.remove(), 300);
    };

    if (!isPremium) {
      const planCards = overlay.querySelectorAll('.plan-card');
      planCards.forEach(card => {
        card.onclick = () => {
          planCards.forEach(c => c.classList.remove('active'));
          card.classList.add('active');
        };
      });

      overlay.querySelector('.premium-checkout-btn').onclick = () => {
        this.showLoader(true);
        setTimeout(() => {
          this.showLoader(false);
          localStorage.setItem('is_premium', 'true');
          
          // Dispatch StorageEvent for local window to update Settings screen
          window.dispatchEvent(new StorageEvent('storage', {
            key: 'is_premium',
            newValue: 'true'
          }));
          
          this.showNotification("Premium Aktif Edildi!", "Tebrikler! Namaz Vakitleri Premium ayrıcalıklarından artık yararlanabilirsiniz.", "default");
          
          // Hide modal
          overlay.classList.remove('active');
          setTimeout(() => overlay.remove(), 300);
        }, 1500);
      };
    }
  }

  openCustomStoryModal(story) {
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.innerHTML = `
      <div class="modal-content">
        <div class="modal-header">
          <h3>${story.baslik}</h3>
          <button class="modal-close-btn">&times;</button>
        </div>
        <div class="modal-body" style="text-align:center; padding:20px;">
          ${story.resim ? `<img src="${story.resim}" style="width:100%; max-height:200px; object-fit:cover; border-radius:12px; box-shadow:0 4px 12px rgba(0,0,0,0.1); margin-bottom:15px;" alt="${story.baslik}">` : ''}
          <div style="font-size:16px; font-weight:bold; color:#27a770; margin-bottom:10px;">${story.baslik}</div>
          <p style="font-size:14px; color:#555; line-height:1.6; text-align:left; white-space:pre-wrap;">${story.icerik}</p>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);
    overlay.querySelector('.modal-close-btn').onclick = () => {
      overlay.classList.remove('active');
      setTimeout(() => overlay.remove(), 300);
    };
  }

  // Helper date utility
  getFormattedDate(date) {
    const d = String(date.getDate()).padStart(2, '0');
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const y = date.getFullYear();
    return `${d}.${m}.${y}`;
  }
}

// Start application
window.addEventListener('DOMContentLoaded', () => {
  window.appInstance = new NamazApp();
});
