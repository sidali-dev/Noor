# Noor rebrand + hardening: execution plan

Goal: rebuild every screen, sheet, dialog and shared component of Noor around the reference style (`assets/screens/Noor Islamic App UI Showcase 1-3.png`, recorded in [design.md](design.md)), fix the bugs found in the audit, and keep all existing features and business logic.

How to use this file: run **waves in order**. Inside a wave, open one fresh Claude Code session per prompt and run them **at the same time**; their file ownership is disjoint. Paste a prompt as-is. Every prompt is self-contained and tells the session which other sections of this file to read, so no context is carried between sessions.

---

## 0. Before you start

1. Commit the current baseline (toolchain fixes, deprecation fixes, `PRODUCT.md`, `design.md`, fonts):
   `git add -A && git commit -m "Baseline: fix build toolchain, add design docs and fonts"`
2. Use a branch: `git switch -c rebrand`.
3. Have the emulator running (`emulator-5554`). Only Wave 4 needs it.

### Decisions assumed (change these here before starting if you disagree)

| # | Decision | Assumed |
|---|---|---|
| D1 | Features shown in the references that the app lacks (per-surah progress bars, search icon, compass "calibrate") | **Not built.** The calibrate button becomes the existing compass-tips sheet. No fake data. |
| D2 | Distance to the Kaaba on the Qibla screen | **Built** (one Geolocator call; the row hides on failure). |
| D3 | Fonts | IBM Plex Sans Arabic (UI), Spectral (numerals, wordmark, Latin titles), Amiri (Arabic titles and dhikr), Quran font unchanged. Poppins removed at the end. |
| D4 | Tab labels | Follow the reference: Quran / Mosque (المسجد) / Adhkar / Qibla. |
| D5 | Native splash | Colours changed to the new paper tones; logo asset untouched. |
| D6 | Background-isolate notification strings (adhan titles and bodies in `helper_functions.dart`) | **Left hardcoded.** They run in the Workmanager isolate where `S` may not be loaded. |
| D7 | Prefetching next year's prayer times in December | **Out of scope.** The Dec 31 fallback is "today's time plus one day". |

---

## 1. Bug and improvement register (what the waves fix)

