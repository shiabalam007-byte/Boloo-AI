# BOLOO AI — Project Audit
**Date:** 2026-06-08  
**Auditor:** Complete codebase read (~80 files)  
**Scope:** All Dart, SQL, TypeScript, config, and platform files

---

## What's Completed

### Backend (Supabase)
| Item | Status |
|------|--------|
| 9-table PostgreSQL schema | ✅ Complete |
| Row Level Security on all tables | ✅ Complete |
| 30-day curriculum seed (all 5 phases, all 30 days) | ✅ Complete |
| `maya-conversation` Edge Function (Gemini 2.0 Flash) | ✅ Complete |
| `score-session` Edge Function (AI scoring rubric) | ✅ Complete |
| `initiate-payment` Edge Function (Zinnipay) | ✅ Complete |
| `zinnipay-webhook` Edge Function (HMAC verification) | ✅ Complete |
| Auto-create profile + streak on signup trigger | ✅ Complete |

### Flutter App — Architecture
| Item | Status |
|------|--------|
| Project structure (lib/features, lib/services, lib/providers, etc.) | ✅ Complete |
| Design system (colors, typography, dimensions, Material 3 theme) | ✅ Complete |
| GoRouter with all 15 routes + ShellRoute bottom nav | ✅ Complete |
| Auth redirect guard (signed-in vs signed-out) | ✅ Complete |
| Riverpod state management (7 providers) | ✅ Complete |
| 7 data models (UserProfile, Conversation, Message, etc.) | ✅ Complete |
| 9 services (auth, user, conversation, payment, score, streak, voice, journey, maya) | ✅ Complete |
| Shared widget library (BoolooButton, BolooCard, SkeletonBox, ScorePill, PhaseBadge, etc.) | ✅ Complete |
| Core utilities (AppException, AppLogger, string/context extensions) | ✅ Complete |
| iOS Info.plist (deep links, microphone, speech recognition) | ✅ Complete |
| AndroidManifest.xml (deep links, INTERNET, RECORD_AUDIO) | ✅ Complete |

