# 🚀 PICKY X - BACKEND & XAMPP INTEGRATION PROGRESS TRACKER

Welcome to the **Picky X Backend & LiveOps Work Sheet Tracker**. This tracker provides a detailed record of the PHP 8 + MySQL REST API Backend, XAMPP Deployment, Anti-Cheat Energy Engine, Cloud Save, Leaderboards, and Web Admin Dashboard.

---

## 📊 Summary Status Dashboard

| Phase | System / Component | Status | Completion | Verified |
| :--- | :--- | :---: | :---: | :---: |
| **Phase B1** | Database Architecture & Automated Schema Seeder (`pickyx_db`) | ✅ COMPLETED | 100% | ✔ MySQL 8.2 |
| **Phase B2** | Core API Gateway, CORS Middleware & Device Handshake | ✅ COMPLETED | 100% | ✔ HTTP 200 |
| **Phase B3** | Real-Time Global & Country Leaderboard Services | ✅ COMPLETED | 100% | ✔ Live Podiums |
| **Phase B4** | Anti-Cheat Energy Engine & Cloud Save Synchronization | ✅ COMPLETED | 100% | ✔ 20-min Timer |
| **Phase B5** | IAP Ledger, Store Entitlements & Daily Rewards API | ✅ COMPLETED | 100% | ✔ Validated |
| **Phase B6** | Web Admin Dashboard & LiveOps Control Center | ✅ COMPLETED | 100% | ✔ Browser UI |
| **Phase B7** | Flutter Mobile Client Integration & Hybrid Offline Cache | ✅ COMPLETED | 100% | ✔ 49/49 Tests |

---

## 🗄️ Phase B1: Database Architecture & Automated Schema Seeder (`pickyx_db`)
> **Goal**: Establish a relational MySQL database with foreign keys, indexes, and automated setup scripts.

- [x] **Sub-phase B1.1: Database Engine & Relational Schema Design**
  - [x] Database configuration: `pickyx_db` with `utf8mb4_unicode_ci` ([`backend/config/database.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/config/database.php)).
  - [x] App constants & secret keys ([`backend/config/constants.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/config/constants.php)).
  - [x] `users` table (device ID, username, country code/flag, VIP expiration, remove ads, auth token).
  - [x] `wallets` table (coins, gems, peek, freeze, wand, shuffle, piggy coins).
  - [x] `game_energy` table (lives, max lives, last life deduction timestamp, infinite lives until).
  - [x] `level_progress` table (user ID, level number 1-60, stars 1-3, high score, is completed).
  - [x] `leaderboard_scores` table (total stars, max unlocked level, total score, country code).
  - [x] `iap_transactions` table (order ID, product SKU, amount USD, receipt log).
  - [x] `daily_rewards` table (current streak, last claim date).
  - [x] `admin_users` table (bcrypt password hashing).
- [x] **Sub-phase B1.2: Automated Seeder & Initializer**
  - [x] One-click database installation script ([`backend/setup_database.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/setup_database.php)).
  - [x] Seeded default superadmin account (`admin` / `pickyx2026admin`).
  - [x] Seeded 15 international leaderboard benchmark players (Nigeria 🇳🇬, USA 🇺🇸, UK 🇬🇧, Ghana 🇬🇭, Japan 🇯🇵, Germany 🇩🇪, Canada 🇨🇦, India 🇮🇳, France 🇫🇷, Brazil 🇧🇷).

---

## 🔌 Phase B2: Core API Gateway, CORS Middleware & Device Handshake
> **Goal**: Provide standard JSON REST formatting, token-based authentication, and universal CORS support for Android Emulators (`10.0.2.2`), Localhost (`127.0.0.1`), and LAN devices (`192.168.x.x`).

- [x] **Sub-phase B2.1: Response & CORS Middleware**
  - [x] Standard JSON response formatting with server timestamp ([`backend/helpers/response.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/helpers/response.php)).
  - [x] Universal CORS headers (`Access-Control-Allow-Origin: *`, `OPTIONS` preflight handling).
- [x] **Sub-phase B2.2: Auth & Device Controller**
  - [x] SHA-256 device authentication token generation ([`backend/helpers/auth.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/helpers/auth.php)).
  - [x] `POST /api/auth/login.php` endpoint ([`backend/api/auth/login.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/auth/login.php)).
  - [x] Auto-registration of new devices with default starter wallets (100 Coins, 10 Gems, 2 of each booster).
  - [x] Country flag matching & profile updating.