| ID | Pri | Problem | Where | Fixed in |
|---|---|---|---|---|
| B1 | P0 | Adhan not scheduled on the last day of each month: `data[month][day]` is read for "tomorrow" and throws `RangeError` | [adhan_controller.dart:132](lib/features/adhan/adhan_controller.dart#L132), [adhan_line_controller.dart:77](lib/features/adhan/controllers/adhan_line_controller.dart#L77) | 1.B |
| B2 | P0 | Fallback "tomorrow" time is built from today's timing | [helper_functions.dart:152](lib/utils/helpers/helper_functions.dart#L152) | 1.B |
| B3 | P0 | `selectedIndex = index.obs` replaces the Rx, breaking the nav `Obx` ("Open Adhkar" from the ring screen) | [bottom_navigation.dart:146](lib/bottom_navigation.dart#L146) | 1.A |
| B4 | P0 | Adhkar: `cards` appended on every build, global singleton controller leaks state between categories, first card always starts at repetition 1 | [adhkar_display_screen.dart:22](lib/features/duaa/adhkar_display_screen.dart#L22), [adhkar_display_controller.dart:6](lib/features/duaa/adhkar_display_controller.dart#L6) | 2.B |
| B5 | P0 | Location flow copy-pasted twice, double `Get.back()`, `!` on nullable placemark fields | [adhan_screen.dart](lib/features/adhan/adhan_screen.dart), [get_locatiol_widget.dart](lib/generals/widgets/get_locatiol_widget.dart), [pick_search_option.dart](lib/generals/widgets/pick_search_option.dart) | 2.A |
| B6 | P1 | `FutureBuilder(future: initController())` created inside `build` (reloads on every rebuild) | [adhan_screen.dart:124](lib/features/adhan/adhan_screen.dart#L124) | 3.A |
| B7 | P1 | `AdhanLineController()` created inline on every rebuild; expanded alarm panel collapses | [adhan_screen.dart:391](lib/features/adhan/adhan_screen.dart#L391) | 3.A |
| B8 | P1 | Six-way switch copy-pasted in `switchAdhan`, `scheduleAdhans`, `scheduleAlarms`, `AdhanLine` | adhan feature | 1.B, 3.A |
| B9 | P1 | `QiblaController.onClose` calls `super.dispose()`; `GetBuilder(init:)` and `getLocation()` inside `build` | [qibla_controller.dart:23](lib/features/qibla/qibla_controller.dart#L23) | 3.B |
| B10 | P1 | Quran reader: `PageController` created in `build` (page resets on rebuild), page text built with `+=` | [read_quran_screen.dart:19](lib/features/quran/mini%20screens/read_quran_screen.dart#L19) | 2.C |
| B11 | P1 | `SharedPrefService.get…!` (48 call sites) crashes if a key is missing (upgrade path) | everywhere | 1.B (per-key defaults) |
| B12 | P1 | Fake 1 s delays in settings; always-running 15 s gradient on the ring screen; one `AudioPlayer` per sound row; four precached background PNGs | settings dialog, ring screen, sound picker, `my_app.dart` | 0.1, 1.A, 2.D, 3.A |
| B13 | P1 | Theme hardcodes the Arabic font for all languages (`getLightTheme(true)`); adhkar text set in Poppins | [my_app.dart:42](lib/my_app.dart#L42), adhkar display | 0.1, 2.B |
| B14 | P2 | "verses" hardcoded in English | [surah_line.dart:55](lib/features/quran/widgets/surah_line.dart#L55) | 0.2, 2.C |
| B15 | P2 | `duaa_screen.dart` repeats one 20-line block 19 times (510 lines) | duaa feature | 2.B |
| B16 | P2 | Dead code and old palette: `SColors`/`SSizes` (286 uses), 8 theme files, `SDivider`, `CustomIconButton`, unused assets and packages | utils, assets, pubspec | 4.1 |

---

## 2. Wave map

| Wave | Run | Prompts | Gate before next wave |
|---|---|---|---|
| **0** Foundation | together | 0.1 theme, tokens, fonts · 0.2 l10n keys | `flutter pub get && flutter analyze && flutter test` |
| **1** Shared parts and logic | together | 1.A shared widgets, nav, settings sheet · 1.B adhan logic, storage defaults, tests | same |
| **2** Features, set 1 | together | 2.A location flow · 2.B Adhkar · 2.C Quran · 2.D ring screen, splash | same |
| **3** Features, set 2 | together | 3.A Adhan screen · 3.B Qibla | same |
| **4** Finish | **one at a time** | 4.1 cleanup → 4.2 device audit → 4.3 fix batch → 4.4 final check | none |

After each wave: `git add -A && git commit -m "Wave N: …"`.

Prompt count: 14. Each is scoped to one feature or layer so a session reads roughly 5–15 files.

---

## 3. Ground rules (every prompt says "read this section")

- Stack: Flutter 3.44, Material 3, GetX (state and routing), `S` for strings (`lib/generated/l10n.dart`). Do not add packages. Do not change versions.
- **Never change** persisted preference keys, alarm IDs or `noor.db`: `fajr chourouk dhuhr asr maghrib isha`, `101/102 … 601/602`, `*_alarm_1_duration` / `*_alarm_2_duration`, `adhan_sound_path`, `adhan_sound_name`, `last_read_quran`, `quran_bookmark` (page numbers joined by `-`), `country state city`, `language`, `isDarkTheme`.
- **File ownership:** a prompt may create or edit only the paths it lists. If something outside them needs changing, do not do it; put one line under "Notes for others" in your final reply.
- **Parallel-safe commands only** inside Waves 0–3: `flutter analyze <your paths>` and `flutter test <your test file>`. Do **not** run `flutter pub get` (except 0.1 and 4.1), `flutter build`, `flutter run` or `dart format .`. Analyzer errors in files you do not own are other sessions mid-edit; ignore them.
- Do not commit. The owner commits after each wave.
- Read only the files you need. Do not open `assets/screens/*.png` unless your prompt names one.
- Design: follow [design.md](design.md). No gradient text, no side-stripe borders, no nested cards, no emoji as icons, no photographic backgrounds, no blue or purple chrome. One primary action per screen. All colours and text styles come from the theme contract below; no hex literals in feature code.
- RTL is native: use `EdgeInsetsDirectional`, `AlignmentDirectional`, mirror chevrons and back arrows with `Directionality.of(context)`. The brand header stays LTR.
- Every screen and sheet must work in ar / fr / en and light / dark, with text scale up to 1.3, without overflow.
- Final reply format, at most 10 lines: what changed, anything blocked, "Notes for others".

---

## 4. Contracts (what earlier waves must create, later waves may rely on)

### 4.1 Theme contract: `lib/utils/theme/noor_theme.dart` (built in 0.1)

`import 'package:noor/utils/theme/noor_theme.dart';`

- `context.noor` returns `NoorColors` with: `paper card line ink body muted primary onPrimary gold danger mushaf`, plus `Color tintBg(NoorTint)` and `Color tintFg(NoorTint)`.
- `enum NoorTint { sage, amber, blue, lilac, mint }`
- `NoorSpace`: `xs=4 sm=8 md=12 lg=16 xl=20 xxl=24 xxxl=32`
- `NoorRadius`: `card=20 tile=16 input=14 sheet=28`
- `NoorText` static methods taking `BuildContext c`: `display(c)` (34; Amiri bold for ar, Spectral 500 otherwise), `section(c)` 20/600, `rowTitle(c)` 17/600, `body(c)` 15/400 h1.5, `meta(c)` 13 muted, `numeral(c, {double size = 22, Color? color})` Spectral 500 tabular figures, `wordmark(c)` Spectral 26/500, `dhikr(c)` Amiri 24 h1.9.
- `List<BoxShadow> noorShadow(BuildContext c)`: soft green-tinted shadow in light, empty in dark.
- `NoorTheme.light()` and `NoorTheme.dark()` return `ThemeData`.
- Font families in `pubspec.yaml`: `Plex`, `Spectral`, `Amiri`, `Quran`.

### 4.2 Shared widget contract: `lib/generals/widgets/` (built in 1.A)

| Widget | Signature (named params) |
|---|---|
| `NoorMark` (sunburst) | `size` |
| `NoorHeader` | none; sunburst + "Noor" wordmark at the start, settings icon button at the end (opens `showSettingsSheet`) |
| `NoorCard` | `child`, `onTap?`, `padding?` |
| `IconTile` | `icon` (IconData) **or** `svg` (asset path), `tint` (NoorTint), `size = 48` |
| `NoorListRow` | `leading`, `title`, `meta?`, `trailing?` (defaults to mirrored chevron), `onTap` |
| `NoorSegmented<T>` | `items` (`List<({T value, String label})>`), `value`, `onChanged` |
| `NoorPill` | `icon`, `label`, `onTap`, `trailing?` |
| `NoorButton` | `label`, `onPressed`, `icon?`, `variant` (`NoorButtonVariant.primary / tonal / outline`) |
| `showNoorSheet<T>(context, {title, builder})` | themed modal bottom sheet, drag handle, scroll-safe, keyboard-safe |
| `EmptyState` | `message`, `actionLabel?`, `onAction?`, `lottie?` (asset path) **or** `icon?` |
| `WaitDialog`, `CheckDialog` | constructors unchanged (`isDark`/`isRtl` ignored); restyled |
| `showSettingsSheet(context)` | dark mode switch, language segmented control |
| `SBottomNavigation({pageIndex})` | floating `NoorNavBar`, order Quran, Mosque, Adhkar, Qibla. `pageIndex` = initial tab. |

All four tab screens keep no-argument constructors: `QuranScreen()`, `AdhanScreen()`, `DuaaScreen()`, `QiblaScreen()`.

### 4.3 Adhan logic contract (built in 1.B, used by 3.A)

- `lib/features/adhan/models/prayer.dart`: `class Prayer { key, adhanId, alarmId1, alarmId2, durationKey1, durationKey2 }`, `Prayer.all` (fajr, chourouk, dhuhr, asr, maghrib, isha) holding today's literal keys and IDs.
- `AdhanController` additions (old members stay until 3.A removes them): `RxBool enabledFor(String key)`, `Future<void> toggle(String key)` (sets the pref, cancels the alarm or reschedules), `Timings? timingsFor(DateTime d)` (handles month and year rollover, null if missing), `Timings? get selectedTimings`, `Prayer? nextPrayer()` (today only), `RxBool isLoading`, and `onInit` loads the current year once.
- `AdhanLineController` static additions: `List<({int slot, int minutes})> reminders(Prayer p)`, `Future<void> addReminder(Prayer p, int minutes, String timing)`, `Future<void> removeReminder(Prayer p, int slot)`.

### 4.4 Location contract (built in 2.A, used by 3.A and 3.B)

- `LocationPill()` widget in `lib/generals/widgets/location_pill.dart`: shows pin + "Country, City" (or `S.enter_location`) + chevron; tapping runs `pickLocation(context)`.
- `Future<void> pickLocation(BuildContext context)` in `lib/generals/location_flow.dart`: the single flow (wait, internet check, GPS or manual, refresh data, reschedule adhans).
- `GetLocationWidget` stays as a thin wrapper around `LocationPill` until 3.A and 3.B delete it.

---

## 5. Prompts

Each prompt starts with `/ponytail:ponytail ultra`. UI prompts also tell the session to use `/impeccable`.

---

### WAVE 0: run 0.1 and 0.2 together

#### 0.1 Theme, tokens, fonts

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the token and theme work.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules" and "4.1 Theme contract". (To read only a section, grep -n for its heading and read that line range.)

Task: build the new theme foundation exactly as the "Theme contract" says.

You own (create/edit only these):
- pubspec.yaml (fonts section only)
- lib/utils/theme/noor_theme.dart (new)
- lib/my_app.dart
- assets/fonts/LICENSES.md (new, one paragraph: IBM Plex Sans Arabic, Spectral and Amiri are SIL OFL 1.1)
- test/noor_theme_test.dart (new)

Steps:
1. pubspec.yaml: register family "Plex" from assets/fonts/plex/IBMPlexSansArabic-{Regular 400, Medium 500, SemiBold 600, Bold 700}.ttf and family "Spectral" from assets/fonts/spectral/Spectral-{Regular 400, Medium 500, SemiBold 600}.ttf. The files are already in the repo. KEEP Poppins, Amiri and Quran entries (old screens still use them until Wave 4). Run `flutter pub get` once.
2. noor_theme.dart: implement NoorColors as a ThemeExtension with the light and dark values from design.md (add `mushaf`: light #FBF6E8, dark #121A16). Implement NoorTint, NoorSpace, NoorRadius, NoorText, noorShadow, the `context.noor` extension, NoorTheme.light()/dark(). ThemeData: useMaterial3, fontFamily 'Plex' with fontFamilyFallback ['Amiri'], a ColorScheme built from the tokens, scaffoldBackgroundColor = paper, plus minimal themes: dividerTheme (line, 1px), bottomSheetTheme (card, top radius 28), dialogTheme (card, radius 24), inputDecorationTheme (filled card, radius 14, no border until focus), switchTheme (primary track when on), textSelectionTheme (primary cursor and selection), iconTheme (ink). Add NoorTheme extension registration. Do NOT delete the old theme files or SColors/SSizes yet.
3. my_app.dart: use NoorTheme.light()/dark() (remove the `getLightTheme(true)` Arabic-font hack), delete the four precacheImage calls, wrap the app via `builder:` in an AnnotatedRegion<SystemUiOverlayStyle> (transparent status and nav bar, icon brightness from the current theme brightness). Keep FlutterNativeSplash.remove(), localisation delegates, locale and themeMode logic.
4. test/noor_theme_test.dart: for light and dark assert contrast(body on card) >= 4.5, contrast(muted on card) >= 4.5, contrast(onPrimary on primary) >= 4.5, and that Theme.of(context).extension<NoorColors>() is non-null. Compute contrast from Color.computeLuminance().

Acceptance: `flutter analyze lib/utils/theme lib/my_app.dart test` is clean and `flutter test test/noor_theme_test.dart` passes. If a contrast assertion fails, adjust the token slightly (keep the hue), do not weaken the test, and mention the changed hex in your reply.
```

#### 0.2 Localisation keys

```text
/ponytail:ponytail ultra

Read first: plan.md section "3. Ground rules" only.

Task: add the new strings the redesign needs to the three ARB files and regenerate the localisation code.

You own: lib/l10n/intl_en.arb, lib/l10n/intl_ar.arb, lib/l10n/intl_fr.arb, lib/generated/** (generated output only).

Add these keys to all three files (keep the existing keys and style; ar is the default language so give it care). Keys with {count} need an "@key" placeholders entry in the English file in the same format intl_utils expects:

nav_quran: Quran | القرآن | Coran
nav_prayers: Mosque | المسجد | Mosquée
nav_adhkar: Adhkar | الأذكار | Adhkar
nav_qibla: Qibla | القبلة | Qibla
adhkar_subtitle: Peace for the heart, calm for the soul | راحة للقلوب .. وطمأنينة للنفوس | Le repos du cœur, l'apaisement de l'âme
quran_title: The Noble Quran | القرآن الكريم | Le Noble Coran
quran_subtitle: God's words, a light for your life | كلام الله .. نورًا لحياتك | La parole de Dieu, lumière de votre vie
verse_count ({count}): {count} verses | {count} آية | {count} versets
adhkar_count ({count}): {count} adhkar | {count} ذكر | {count} adhkar
meccan: Meccan | مكية | Mecquoise
medinan: Medinan | مدنية | Médinoise
qibla_direction: Qibla direction | اتجاه القبلة | Direction de la Qibla
distance_to_kaaba: Distance to the Kaaba | المسافة إلى الكعبة | Distance jusqu'à la Kaaba
next_prayer: Next | التالية | Prochaine
remove: Remove | إزالة | Supprimer
done: Done | تم | Terminé
try_again: Try again | أعد المحاولة | Réessayer
open_settings: Open settings | افتح الإعدادات | Ouvrir les réglages
reminders: Reminders | التنبيهات | Rappels
location_failed: Couldn't find your location | تعذر تحديد موقعك | Impossible de trouver votre position

Then run: dart pub global run intl_utils:generate
(intl_utils is globally activated. If it is not found: dart pub global activate intl_utils.)
Do not run flutter pub get.

Acceptance: `flutter analyze lib/generated lib/l10n` is clean, and `S.of(context).verse_count(5)` / `adhkar_count(12)` exist in lib/generated/l10n.dart. Report the exact generated method signatures in your reply.
```

**Gate:** `flutter pub get && flutter analyze && flutter test`, then commit.

---

### WAVE 1: run 1.A and 1.B together

#### 1.A Shared widgets, nav bar, settings sheet

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for all UI in this task.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme contract", "4.2 Shared widget contract". Look at assets/screens/Noor Islamic App UI Showcase 1.png (header, rows, nav bar) and Showcase 3.png (segmented control). Do not open the other reference.

Task: build the shared component set and the navigation shell exactly as the "Shared widget contract" says.

You own:
- lib/generals/widgets/: noor_mark.dart, noor_header.dart, noor_card.dart, icon_tile.dart, noor_list_row.dart, noor_segmented.dart, noor_pill.dart, noor_button.dart, noor_sheet.dart, empty_state.dart, noor_nav_bar.dart, settings_sheet.dart (all new)
- lib/generals/widgets/check_dialog.dart and wait_dialog.dart (restyle in place, keep constructors)
- lib/generals/widgets/settings_dialog.dart (delete once settings_sheet.dart replaces it)
- lib/bottom_navigation.dart
- test/widgets/noor_widgets_test.dart (new)
Do not touch the other files in lib/generals/widgets/ (icon_button.dart, get_locatiol_widget.dart, pick_search_option.dart belong to later prompts).

Details:
- NoorMark: CustomPainter sunburst (about 12 rays of two alternating lengths around a small ring), colour from context.noor.primary. Geometry only.
- NoorHeader: always LTR (wrap in Directionality ltr). Mark + "Noor" (NoorText.wordmark) at the start, an IconButton (Iconsax.setting_4 or a Material icon) at the end that calls showSettingsSheet. 48dp target, 20dp side padding.
- NoorNavBar: floating card (margin 16 bottom and sides, radius 28, noorShadow), four items with existing SVGs (SImageString.quran, adhan, prayingHands, kaaba) tinted muted/primary plus a label from S (nav_quran, nav_prayers, nav_adhkar, nav_qibla), selected item gets primary colour and a 2dp underline pill. Use InkResponse, 48dp targets, Semantics(selected). Animate the underline with AnimatedContainer 200ms ease-out.
- SBottomNavigation: Scaffold with extendBody, the selected screen above the bar (only the selected tab is built; do not use IndexedStack, the compass must not run in the background). Keep SBottomNavigationController, its Alarm.ringStream subscription and permission checks, and FIX `changeIndex` (it replaces the Rx; set `.value`). Keep the constructor param name `pageIndex` and use it as the initial index. Remove the floating settings button (the header owns settings now). Keep Get.lazyPut calls for SoundPickerController, AdhanController, LocationController.
- settings_sheet.dart: showSettingsSheet(context) via showNoorSheet. Dark mode: a Switch row calling ThemeController.switchTheme() (no spinner, no delay). Language: NoorSegmented with العربية / English / Français, onChanged: localizationController.setLanguage(v), then `await AdhanController.scheduleAdhans()` and `SoundPickerController.updateAdhanName()` (no spinner, no delay). Keep the same controller calls the old dialog made.
- noor_sheet.dart: showNoorSheet uses showModalBottomSheet(isScrollControlled: true, useSafeArea: true), card background, top radius 28, drag handle, optional title in NoorText.section, content in a SingleChildScrollView with bottom padding for the keyboard and the system inset.
- WaitDialog / CheckDialog: restyle with context.noor (card, radius 24, calm spinner in primary using the existing flutter_spinkit or CircularProgressIndicator, lottie unchanged for CheckDialog). Do not use isDark/isRtl any more.
- test/widgets/noor_widgets_test.dart: pump NoorHeader, NoorCard, IconTile, NoorListRow, NoorSegmented, NoorPill, NoorButton (3 variants) and NoorNavBar inside MaterialApp(theme: NoorTheme.light()/dark(), locale ar then en, localizationsDelegates from S) and assert no exceptions and no overflow (tester.takeException() == null), once at text scale 1.0 and once at 1.3.

Acceptance: `flutter analyze lib/generals lib/bottom_navigation.dart test/widgets` is clean (errors in lib/features or unrelated utils are other sessions) and `flutter test test/widgets` passes.
```

#### 1.B Adhan logic, storage defaults, tests

```text
/ponytail:ponytail ultra

Read first: plan.md sections "1. Bug and improvement register" (B1, B2, B8, B11 rows), "3. Ground rules", "4.3 Adhan logic contract".

Task: fix the scheduling bugs and add the logic API the new Adhan screen will use. Do NOT touch any UI file and do NOT remove any existing public member (the old UI still uses them; a later prompt deletes them).

You own:
- lib/features/adhan/adhan_controller.dart
- lib/features/adhan/controllers/adhan_line_controller.dart
- lib/features/adhan/models/prayer.dart (new)
- lib/utils/helpers/helper_functions.dart (ONLY: setUpAdhan, saveInitialValues, and a small tidy of getAlarmText's dead `else {}` is in adhan_line_controller.dart)
- test/adhan_schedule_test.dart (new)

Steps:
1. prayer.dart: `Prayer` class and `Prayer.all` with today's exact literals: fajr (adhan 1, alarms 101/102), chourouk (2, 201/202), dhuhr (3, 301/302), asr (4, 401/402), maghrib (5, 501/502), isha (6, 601/602); duration keys `<key>_alarm_1_duration` and `<key>_alarm_2_duration`. Add a way to read a prayer's string from `Timings` (sunrise is the chourouk time).
2. B1/B2: add a pure function `Timings? timingsFor(PrayerTime pt, DateTime d)` (month key = d.month.toString(), index = d.day - 1, null if absent; it must work for Jan 31 -> Feb 1, Feb 28/29, Dec 31 -> missing next year). Use it in `AdhanController.scheduleAdhans` and `AdhanLineController.scheduleAlarms` for both today and tomorrow. If tomorrow is missing, fall back to today's timing and let the existing "+1 day" logic apply. In `SHelperFunctions.setUpAdhan` use `tomorrowTiming` (it currently re-reads `timing`).
3. B8: rewrite scheduleAdhans and scheduleAlarms as loops over Prayer.all. Behaviour must be identical to today: same ids, same pref keys, same early returns (no notification permission, no cached year data), same cancel-when-disabled.
4. Add the contract members to AdhanController: enabledFor(key) (return the existing RxBool fields so there is one source of truth), toggle(key) (what AdhanLine's onPressed does: flip the pref, cancel alarm `adhanId` when off, otherwise call scheduleAdhans), timingsFor(DateTime) instance wrapper, selectedTimings (uses `date.value`), nextPrayer() (today only, first prayer whose time is after now, else null), isLoading RxBool, and `onInit` calling `initController(DateTime.now().year)` once (keep initController public and idempotent).
5. Add the AdhanLineController statics from the contract (reminders, addReminder, removeReminder) reusing existing logic: first free slot, requires notification permission and minutes != 0, remove sets the bool false, duration 0 and `Alarm.stop(alarmId)`. Keep all existing members.
6. B11: make `saveInitialValues` set each default per key when that key is null (not only on first run): fajr true, chourouk false, dhuhr/asr/maghrib/isha true, country/state/city "", adhan_sound_path "assets/sounds/ahmad_alnafees.mp3", adhan_sound_name "أذان الشيخ النفيس", last_read_quran 1, quran_bookmark "", keep the isFirstRun flag.
7. test/adhan_schedule_test.dart (pure Dart, no plugins): build a tiny PrayerTime from JSON fixtures (look at lib/features/adhan/models/** for the shape; keep the fixture to the days you need) and assert timingsFor for: mid-month, Jan 31 -> Feb 1, Dec 31 with no next year (null), a leap day. Also assert Prayer.all keys/ids match the literals above.

Acceptance: `flutter analyze lib/features/adhan lib/utils/helpers test/adhan_schedule_test.dart` has no new errors (the old adhan UI must still compile) and `flutter test test/adhan_schedule_test.dart` passes. `git diff` shows no change to any preference key or alarm id.
```

**Gate:** `flutter analyze && flutter test`, then commit.

---

### WAVE 2: run 2.A, 2.B, 2.C and 2.D together

#### 2.A Location flow

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the sheets.

Read first: design.md, plan.md sections "3. Ground rules", "4.2 Shared widget contract", "4.4 Location contract", and bug B5 in section 1.

Task: replace the duplicated location flow with one function and one pill widget.

You own:
- lib/generals/location_flow.dart (new)
- lib/generals/widgets/location_pill.dart (new)
- lib/generals/widgets/get_locatiol_widget.dart (reduce to a thin wrapper that keeps the old constructor `GetLocationWidget({isDark, isRtl, controller})` and just renders LocationPill; a later prompt deletes it)
- lib/generals/widgets/pick_search_option.dart (delete; the GPS/Manual choice becomes a sheet inside location_flow.dart)
- lib/features/adhan/widgets/location_picker_dialog.dart (replace with lib/features/adhan/widgets/location_picker_sheet.dart: the CSCPickerPlus country/state/city picker inside a NoorSheet, Confirm/Cancel with NoorButton; same result map {country,state,city} and same "all three required" validation)
- lib/generals/widgets/icon_button.dart (delete once nothing under your ownership uses it; others may still import it, so grep first and leave it if used)

Behaviour of pickLocation(context) (one owner for each navigator pop; use the passed context, check `context.mounted` after every await, do not use Get.context!):
1. Show WaitDialog, `SHelperFunctions.isInternetConnected()`; if offline: close wait, show CheckDialog(no_internet, SImageString.lottieNoInternet) and return.
2. Close wait, show a showNoorSheet with two big NoorCard choices: GPS (SImageString.location) and Manually (SImageString.manual).
3. GPS: wait dialog, `SHelperFunctions.getLocation()`; if country/administrativeArea/locality are null use sensible fallbacks (administrativeArea ?? subAdministrativeArea ?? locality; if country or city still missing show an error via CheckDialog with S.location_failed and lottieError) instead of `!`.
4. Manual: location_picker_sheet; if the result is empty do nothing.
5. On a result: wait dialog, `AdhanController.refreshAdhanData(country, state, city, DateTime.now().year)` (find it with Get.find), `AdhanController.scheduleAdhans()`, close wait. Wrap in try/catch: on error close wait and show the error CheckDialog.
Keep strings from S (gps, manually, enter_location, pick_location, confirm, cancel, no_internet, location_failed).

LocationPill: reads Get.find<AdhanController>().locationController.country/city (Obx); NoorPill with a pin icon, "Country, City" or S.enter_location, mirrored chevron; onTap => pickLocation(context). Use `Directionality` ltr for the place text only when it is Latin.

Acceptance: `flutter analyze lib/generals lib/features/adhan/widgets` has no errors in your files. Old screens still compile because GetLocationWidget still exists. Add a one-line widget test only if it is cheap (pump LocationPill with a fake registered controller); otherwise skip.
```

#### 2.B Adhkar

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme contract", "4.2 Shared widget contract", bug B4/B13/B15 in section 1. View assets/screens/Noor Islamic App UI Showcase 1.png (it is the reference for this screen). Do not open the other references.

Task: rebuild the Adhkar tab and the adhkar reader.

You own: lib/features/duaa/** and lib/utils/local_storage/services/database_service.dart.

Steps:
1. database_service.dart: add `static Future<Map<int,int>> getAdhkarCounts()` using one `SELECT dhikr_type, COUNT(*) AS c FROM adhkar_table GROUP BY dhikr_type`. Keep getAdhkar.
2. lib/features/duaa/adhkar_categories.dart (new): a const list of the 19 categories: type id (1 morning, 2 evening, 3 prayer, 4 mosque, 5 wake-up, 6 sleep, 7 after prayer, 8 tasbeeh, 9 prophet duaa, 10 quranic duaa, 11 prophets' duaa, 12 general, 13 hearing adhan, 14 comprehensive duaa, 15 wudu, 16 home, 17 bathroom, 18 food, 19 hajj; use the ids exactly as in the current `adhkartypeMap` in duaa_screen.dart, which has 19 entries, all shown on screen), the S getter for the title (same strings the screen uses today), the existing svg asset (SImageString.*) and a NoorTint (morning sage, evening amber, prayer blue, sleep lilac, tasbeeh mint, the rest cycle through the five).
3. duaa_screen.dart: DuaaScreen keeps a no-arg constructor. NoorHeader, then a large title S.adhkar (NoorText.display) with the subtitle S.adhkar_subtitle (NoorText.meta, muted) as in the reference, then a ListView.separated of NoorListRow in NoorCards: IconTile(svg tinted with tintFg, tint), title = category title, meta = S.adhkar_count(count) from getAdhkarCounts (load once in a StatefulWidget initState; show rows immediately and fill counts when ready), onTap loads getAdhkar(type) and pushes AdhkarDisplayScreen. Leave bottom padding for the floating nav bar (about 96dp).
4. adhkar_display_screen.dart: StatefulWidget with LOCAL state (delete adhkar_display_controller.dart, there must be no Get.put singleton). Fix B4: build cards once, start the repetition counter from adhkar.first.dhikrRepetition, reset it on page change. Layout: back button (mirrored arrow) + title, a "n / total" label with a thin progress bar (use the existing smooth_page_indicator only if it stays clean; a plain LinearProgressIndicator is fine), a CarouselSlider (carousel_slider ^5; viewportFraction about 0.9, no infinite scroll) of NoorCards on the paper background, and one large primary counter button showing the remaining repetitions; tap decrements, light haptic (HapticFeedback.selectionClick), at 0 advance to the next card, at 0 on the last card show a calm completed state (check icon + S.done), do not loop. Dhikr text uses NoorText.dhikr (Arabic face). If a dhikr has two lines (the existing splitAtFirstNewLine logic) show the first line as a gold-free accent in `primary` and the rest as body. The info (dhikrInfo) opens showNoorSheet with the text. No background images (do not reference duaa_bg_img_*).
5. Delete the 19x copy-paste. No `Get.to` with `context` captured across an await without a mounted check.

Acceptance: `flutter analyze lib/features/duaa lib/utils/local_storage` is clean. Add test/duaa_categories_test.dart asserting the 19 type ids are unique and every category has a title and an asset path that exists on disk.
```

#### 2.C Quran

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme contract", "4.2 Shared widget contract", bugs B10/B14 in section 1. View assets/screens/Noor Islamic App UI Showcase 3.png (the reference for this screen). Do not open the other references.

Task: rebuild the Quran tab, its sheets and the reader. Preserve: surah list, hizb list, last-read, continue reading, bookmarks (add/remove/open), page-by-page reader with the Quran font.

You own: lib/features/quran/** (including renaming the folder "mini screens" to "screens" with `git mv` and fixing imports), test/quran_bookmarks_test.dart (new).

Steps:
1. Logic: add small pure helpers for the bookmark string (parse "12-45-" into List<int>, toggle, remove, serialise back to the same "-"-joined format) in ReadQuranScreenController (or a plain file in the quran folder) and use them everywhere instead of the three copies of split/join. Keep the stored format. Make QuranScreenController resilient: no `!` on missing prefs (fall back to page 1).
2. QuranScreen (no-arg ctor): NoorHeader; title S.quran_title (NoorText.display) + subtitle S.quran_subtitle on the start side, and a soft tinted round IconTile with the quran svg on the end side (the reference shows a book illustration; do not draw a picture); a compact NoorCard "continue reading": label S.last_read, "Surah name · S.page N" (Arabic name when the locale is ar), a primary NoorButton S.continue_reading, and a tonal icon button that opens the bookmarks sheet; below it a NoorSegmented (Surah / Hizb, S.surah, S.hizb) then the list. Use a CustomScrollView with SliverList.builder so 114 rows stay lazy. Leave bottom padding for the floating nav bar (about 96dp).
3. Surah row: NoorListRow with a number circle (tintBg sage, number in NoorText.numeral), Arabic name (NoorText.rowTitle, Amiri) and Latin name, meta = "S.verse_count(n) · S.meccan/S.medinan" (map quran.getPlaceOfRevelation: 'Makkah' -> meccan, else medinan). Hizb row: number circle, "S.hizb N", meta "S.page <starting page>". Tapping sets last_read_quran and opens the reader exactly as today (same prefs, same controller updates).
4. Bookmarks: showNoorSheet listing bookmarked pages as rows (title via getLineTitle, tap = open the reader at that page and set last_read_quran, trailing remove icon with S.remove); empty list shows EmptyState with S.no_bookmarks (lottie SImageString.lottieQuran). No auto-dismissing dialog.
5. Reader (B10): StatefulWidget; create the PageController once in initState and dispose it; RTL; background context.noor.mushaf; page text with the Quran font via a TextSpan list built with a StringBuffer or spans (surah name headers as centred Amiri lines in `gold`, not the old "~~~~{ name }~~~~" ASCII text; basmala line when a surah starts, except surah 1 and 9 as today); tap toggles a quiet top bar (mirrored back arrow, surah name + page, bookmark toggle) and a bottom page number; keep onPageChanged persisting last_read_quran and refreshing QuranScreenController.
6. test/quran_bookmarks_test.dart: parse/toggle/remove/serialise round trips, including empty string and trailing "-".

Acceptance: `flutter analyze lib/features/quran test/quran_bookmarks_test.dart` is clean and the test passes. Nothing outside lib/features/quran changed.
```

#### 2.D Ring screen, splash, entry point

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme contract", "4.2 Shared widget contract", bug B12 in section 1.

Task: redesign the alarm "ring" screen and align the native splash with the new palette.

You own: lib/features/adhan/adhan_ring_screen.dart, splash.yaml, and the files that `dart run flutter_native_splash:create` regenerates (android/app/src/main/res/**, android/app/src/main/res/values*/**, ios/Runner/**, but only the splash outputs).

Steps:
1. adhan_ring_screen.dart: keep behaviour (PopScope canPop false; `Alarm.stop(id)` on dispose; "Open Adhkar" stops the alarm then `Get.offAll(() => const SBottomNavigation(pageIndex: 2))` and drops the old `Get.put(SBottomNavigationController()); controller.changeIndex(2)` lines; "Close" stops the alarm then SystemNavigator.pop). Remove the 15 s looping gradient animation and the AnimationController. New look: flat paper background; small NoorMark at the top; a 64dp IconTile tinted by prayer (use SHelperFunctions.getAlarmColor(id) only as the icon colour); the title (alarmSettings.notificationSettings.title) in NoorText.display, centred; the time (DateFormat HH:mm) large in NoorText.numeral (size 56); the body text in NoorText.body muted; at the bottom two buttons: primary NoorButton S.open_adhkar, tonal NoorButton S.close; SafeArea; scrollable for large text scales.
2. splash.yaml: colour "#F6F3EB", color_dark "#0E1512" (both the flutter_native_splash and android_12 blocks). Keep images and branding. Run `dart run flutter_native_splash:create` once.

Acceptance: `flutter analyze lib/features/adhan/adhan_ring_screen.dart` has no errors in your file; `git status` shows only your paths changed. Do not run flutter build.
```

**Gate:** `flutter analyze && flutter test`, then commit.

---

### WAVE 3: run 3.A and 3.B together

#### 3.A Adhan screen

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1", "4.2", "4.3", "4.4", bugs B6/B7/B8/B12 in section 1. View assets/screens/Noor Islamic App UI Showcase 2.png only for the location pill and the card styling (this screen has no reference of its own). Do not open the other references.

Task: rebuild the Adhan (Mosque) tab and its sound picker. Preserve: location (tap to change), adhan sound choice, day navigation with the year bounds, six prayer rows with an adhan on/off toggle, up to two reminders per prayer with an offset of -60..+60 minutes (add/remove), no-location empty state.

You own: lib/features/adhan/** EXCEPT adhan_ring_screen.dart; lib/generals/widgets/get_locatiol_widget.dart (delete it, along with removing every use of it you own); test/adhan_screen_test.dart (new, optional).

Steps:
1. adhan_screen.dart (AdhanScreen, no-arg ctor): NoorHeader; LocationPill (from 2.A); a NoorPill showing the current adhan sound name (SoundPickerController.adhanSoundName) that opens the sound sheet; a NoorCard day navigator (mirrored arrows for rtl; same year-bound behaviour: on Jan 1 / Dec 31 show CheckDialog(year_ended, lottieCalendarOut); title = S.today or weekday + formatted date exactly as today); then one NoorCard with six prayer rows. Use the logic contract: `controller.selectedTimings`, `controller.enabledFor(key)`, `controller.toggle(key)`, `controller.nextPrayer()` (when the selected day is today, mark the next prayer with a `gold` dot and the S.next_prayer label), `controller.isLoading` for the loading state (no FutureBuilder in build, B6). No location yet: EmptyState with lottie SImageString.lottieAddLocation and a NoorButton S.add_location that calls pickLocation(context). Bottom padding about 96dp for the floating nav.
2. adhan_line.dart: StatefulWidget per prayer (state is local so rebuilds do not collapse it, B7). Row: IconTile (Iconsax icons as today), prayer title, time in NoorText.numeral, a speaker toggle (volume_high / volume_cross) wired to controller.toggle, a chevron that rotates when expanded. Expanded panel (AnimatedSize 250 ms): the active reminders via AdhanLineController.reminders(prayer) each with text from getAlarmText and a remove button (removeReminder); if fewer than two exist, a minutes stepper (-/+ in steps of 1, range -60..60, 0 not allowed) with a NoorButton tonal S.set_new_alarm that calls addReminder(prayer, minutes, time). Keep keys via Prayer.all.
3. sound picker: replace sound_picker_dialog.dart with a sheet (showNoorSheet): five rows, radio indicator for the selected one, a play/pause preview button per row using ONE AudioPlayer (the shared SoundPickerController.player) so only one preview plays, stop the preview when the sheet closes; tapping a row saves `adhan_sound_path` and `adhan_sound_name`, calls updateAdhanName() and AdhanController.scheduleAdhans(), closes. Delete divider.dart and the per-row `SoundPickerController()` instances.
4. Remove the deprecated members the old UI needed (legacy adhanFajr… fields, switchAdhan, per-instance AdhanLineController state) from adhan_controller.dart / adhan_line_controller.dart ONLY after grepping that nothing else uses them; keep the static scheduling functions (main.dart's Workmanager callback uses AdhanLineController.scheduleAlarms and AdhanController.scheduleAdhans).
5. Replace any remaining GetLocationWidget use in files you own with LocationPill and delete get_locatiol_widget.dart. (The Qibla session replaces its own use; if grep shows lib/features/qibla still imports it when you finish, leave the file and say so in "Notes for others".)

Acceptance: `flutter analyze lib/features/adhan lib/generals` clean for your files; `flutter test` for your tests passes. Alarm ids, pref keys and scheduling behaviour are unchanged (verify with `git diff` on those literals).
```

#### 3.B Qibla

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1", "4.2", "4.4", bug B9 in section 1. View assets/screens/Noor Islamic App UI Showcase 2.png (the reference for this screen). Do not open the other references.

Task: rebuild the Qibla tab, the compass, the empty/permission states and the tips sheet. Preserve the flutter_qiblah stream logic, permission/GPS handling and sensor-support check.

You own: lib/features/qibla/** and test/qibla_screen_test.dart (new, optional).

Steps:
1. qibla_controller.dart (B9): fix onClose (do not call super.dispose(); close the StreamController, FlutterQiblah().dispose(), then super.onClose()). Create it once (Get.put in a StatefulWidget's initState with Get.delete in dispose, or Get.put with `permanent: false`); no `GetBuilder(init:)` inside build. Move `LocationController.getLocation()` out of build into initState. Add `Future<double?> distanceToKaabaKm()` using Geolocator.getLastKnownPosition() then getCurrentPosition(timeLimit 5 s) as a fallback, Geolocator.distanceBetween to the Kaaba (21.4225, 39.8262), rounded to a whole number; null on any failure.
2. qibla_screen.dart (QiblaScreen, no-arg ctor): NoorHeader, LocationPill (from 2.A), then the compass area, then a NoorCard "direction": label S.qibla_direction, the degrees (`qiblahDirection.offset.toStringAsFixed(2)°`) in NoorText.numeral size 56, a hairline, a row with S.distance_to_kaaba and "~ N km" in numerals (hide the row if null), and a tonal NoorButton with an info icon + S.tips that opens the tips sheet (the reference's "calibrate" button; do not invent calibration). States, each an EmptyState with one action: sensor unsupported (lottieError + S.sensor_not_supported), location permission denied (S.enable_location_permission, action runs the existing requestPermission + restartCheckLocationStatus), GPS off (S.enable_location, action as today), error (message + S.try_again). Loading: a calm spinner.
3. widgets/qibla_compass.dart: replace the SVG compass with a CustomPainter dial (compass_dial.dart): 1.5dp `primary` ring, a softer outer ring in `line`, 60 ticks (major every 15 degrees, longer), N/E/S/W in NoorText.numeral, rotated by `-direction` radians exactly as the old Transform.rotate did; a fixed `gold` heading tick at the top; the Kaaba glyph (assets/images/svg/kaaba.svg tinted `ink`) in a small round card at the centre; a `primary` arrow rotated by `-qiblah` radians exactly as before. Wrap the painter in RepaintBoundary; the dial must be at least 280dp and scale down on small screens (LayoutBuilder). Subscribe to FlutterQiblah.qiblahStream only while this widget is mounted.
4. qibla_tips_dialog.dart -> a sheet (showNoorSheet) with the three tips (flat_phone, keep_from_magnetic, enable_location) as rows with IconTiles. Delete the old dialog class.
5. Replace any GetLocationWidget use with LocationPill. Delete the old compass.svg/needle.svg references from code (4.1 deletes the files).

Acceptance: `flutter analyze lib/features/qibla` clean; rotating the dial and arrow uses the same sign conventions as before (state this in your reply and cite the two lines). Optional widget test: pump the screen's direction card with a fake stream value and assert the degrees text.
```

**Gate:** `flutter analyze && flutter test`, then commit.

---

### WAVE 4: run one at a time, in order

#### 4.1 Cleanup

```text
/ponytail:ponytail ultra

Read first: plan.md sections "3. Ground rules" (ignore the "parallel-safe commands" bullet: you are alone now, you may run pub get and analyze) and bug B16.

Task: delete everything the redesign made dead. Delete only after grepping that nothing references it.

Targets:
- lib/utils/constants/colors.dart (SColors), lib/utils/constants/sizes.dart (SSizes) if no usages remain; if a few remain in files that still compile, migrate them to the theme contract instead of keeping the old constants.
- lib/utils/theme/theme.dart and lib/utils/theme/widget_themes/** (old SAppTheme).
- lib/generals/widgets/icon_button.dart, get_locatiol_widget.dart (if still present), any remaining old dialogs.
- WaitDialog/CheckDialog: remove the now-ignored isDark/isRtl parameters and fix call sites.
- Unused image strings and assets: assets/images/background_images/** (bg_img_*, duaa_bg_img_*), assets/images/general/hizb_frame1.png, assets/images/svg/compass.svg and needle.svg, flags if unused, unused lottie files, unused svgs; keep pubspec asset lists in sync. Verify each asset path against `grep -rn` of its filename before deleting.
- Poppins: remove the family from pubspec.yaml and delete assets/fonts/poppins.
- Unused packages in pubspec.yaml (check each: iconsax, flutter_spinkit, smooth_page_indicator, lottie, flutter_svg, etc.); remove only the unused ones, then `flutter pub get`.
- Unused imports and dead helpers in lib/utils/helpers/helper_functions.dart (e.g. screenHeight(), screenWidth(), getLanguage() if now unused) and lib/utils/device/device_utility.dart.

Acceptance: `flutter pub get && flutter analyze && flutter test` all clean; `flutter build apk --debug` succeeds; report the size of the debug APK before/after if you can get the old number from build/app/outputs.
```

#### 4.2 Device audit (read-only)

```text
/ponytail:ponytail ultra
Use the /impeccable skill: command `audit`, then `critique`, mode Operate. Do NOT edit any file in this prompt.

Read first: PRODUCT.md, design.md, plan.md "3. Ground rules".

Task: one batched inspection round on the emulator (emulator-5554; adb is at C:\AndroidSDK\platform-tools). Build and install the debug app (`flutter run -d emulator-5554 --no-resident`), then screenshot with `adb exec-out screencap -p` into the session scratchpad (never into the repo).

Matrix, in ONE pass:
- Languages: ar (default), en, fr. Themes: light and dark.
- Screens: each of the 4 tabs; Adhkar category list (19 rows) -> reader (first card and an info sheet); Quran: surah list, hizb list, bookmarks sheet (empty and with an entry), reader with the top bar shown; Adhan: location empty state (clear app data first) and with a location set, a prayer row expanded with a reminder added; settings sheet; sound sheet; location flow sheets; Qibla in each state you can reach on the emulator (location permission denied, granted, GPS off); ring screen (trigger via a test alarm or `adb` intent if feasible, otherwise say it could not be triggered).
- Also once: font scale 1.3 (`adb shell settings put system font_scale 1.3`; reset to 1.0 after) on the four tabs in ar.

Compare each screen against the matching reference PNG and design.md. Output ONE report, ordered by severity (Blocker / Major / Minor), each item: screen, language/theme, what is wrong, the file to fix. Include a short "matches the reference" list and an explicit "Not verifiable on the emulator" list (real adhan firing in the background, real compass sensor). Also run the impeccable detector if available on the changed UI files and include its findings. Do not fix anything.
```

#### 4.3 Fix batch

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: polish, mode Operate) for the UI fixes.

Read first: design.md, plan.md "3. Ground rules" (you may run builds now). Below is the audit report from the previous step; fix every Blocker and Major item and the cheap Minor items, in one batch, touching only the files the report names:

<paste the 4.2 report here>

Then do one confirmation round: rebuild, re-screenshot only the screens you changed in ar light and en dark, confirm each fixed item, and stop. Do not start a new polishing loop. List anything you deliberately did not fix and why.
```

#### 4.4 Final check

```text
/ponytail:ponytail ultra

Read first: plan.md sections "1. Bug and improvement register" and "6. Definition of done".

Task: final verification, no new features. Run `flutter analyze`, `flutter test`, `flutter build apk --debug`. Confirm each bug B1..B16 against the code (cite the file and line that fixes it, or say it is not fixed). Run `git diff main --stat -- lib | tail -1` and `git diff main -- lib | grep -E "^[-+].*(\"fajr\"|\"chourouk\"|\"dhuhr\"|\"asr\"|\"maghrib\"|\"isha\"|alarm_[12]_duration|last_read_quran|quran_bookmark|adhan_sound_path|adhan_sound_name|isDarkTheme)"` and confirm no preference key or alarm id changed. Update README.md only if it describes anything that changed (theme, structure, fonts), keeping it short. Report PASS/FAIL per item and the list of things only a physical device can verify (background adhan alarms, Workmanager rescheduling, compass sensor).
```

---

## 6. Definition of done

- `flutter analyze` and `flutter test` clean; debug APK builds.
- All four tabs, the reader, the ring screen and every sheet/dialog use the shared components and tokens; no `SColors`/`SSizes`/Poppins/background-image references remain.
- B1–B16 resolved or explicitly deferred with a reason.
- ar / fr / en and light / dark verified on the emulator at font scale 1.0 and 1.3.
- No change to persisted keys, alarm IDs or `noor.db`.
- Physical-device checks listed for the owner: background adhan firing after reboot, Workmanager reschedule, compass sensor accuracy.

## 7. Risks and fallbacks

- **Concurrent sessions in one tree:** only own-path analyzers run in Waves 0–3, and nobody commits. If two sessions collide on a file, rerun the later prompt; ownership lists are disjoint by design.
- **Wave order matters:** 3.A and 3.B need `LocationPill` from 2.A; 2.x need the shared widgets from 1.A; everything needs 0.1 and 0.2. If a wave's gate fails, fix it before starting the next wave.
- **Generated l10n drift:** only 0.2 regenerates `lib/generated`. If a later prompt needs a string, it reports it under "Notes for others" and you add it in 4.3.
- **Alarm regressions can't be seen on the emulator.** 1.B's unit tests cover the date math; the owner must test a real adhan on a device.
