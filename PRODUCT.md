# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users
Muslims who keep a daily practice on their phone: checking prayer times, hearing the adhan, reading Quran, reciting adhkar, finding the qibla. Used in short moments between tasks, at the mosque door, at dawn and before sleep, one-handed. Arabic, French and English speakers; Arabic (RTL) is the default language.

## Product Purpose
Noor puts a Muslim's daily worship in one calm, offline-friendly app: adhan alarms (with before/after reminders), the Mushaf by page, categorised adhkar with a repetition counter, and a qibla compass. Success is that the user opens it, does the one thing they came for in seconds, and closes it.

## Capabilities and Constraints
- Prayer times come from the aladhan.com calendar API and are cached per year in shared preferences. Adhan and reminder alarms use the `alarm` plugin; a Workmanager task reschedules them every 12 hours. Alarm IDs and preference keys are persisted and must not change.
- Adhkar content lives in the bundled `assets/noor.db` (SQLite). Quran text comes from the `quran` package, rendered with the bundled Quran font.
- Three languages (ar, fr, en) through generated `S` localisations; light and dark themes.
- Qibla needs location permission, GPS and a compass sensor.
- No account, no analytics, no ads.

## Brand Commitments
Name: Noor Imene (نور الإيمان, "light of faith"). Brand mark: the arch-and-book emblem for the app icon and the custom splash; the small star mark beside the serif wordmark "Noor Imene" in screen headers. The Dart package name `noor` and the application id `com.sidalidev.noor` stay unchanged. References that are binding: `assets/screens/screens.png`, `assets/screens/splash.png` and `assets/screens/splash_dark.png`.

## Evidence on Hand
Three reference screens (Adhkar, Qibla, Quran) in `assets/screens/`. Reading progress, search and compass calibration are new features: progress is computed only from pages the user actually dwelled on, search runs over real adhkar and surah data, and the calibration sheet guides the user but never claims to calibrate the sensor. None of these may show invented numbers.

## Product Principles
1. Calm over clever: nothing flashes, nothing competes with the text of worship.
2. One obvious action per screen; everything else is a quiet secondary.
3. Arabic is the primary script, never a translation afterthought; layouts mirror cleanly.
4. Preserve trust: alarms and saved state behave exactly as before.

## Accessibility & Inclusion
Body text at least 4.5:1 contrast in both themes, 48dp touch targets, respect system text scale, no information carried by colour alone.

<!-- Inferred, not interviewed: the user supplied a complete brief and references, so platform, users and principles were derived from the codebase and the brief. Confirm or correct. -->