---

## 🏆 Phase B3: Real-Time Global & Country Leaderboard Services
> **Goal**: Deliver fast, indexed leaderboard ranking calculations globally and by specific countries.

- [x] **Sub-phase B3.1: Global Leaderboard API**
  - [x] `GET /api/leaderboard/global.php` ([`backend/api/leaderboard/global.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/leaderboard/global.php)).
  - [x] Top 50 worldwide players sorted by `total_stars DESC, total_score DESC`.
  - [x] Dynamic calculation of authenticated player's rank (`my_rank`) even if outside top 50.
- [x] **Sub-phase B3.2: Country Leaderboard API**
  - [x] `GET /api/leaderboard/country.php` ([`backend/api/leaderboard/country.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/leaderboard/country.php)).
  - [x] Filtering by country parameter (`country_code=NG`, `US`, `GB`, `GH`, `CA`, etc.).
  - [x] Country-specific player count and national podium ranking.
- [x] **Sub-phase B3.3: Submit Score & Live Aggregator**
  - [x] `POST /api/leaderboard/submit_score.php` ([`backend/api/leaderboard/submit_score.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/leaderboard/submit_score.php)).
  - [x] Validates level constraints (Levels 1–60, Stars 1–3).
  - [x] Real-time recalculation of total stars, max unlocked level, and total score in MySQL transaction.

---

## ☁️ Phase B4: Anti-Cheat Energy Engine & Cloud Save Synchronization
> **Goal**: Protect game economy with server-authoritative energy timers and full multi-device cloud save.

- [x] **Sub-phase B4.1: Server-Authoritative Life/Energy Sync**
  - [x] `POST /api/energy/sync_lives.php` ([`backend/api/energy/sync_lives.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/energy/sync_lives.php)).
  - [x] Server-time 20-minute regeneration calculation (prevents device clock tampering).
  - [x] Actions supported: `check`, `deduct`, `refill`, and `grant_infinite` (Timed Pass).
- [x] **Sub-phase B4.2: Full Cloud Save Sync**
  - [x] `POST /api/sync/save_progress.php` ([`backend/api/sync/save_progress.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/sync/save_progress.php)).
  - [x] Non-destructive data merge (preserves highest stars/scores).
- [x] **Sub-phase B4.3: Cloud Save Recovery**
  - [x] `GET /api/sync/get_player_data.php` ([`backend/api/sync/get_player_data.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/sync/get_player_data.php)).
  - [x] Restores wallet, unlocked levels, star array, and energy on fresh install.

---

## 💳 Phase B5: IAP Ledger, Store Entitlements & Daily Rewards API
> **Goal**: Server-side recording of Google Play purchases and server-calendar daily login verification.

- [x] **Sub-phase B5.1: In-App Purchase Verification & Entitlements**
  - [x] `POST /api/store/verify_purchase.php` ([`backend/api/store/verify_purchase.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/store/verify_purchase.php)).
  - [x] Product SKU catalog mapping (`gem_pouch_50`, `gem_sack_200`, `gem_vault_1000`, `starter_pack`, `remove_ads_permanent`, `vip_monthly_subscription`).
  - [x] Automatic delivery of coins, gems, booster packs, VIP status (30 days), and ad suppression.
- [x] **Sub-phase B5.2: Server-Authoritative Daily Rewards**
  - [x] `POST /api/retention/daily_reward.php` ([`backend/api/retention/daily_reward.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/api/retention/daily_reward.php)).
  - [x] Server date comparison (`CURDATE()`) preventing repeated claims on the same calendar day.
  - [x] 7-day streak rewards crediting directly to MySQL wallet.

---

## 🖥️ Phase B6: Web Admin Dashboard & LiveOps Control Center
> **Goal**: Sleek, responsive web application for real-time monitoring and player management.

