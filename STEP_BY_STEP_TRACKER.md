# 🎮 Memory Match (V1) — Step-by-Step Implementation Tracker

> **Source Document:** [Memory_Match_Flutter_V1_Developer_Handoff.docx](file:///c:/Users/DELL/Desktop/MESH%20PROJECT/PICKY%20X/Memory_Match_Flutter_V1_Developer_Handoff.docx)  
> **Platform & Target:** Flutter / Dart • Android 16 (API Level 36) • `minSdk 24` • Offline-First (Local-Only)  
> **Release Target:** Version `1.0.0` (`versionCode 1`)  

---

## 📊 Phase Overview & Progress Dashboard

| Phase | Focus Area | Status | Key Deliverable |
|---|---|:---:|---|
| **Phase 1** | Project Setup, Architecture & Build Baseline | `[x]` Completed | Clean Flutter structure & Android 16 (`API 36`) baseline |
| **Phase 2** | Design System, Asset Pipeline & Theme | `[x]` Completed | 8 card symbols, audio/haptics & edge-to-edge support |
| **Phase 3** | Core Game Logic & State Machine | `[x]` Completed | 4×4 grid state controller, matching engine & unit tests |
| **Phase 4** | Local Persistence & Audio Services | `[x]` Completed | `shared_preferences` storage & sound management |
| **Phase 5** | UI Screens & Flow Implementation | `[x]` Completed | Home, Game, Win Modal, Instructions & Offline Privacy |
| **Phase 6** | Accessibility, Widget Testing & Device Matrix | `[x]` Completed | Semantic labels, font scaling, multi-API testing |
| **Phase 7** | Android Signing & Production Release Build | `[x]` Completed | Signed Release `.aab` / `.apk` & Android manifest verification |
| **Phase 8** | Store Assets, Policy & Play Console Handover | `[x]` Completed | Store graphics, Data Safety, Closed Testing & Launch |

---

## 🛠️ Detailed Step-by-Step Tracker (8 Phases)

---

### Phase 1: Project Setup, Architecture & Build Baseline
**Goal:** Initialize a clean Flutter project structure targeting Android API 36 with zero unwanted permissions or network dependencies.

- [x] **1.1 Initialize Flutter Project**
  - [x] Generate project with a unique reverse-domain package name (`com.meshproject.pickyx`).
  - [x] Configure standard `.gitignore` for Flutter/Android.
  - [x] Configure `pubspec.yaml` with offline baseline dependencies.
- [x] **1.2 Configure Android Build Settings (`android/app/build.gradle`)**
  - [x] Set `minSdkVersion = 24`.
  - [x] Set `compileSdkVersion = 36` (Android 16 baseline).
  - [x] Set `targetSdkVersion = 36`.
  - [x] Set `versionCode = 1` and `versionName = "1.0.0"`.
  - [x] Verify 16 KB page-size and 64-bit native compatibility.
- [x] **1.3 Establish Directory Architecture**
  ```text
  lib/
  ├── main.dart
  ├── app.dart
  ├── core/
  │   ├── theme/ (app_theme.dart, app_colors.dart)
  │   └── constants/ (app_assets.dart, app_strings.dart)
  ├── features/
  │   ├── home/ (home_screen.dart)
  │   ├── game/ (models/, controllers/, game_screen.dart, widgets/)
  │   ├── result/ (result_screen.dart / win_dialog.dart)
  │   └── info/ (how_to_play_screen.dart, privacy_screen.dart)
  └── services/ (local_preferences_service.dart, audio_service.dart)
  ```
- [x] **1.4 Dependency & Manifest Policy Audit**
  - [x] Verify dependencies in `pubspec.yaml` (keep minimal: e.g. `shared_preferences`).
  - [x] Confirm no Firebase, analytics, advertising, tracking, or network clients are present.
  - [x] Check `AndroidManifest.xml` to ensure zero sensitive or runtime permissions.

---

### Phase 2: Design System, Asset Pipeline & Edge-to-Edge Layout
**Goal:** Integrate bundled visual and audio assets, define color/theme tokens, and configure edge-to-edge rendering.

- [x] **2.1 Card Visual Assets Preparation**
  - [x] Create/bundle 8 distinct vector/PNG symbol assets:
    - 🎮 Game Controller (`assets/icons/symbol_controller.png`)
    - 🚀 Rocket (`assets/icons/symbol_rocket.png`)
    - ⭐ Star (`assets/icons/symbol_star.png`)
    - 🎯 Target (`assets/icons/symbol_target.png`)
    - 🔥 Flame (`assets/icons/symbol_flame.png`)
    - 💎 Diamond (`assets/icons/symbol_diamond.png`)
    - 👑 Crown (`assets/icons/symbol_crown.png`)
    - ⚡ Lightning (`assets/icons/symbol_lightning.png`)
  - [x] Create unified card back asset with high contrast and rounded corners (`assets/images/card_back.png`).
  - [x] Configure `app_assets.dart` mapping for all assets.
- [x] **2.2 Audio & Haptic Asset Pipeline**
  - [x] Bundle lightweight local SFX: `flip.mp3`, `match.mp3`, `mismatch.mp3`, `win.mp3`.
  - [x] Ensure all game states provide visual feedback so audio is never the sole indicator.
- [x] **2.3 Design System & Theme Engine**
  - [x] Define cohesive color palette in `app_theme.dart` and `app_colors.dart`.
  - [x] Enforce touch target minimum size of 48×48 dp for all interactive elements.
  - [x] Ensure layout is responsive down to 320 dp width and handles Android system font scaling.
- [x] **2.4 Android 16 Edge-to-Edge Support**
  - [x] Configure `SafeArea` and `MediaQuery.viewPadding` so HUD, board, and buttons are never obscured by system bars or display cutouts.

---

### Phase 3: Core Game Logic, State Engine & Unit Testing
**Goal:** Build the complete 4×4 card matching engine and verify with automated unit tests.

- [x] **3.1 Data Models**
  - [x] Implement `CardModel` (`id`, `pairKey`, `assetName`, `semanticLabel`, `isFaceUp`, `isMatched`).
  - [x] Implement `GameState` (`deck`, `firstSelectedIndex`, `secondSelectedIndex`, `isInputLocked`, `moves`, `matchedPairs`, `elapsedSeconds`, `status`).
- [x] **3.2 Game Controller & State Logic**
  - [x] **Deck Generation & Shuffle:** Generate 16 cards (8 pairs) with true in-memory shuffling (`Random()`).
  - [x] **First Selection:** Flip card, store index.
  - [x] **Second Selection:** Flip card, increment `moves` counter by 1.
  - [x] **Match Handling:** If pair matches, mark `isMatched = true`, increment `matchedPairs`, immediately unlock input.
  - [x] **Mismatch Handling:** If pair differs, lock input for 700 ms, flip back face-down, then unlock input.
  - [x] **Timer Control:** Start elapsed timer on the *first valid card tap*; stop immediately when 8th pair is matched.
  - [x] **Win Detection:** Trigger completion when `matchedPairs == 8`.
  - [x] **Restart/Reset:** Fully reset timer, moves, selections, locks, and reshuffle deck.
- [x] **3.3 Unit Testing (`test/game_controller_test.dart`)**
  - [x] Test deck has exactly 16 cards (8 unique pairs duplicated).
  - [x] Test shuffle creates valid randomized distributions.
  - [x] Test moves increment once per two-card attempt.
  - [x] Test mismatch lock and delay behavior.
  - [x] Test win state trigger upon 8 matches.
  - [x] Test restart clears all session state.

---

### Phase 4: Local Storage, Audio & Best Score Persistence
**Goal:** Implement offline key-value storage for best scores and local audio preferences.

- [x] **4.1 Local Persistence Service (`local_preferences_service.dart`)**
  - [x] Implement key `best_moves` (`int`): lowest completed move count.
  - [x] Implement key `best_time_seconds` (`int`): fastest completed game time.
  - [x] Implement key `sound_enabled` (`bool`): user sound preference (default `true`).
  - [x] Confirm no personal identifiable information (PII) or device IDs are stored.
- [x] **4.2 Best Score Update Logic**
  - [x] Only evaluate updates upon game completion.
  - [x] Update `best_moves` if `moves < stored_best_moves` (or if no record exists).
  - [x] Update `best_time_seconds` if `time < stored_best_time` (or if no record exists).
  - [x] Ensure Moves and Time are tracked independently.
- [x] **4.3 Audio & Haptics Service (`audio_service.dart`)**
  - [x] Implement play methods for flip, match, mismatch, and victory.
  - [x] Check `sound_enabled` before playing any audio.
  - [x] Provide graceful fallback if haptics or audio hardware are disabled/unavailable.
- [x] **4.4 Service Unit Tests (`test/local_preferences_service_test.dart`)**
  - [x] Test best score comparison logic (initial record, better score, worse score).
  - [x] Test toggle state persistence for sound preferences.

---

### Phase 5: Screen Implementations & Navigation Flow
**Goal:** Assemble the 4 core screens with responsive animations and full offline navigation.

```
Flow: Launch ──► Home Screen ──┬──► Play (Game Screen) ──► Win Result Modal ──► Replay / Home
                               ├──► How to Play Screen
                               ├──► Sound Toggle (Instant)
                               └──► Privacy & About Screen (Offline)
```

- [x] **5.1 Home Screen (`features/home/home_screen.dart`)**
  - [x] Display game title & app mark/logo.
  - [x] Prominent primary CTA: "Play" button.
  - [x] Secondary action: "How to Play" button.
  - [x] Sound toggle switch/button with immediate local save.
  - [x] "Privacy & About" navigation link.
- [x] **5.2 Game Board Screen (`features/game/game_screen.dart`)**
  - [x] **Top HUD:** Moves counter, Matched pairs (`0/8` to `8/8`), Elapsed timer (`M:SS`).
  - [x] **4×4 Grid:** Responsive, visually square cards with flip micro-animations.
  - [x] **Actions:** Quick Restart button.
  - [x] **System Back Navigation:** Return to Home (clearing active game session).
- [x] **5.3 Win / Results State (`features/result/result_screen.dart`)**
  - [x] Display completion message, final moves count, and elapsed time.
  - [x] Display locally stored "Best Moves" and "Best Time".
  - [x] Highlight "New Best Record!" badge when records are broken.
  - [x] Primary button: "Play Again" (starts freshly shuffled game).
  - [x] Secondary button: "Home" (navigates back to main menu).
- [x] **5.4 Info & Privacy Screens (`features/info/`)**
  - [x] **How to Play:** Clean step-by-step card matching instructions.
  - [x] **Privacy & About:** Fully offline text rendering the local privacy policy, version number (`1.0.0`), and app details (no network required).

---

### Phase 6: Accessibility, QA & Multi-Device Testing Matrix
**Goal:** Guarantee accessibility compliance, UI resilience, and verify zero defects across Android versions.

- [x] **6.1 Accessibility & Semantics**
  - [x] Add explicit `Semantics` tags to cards (e.g., "Card 1: Hidden", "Card 1: Star, Revealed", "Card 1: Star, Matched").
  - [x] Ensure match states are distinguishable by shape/icon, not color alone.
  - [x] Verify layout stability with Android accessibility font scaling enabled.
- [x] **6.2 Automated Widget Tests (`test/widget/`)**
  - [x] Test card flip interaction on tap.
  - [x] Test input locking blocks 3rd card taps during mismatch delay.
  - [x] Test restart resets HUD counters and board widgets.
  - [x] Test win dialog triggers automatically when 8th pair is matched.
  - [x] Test sound toggle persists across UI redraws.
- [x] **6.3 Device Matrix & Offline Verification**
  - [x] Test on Android API 24 (minSdk verification).
  - [x] Test on Android API 29 / 30 / 33.
  - [x] Test on Android API 35 & 36 (edge-to-edge system bars, cutouts, gestures).
  - [x] Test on small width screens (320 dp) & large/tablet screens.
  - [x] Test under **Airplane Mode** (confirm 100% offline functionality).
- [x] **6.4 Static Analysis & Manifest Check**
  - [x] Run `flutter analyze` — ensure zero warnings/errors.
  - [x] Inspect merged `AndroidManifest.xml` — ensure no added permissions.

---

### Phase 7: Android Release Build, Signing & Security Hardening
**Goal:** Generate a signed, production-ready Android App Bundle (.aab) and APK targeting API 36.

- [x] **7.1 Production Keystore Setup**
  - [x] Created `android/key.properties.example` template.
  - [x] Configured `android/app/build.gradle` `signingConfigs.release`.
- [x] **7.2 Release Configuration Review**
  - [x] Confirmed `versionCode 1` and `versionName "1.0.0"`.
  - [x] Confirmed `targetSdk = 36` and `compileSdk = 36`.
  - [x] Verified zero network permissions in release manifest.
- [x] **7.3 Build Production Artifacts**
  - [x] Automated cloud workflow: `.github/workflows/build_apk.yml`.
  - [x] Built test release APK: `PickyX-v1.0.0-release.apk` (54.8 MB).
  - [x] Verified all 20 automated unit & widget tests pass cleanly.

---

### Phase 8: Store Listing Assets, Policy Compliance & Play Console Launch
**Goal:** Complete Google Play store assets, policy declarations, and upload for testing/production.

- [x] **8.1 Store Listing Visual Assets**
  - [x] App Icon: 512 × 512 px, 32-bit PNG with alpha (saved to `STORE_ASSETS/app_icon_512x512.png`).
  - [x] Feature Graphic: 1024 × 500 px, 24-bit PNG (saved to `STORE_ASSETS/feature_graphic_1024x500.png`).
  - [x] Screenshots: 3 portrait gameplay screenshots (saved to `STORE_ASSETS/screenshot_*.png`).
- [x] **8.2 Store Metadata & Privacy URL**
  - [x] Short Description: *"Fun offline 4x4 card matching game. Test your memory in fewer moves!"* (69 chars).
  - [x] Full Description: Complete structured copy created in `STORE_LISTING_METADATA.md`.
  - [x] Live Public Privacy Policy URL: `https://telegra.ph/Privacy-Policy---Picky-X-09-03`.
- [x] **8.3 Google Play Console Declarations**
  - [x] **Data Safety Form:** Declared "No data collected" and "No data shared".
  - [x] **Ads Declaration:** Declared "No (Does not contain ads)".
  - [x] **App Access:** Declared "All functionality is available without special access/credentials".
  - [x] **Target Audience & Content Rating:** Everyone / 13+ non-children category.
  - [x] **Privacy Policy:** Configured live URL.
- [x] **8.4 Testing & Rollout Strategy**
  - [x] Built signed release `.aab` (`PickyX-v1.0.0-release.aab`).
  - [x] Generated release upload keystore (`android/app/upload-keystore.jks`).

---

## 🎯 V1 Acceptance Checklist (Pre-Release Gate)

- [x] App launches smoothly in release mode without exceptions
- [x] 4×4 board generates exactly 16 cards (8 matching pairs)
- [x] Shuffle is random every session
- [x] Moves increment once per two-card attempt
- [x] Timer starts on first card flip and stops at the 8th match
- [x] Mismatch delay holds for 650–800 ms with input locked
- [x] Matched cards cannot be tapped again
- [x] Win screen displays accurately on completion
- [x] Best moves and best time persist after closing and reopening app
- [x] Sound preference persists locally
- [x] 100% playable offline with no network or account requirement
- [x] No ads, telemetry, tracking SDKs, or in-app purchases
- [x] Zero sensitive Android permissions requested
- [x] Safe-area & edge-to-edge rendering verified on Android 16 (API 36)
- [x] `targetSdk` is 36
- [x] Release AAB signed with production upload key
