# Project Progress & Context for AI Assistant

This document contains the progress, architectural details, and recent changes of the **Namaz Vakti** Flutter application. Read this first to align with the current state of development and prevent duplicate work or regression bugs.

---

## 🛠️ Tech Stack & Architecture
- **Framework:** Flutter (Android/iOS)
- **Local Storage:** `SharedPreferences` (used for selecting city, district, zikir counts, daily tracking, bookmarks, notifications, etc.)
- **State Management:** Key-based callbacks and public states for dynamic screen reloading in `MainAppContainerWrapper` (`lib/main.dart`).

---

## 🚀 Recent Implementations & Features Done

### 1. In-place Location Synchronisation (No App Restarts)
- **Problem:** Updating location previously triggered a full route replacement to `SplashScreen` or app restart.
- **Solution:** 
  - Exposed `MainScreenState` and `SettingsScreenState` by removing the private underscore prefix.
  - Exposed `loadData()` in `MainScreenState` and `loadSettings()` in `SettingsScreenState`.
  - Added a `GlobalKey` wrapper inside `MainAppContainerWrapper` (`lib/main.dart`) to trigger dynamic in-place updates.
  - Now, updating location in Home or Settings updates the other screen instantly without any app restart.

### 2. Settings Screen GPS White Screen Fix
- **Problem:** Selecting "Cihaz Konumunu Kullan" (GPS) inside the Settings screen's "Lokasyonlarım" dialog turned the screen white for 10 seconds.
- **Solution:**
  - Replaced the global `_loading = true` page-level state during location detection with a modal overlay loading dialog (`_showLoadingDialog`).
  - Correctly pops the context (`Navigator.pop`) on success or early return paths, preventing full screen state transitions.

### 3. Zikirmatik Daily Automatic Tracking
- **Problem:** Tapping zikir did not log completed dates dynamically.
- **Solution:**
  - Added `zikir_completed_dates` in SharedPreferences.
  - Tapping a dhikr automatically checks and appends the current date (`yyyy-MM-dd`) to the completed checklist and updates the UI instantly.

### 4. Main Screen Layout Modifications
- Swapped the inner icon/image for **Kur'an-ı Kerim** and **Dini Bilgiler** circles.
- Routed **Dini Danışman** card directly to the "Dini Hoca" tool inside the Tools/Araçlar screen.
- Routed **Dini Bilgiler** card directly to the Tools/Araçlar section.

### 5. Nearby Mosques Tool Speed Optimization
- **Problem:** "Yakındaki Camiler" took 10+ seconds to open because:
  1. It requested a fresh GPS position with `LocationAccuracy.high` and a 7-second timeout first.
  2. The primary Overpass API server list placed a slow/unreliable mirror first (`overpass.kumi.systems`).
  3. A 20-second timeout meant offline servers caused massive sequential hangs during radii loops.
- **Solution:**
  - Now requests `getLastKnownPosition` first (resolves instantly) to fetch and display nearby mosques immediately.
  - Requests a fresh `LocationAccuracy.medium` GPS coordinate in the background and refreshes the list only if the user moved more than 150 meters.
  - Reordered Overpass servers: official server (`overpass-api.de`) and Swiss mirror (`overpass.osm.ch`) are queried first.
  - Reduced endpoint network timeout from 20 seconds to 4 seconds, avoiding long sequential freezes.

### 6. Admin Panel Notification & Daily Verse Sender
- **Problem:** No real-time announcements, notification sending, or daily verse push functionality from the administration panel.
- **Solution:**
  - Added "Bildirim Gönder" tab and dark-glassmorphic form in `admin.html` / `admin.js` to write custom announcements to Firestore `announcements` collection.
  - Implemented background loop check (`_checkAnnouncements`) in `lib/main.dart` running every 3 seconds to fetch the latest announcement, compare its ID with SharedPreferences cache, and trigger a native system notification instantly via `NotificationService`.

### 7. Premium Splash Screen Rebranding
- **Problem:** The original opening splash screen felt amateurish and lacked high-end aesthetics.
- **Solution:**
  - Generated a high-resolution 3D cartoon Muslim character (holding hands in a heart shape, wearing a kufi) using Gemini and saved it as the main asset `assets/muslim_boy_heart.png`.
  - Upgraded `MandalaPainter` to paint a highly intricate, lace-like golden Islamic geometric mandala motif on the top-left (with nested star polygons and outer loops).
  - Upgraded `LanternPainter` to paint an ornate, detailed golden hanging lantern with a glowing radial light gradient and filigree overlays on the top-right.
  - Formatted calligraphy typography ("سَلَامٌ عَلَيْكُمْ" and "Selamün Aleyküm") using elegant serifs, custom italics, and drop shadows with decorative separators (`•••• ⚜ ••••`).
  - Redesigned the bottom bar into a gold-bordered mahogany panel containing custom icons for each of the six prayer times.

---

## 📋 Next Steps & Open Tasks
1. **Verify New Splash Screen:** Launch the app to verify the golden mandala, hanging lantern, and the new 3D character display correctly on physical devices.
2. **Verify Notifications:** Send a test daily verse/notification from the web admin panel and check if it pops up on the mobile screen within 3 seconds.

---

## 📝 Guide for Starting a New Session
When you start a new conversation under another account or session:
1. Parse this `PROJECT_AI_CONTEXT.md` file.
2. Run `git status` to see if there are any uncommitted files in the workspace.
3. Use `flutter analyze` to verify syntax and ensure there are no compilation warnings.