### Flutter App — Screens
| Screen | Status |
|--------|--------|
| SplashScreen (fade/scale animation, auth routing) | ✅ Complete |
| AuthScreen (Google, Phone, Email options) | ✅ Complete |
| PhoneAuthScreen (OTP send + verify flow) | ✅ Complete |
| EmailAuthScreen (sign in + sign up tabs) | ✅ Complete |
| OnboardingFlow (5 steps: language, goal, level, occupation, commitment) | ✅ Complete |
| MeetMayaScreen (intro to the AI coach) | ✅ Complete |
| PaywallScreen (features, price card, payment methods, Zinnipay WebView) | ✅ Complete |
| DashboardScreen (greeting, today's challenge, scores, recent sessions, FAB) | ✅ Complete |
| SessionSetupScreen (topic card, voice/text mode selector) | ✅ Complete |
| VoiceSessionScreen (STT/TTS pipeline, pulse animation, Maya avatar) | ✅ Complete |
| TextSessionScreen (chat bubbles, typing indicator, input bar) | ✅ Complete |
| ScorecardScreen (animated score reveal, Maya feedback, strengths/improvements) | ✅ Complete |
| JourneyMapScreen (5 phases, day cards with locked/unlocked/current/completed states) | ✅ Complete |
| ProgressScreen (stats row, average score bars, fl_chart trend line, session history) | ✅ Complete |
| ProfileScreen (user info, stats display) | ✅ Complete |
| SettingsScreen (scaffolded with sections) | ⚠️ Partial — see below |

---

## What's Incomplete

### Critical Logic Gaps

**1. Maya never receives curriculum day context**  
File: `lib/providers/conversation_provider.dart:109`  
`day: null` is always passed to `MayaService.sendMessage()`. The topic and scenario strings reach Maya, but the structured curriculum data (`keyPhrases`, `learningObjectives`, `difficulty`) does not. Maya cannot personalise guidance to the day's specific learning targets.

**2. Journey completion is never recorded**  
File: `lib/providers/conversation_provider.dart` — `endSession()` method  
`JourneyService.markDayCompleted()` exists and is correct. It is never called. Day status will never advance from `unlocked` to `completed` in production. The journey map will always show every day as not-done. Streak updates also only happen in `conversation_service.dart`; the `streak_service.updateStreak()` is never called from the provider.

**3. No subscription or onboarding gate in the router**  
File: `lib/app/router.dart:46–57`  
The redirect only checks `isAuth`. A new user who has signed in but not completed onboarding goes straight to `/dashboard`. A user who completed onboarding but has no active subscription also goes straight to `/dashboard`. Both the onboarding funnel and the paywall are bypassable.

### Memory Leak

**4. Stream subscriptions not cancelled in VoiceSessionScreen**  
File: `lib/features/conversation/voice_session_screen.dart:40–44`  
`.listen()` is called on `stateStream` and `transcriptStream` but the returned `StreamSubscription` objects are discarded. They are never cancelled in `dispose()`. Each navigation in/out of a voice session adds a new uncancelled listener. On repeated sessions this will accumulate until the app is killed.

### Settings Screen — Dead UI

**5. Six non-functional taps in SettingsScreen**  
File: `lib/features/settings/settings_screen.dart`  
The following items have `onTap: () {}` (empty callbacks):
- Language Preference
- Manage Subscription
- Help & FAQ
- Contact Support
- Privacy Policy
- Terms of Service

These are visible and tappable by users. Privacy Policy and Terms of Service are legally required before App Store / Play Store submission.

### Missing Assets (Compile-Time)

**6. All declared fonts are absent**  
`pubspec.yaml` declares five font files. None exist on disk — only `.gitkeep` in `assets/fonts/`. Flutter's build pipeline will **fail at compile time**.

| Font declared | File path required |
|---------------|--------------------|
| PlusJakartaSans-Regular | assets/fonts/PlusJakartaSans-Regular.ttf |
| PlusJakartaSans-Medium | assets/fonts/PlusJakartaSans-Medium.ttf |
| PlusJakartaSans-SemiBold | assets/fonts/PlusJakartaSans-SemiBold.ttf |
| PlusJakartaSans-Bold | assets/fonts/PlusJakartaSans-Bold.ttf |
| DMMono-Medium | assets/fonts/DMMono-Medium.ttf |

**7. No Lottie animation files**  
`assets/animations/` contains only `.gitkeep`. If any screen calls `Lottie.asset(...)`, it will throw a runtime exception. Audit found no active `Lottie.asset()` calls in the read screens, but `lottie: ^3.1.2` is declared in `pubspec.yaml` and the dependency was intended for the Maya greeting animation.

### Dead Code / Unused Packages

**8. Seven packages declared but never used**  
`google_generative_ai` is the most notable — Gemini is called via Supabase Edge Functions, not the SDK. The others add ~12MB to the release binary for zero benefit.

| Package | Declared version | Used in codebase |
|---------|-----------------|-----------------|
| google_generative_ai | ^0.4.6 | No |
| connectivity_plus | ^6.0.2 | No |
| path_provider | ^2.1.3 | No |
| flutter_secure_storage | ^9.0.0 | No |
| cached_network_image | ^3.3.1 | No |
| shimmer | ^3.0.0 | No |
| lottie | ^3.1.2 | No |

**9. Unused imports in maya_service.dart**  
`import 'dart:convert'` and `import 'package:http/http.dart' as http` are declared but never referenced. These are warnings, not blockers.

### Security Issue

**10. Non-constant-time HMAC comparison in Zinnipay webhook**  
File: `supabase/functions/zinnipay-webhook/index.ts`  
`if (signature !== expectedSig)` uses JavaScript string equality, which short-circuits. This is a timing oracle: an attacker can probe response latency to reconstruct a valid signature and forge a webhook that grants a free subscription. This is a financial security issue.

---

## What Prevents Launch

In priority order:

### P0 — Blocks the first build (fix in hours)
1. **Missing font files** — App will not compile. Download Plus Jakarta Sans (4 weights) and DM Mono (Medium) from Google Fonts and place in `assets/fonts/`. (~30 min)

### P1 — Blocks production use (fix before any real user touches the app)
2. **No subscription gate** — Any authenticated user bypasses the paywall and uses the full product for free. Add `hasSubscription` check to the router redirect. (~2 hours)
3. **No onboarding gate** — New users skip profile setup and land on dashboard with no name, no goal, no language preference set. Maya gets no context for personalisation. (~1 hour)
4. **Webhook timing attack** — Replace `!==` with a constant-time compare using Deno's `timingSafeEqual`. A forged webhook grants a free ৳2,999 subscription. (~30 min)
5. **Maya receives no day context** — Every session, regardless of curriculum day, gets generic coaching. The product's core differentiator (structured 30-day programme) is broken. (~30 min)
6. **Journey completion never recorded** — Users can complete every session and their journey map will always show Day 1 as current. Streak logic also relies on this. (~30 min)

### P2 — Blocks App Store / Play Store submission
7. **No Android native project** — Only `AndroidManifest.xml` exists. `build.gradle`, `MainActivity.kt`, `google-services.json`, and Gradle wrapper files are absent. Flutter cannot build an APK or AAB without them. These are generated by `flutter create` and may exist locally but were never committed. (~1 day to set up and commit)
8. **No iOS Xcode project** — Only `Info.plist` exists. The `.xcodeproj`, `Podfile`, and Runner source files are absent. Cannot build an IPA. (~1 day to set up)
9. **Supabase project not provisioned** — Migrations must be run, Edge Functions deployed, and six secrets set (`GEMINI_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `ZINNIPAY_SECRET_KEY`, `ZINNIPAY_MERCHANT_ID`, and the two Supabase URL/anon key values) before any integration works. (~1 day)
10. **`--dart-define` secrets not configured** — If the app is built without these flags, it runs with placeholder strings (`'your-anon-key'`) and all Supabase calls silently fail. Must be wired into the CI/CD or build script. (~2 hours)
11. **Privacy Policy and Terms of Service pages not implemented** — App Store and Play Store both reject apps without links to hosted legal documents. (~0.5 day to link external URLs)
12. **Stream subscription leak** — Not a launch blocker per se, but will manifest as degraded performance and crash reports after moderate usage. Fix before public launch. (~30 min)

---

## Estimated Days to MVP (Shipped to Stores)

This estimate assumes one experienced Flutter developer who knows the codebase.

| Phase | Work | Days |
|-------|------|------|
| **P0: Make it compile** | Font files | 0.5 |
| **P1: Make the core loop correct** | Subscription gate, onboarding gate, Maya day context, journey completion wiring, webhook fix, stream leak fix | 3 |
| **P2: Platform setup** | Commit Android + iOS native project files, Supabase provisioning, Edge Function deployment, build script secrets, payment sandbox test | 3 |
| **P3: Pre-submission polish** | Settings screen legal links, Lottie file or removal, remove unused packages, end-to-end QA on real device | 2 |
| **App Store / Play Store submission prep** | Screenshots, store listing copy, app icon, privacy policy hosted URL | 2 |
| **Review wait** | Apple typically 1–3 days; Google Play 3–7 days | not dev time |

**Total developer time: ~10–11 days**  
**Calendar time to first store listing (including review): ~3 weeks**

The codebase is architecturally sound and feature-complete at the screen level. The gaps are wiring issues, not missing features. A focused developer can get this to a shippable APK in under two weeks.