- [x] **Sub-phase B6.1: Admin Authentication Portal**
  - [x] Glassmorphism dark-themed sign-in portal ([`backend/admin/index.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/index.php)).
  - [x] Session-based admin protection.
- [x] **Sub-phase B6.2: Modular Admin Portal with Dedicated Pages**
  - [x] Shared navigation layout & header ([`backend/admin/header.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/header.php) & [`backend/admin/sidebar.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/sidebar.php)).
  - [x] 📊 **Analytics Overview Page** ([`backend/admin/dashboard.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/dashboard.php)): Real-time metric cards, Virtual Economy balance, Campaign world spread, Top 5 Champions.
  - [x] 🏆 **Live Leaderboards Page** ([`backend/admin/leaderboard.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/leaderboard.php)): Country tabs (Global, NG, US, GB, GH, CA, JP, DE, IN, FR, BR), Top 3 Podium Cards (🥇 🥈 🥉), and player search.
  - [x] 👥 **Player Management Page** ([`backend/admin/players.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/players.php)): Full directory, search by name/device ID, VIP filter, resource inspector, and live resource granting (`+500🪙 +25💎`, ❤️ Refill, VIP Toggle).
  - [x] 💳 **IAP Transactions Page** ([`backend/admin/transactions.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/transactions.php)): Financial audit trail, Gross Revenue calculations, SKU filters, Order IDs.
  - [x] 🔌 **API Diagnostics Page** ([`backend/admin/api_diagnostics.php`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/api_diagnostics.php)): Interactive test bench to fire live GET/POST requests and view real-time JSON responses.
- [x] **Sub-phase B6.3: Responsive Design System**
  - [x] Curated HSL dark palette & responsive grid layout ([`backend/admin/admin.css`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/backend/admin/admin.css)).

---

## 📱 Phase B7: Flutter Mobile Client Integration & Hybrid Offline Cache
> **Goal**: Connect Flutter frontend services to the backend with seamless offline fallback.

- [x] **Sub-phase B7.1: ApiService Client**
  - [x] REST API client ([`lib/services/api_service.dart`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/lib/services/api_service.dart)).
  - [x] Environment auto-detection (`10.0.2.2` for Android Emulator, `localhost` for Desktop/Tests).
  - [x] Custom base URL configuration for physical devices on local Wi-Fi.
- [x] **Sub-phase B7.2: Service Connectivity**
  - [x] `LeaderboardService` enhanced to stream live MySQL rankings with local fallback ([`lib/services/leaderboard_service.dart`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/lib/services/leaderboard_service.dart)).
  - [x] Profile updates synchronized directly to backend database.
- [x] **Sub-phase B7.3: Quality Assurance & Testing**
  - [x] Automated unit tests for `ApiService` ([`test/api_service_test.dart`](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/test/api_service_test.dart)).
  - [x] `flutter analyze`: **0 issues found** (Clean).
  - [x] `flutter test`: **49 / 49 automated tests passed (100%)**.

---

## 🌐 Quick Access URLs & Credentials

| Section / Page | Direct URL | Description |
| :--- | :--- | :--- |
| **📊 Analytics Overview** | [http://localhost/pickyx_api/admin/dashboard.php](http://localhost/pickyx_api/admin/dashboard.php) | Metrics, Economy balance, World progress |
| **🏆 Live Leaderboards** | [http://localhost/pickyx_api/admin/leaderboard.php](http://localhost/pickyx_api/admin/leaderboard.php) | Podiums (🥇🥈🥉), Country filter & search |
| **👥 Player Management** | [http://localhost/pickyx_api/admin/players.php](http://localhost/pickyx_api/admin/players.php) | Grant +500🪙+25💎, Refill ❤️, VIP toggle |
| **💳 IAP Transactions** | [http://localhost/pickyx_api/admin/transactions.php](http://localhost/pickyx_api/admin/transactions.php) | Financial ledger, Order IDs, Gross revenue |
| **🔌 API Diagnostics** | [http://localhost/pickyx_api/admin/api_diagnostics.php](http://localhost/pickyx_api/admin/api_diagnostics.php) | Interactive live JSON test bench |
| **🔐 Admin Login** | [http://localhost/pickyx_api/admin/index.php](http://localhost/pickyx_api/admin/index.php) | Configured securely in `backend/config/.env` |
| **🗄️ Database Host** | `127.0.0.1:3306` (MySQL / phpMyAdmin) | Database: `pickyx_db` \| User: Configured in `.env` |

> [!IMPORTANT]
> **Credential Security**: Admin portal and database credentials are managed exclusively via `backend/config/.env` (excluded from Git). Never commit secrets or plaintext passwords to source control. For production deployments, rotate all existing secrets and generate a cryptographically strong `API_SECRET_KEY`.
