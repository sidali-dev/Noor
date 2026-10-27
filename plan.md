# Noor rebrand + rebuild: execution plan

Goal: rebuild every screen, sheet, dialog and shared component of Noor around the reference style (`assets/screens/Noor Islamic App UI Showcase 1-3.png`, recorded in [design.md](design.md)), replace the weak internals with clean ones, and keep every existing feature working. This is a full rebuild: old bad implementations are removed or replaced, not wrapped.

How to use this file: run **waves in order**. Inside a wave, open one fresh Claude Code session per prompt and run them **at the same time**; their file ownership is disjoint. Paste a prompt as-is. Every prompt is self-contained and names the sections of this file it needs, so no context is carried between sessions.

---

## 0. Before you start

Done already: baseline committed on `main` (`0cca658`), working on branch `rebrand`. Have the emulator running (`emulator-5554`); only Wave 4 needs it.

After each wave: `flutter pub get && flutter analyze && flutter test`, then `git add -A && git commit -m "Wave N: ..."`.

### Decisions (edit here before starting if you disagree)

| # | Decision | Chosen |
|---|---|---|
| D1 | Features in the references that the app lacked | **All built, on real data:** per-surah reading progress (pages you actually dwelled on) plus an overall progress bar, search (Adhkar categories and adhkar text; Quran surahs), and a compass calibration guide (animated figure-8 plus tips; the OS owns real sensor calibration, the app only guides). |
| D2 | Distance to the Kaaba | Built (one Geolocator call; hidden on failure). |
| D3 | Fonts | IBM Plex Sans Arabic (UI), Spectral (numerals, wordmark, Latin titles), Amiri (Arabic titles, dhikr), Quran font unchanged. Poppins removed at the end. |
| D4 | Tab labels | **Quran / Prayers (الصلاة, Prières) / Adhkar / Qibla.** Not "Mosque". |
| D5 | Native splash | Colours changed to the new paper tones; logo asset untouched. |
| D6 | Adhan notification text | **Rebuilt:** the three hardcoded 3-language switch blocks in `helper_functions.dart` are deleted. Texts come from the ARB files through the context-free `S.load(Locale)`, which also works in the Workmanager isolate. Reminder texts become two parameterised ARB keys instead of twelve hardcoded cases. |
| D7 | Adhan scheduling | **Rebuilt as one `AdhanScheduler`:** a rolling 3-day window (today + 2), re-synced on app start, on every settings change and by Workmanager, instead of "next occurrence only, refreshed every 12 h". Next year's calendar is fetched automatically from Dec 24 if missing. |
| D8 | Preferences | **Rebuilt as typed `AppPrefs`** (defaults built in, no `!`, one place for key names). Same preference keys on disk. |
| D9 | Network | **Rebuilt:** no google.com pre-flight ping, a 15 s timeout, `Uri.https` encoding, typed exceptions; location and data are saved together only after the fetch succeeds. |
| D10 | App name | **Noor Imene** (Latin wordmark in every language; Arabic text where a localised name is needed: نور إيمان). Package id `com.sidalidev.noor` and the Dart package name `noor` stay unchanged so installed apps keep updating. `assets/logo/brand-*.png` is the "Developed by SIDALI-DEV" credit, not the app name, so it stays. App icon artwork (`assets/logo/logo.png`) is yours to replace if it contains the old name. |

---

## 1. Bug and improvement register (what the waves fix)

