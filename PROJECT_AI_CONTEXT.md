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

---

## 📋 Next Steps & Open Tasks
1. **Verify GPS in Settings:** Test the GPS auto-detect modal dialog on a physical device or emulator.
2. **Verify Zikirmatik Checklist:** Test that dhikrs completed on different days are correctly persisted and marked in the tracker list.
3. **Verify Route Redirects:** Check that clicking the home screen advisor/religious info circles correctly navigates to the expected tools pages.

---

## 📝 Guide for Starting a New Session
When you start a new conversation under another account or session:
1. Parse this `PROJECT_AI_CONTEXT.md` file.
2. Run `git status` to see if there are any uncommitted files in the workspace.
3. Use `flutter analyze` to verify syntax and ensure there are no compilation warnings.
