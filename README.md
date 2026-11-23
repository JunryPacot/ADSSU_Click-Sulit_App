# ADSSU Click & Sulit

**ADSSU Click & Sulit** is a dedicated campus peer-to-peer marketplace and academic exchange mobile application tailored for the student community of Agusan del Sur State University (ADSSU). The platform enables verified students to buy, sell, exchange, and donate academic essentials such as textbooks, uniforms, laboratory apparatus, and dorm supplies.

---

## Laboratory Exercise 4: Networking and Local Data Storage (F2)

This project fulfills all criteria of **Laboratory Exercise 4**:
- **Task 1 – External API Integration**:
  - Live REST API communication using Dart's `http` package (`fetch` / `axios` equivalent).
  - Fetches external student deals from `https://dummyjson.com/products` (with fallback to `FakeStoreAPI`).
  - Implements dynamic category chips, currency conversion from USD to Philippine Pesos (`₱58.00 / $1`), real-time search, loading indicators, error handling with a "Try Again" retry button, and pull-to-refresh (`RefreshIndicator`).
- **Task 2 – Local Data Persistence (AsyncStorage Equivalent)**:
  - Persistent storage using Flutter's `SharedPreferences` (AsyncStorage equivalent).
  - **Full CRUD operations**:
    - **Create**: Registering a student account saves their profile and credentials locally; creating a marketplace listing or saving an external deal persists to storage.
    - **Read**: Automatically restores user sessions, custom items, and bookmarks on application boot (`main.dart`).
    - **Update**: Profile edits (name, college, bio) and item modifications are immediately saved to persistent storage.
    - **Delete**: Users can delete bookmarked items or API deals from their wishlist.
- **Task 3 – System Integration**:
  - Direct integration into the home banner, activity wishlist, and campus navigation flows.
  - Zero external database required; 100% functional offline with manual account registration and local session management.

---

## Project Structure

```
lib/
├── main.dart                                # App initialization and local storage restore
├── core/
│   ├── constants/
│   │   ├── campus_constants.dart           # University colleges, demo credentials, categories
│   │   └── app_assets.dart                 # Asset paths and branding
│   ├── router/
│   │   ├── app_router.dart                 # GoRouter declarations and navigation guards
│   │   └── route_names.dart                # String route constants
│   └── theme/
│       ├── app_colors.dart                 # ADSSU brand color palette (Forest Green & Gold)
│       └── app_theme.dart                  # Material 3 theme definitions
├── data/
│   ├── models/
│   │   ├── user_model.dart                 # Student profile model
│   │   ├── item_model.dart                 # Campus listing model (Sell, Donate, Exchange)
│   │   └── external_product_model.dart     # REST API model with PHP currency conversion
│   ├── services/
│   │   ├── local_storage_service.dart      # SharedPreferences persistence layer (CRUD)
│   │   └── external_api_service.dart       # HTTP client for REST API endpoints
│   └── mock/
│       ├── mock_database.dart              # Offline state manager & repository (Provider)
│       └── seed_data.dart                  # Initial campus demo items
└── features/
    ├── auth/                               # Manual Login, Register Step 1 & 2, Password Reset
    ├── home/                               # Campus feed and REST API Deal banner
    ├── browse/                             # External API Deals screen with pull-to-refresh
    ├── activity/                           # Saved campus items & saved external API products
    ├── items/                              # Item detail (Sell, Donate, Exchange)
    ├── post/                               # Post new item listing (Create CRUD)
    └── profile/                            # Profile view and edit (Update CRUD)
```

---

## Build & Installation Commands

### 1. Build Release APK via Terminal
```powershell
# Set temporary directories to drive D:
$env:TEMP = 'D:\Temp'; $env:TMP = 'D:\Temp'; $env:GRADLE_USER_HOME = 'D:\.gradle'

# Build the release APK
flutter build apk --release
```
The compiled APK will be located at:
- `build/app/outputs/flutter-apk/app-release.apk`
- Ready-to-use copy: `adssu_click_and_sulit_v2_local.apk` (Project Root)

### 2. Install APK to Connected Android Device / Emulator
Ensure USB debugging is enabled on your Android phone, then run:
```powershell
adb devices
adb install -r adssu_click_and_sulit_v2_local.apk
```

### 3. Run Automated Tests
```powershell
$env:TEMP = 'D:\Temp'; $env:TMP = 'D:\Temp'
flutter test
```
*All 41 unit and widget tests pass.*

---


