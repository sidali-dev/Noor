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
- Adhkar content lives in the bundled `assets/data/adhkar.json`. Quran text comes from the `quran` package, rendered with the bundled Quran font.
- Three languages (ar, fr, en) through generated `S` localisations; Paper (light) and Night (dark) themes.
- Qibla needs location permission, GPS and a compass sensor.
- No account, no analytics, no ads.

## Brand Commitments
Name: Faith in every language. Design system: Hilal, in cut paper. Surfaces are layered sheets of paper lifted by shadow; hierarchy comes from that layering, not from colour, borders or gradients. Two themes: Paper (light, cool card-stock) and Night (dark, a near-black ground with the same layering). A "window" is the night sky seen through a cut-out; it is always framed by raised paper, and in Night its buttons and tabs invert to moon-white. Brass is the single warm accent and means the one current thing (the next prayer, the place you left off, the qibla); it appears at most once per region. Brand mark: the new Faith logo in `docs/design-system/assets/Logos/` (Paper and Night lockups, mark, app icon), for the app icon, the splash and the Prayers hero. The old teal-mint emblem and its gradient are retired. Type: Cormorant Garamond and Jost for Latin, Amiri for all Arabic; Western digits 0–9 in every locale. The contract is in `DESIGN.md`. The Dart package name `noor` and the application id `com.sidalidev.noor` stay unchanged.

## Evidence on Hand
Reading progress, search and compass calibration are new features: progress is computed only from pages the user actually dwelled on, search runs over real adhkar and surah data, and the calibration sheet guides the user but never claims to calibrate the sensor. None of these may show invented numbers.

## Product Principles
1. Calm over clever: nothing flashes, nothing competes with the text of worship.
2. One obvious action per screen; everything else is a quiet secondary.
3. Arabic is the primary script, never a translation afterthought; layouts mirror cleanly.
4. Preserve trust: alarms and saved state behave exactly as before.

## Accessibility & Inclusion
Body text at least 4.5:1 contrast in both themes, 48dp touch targets, respect system text scale, no information carried by colour alone.

<!-- Inferred, not interviewed: the user supplied a complete brief and references, so platform, users and principles were derived from the codebase and the brief. Confirm or correct. -->