| ID | Pri | Problem | Where | Fixed in |
|---|---|---|---|---|
| B1 | P0 | Adhan not scheduled on the last day of each month: `data[month][day]` is read for "tomorrow" and throws `RangeError` | [adhan_controller.dart:132](lib/features/adhan/adhan_controller.dart#L132), [adhan_line_controller.dart:77](lib/features/adhan/controllers/adhan_line_controller.dart#L77) | 1.B |
| B2 | P0 | Fallback "tomorrow" time is built from today's timing | [helper_functions.dart:152](lib/utils/helpers/helper_functions.dart#L152) | 1.B |
| B3 | P0 | `selectedIndex = index.obs` replaces the Rx, breaking the nav `Obx` ("Open Adhkar" from the ring screen) | [bottom_navigation.dart:146](lib/bottom_navigation.dart#L146) | 1.A |
| B4 | P0 | Adhkar: `cards` appended on every build, global singleton controller leaks state between categories, first card always starts at repetition 1 | [adhkar_display_screen.dart:22](lib/features/duaa/adhkar_display_screen.dart#L22) | 2.B |
| B5 | P0 | Location flow copy-pasted twice, double `Get.back()`, `!` on nullable placemark fields | adhan_screen, get_locatiol_widget, pick_search_option | 2.A |
| B6 | P1 | `FutureBuilder(future: initController())` created inside `build` | [adhan_screen.dart:124](lib/features/adhan/adhan_screen.dart#L124) | 3.A |
| B7 | P1 | `AdhanLineController()` created inline on every rebuild; expanded alarm panel collapses | [adhan_screen.dart:391](lib/features/adhan/adhan_screen.dart#L391) | 3.A |
| B8 | P1 | Six-way switch copy-pasted in four places | adhan feature | 1.B, 3.A |
| B9 | P1 | `QiblaController.onClose` calls `super.dispose()`; `GetBuilder(init:)` and `getLocation()` inside `build` | [qibla_controller.dart:23](lib/features/qibla/qibla_controller.dart#L23) | 3.B |
| B10 | P1 | Quran reader: `PageController` created in `build`, page text built with `+=` | [read_quran_screen.dart:19](lib/features/quran/mini%20screens/read_quran_screen.dart#L19) | 2.C |
| B11 | P1 | 48 raw `SharedPrefService.get…!` call sites crash on a missing key | everywhere | 0.3, then each owner |
| B12 | P1 | Fake 1 s delays in settings; always-running 15 s gradient on the ring screen; one `AudioPlayer` per sound row; four precached background PNGs | settings, ring, sound picker, `my_app.dart` | 0.1, 1.A, 2.D, 3.A |
| B13 | P1 | Theme hardcodes the Arabic font for all languages; adhkar text set in Poppins | [my_app.dart:42](lib/my_app.dart#L42), adhkar display | 0.1, 2.B |
| B14 | P2 | "verses" hardcoded in English | [surah_line.dart:55](lib/features/quran/widgets/surah_line.dart#L55) | 0.2, 2.C |
| B15 | P2 | `duaa_screen.dart` repeats one 20-line block 19 times (510 lines) | duaa feature | 2.B |
| B16 | P2 | Dead code and old palette: `SColors`/`SSizes` (286 uses), 8 theme files, `SDivider`, `CustomIconButton`, unused assets and packages | utils, assets, pubspec | 4.1 |
| B17 | P1 | Notification strings hardcoded in three languages, duplicating the ARB files | [helper_functions.dart:237](lib/utils/helpers/helper_functions.dart#L237) onward | 1.B |
| B18 | P1 | Network: google.com HEAD pre-flight (a 301 reads as "offline"), no API timeout, hand-built query string, location saved before the fetch succeeds | [http_client.dart](lib/utils/http/http_client.dart), `isInternetConnected`, `refreshAdhanData` | 1.B, 2.A |
| B19 | P1 | Alarms only exist for the next occurrence and are refreshed solely by a 12 h Workmanager job; if the OS delays it the adhan can be missed. No re-sync on app start. | main.dart, scheduling | 1.B |
| B20 | P2 | SQL built by string interpolation | [database_service.dart](lib/utils/local_storage/services/database_service.dart) | 1.C |
| B21 | P2 | `getHizbStartingPage` is a 60-case switch; `helper_functions.dart` is a 614-line static grab-bag | helper_functions.dart | 2.C, 4.1 |

---

## 2. Wave map

| Wave | Run | Prompts |
|---|---|---|
| **0** Foundation | together | 0.1 theme, tokens, fonts · 0.2 l10n keys · 0.3 typed `AppPrefs` |
| **1** Shared parts, engine, data | together | 1.A shared widgets, nav, settings · 1.B adhan engine and network · 1.C search, progress, DB |
| **2** Features, set 1 | together | 2.A location flow · 2.B Adhkar · 2.C Quran · 2.D ring screen, splash |
| **3** Features, set 2 | together | 3.A Prayers screen · 3.B Qibla |
| **4** Finish | **one at a time** | 4.1 cleanup → 4.2 device audit → 4.3 fix batch → 4.4 final check |

16 prompts. Each is scoped to one feature or layer, so a session reads roughly 5–15 files.

---

## 3. Ground rules (every prompt says "read this section")

- Stack: Flutter 3.44, Material 3, GetX (state and routing), `S` for strings (`lib/generated/l10n.dart`). Do not add packages and do not change versions.
- **Persisted data is sacred:** existing preference keys (`fajr chourouk dhuhr asr maghrib isha`, `101/102 … 601/602`, `*_alarm_1_duration`/`*_alarm_2_duration`, `adhan_sound_path`, `adhan_sound_name`, `last_read_quran`, `quran_bookmark` = page numbers joined by `-`, `country state city`, `language`, `isDarkTheme`, `Adhan<year>`), base alarm ids 1–6 and 101–602, and `assets/noor.db` keep their meaning. New additive keys are allowed (`quran_read_pages`); alarm ids ≥ 10000 are the new rolling-window offsets (section 4.3).
- **File ownership:** a prompt may create or edit only the paths it lists. If something outside them needs changing, do not do it; write one line under "Notes for others" in your final reply.
- **Parallel-safe commands only** inside Waves 0–3: `flutter analyze <your paths>` and `flutter test <your test file>`. Do **not** run `flutter pub get` (except 0.1, 4.1), `flutter build`, `flutter run` or `dart format .`. Analyzer errors in files you do not own are other sessions mid-edit; ignore them.
- Do not commit. The owner commits after each wave.
- Read only the files you need. Do not open `assets/screens/*.png` unless your prompt names one.
- Design: follow [design.md](design.md). No gradient text, no side-stripe borders, no nested cards, no emoji as icons, no photographic backgrounds, no blue or purple chrome. One primary action per screen. Colours and text styles come from the theme contract; no hex literals in feature code.
- RTL is native: `EdgeInsetsDirectional`, `AlignmentDirectional`, mirrored chevrons and back arrows. The brand header stays LTR.
- Every screen and sheet must work in ar / fr / en and light / dark, with text scale up to 1.3, without overflow.
- Prefer deleting to wrapping. If you replace something, remove the old thing in the same prompt when you own it; otherwise list it under "Notes for others" so 4.1 deletes it.
- Final reply format, at most 10 lines: what changed, anything blocked, "Notes for others".

---

## 4. Contracts (what earlier waves create, later waves may rely on)

### 4.1 Theme: `lib/utils/theme/noor_theme.dart` (0.1)

`import 'package:noor/utils/theme/noor_theme.dart';`

- `context.noor` returns `NoorColors`: `paper card line ink body muted primary onPrimary gold danger mushaf`, plus `Color tintBg(NoorTint)` and `Color tintFg(NoorTint)`.
- `enum NoorTint { sage, amber, blue, lilac, mint }`
- `NoorSpace`: `xs=4 sm=8 md=12 lg=16 xl=20 xxl=24 xxxl=32`; `NoorRadius`: `card=20 tile=16 input=14 sheet=28`
- `NoorText` statics taking `BuildContext c`: `display(c)` (34; Amiri bold for ar, Spectral 500 otherwise), `section(c)` 20/600, `rowTitle(c)` 17/600, `body(c)` 15/400 h1.5, `meta(c)` 13 muted, `numeral(c, {double size = 22, Color? color})` Spectral 500 tabular, `wordmark(c)` Spectral 26/500, `dhikr(c)` Amiri 24 h1.9.
- `List<BoxShadow> noorShadow(BuildContext c)`; `NoorTheme.light()` / `NoorTheme.dark()`.
- Font families: `Plex`, `Spectral`, `Amiri`, `Quran`.

### 4.2 Shared widgets: `lib/generals/widgets/` (1.A)

| Widget | Signature (named params) |
|---|---|
| `NoorMark` | `size` (sunburst) |
| `NoorHeader` | none; mark + app name `kAppName` ("Noor Imene", from `lib/utils/constants/app_name.dart`) at the start, settings icon at the end (opens `showSettingsSheet`) |
| `NoorCard` | `child`, `onTap?`, `padding?` |
| `IconTile` | `icon` (IconData) or `svg` (asset path), `tint`, `size = 48` |
| `NoorListRow` | `leading`, `title`, `meta?`, `trailing?` (default mirrored chevron), `onTap` |
| `NoorSegmented<T>` | `items` (`List<({T value, String label})>`), `value`, `onChanged` |
| `NoorPill` | `icon`, `label`, `onTap`, `trailing?` |
| `NoorButton` | `label`, `onPressed`, `icon?`, `variant` (`NoorButtonVariant.primary / tonal / outline`) |
| `NoorSearchField` | `hint`, `onChanged`, `controller?` (clear button, 48dp, RTL aware) |
| `NoorProgressBar` | `value` (0..1), `height = 4` (primary on line, animated) |
| `showNoorSheet<T>(context, {title, builder})` | themed modal bottom sheet, drag handle, scroll- and keyboard-safe |
| `EmptyState` | `message`, `actionLabel?`, `onAction?`, `lottie?` or `icon?` |
| `WaitDialog`, `CheckDialog` | constructors unchanged (`isDark`/`isRtl` ignored); restyled |
| `showSettingsSheet(context)` | dark mode switch, language segmented control |
| `SBottomNavigation({pageIndex})` | floating `NoorNavBar`: Quran, Prayers, Adhkar, Qibla. `pageIndex` = initial tab. |

The four tab screens keep no-argument constructors: `QuranScreen()`, `AdhanScreen()`, `DuaaScreen()`, `QiblaScreen()`.

### 4.3 Adhan engine (1.B; used by 2.A, 2.D, 3.A)

- `lib/features/adhan/models/prayer.dart`: `Prayer {key, adhanId, alarmId1, alarmId2, durationKey1, durationKey2}`, `Prayer.all` (fajr, chourouk, dhuhr, asr, maghrib, isha with today's literal keys and ids), a way to read the prayer's time from `Timings`.
- `lib/features/adhan/services/adhan_scheduler.dart`:
  - `AdhanScheduler.windowDays = 3`; `idFor(baseId, dayOffset) = baseId + dayOffset * 10000`; `baseOf(id) = id % 10000`.
  - pure `planAlarms(...)` returns the list of alarms to set (id, DateTime, kind adhan/reminder, prayer, minutes) and the ids to cancel, from now + cached calendar + enabled flags + reminders. No plugin calls.
  - `Future<void> sync()`: the single entry point; checks notification permission, reads `AppPrefs` and the cached calendar, runs `planAlarms`, applies it with `Alarm.set` / `Alarm.stop`, tops up next year's calendar from Dec 24.
  - `reminders(Prayer)` → `List<({int slot, int minutes})>`, `addReminder(Prayer, int minutes)`, `removeReminder(Prayer, int slot)`; both mutate `AppPrefs` then `sync()`.
- `lib/features/adhan/services/adhan_texts.dart`: builds notification title, body and stop-button text for adhans and reminders from `S.load(Locale(AppPrefs.languageCode))` (no BuildContext, safe in the background isolate).
- `AdhanController`: `RxBool enabledFor(String key)`, `Future<void> toggle(String key)`, `Timings? timingsFor(DateTime d)`, `Timings? get selectedTimings`, `({Prayer prayer, DateTime at, bool isTomorrow})? nextPrayer()`, `RxBool isLoading`, loads once in `onInit`, `refreshAdhanData(country, state, city, year)` fetches first and persists location + calendar only on success, then calls `AdhanScheduler.sync()`.
- `lib/utils/http/http_client.dart`: throws `NoInternetException` or `PrayerApiException(statusCode)`.
- Deprecated delegates kept until 3.A/4.1 remove them: `AdhanController.scheduleAdhans()`, `AdhanLineController.scheduleAlarms()`, the legacy `adhanFajr…` fields, `switchAdhan`, `SHelperFunctions.saveInitialValues`, `isInternetConnected`.

### 4.4 Location (2.A; used by 3.A and 3.B)

- `LocationPill()` in `lib/generals/widgets/location_pill.dart`: pin + "Country, City" (or `S.enter_location`) + chevron; tap runs `pickLocation(context)`.
- `Future<void> pickLocation(BuildContext context)` in `lib/generals/location_flow.dart`: the single flow. `GetLocationWidget` stays as a thin wrapper until 3.A/3.B delete it.

### 4.5 `AppPrefs`: `lib/utils/local_storage/app_prefs.dart` (0.3)

Static, typed, defaults built in, no nullable getters. Backed by `SharedPrefService`; key names live in `lib/utils/constants/shared_pref_keys.dart`.

- `prayerEnabled(key)` / `setPrayerEnabled(key, v)` (defaults: fajr, dhuhr, asr, maghrib, isha true; chourouk false)
- `reminderActive(alarmId)` / `reminderMinutes(durationKey)` / `setReminder(alarmId, durationKey, minutes)` / `clearReminder(alarmId, durationKey)`
- `country state city` getters (default `""`) + `setLocation(country, state, city)`
- `adhanSoundPath` (default `assets/sounds/ahmad_alnafees.mp3`) and `adhanSoundName` + setters
- `lastReadPage` (default 1) + setter; `bookmarks` → `List<int>` + `setBookmarks(List<int>)` (stored as the `-`-joined string)
- `languageCode` (default `ar`) + `setLanguage`; `isDark` (default false) + setter
- `prayerYearJson(int year)` → `String?` + `setPrayerYearJson(year, json)`
- `quranReadPages` (String, default `''`) + setter

### 4.6 Data layer (1.C; used by 2.B, 2.C)

- `lib/utils/text_normalize.dart`: `normalizeArabic(String)` (strip tashkeel and tatweel, unify alef/yaa/taa-marbuta forms, lowercase Latin, strip Latin accents) and `matchesQuery(text, query)`.
- `lib/features/duaa/data/adhkar_search.dart`: `AdhkarSearch.search(String q)` → `Future<List<AdhkarHit>>` (`AdhkarHit {type, indexInType, snippet}`), index built once, lazily, in memory.
- `lib/features/quran/data/quran_progress.dart`: `QuranProgress` with `markRead(int page)`, `isRead(page)`, `surahFraction(int surah)` (read pages of the surah / pages of the surah, using `quran.getSurahPages`), `overallFraction`, `readCount`, `reset()`; persists through `AppPrefs.quranReadPages` (604-character `0/1` string).
- `DatabaseService.getAdhkar(type)` (parameterised), `getAdhkarCounts()` → `Map<int,int>`, `getAllAdhkar()`.

---

## 5. Prompts

Each prompt starts with `/ponytail:ponytail ultra`. Prompts that touch UI also tell the session to use `/impeccable`.

---

### WAVE 0: run 0.1, 0.2 and 0.3 together

#### 0.1 Theme, tokens, fonts

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the token and theme work.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules" and "4.1 Theme". (To read only a section, grep -n for its heading and read that line range.)

Task: build the new theme foundation exactly as the "Theme" contract says.

You own (create/edit only these):
- pubspec.yaml (fonts section only)
- lib/utils/theme/noor_theme.dart (new)
- lib/my_app.dart
- assets/fonts/LICENSES.md (new, one paragraph: IBM Plex Sans Arabic, Spectral and Amiri are SIL OFL 1.1)
- test/noor_theme_test.dart (new)

Steps:
1. pubspec.yaml: register family "Plex" from assets/fonts/plex/IBMPlexSansArabic-{Regular 400, Medium 500, SemiBold 600, Bold 700}.ttf and family "Spectral" from assets/fonts/spectral/Spectral-{Regular 400, Medium 500, SemiBold 600}.ttf (files already in the repo). KEEP Poppins, Amiri and Quran (old screens use them until Wave 4). Run `flutter pub get` once.
2. noor_theme.dart: NoorColors as a ThemeExtension with the light and dark values from design.md (plus `mushaf`: light #FBF6E8, dark #121A16). Implement NoorTint, NoorSpace, NoorRadius, NoorText, noorShadow, `context.noor`, NoorTheme.light()/dark(). ThemeData: useMaterial3, fontFamily 'Plex' with fontFamilyFallback ['Amiri'], ColorScheme from the tokens, scaffoldBackgroundColor = paper, plus minimal themes: divider (line, 1px), bottomSheet (card, top radius 28), dialog (card, radius 24), inputDecoration (filled card, radius 14, no border until focus), switch (primary track when on), textSelection (primary), icon (ink). Do NOT delete the old theme files or SColors/SSizes.
3. my_app.dart: use NoorTheme.light()/dark() (remove the `getLightTheme(true)` hack), delete the four precacheImage calls, wrap the app via `builder:` in an AnnotatedRegion<SystemUiOverlayStyle> (transparent status and nav bar, icon brightness from the theme). Keep FlutterNativeSplash.remove(), delegates, locale and themeMode logic.
4. test/noor_theme_test.dart: for light and dark assert contrast(body on card) >= 4.5, contrast(muted on card) >= 4.5, contrast(onPrimary on primary) >= 4.5, and that the NoorColors extension is present in the theme. Compute contrast from Color.computeLuminance().

Acceptance: `flutter analyze lib/utils/theme lib/my_app.dart test` clean and `flutter test test/noor_theme_test.dart` passes. If a contrast assertion fails, adjust the token slightly (keep the hue), never weaken the test, and report the changed hex.
```

#### 0.2 Localisation keys

```text
/ponytail:ponytail ultra

Read first: plan.md section "3. Ground rules" only.

Task: add the new strings the rebuild needs to the three ARB files and regenerate the localisation code.

You own: lib/l10n/intl_en.arb, intl_ar.arb, intl_fr.arb, lib/generated/** (generated output only).

First verify these EXISTING keys exist in all three files with correct text, fixing any that are missing or wrong (the adhan notifications will be built from them): adhan_fajr, adhan_chourouk, adhan_dhuhr, adhan_asr, adhan_maghrib, adhan_isha, masjid_time, sun_rising, stop_adhan, fajr, sun_rise, dhuhr, asr, maghrib, isha.

Then add these keys to all three files (keep the file style; Arabic is the default language so give it care). Keys with {placeholders} need an "@key" placeholders entry in the English file in the form intl_utils expects (numeric ones as int, names as String):

noor (EXISTING key, change its value): Noor Imene | نور إيمان | Noor Imene
nav_quran: Quran | القرآن | Coran
nav_prayers: Prayers | الصلاة | Prières
nav_adhkar: Adhkar | الأذكار | Adhkar
nav_qibla: Qibla | القبلة | Qibla
adhkar_subtitle: Peace for the heart, calm for the soul | راحة للقلوب .. وطمأنينة للنفوس | Le repos du cœur, l'apaisement de l'âme
quran_title: The Noble Quran | القرآن الكريم | Le Noble Coran
quran_subtitle: God's words, a light for your life | كلام الله .. نورًا لحياتك | La parole de Dieu, lumière de votre vie
verse_count {count:int}: {count} verses | {count} آية | {count} versets
adhkar_count {count:int}: {count} adhkar | {count} ذكر | {count} adhkar
meccan: Meccan | مكية | Mecquoise
medinan: Medinan | مدنية | Médinoise
qibla_direction: Qibla direction | اتجاه القبلة | Direction de la Qibla
distance_to_kaaba: Distance to the Kaaba | المسافة إلى الكعبة | Distance jusqu'à la Kaaba
next_prayer: Next | التالية | Prochaine
next_prayer_in {prayer:String, time:String}: {prayer} in {time} | {prayer} بعد {time} | {prayer} dans {time}
duration_hm {hours:int, minutes:int}: {hours}h {minutes}m | {hours}س {minutes}د | {hours} h {minutes} min
duration_m {minutes:int}: {minutes}m | {minutes}د | {minutes} min
remove: Remove | إزالة | Supprimer
done: Done | تم | Terminé
try_again: Try again | أعد المحاولة | Réessayer
open_settings: Open settings | افتح الإعدادات | Ouvrir les réglages
reminders: Reminders | التنبيهات | Rappels
location_failed: Couldn't find your location | تعذر تحديد موقعك | Impossible de trouver votre position
reminder_title {prayer:String}: {prayer} reminder | تنبيه {prayer} | Rappel {prayer}
reminder_before {minutes:int, prayer:String}: {minutes} min until {prayer} | تبقى {minutes} د على {prayer} | Il reste {minutes} min avant {prayer}
reminder_after {minutes:int, prayer:String}: {minutes} min since {prayer} | مرت {minutes} د على {prayer} | {minutes} min depuis {prayer}
search_adhkar: Search adhkar | ابحث في الأذكار | Rechercher des adhkar
search_surah: Search surah | ابحث عن سورة | Rechercher une sourate
no_results: No results | لا نتائج | Aucun résultat
in_adhkar_text: In the adhkar | في نصوص الأذكار | Dans les adhkar
reading_progress: Reading progress | تقدم القراءة | Progression de lecture
pages_read {read:int, total:int}: {read} of {total} pages | {read} من {total} صفحة | {read} sur {total} pages
reset_progress: Reset reading progress | إعادة ضبط تقدم القراءة | Réinitialiser la progression
reset_progress_body: This clears the pages marked as read. Your bookmarks are kept. | يمسح هذا الصفحات المحددة كمقروءة. تبقى علامات الحفظ. | Cela efface les pages lues. Vos signets sont conservés.
calibrate: Calibrate | معايرة | Calibrer
calibrate_title: Calibrate the compass | معايرة البوصلة | Calibrer la boussole
calibrate_step_1: Move your phone in a slow figure-8 a few times. | حرّك هاتفك ببطء على شكل الرقم 8 عدة مرات. | Déplacez lentement votre téléphone en forme de 8 plusieurs fois.
calibrate_step_2: Keep away from metal, magnets and speakers. | ابتعد عن المعادن والمغناطيس ومكبرات الصوت. | Éloignez-vous des métaux, aimants et haut-parleurs.
calibrate_step_3: Hold the phone flat, then check the arrow again. | أمسك الهاتف أفقيًا ثم تحقق من السهم مجددًا. | Tenez le téléphone à plat puis vérifiez à nouveau la flèche.

Then run: dart pub global run intl_utils:generate
(If intl_utils is missing: dart pub global activate intl_utils.) Do not run flutter pub get.

Acceptance: `flutter analyze lib/generated lib/l10n` clean. Report the exact generated method signatures for every placeholder key in your reply (later prompts rely on them).
```

#### 0.3 Typed preferences

```text
/ponytail:ponytail ultra

Read first: plan.md sections "3. Ground rules" and "4.5 AppPrefs", bug B11 in section 1.

Task: build `AppPrefs`, the one typed door to SharedPreferences. Do not migrate other files; later prompts do that inside the files they own.

You own: lib/utils/local_storage/app_prefs.dart (new), lib/utils/constants/shared_pref_keys.dart (fill with the key constants), lib/utils/local_storage/services/sharedpreferences_service.dart (only if you need a tiny addition), test/app_prefs_test.dart (new).

Steps:
1. shared_pref_keys.dart: constants for every existing key (fajr, chourouk, dhuhr, asr, maghrib, isha, the reminder keys "101".."602" and `*_alarm_N_duration`, country, state, city, adhan_sound_path, adhan_sound_name, last_read_quran, quran_bookmark, language, isDarkTheme, "Adhan<year>" as a function) plus the new `quran_read_pages`. Look at how the current code spells each key (grep SharedPrefService.) and keep the spelling byte-for-byte.
2. app_prefs.dart: implement exactly the members in "4.5 AppPrefs". Defaults live here and nowhere else. Parsing helpers must tolerate garbage (e.g. bookmarks "12--x-45-" -> [12, 45]; negative or non-numeric minutes -> 0).
3. test/app_prefs_test.dart: use SharedPreferences.setMockInitialValues + `await SharedPrefService.init()`: defaults on an empty store, round trips, bookmark string parse/serialise (empty string, trailing "-", garbage), existing-key compatibility (a store written with the OLD key names and formats reads correctly).

Acceptance: `flutter analyze lib/utils/local_storage lib/utils/constants/shared_pref_keys.dart test/app_prefs_test.dart` clean and the test passes. Nothing else changed.
```

**Gate:** `flutter pub get && flutter analyze && flutter test`, then commit.

---

### WAVE 1: run 1.A, 1.B and 1.C together

#### 1.A Shared widgets, nav bar, settings sheet

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for all UI in this task.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme", "4.2 Shared widgets", "4.5 AppPrefs". View assets/screens/Noor Islamic App UI Showcase 1.png (header, rows, nav bar) and Showcase 3.png (segmented control, progress bars). Do not open the other reference.

Task: build the shared component set and the navigation shell exactly as "4.2 Shared widgets" says.

You own:
- lib/generals/widgets/: noor_mark.dart, noor_header.dart, noor_card.dart, icon_tile.dart, noor_list_row.dart, noor_segmented.dart, noor_pill.dart, noor_button.dart, noor_search_field.dart, noor_progress_bar.dart, noor_sheet.dart, empty_state.dart, noor_nav_bar.dart, settings_sheet.dart (all new)
- lib/utils/constants/app_name.dart (new: `const String kAppName = 'Noor Imene';`)
- lib/generals/widgets/check_dialog.dart and wait_dialog.dart (restyle in place, keep constructors)
- lib/generals/widgets/settings_dialog.dart (delete once settings_sheet.dart replaces it)
- lib/generals/controllers/theme_controller.dart, localization_controller.dart, location_controller.dart (migrate to AppPrefs; keep public method names)
- lib/bottom_navigation.dart
- test/widgets/noor_widgets_test.dart (new)
Do not touch the other files in lib/generals/widgets/ (icon_button.dart, get_locatiol_widget.dart, pick_search_option.dart belong to later prompts).

Details:
- NoorMark: CustomPainter sunburst (about 12 rays of two alternating lengths around a small ring), colour primary. Geometry only.
- NoorHeader: always LTR. Mark + kAppName "Noor Imene" (NoorText.wordmark, single line, scale down with FittedBox so it never overflows at large text scales or on 320dp-wide screens) at the start, an IconButton at the end that calls showSettingsSheet. 48dp target, 20dp side padding.
- NoorNavBar: floating card (16dp margin, radius 28, noorShadow), four items using the existing SVGs (SImageString.quran, adhan, prayingHands, kaaba) plus labels S.nav_quran, nav_prayers, nav_adhkar, nav_qibla; selected = primary colour + a 2dp underline pill (AnimatedContainer 200 ms ease-out); InkResponse, 48dp targets, Semantics(selected).
- SBottomNavigation: Scaffold with extendBody, only the selected tab is built (no IndexedStack: the compass must not run in the background). Keep SBottomNavigationController, its Alarm.ringStream subscription and permission checks, and FIX `changeIndex` (it replaces the Rx; set `.value`). Keep the constructor param name `pageIndex` as the initial tab. Remove the floating settings button. Keep the Get.lazyPut calls for SoundPickerController, AdhanController, LocationController.
- NoorSearchField: filled card, radius 14, search icon at the start, clear button when non-empty, controller optional, RTL aware.
- NoorProgressBar: rounded track in `line`, fill in `primary`, animates value changes (200 ms).
- settings_sheet.dart: showSettingsSheet via showNoorSheet. Dark mode: Switch row -> ThemeController.switchTheme() (no spinner, no delay). Language: NoorSegmented with العربية / English / Français -> localizationController.setLanguage(v), then `await AdhanController.scheduleAdhans()` (deprecated delegate that 1.B keeps; it is replaced by AdhanScheduler.sync later) and `SoundPickerController.updateAdhanName()`; no spinner, no delay.
- noor_sheet.dart: showModalBottomSheet(isScrollControlled: true, useSafeArea: true), card background, top radius 28, drag handle, optional title (NoorText.section), content scrollable with bottom padding for keyboard and system inset.
- WaitDialog / CheckDialog: restyle with context.noor (card, radius 24, calm spinner in primary; CheckDialog keeps its lottie and auto-dismiss). Ignore isDark/isRtl.
- Controllers: ThemeController/LocalizationController/LocationController use AppPrefs instead of raw SharedPrefService. LocationController.getLocation reads AppPrefs.country/state/city; insertNewLocation -> AppPrefs.setLocation.
- test/widgets/noor_widgets_test.dart: pump every new widget (NoorButton in 3 variants) in MaterialApp(theme: NoorTheme.light()/dark(), locale ar then en, S delegates) and assert tester.takeException() == null at text scale 1.0 and 1.3.

Acceptance: `flutter analyze lib/generals lib/bottom_navigation.dart test/widgets` clean (errors under lib/features are other sessions) and `flutter test test/widgets` passes.
```

#### 1.B Adhan engine and network

```text
/ponytail:ponytail ultra

Read first: plan.md sections "3. Ground rules", "4.3 Adhan engine", "4.5 AppPrefs", and bugs B1, B2, B8, B17, B18, B19 in section 1.

Task: REBUILD the adhan scheduling, its notification texts and the prayer-times network layer. This replaces the old per-prayer switch blocks. No UI files. Keep the old public members listed as "deprecated delegates" in 4.3 working (the old UI still compiles against them; a later prompt deletes them).

You own:
- lib/features/adhan/models/prayer.dart (new)
- lib/features/adhan/services/adhan_scheduler.dart, adhan_texts.dart (new)
- lib/features/adhan/adhan_controller.dart
- lib/features/adhan/controllers/adhan_line_controller.dart
- lib/utils/http/http_client.dart
- lib/utils/helpers/helper_functions.dart (only: delete setUpAdhan, setUpAlarm, getAdhanNotificationTitle/Body, getAlarmNotificationTitle/Body, getAdhanStopText, turnTimingToDate if unused after your change; keep saveInitialValues and isInternetConnected as deprecated delegates; keep getAlarmColor; do not touch the rest)
- lib/main.dart
- test/adhan_scheduler_test.dart (new)

Design (follow 4.3 exactly):
1. prayer.dart: Prayer + Prayer.all with today's exact literals (fajr: adhan 1, reminders 101/102; chourouk 2, 201/202; dhuhr 3, 301/302; asr 4, 401/402; maghrib 5, 501/502; isha 6, 601/602; duration keys `<key>_alarm_1_duration` / `_2_`). Chourouk's time is Timings.sunrise.
2. adhan_scheduler.dart: pure `planAlarms` (inputs: now, a lookup of cached calendars by year, enabled flags, reminders, windowDays) -> (alarmsToSet, idsToCancel). Rules: for dayOffset 0..windowDays-1 and every Prayer: if enabled and the prayer time is after `now`, plan the adhan with id idFor(adhanId, offset); if disabled plan cancellation of all offsets. Reminders: for each active slot, time = prayer time + minutes (negative = before); same window and cancellation rules; only future times; ids idFor(alarmIdN, offset). Missing day data (e.g. next year not cached) -> skip that day, never throw. Month and year rollover must work. `sync()`: return early without notification permission or without cached data (as today), load texts via AdhanTexts, apply the plan with Alarm.set / Alarm.stop (AlarmSettings fields exactly as the old helper used: androidFullScreenIntent true, loopAudio false, vibrate false, volume 0.5, fadeDuration 3.0, warningNotificationOnKill false, assetAudioPath = AppPrefs.adhanSoundPath), and from Dec 24 try (best effort, never throw) to fetch and cache next year's calendar for the saved location if missing. reminders/addReminder/removeReminder per the contract (first free slot; require notification permission and minutes != 0; remove clears the pref and stops the alarm for every offset).
3. adhan_texts.dart: `S s = await S.load(Locale(AppPrefs.languageCode))`; adhan title = s.adhan_<prayer>, body = s.masjid_time (s.sun_rising for chourouk), stop button = s.stop_adhan; reminder title = s.reminder_title(prayerName), body = s.reminder_before / reminder_after(minutes.abs(), prayerName) where prayerName is s.fajr / s.sun_rise / s.dhuhr / s.asr / s.maghrib / s.isha. Delete the hardcoded 3-language strings in helper_functions.dart.
4. AdhanController: implement the contract members. `refreshAdhanData` fetches FIRST; only on success persist the location (AppPrefs.setLocation) and the year JSON, then `await AdhanScheduler.sync()`. enabledFor must return the existing RxBool fields so there is one source of truth (legacy fields stay, deprecated). Use AppPrefs instead of raw SharedPrefService in the files you own. Keep `scheduleAdhans()` as a deprecated static delegate to AdhanScheduler.sync(); same for AdhanLineController.scheduleAlarms().
5. http_client.dart: Uri.https('api.aladhan.com', '/v1/calendarByCity/$year', {'city': city, 'country': country}); 15 s timeout; SocketException/TimeoutException/http.ClientException -> NoInternetException; non-200 or JSON code != 200 -> PrayerApiException(statusCode). Callers must pass raw (unencoded) strings now: remove the manual `.replaceAll(" ", "%20")`.
6. main.dart: keep the init order; keep `Workmanager` registration (frequency 12 h) but make `callbackDispatcher` call `AdhanScheduler.sync()` after `SharedPrefService.init(); Alarm.init()`; at app start call `unawaited(AdhanScheduler.sync())` after init. Keep `SHelperFunctions.saveInitialValues()` call for now.
7. test/adhan_scheduler_test.dart (pure Dart, no plugins; fixtures built from small JSON, look at lib/features/adhan/models/** for the shape): planAlarms for mid-month (3 days x enabled prayers), Jan 31 -> Feb 1, Dec 31 with no next-year data (skips, no throw), a leap day, past prayer times skipped, disabled prayer yields cancellation of all offsets, reminder offsets (-10 before, +15 after), idFor/baseOf round trip, Prayer.all literals.

Acceptance: `flutter analyze lib/features/adhan lib/utils/http lib/utils/helpers lib/main.dart test/adhan_scheduler_test.dart` has no new errors (old adhan UI must still compile) and `flutter test test/adhan_scheduler_test.dart` passes. `git diff` shows no change to any preference key or base alarm id.
```

#### 1.C Search, progress and database layer

```text
/ponytail:ponytail ultra

Read first: plan.md sections "3. Ground rules", "4.5 AppPrefs", "4.6 Data layer", bug B20 in section 1.

Task: build the pure data layer for Adhkar search, Quran reading progress and safer SQL. No UI.

You own:
- lib/utils/text_normalize.dart (new)
- lib/features/duaa/data/adhkar_search.dart (new)
- lib/features/quran/data/quran_progress.dart (new)
- lib/utils/local_storage/services/database_service.dart
- test/text_normalize_test.dart, test/quran_progress_test.dart (new)

Steps:
1. text_normalize.dart: normalizeArabic and matchesQuery per 4.6 (strip U+064B..U+065F, U+0670, tatweel U+0640; alef forms أ إ آ ٱ -> ا; ى -> ي; ة -> ه; lowercase; strip common Latin accents so "Médine" matches "medine"). Pure Dart.
2. database_service.dart: parameterise getAdhkar (`where: 'dhikr_type = ?', whereArgs: [type]`), add getAdhkarCounts() (one GROUP BY query) and getAllAdhkar(). Keep the existing method names and return types for getAdhkar.
3. adhkar_search.dart: `AdhkarSearch` builds a normalized in-memory index lazily from getAllAdhkar() on first use (rows are few hundred), `search(q)` returns up to 20 hits for queries of 2+ normalized characters, each with the dhikr type, its index within that type (same order getAdhkar returns), and a snippet (about 80 characters around the first match). Expose a way to inject rows for tests.
4. quran_progress.dart: implement the QuranProgress API in 4.6 over AppPrefs.quranReadPages (604-char 0/1 string; pad or truncate garbage safely). surahFraction uses `quran.getSurahPages(surah)` (package `quran`); keep it cheap (compute on demand, no caching beyond the string). reset() writes ''.
5. Tests: normalizeArabic cases (diacritics, alef/yaa/taa-marbuta, Latin accents), search over an injected fixture (diacritised Arabic content found by undiacritised query), QuranProgress (SharedPreferences.setMockInitialValues + SharedPrefService.init(): mark, idempotent mark, fractions for a 1-page and a multi-page surah, overall, reset, corrupted stored string).

Acceptance: `flutter analyze lib/utils lib/features/duaa/data lib/features/quran/data test` has no errors in your files and `flutter test test/text_normalize_test.dart test/quran_progress_test.dart` passes. getAdhkar callers elsewhere still compile.
```

**Gate:** `flutter analyze && flutter test`, then commit.

---

### WAVE 2: run 2.A, 2.B, 2.C and 2.D together

#### 2.A Location flow

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the sheets.

Read first: design.md, plan.md sections "3. Ground rules", "4.2 Shared widgets", "4.3 Adhan engine", "4.4 Location", bugs B5 and B18 in section 1.

Task: replace the duplicated location flow with one function and one pill widget.

You own:
- lib/generals/location_flow.dart (new)
- lib/generals/widgets/location_pill.dart (new)
- lib/generals/widgets/get_locatiol_widget.dart (reduce to a thin wrapper keeping the old constructor `GetLocationWidget({isDark, isRtl, controller})` that just renders LocationPill; a later prompt deletes it)
- lib/generals/widgets/pick_search_option.dart (delete; the GPS/Manual choice becomes a sheet inside location_flow.dart)
- lib/features/adhan/widgets/location_picker_dialog.dart (replace with location_picker_sheet.dart: CSCPickerPlus country/state/city inside a NoorSheet, Confirm/Cancel NoorButtons; same result map {country,state,city} and the same "all three required" validation)
- lib/generals/widgets/icon_button.dart (delete only if grep shows nothing outside your files imports it; otherwise leave it and say so)

Behaviour of pickLocation(context) (one owner for every navigator pop; use the passed context and check `context.mounted` after each await; never Get.context!):
1. No pre-flight ping. Choose the source first: showNoorSheet with two big NoorCard choices: GPS (SImageString.location) and Manually (SImageString.manual).
2. GPS: WaitDialog, `SHelperFunctions.getLocation()`; if country or a city-like field is missing use fallbacks (administrativeArea ?? subAdministrativeArea ?? locality for state; locality ?? subAdministrativeArea for city) and if still missing close the wait dialog and show CheckDialog(S.location_failed, lottieError). No `!` on placemark fields.
3. Manual: location_picker_sheet; an empty result does nothing.
4. With a result: WaitDialog, `Get.find<AdhanController>().refreshAdhanData(country, state, city, DateTime.now().year)` (it fetches first, persists on success and calls AdhanScheduler.sync itself), close the wait dialog. Catch `NoInternetException` -> CheckDialog(S.no_internet, SImageString.lottieNoInternet); `PrayerApiException` or anything else -> CheckDialog(S.location_failed, lottieError). The wait dialog is always closed, in every path.
Strings from S (gps, manually, enter_location, pick_location, confirm, cancel, no_internet, location_failed).

LocationPill: Obx over Get.find<AdhanController>().locationController country/city; NoorPill with a pin icon, "Country, City" or S.enter_location, mirrored chevron; onTap => pickLocation(context).

Acceptance: `flutter analyze lib/generals lib/features/adhan/widgets` has no errors in your files (old screens still compile through the wrapper). Optional cheap widget test for LocationPill with a registered fake controller.
```

#### 2.B Adhkar

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme", "4.2 Shared widgets", "4.6 Data layer", bugs B4, B13, B15. View assets/screens/Noor Islamic App UI Showcase 1.png (the reference for this screen). Do not open the other references.

Task: rebuild the Adhkar tab, add search, and rebuild the adhkar reader.

You own: lib/features/duaa/** EXCEPT lib/features/duaa/data/ (owned by 1.C, import it), and test/duaa_categories_test.dart (new). Do not edit database_service.dart (getAdhkarCounts, getAllAdhkar and the parameterised getAdhkar already exist).

Steps:
1. lib/features/duaa/adhkar_categories.dart (new): a const list of the 19 categories: type id (1 morning, 2 evening, 3 prayer, 4 mosque, 5 wake-up, 6 sleep, 7 after prayer, 8 tasbeeh, 9 prophet duaa, 10 quranic duaa, 11 prophets' duaa, 12 general, 13 hearing adhan, 14 comprehensive duaa, 15 wudu, 16 home, 17 bathroom, 18 food, 19 hajj; use the ids exactly as in the current `adhkartypeMap` in duaa_screen.dart, which has 19 entries, all shown on screen), the S getter for the title (the same strings the screen uses today), the existing svg asset (SImageString.*) and a NoorTint (morning sage, evening amber, prayer blue, sleep lilac, tasbeeh mint, the rest cycle through the five).
2. duaa_screen.dart: DuaaScreen keeps a no-arg constructor. NoorHeader; large title S.adhkar (NoorText.display) with S.adhkar_subtitle (NoorText.meta) as in the reference; a NoorSearchField (S.search_adhkar). Below: the 19 NoorListRows in NoorCards (IconTile svg tinted with tintFg, title, meta = S.adhkar_count(count) from DatabaseService.getAdhkarCounts loaded once in initState; rows show immediately, counts fill in). Typing filters categories by matchesQuery on the title; when the query has 2+ normalized characters also show a section S.in_adhkar_text with AdhkarSearch.search hits as NoorListRows (category title + snippet); tapping a hit opens that category's reader at that dhikr (`initialIndex`). Nothing matches -> EmptyState(S.no_results). Bottom padding about 96dp for the floating nav bar.
3. adhkar_display_screen.dart: StatefulWidget with LOCAL state (delete adhkar_display_controller.dart; no Get.put singleton), constructor `({title, adhkar, initialIndex = 0})`. Fix B4: build the cards once, start the repetition counter from the current item's dhikrRepetition and reset it on page change. Layout: back button (mirrored) + title, "n / total" with a NoorProgressBar, a CarouselSlider (carousel_slider ^5, viewportFraction about 0.9, no infinite scroll, initialPage = initialIndex) of NoorCards on the paper background, one large primary counter button showing the remaining repetitions; tap decrements with HapticFeedback.selectionClick, at 0 advance; at 0 on the last card show a calm completed state (check icon + S.done), never loop. Dhikr text uses NoorText.dhikr. If a dhikr has two lines (existing splitAtFirstNewLine logic) show the first line in `primary` and the rest as body. dhikrInfo opens showNoorSheet with the text. No background images (do not reference duaa_bg_img_*).
4. Delete the 19x copy-paste. Never use a BuildContext across an await without a `mounted` check.
5. test/duaa_categories_test.dart: the 19 type ids are unique and every category has a non-empty title getter source and an asset path that exists on disk.

Acceptance: `flutter analyze lib/features/duaa test/duaa_categories_test.dart` clean (apart from other sessions' files) and the test passes.
```

#### 2.C Quran

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme", "4.2 Shared widgets", "4.5 AppPrefs", "4.6 Data layer", bugs B10, B14, B21. View assets/screens/Noor Islamic App UI Showcase 3.png (the reference for this screen). Do not open the other references.

Task: rebuild the Quran tab, its sheets and the reader, and add real reading progress and surah search. Preserve: surah list, hizb list, last read, continue reading, bookmarks (add/remove/open), page-by-page reader with the Quran font.

You own: lib/features/quran/** EXCEPT lib/features/quran/data/ (owned by 1.C, import it). Rename the folder "mini screens" to "screens" with `git mv` and fix imports. Also create test/quran_hizb_test.dart.

Steps:
1. Replace SharedPrefService/`!` use in this feature with AppPrefs (lastReadPage, bookmarks). Bookmark add/toggle/remove become plain List<int> operations on AppPrefs.bookmarks. QuranScreenController no longer has `!` on prefs. Delete the string split/join copies.
2. lib/features/quran/hizb_pages.dart (new): `const List<int> hizbStartPages = [...]` with the 60 values from SHelperFunctions.getHizbStartingPage, in order: 2,12,23,33,43,52,63,73,83,93,103,113,122,133,143,152,163,174,183,193,202,213,223,232,243,253,263,273,283,293,303,313,323,333,343,353,363,372,383,393,403,414,423,432,443,452,463,473,483,492,503,514,523,532,543,554,563,573,583,592, and a `hizbStartPage(int hizb)` helper. Do NOT edit helper_functions.dart (4.1 deletes the old switch). test/quran_hizb_test.dart checks the list has 60 ascending values within 1..604.
3. QuranScreen (no-arg ctor): NoorHeader; title S.quran_title (NoorText.display) + subtitle S.quran_subtitle on the start side and a soft tinted IconTile with the quran svg on the end side (the reference shows a book illustration; do not draw a picture); a NoorSearchField (S.search_surah); a compact "continue reading" NoorCard: S.last_read, "Surah name · S.page N" (Arabic name when the locale is ar), an overall NoorProgressBar with S.pages_read(readCount, 604) from QuranProgress, a primary NoorButton S.continue_reading and a tonal icon button that opens the bookmarks sheet; a text action S.reset_progress that opens a confirmation sheet (S.reset_progress_body, NoorButton primary confirm / outline cancel) calling QuranProgress.reset(); then a NoorSegmented (Surah / Hizb) and the list. CustomScrollView with SliverList.builder (114 rows stay lazy). Search filters surahs by matchesQuery on the Arabic name, Latin name and number; it filters hizbs by number. Bottom padding about 96dp for the nav bar.
4. Surah row: NoorListRow with a number circle (tintBg sage, number via NoorText.numeral), Arabic name (NoorText.rowTitle with Amiri) and Latin name, meta "S.verse_count(n) · S.meccan/S.medinan" (quran.getPlaceOfRevelation 'Makkah' -> meccan, else medinan), and at the end a NoorProgressBar (about 72dp wide) with the percentage in NoorText.numeral small, from QuranProgress.surahFraction (the reference shows 100% / 24% / 0%). Rows rebuild when progress changes (a small Rx or ValueNotifier in the controller; no polling). Hizb row: number circle, "S.hizb N", meta "S.page <start page>". Tapping sets lastReadPage and opens the reader exactly as today.
5. Bookmarks: showNoorSheet listing bookmarked pages as rows (title via getLineTitle, tap opens the reader and sets lastReadPage, trailing remove icon with S.remove); empty -> EmptyState(S.no_bookmarks, lottie SImageString.lottieQuran). No auto-dismissing dialog.
6. Reader (B10): StatefulWidget; PageController created once in initState and disposed; RTL; background context.noor.mushaf; page text via TextSpans built with a StringBuffer/spans, with the Quran font; surah name headers as centred Amiri lines in `gold` (no more "~~~{ name }~~~" ASCII), basmala line when a surah starts except surahs 1 and 9 as today; a tap toggles a quiet top bar (mirrored back arrow, surah name + page, bookmark toggle) and a bottom page number; onPageChanged persists lastReadPage and refreshes QuranScreenController. Progress rule: a page is marked read through QuranProgress.markRead only after it has stayed visible for 5 seconds (a Timer cancelled on page change and on dispose), so flicking through pages does not count.

Acceptance: `flutter analyze lib/features/quran test/quran_hizb_test.dart` clean (apart from other sessions' files); the test passes. Nothing outside lib/features/quran (and the test) changed.
```

#### 2.D Ring screen, splash

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1 Theme", "4.2 Shared widgets", "4.3 Adhan engine", bug B12 in section 1.

Task: redesign the alarm "ring" screen and align the native splash with the new palette.

You own: lib/features/adhan/adhan_ring_screen.dart, splash.yaml, the files `dart run flutter_native_splash:create` regenerates (splash outputs only under android/app/src/main/res/** and ios/Runner/**), android/app/src/main/AndroidManifest.xml (only the application `android:label`), ios/Runner/Info.plist (only CFBundleDisplayName and CFBundleName), web/index.html and web/manifest.json (name fields only), and lib/my_app.dart (only the MaterialApp `title`).

Steps:
1. adhan_ring_screen.dart: keep behaviour (PopScope canPop false; `Alarm.stop(id)` on dispose; "Open Adhkar" stops the alarm then `Get.offAll(() => const SBottomNavigation(pageIndex: 2))`, dropping the old controller.changeIndex lines; "Close" stops the alarm then SystemNavigator.pop). Alarm ids may now be offset (id >= 10000): derive the prayer from `AdhanScheduler.baseOf(id)` and use `SHelperFunctions.getAlarmColor(baseId)` only as the icon colour. Remove the 15 s looping gradient and the AnimationController. New look: flat paper background; a small NoorMark at the top; a 64dp IconTile for the prayer; the notification title in NoorText.display, centred; the time (DateFormat HH:mm) large in NoorText.numeral (size 56); the body in NoorText.body muted; at the bottom a primary NoorButton S.open_adhkar and a tonal NoorButton S.close; SafeArea; scrollable at large text scales.
2. splash.yaml: color "#F6F3EB", color_dark "#0E1512" in both the flutter_native_splash and android_12 blocks. Keep images and branding (brand-*.png is the developer credit, not the app name). Run `dart run flutter_native_splash:create` once.
3. Rename to "Noor Imene": Android `android:label="Noor Imene"`; iOS CFBundleDisplayName "Noor Imene" and CFBundleName "Noor Imene"; web title and manifest `name`/`short_name` "Noor Imene"; MaterialApp `title: 'Noor Imene'`. Do NOT change applicationId/namespace (`com.sidalidev.noor`), the Dart package name `noor`, the bundle identifier, or any import path. Leave windows/linux/macos untouched and mention them in "Notes for others".

Acceptance: `flutter analyze lib/features/adhan/adhan_ring_screen.dart` has no errors in your file; `git status` shows only your paths changed. Do not run flutter build.
```

**Gate:** `flutter analyze && flutter test`, then commit.

---

### WAVE 3: run 3.A and 3.B together

#### 3.A Prayers screen

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1", "4.2", "4.3", "4.4", "4.5", bugs B6, B7, B8, B12. View assets/screens/Noor Islamic App UI Showcase 2.png only for the location pill and card styling (this screen has no reference of its own). Do not open the other references.

Task: rebuild the Prayers tab and its sound picker. Preserve: location (tap to change), adhan sound choice, day navigation with the year bounds, six prayer rows each with an adhan on/off toggle, up to two reminders per prayer with an offset of -60..+60 minutes (add/remove), the no-location empty state.

You own: lib/features/adhan/** EXCEPT adhan_ring_screen.dart and the files under lib/features/adhan/services/ and models/prayer.dart (built in 1.B; import them); lib/generals/widgets/get_locatiol_widget.dart (delete it); test/adhan_screen_test.dart (optional).

Steps:
1. adhan_screen.dart (AdhanScreen, no-arg ctor): NoorHeader; LocationPill; a NoorPill with the current adhan sound name that opens the sound sheet; a "next prayer" NoorCard at the top when the engine returns one: "S.next_prayer_in(prayerName, time)" with the time formatted via S.duration_hm / S.duration_m, refreshed every 30 s by one Timer in State (cancelled on dispose); the day navigator NoorCard (mirrored arrows; same year-bound behaviour: on Jan 1 / Dec 31 show CheckDialog(S.year_ended, lottieCalendarOut); title = S.today or weekday + formatted date exactly as today); one NoorCard with the six prayer rows. Data from the engine contract only: `controller.selectedTimings`, `enabledFor(key)`, `toggle(key)`, `nextPrayer()` (mark the next prayer row with a `gold` dot when the selected day is today), `controller.isLoading` (no FutureBuilder in build). No location yet: EmptyState with lottie SImageString.lottieAddLocation and a NoorButton S.add_location calling pickLocation(context). Bottom padding about 96dp for the nav bar.
2. adhan_line.dart: StatefulWidget per prayer (local state, so rebuilds do not collapse it). Row: IconTile (the existing Iconsax icons), title, time via NoorText.numeral, a speaker toggle (volume_high / volume_cross) wired to controller.toggle, a chevron that rotates when expanded. Expanded panel (AnimatedSize 250 ms): the active reminders from AdhanScheduler.reminders(prayer), each with text from getAlarmText and a remove button (S.remove, AdhanScheduler.removeReminder); if fewer than two exist, a minutes stepper (-/+ by 1, range -60..60, 0 not allowed) and a tonal NoorButton S.set_new_alarm calling AdhanScheduler.addReminder(prayer, minutes). Iterate Prayer.all, no per-prayer switch.
3. Sound picker: replace sound_picker_dialog.dart with a sheet (showNoorSheet): five rows with a radio indicator for the selected one and a play/pause preview per row using ONE AudioPlayer (the shared SoundPickerController.player) so only one preview plays; stop the preview when the sheet closes; tapping a row saves AppPrefs.adhanSoundPath/Name, calls updateAdhanName() and `AdhanScheduler.sync()`, closes. Delete divider.dart and the per-row `SoundPickerController()` instances.
4. Delete from the controllers every deprecated member the old UI needed (legacy adhanFajr… fields, switchAdhan, instance state in AdhanLineController, `scheduleAdhans`/`scheduleAlarms` delegates) ONLY after grepping that nothing else uses them; if something outside your files still does (e.g. lib/generals/widgets/settings_sheet.dart calls AdhanController.scheduleAdhans), leave the delegate and list it under "Notes for others".
5. Replace any GetLocationWidget use in files you own with LocationPill and delete get_locatiol_widget.dart unless lib/features/qibla still imports it (then leave it and say so).

Acceptance: `flutter analyze lib/features/adhan lib/generals` clean for your files. Alarm ids, preference keys and scheduling behaviour unchanged (verify with `git diff` on those literals).
```

#### 3.B Qibla

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: craft, mode Operate) for the UI.

Read first: PRODUCT.md, design.md, plan.md sections "3. Ground rules", "4.1", "4.2", "4.4", bug B9. View assets/screens/Noor Islamic App UI Showcase 2.png (the reference for this screen). Do not open the other references.

Task: rebuild the Qibla tab: compass, states, calibration guide. Preserve the flutter_qiblah stream logic, permission and GPS handling and the sensor-support check.

You own: lib/features/qibla/** and test/qibla_screen_test.dart (optional).

Steps:
1. qibla_controller.dart (B9): fix onClose (close the StreamController, FlutterQiblah().dispose(), then super.onClose(), never super.dispose()). Create the controller once (Get.put in a StatefulWidget's initState, Get.delete in dispose); no `GetBuilder(init:)` in build; move `LocationController.getLocation()` out of build into initState. Add `Future<double?> distanceToKaabaKm()`: Geolocator.getLastKnownPosition() then getCurrentPosition(timeLimit 5 s) as fallback, Geolocator.distanceBetween to the Kaaba (21.4225, 39.8262), rounded to a whole number; null on any failure.
2. qibla_screen.dart (QiblaScreen, no-arg ctor): NoorHeader, LocationPill, the compass, then a NoorCard: label S.qibla_direction, degrees (`qiblahDirection.offset.toStringAsFixed(2)°`) in NoorText.numeral size 56, a hairline, a row S.distance_to_kaaba with "~ N km" in numerals (hidden when null), and a tonal NoorButton with the compass icon + S.calibrate that opens the calibration sheet. States, each an EmptyState with one action: sensor unsupported (lottieError + S.sensor_not_supported), permission denied (S.enable_location_permission; action runs the existing requestPermission + restartCheckLocationStatus), GPS off (S.enable_location; action as today), error (message + S.try_again). Loading: a calm spinner.
3. widgets/qibla_compass.dart + compass_dial.dart (CustomPainter): 1.5dp `primary` ring, a softer outer ring in `line`, 60 ticks (major every 15 degrees, longer), N/E/S/W in NoorText.numeral, rotated by `-direction` radians exactly as the old Transform.rotate did; a fixed `gold` heading tick at the top; the Kaaba glyph (assets/images/svg/kaaba.svg tinted `ink`) in a small round card at the centre; a `primary` arrow rotated by `-qiblah` radians exactly as before. RepaintBoundary; at least 280dp and scaling down on small screens (LayoutBuilder). Subscribe to FlutterQiblah.qiblahStream only while mounted.
4. Calibration sheet (replaces qibla_tips_dialog.dart; delete the old class): showNoorSheet titled S.calibrate_title with an animated figure-8 guide (CustomPainter + AnimationController, a dot tracing a lemniscate in `primary` over a faint path in `line`, 3 s loop, disposed with the sheet; static when the OS asks for reduced motion), the three steps S.calibrate_step_1..3, then the three existing tips (flat_phone, keep_from_magnetic, enable_location) as rows with IconTiles. Be honest in the copy: it guides the user, it does not claim to calibrate the sensor itself.
5. Replace any GetLocationWidget use with LocationPill. Remove code references to compass.svg/needle.svg (4.1 deletes the files).

Acceptance: `flutter analyze lib/features/qibla` clean; the rotation sign conventions match the old code (cite the two lines in your reply). Optional widget test: pump the direction card with a fake value and assert the degrees text.
```

**Gate:** `flutter analyze && flutter test`, then commit.

---

### WAVE 4: run one at a time, in order

#### 4.1 Cleanup

```text
/ponytail:ponytail ultra

Read first: plan.md sections "3. Ground rules" (you are alone now: you may run pub get, analyze, test and build), "4.3 Adhan engine" (deprecated delegates list) and bugs B16, B21.

Task: delete everything the rebuild made dead and finish the migrations. Delete only after grepping that nothing references it.

Targets:
- lib/utils/constants/colors.dart (SColors) and sizes.dart (SSizes): migrate remaining usages to the theme contract, then delete.
- lib/utils/theme/theme.dart and lib/utils/theme/widget_themes/** (old SAppTheme).
- lib/generals/widgets/icon_button.dart, get_locatiol_widget.dart, any remaining old dialogs.
- WaitDialog/CheckDialog: remove the ignored isDark/isRtl parameters and fix call sites.
- Deprecated delegates from 4.3: AdhanController.scheduleAdhans, AdhanLineController.scheduleAlarms, legacy adhanFajr… fields, SHelperFunctions.saveInitialValues, isInternetConnected (and the saveInitialValues call in main.dart). Migrate any remaining raw `SharedPrefService.get…!` call sites to AppPrefs; afterwards SharedPrefService is only used by AppPrefs.
- lib/utils/helpers/helper_functions.dart: delete getHizbStartingPage (replaced by hizb_pages.dart), screenHeight/screenWidth, getLanguage (widget), and anything else unused; move what is still used next to its single user (e.g. getAlarmColor into the ring screen file, getLocation into location_flow.dart) or into a tiny util; delete the file if it empties. Same pass over lib/utils/device/device_utility.dart (keep only used members).
- Assets: assets/images/background_images/**, assets/images/general/hizb_frame1.png, assets/images/svg/compass.svg and needle.svg, flags if unused, unused lottie files and svgs; keep pubspec asset lists and lib/utils/constants/image_strings.dart in sync (verify each filename with grep before deleting).
- Poppins: remove the family from pubspec.yaml and delete assets/fonts/poppins.
- Unused packages in pubspec.yaml (check each: iconsax, flutter_spinkit, smooth_page_indicator, lottie, flutter_svg, ...); remove only the unused ones, then `flutter pub get`.
- Unused imports; the `sub_models.dart/` directory that is named like a file may be renamed to `sub_models/` with imports fixed.

Acceptance: `flutter pub get && flutter analyze && flutter test` clean and `flutter build apk --debug` succeeds. Report the debug APK size before/after if the old build output is still in build/app/outputs.
```

#### 4.2 Device audit (read-only)

```text
/ponytail:ponytail ultra
Use the /impeccable skill: command `audit`, then `critique`, mode Operate. Do NOT edit any file in this prompt.

Read first: PRODUCT.md, design.md, plan.md section "3. Ground rules".

Task: one batched inspection round on the emulator (emulator-5554; adb is at C:\AndroidSDK\platform-tools). Build and install the debug app (`flutter run -d emulator-5554 --no-resident`), then screenshot with `adb exec-out screencap -p` into the session scratchpad (never into the repo).

Matrix, in ONE pass:
- Languages ar (default), en, fr; themes light and dark.
- Screens: the four tabs; Adhkar list, a search by title and a search by text (e.g. an Arabic phrase typed without diacritics), a reader (first card, an info sheet, counting down to the next card); Quran: surah list with progress bars, hizb list, search, bookmarks sheet (empty and with an entry), the reset-progress sheet, the reader with the top bar shown (stay on a page > 5 s and confirm its surah progress changes on return); Prayers: empty state (clear app data first) and with a location set (fetch needs network), the next-prayer card, a row expanded with a reminder added and removed, the sound sheet with preview; settings sheet (theme and language switch live); location flow sheets (GPS/manual, offline error by turning off network); Qibla in each reachable state (permission denied, granted, GPS off) plus the calibration sheet; the ring screen (trigger via a short test alarm if feasible, otherwise say so).
- Alarm check: after setting a location, run `adb shell dumpsys alarm | grep com.sidalidev.noor` and report how many alarms exist (expect the 3-day window: adhans for enabled prayers plus any reminders).
- Also once: font scale 1.3 (`adb shell settings put system font_scale 1.3`, reset to 1.0 after) on the four tabs in ar.

Compare each screen against the matching reference PNG and design.md. Output ONE report ordered by severity (Blocker / Major / Minor): screen, language/theme, what is wrong, the file to fix. Include a short "matches the reference" list and an explicit "Not verifiable on the emulator" list (a real adhan firing in the background after a reboot, the real compass sensor). Also run the impeccable detector if available on the changed UI files and include its findings. Do not fix anything.
```

#### 4.3 Fix batch

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: polish, mode Operate) for the UI fixes.

Read first: design.md, plan.md section "3. Ground rules" (builds are allowed now). Below is the audit report from the previous step. Fix every Blocker and Major item and the cheap Minor items, in one batch, touching only the files the report names:

<paste the 4.2 report here>

Then one confirmation round: rebuild, re-screenshot only the screens you changed (ar light and en dark), confirm each fixed item, and stop. Do not start a new polishing loop. List anything you deliberately did not fix and why.
```

#### 4.4 Final check

```text
/ponytail:ponytail ultra

Read first: plan.md sections "1. Bug and improvement register" and "6. Definition of done".

Task: final verification, no new features. Run `flutter analyze`, `flutter test`, `flutter build apk --debug`. Confirm each of B1..B21 against the code (cite the file and line that fixes it, or say it is not fixed). Run `git diff main -- lib | grep -E "^[-+].*(\"fajr\"|\"chourouk\"|\"dhuhr\"|\"asr\"|\"maghrib\"|\"isha\"|alarm_[12]_duration|last_read_quran|quran_bookmark|adhan_sound_path|adhan_sound_name|isDarkTheme|\"language\")"` and confirm every persisted key spelling is unchanged (they now live in shared_pref_keys.dart). Confirm base alarm ids 1-6 and 101-602 are unchanged and offset ids are base + n*10000. Grep the repo (excluding build/, .dart_tool/, generated files and imports of package:noor) for the old display name "Noor" used as a product name and report any stragglers (README title, pubspec description "A new Flutter project.", desktop platform titles); fix README.md and the pubspec description only. Keep README short. Report PASS/FAIL per item and the list of things only a physical device can verify (background adhan firing after reboot, Workmanager, the compass sensor).
```

---

## 6. Definition of done

- `flutter analyze` and `flutter test` clean; debug APK builds.
- All four tabs, the reader, the ring screen and every sheet/dialog use the shared components and tokens; no `SColors`/`SSizes`/Poppins/background-image references remain.
- Adhan notifications and reminders are built from the ARB files in the user's language; no hardcoded notification strings remain.
- One `AdhanScheduler` owns all alarm scheduling, with a 3-day window and a sync on app start; no raw `SharedPrefService.get…!` remains.
- Quran progress, Adhkar and Quran search, and the calibration guide work on real data; no fake numbers.
- B1–B21 resolved or explicitly deferred with a reason.
- ar / fr / en and light / dark verified on the emulator at font scale 1.0 and 1.3.
- No persisted key spelling or base alarm id changed.
- Physical-device checks listed for the owner: background adhan firing after a reboot, Workmanager reschedule, compass sensor accuracy.

## 7. Risks and fallbacks

- **Concurrent sessions in one tree:** only own-path analyzers run in Waves 0–3 and nobody commits. If two sessions collide on a file, rerun the later prompt; ownership lists are disjoint by design.
- **Wave order matters:** 3.x need `LocationPill` from 2.A; 2.x need the widgets from 1.A and the engine and data layers from 1.B/1.C; everything needs Wave 0. If a gate fails, fix it before the next wave.
- **Alarm rework is the riskiest change.** `planAlarms` is pure and unit-tested for rollover, window and cancellation; the `dumpsys alarm` count in 4.2 checks the real plugin. A real adhan still has to be tested on a physical device.
- **Alarm count:** 6 prayers × 3 days plus up to 12 reminders × 3 days is at most 54 alarms, well within Android's limits. If the `alarm` plugin misbehaves at that count, lower `AdhanScheduler.windowDays` to 2; it is one constant.
- **Generated l10n drift:** only 0.2 regenerates `lib/generated`. If a later prompt needs another string, it reports it under "Notes for others" and you add it in 4.3.
