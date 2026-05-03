# Sovereign Maareg Fund — Flutter Android App

A premium, production-ready native Android application built in Flutter, faithfully replicating the **Sovereign Maareg Fund** website design for mobile.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | Riverpod 2.x |
| Navigation | GoRouter 14.x |
| Backend | Supabase (existing project) |
| Animations | flutter_animate 4.x |
| Images | cached_network_image |
| Typography | Google Fonts (Inter + Noto Kufi Arabic) |

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── api/          # VisaRepository (mirrors web's lib/api.ts)
│   ├── constants/    # AppConstants (colors, spacing, Supabase keys)
│   ├── models/       # Visa, VisaCategory
│   ├── providers/    # All Riverpod FutureProviders & StateProviders
│   ├── router/       # GoRouter config + locale provider
│   ├── shell/        # MainShell (persistent bottom nav)
│   └── theme/        # AppTheme (dark ThemeData + typography)
├── features/
│   ├── splash/       # Animated splash screen
│   ├── home/         # Home screen + Hero, Trust, Services, HowItWorks, CTA sections
│   ├── visas/        # Visas list screen, detail screen, lead form bottom sheet
│   ├── about/        # About screen
│   ├── contact/      # Contact screen
│   └── auth/         # Login screen (Supabase auth)
└── shared/
    └── widgets/      # VisaCard, ShimmerCard, PrimaryButton, GhostButton, StatusBadge, MonoTag
```

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.3.0
- Android Studio / VS Code
- An Android device or emulator (API 26+)

### Setup

```bash
# 1. Navigate to the project
cd sovereign_maareg_app

# 2. Install dependencies
flutter pub get

# 3. Run on Android
flutter run

# 4. Build release APK
flutter build apk --release
```

---

## Key Features

- **120 FPS ready** – `const` constructors everywhere, `BouncingScrollPhysics`, `ListView.builder` for long lists
- **Full RTL support** – Arabic text renders correctly with `Directionality` widget and Noto Kufi Arabic font
- **Supabase integration** – Categories, Visas, Lead submission via `VisaRepository`
- **Graceful fallbacks** – Mock data served when Supabase is unreachable
- **Haptic feedback** – `HapticFeedback.mediumImpact()` on primary CTA taps
- **Image caching** – `CachedNetworkImage` prevents redundant downloads
- **Shimmer loading** – Beautiful skeleton placeholders while data loads
- **Smooth animations** – `flutter_animate` for fade/slide/scale transitions matching web's Framer Motion

---

## Design System

| Token | Value |
|---|---|
| Background | `#050B14` |
| Card | `#0A1628` |
| Primary | `#2563EB` (blue-600) |
| Accent | `#60A5FA` (blue-400) |
| Emerald | `#34D399` |
| Indigo | `#818CF8` |
| Body text | `#94A3B8` (slate-400) |
| Border | `#1E293B` (slate-800) |

---

## Supabase Tables Used

| Table | Purpose |
|---|---|
| `categories` | Visa categories |
| `visas` | Visa programs (active only) |
| `leads` | Lead submissions from Apply form |

---

*Built from the Sovereign Maareg Fund web codebase — zero files modified in the original Next.js project.*
