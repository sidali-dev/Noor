# Noor Imene UI v2: match the new references

Goal: move the rebuilt app (plan.md Waves 0–3) to the look in `assets/screens/screens.png`, `splash.png` and `splash_dark.png`. This is an **evolution, not a new world**: palette, fonts, tokens and most components already match. What changes is that each screen's header becomes an illustrated hero (the shared app bar goes away), the nav bar gets a raised selected item, the Mushaf gets an ornamental frame, the location and adhan sheets are restyled, and there's a custom splash after the native one plus a new emblem for the app icon.

How to use: do section 1 first; nothing in section 2 starts until its gate passes. Then run waves in order. Inside a wave, open one fresh Claude Code session per prompt and run them **at the same time**, because their file ownership doesn't overlap. Paste prompts as-is.

Reference panels in `screens.png` (row, column):

| | col 1 | col 2 | col 3 | col 4 | col 5 |
|---|---|---|---|---|---|
| **row 1** | Prayers (light) | Quran list (light) | Quran (dark) + Settings sheet | Adhkar list | Enter Your Location |
| **row 2** | Prayers (dusk variant) | Mushaf reader | Qibla | Dhikr reader | Pick Adhan |

---

## 0. Before you start

1. Commit the current working tree (it holds the rebrand assets and the old-asset deletions): `git add -A && git commit -m "Rebrand assets, remove old images and Poppins"`.
2. plan.md Wave 4 (device audit, fix batch, final check) is **moved to after this plan** (step 2.2), so it audits the final UI once instead of twice.
3. Fill in section 1, then run the gate in 1.6.

### Decisions (confirmed)

| # | Decision | Chosen |
|---|---|---|
| U1 | Arabic brand name | **نور الإيمان**, as on the splash. It replaces the current l10n value نور إيمان. |
| U2 | Art in RTL | Hero art is **mirrored in Arabic** so the subject stays opposite the title. **Exception: a piece that contains writing** (Mushaf cover calligraphy, the Kaaba band) is never mirrored. You mark those pieces in table 1.2, and `NoorArt.noMirror` lists them. The Qibla skyline is never mirrored. |
| U3 | Where art may appear | Only in: screen heroes (Prayers, Quran, Athkar), the Qibla footer, and the custom splash. Never behind lists, prayer times, Quran text or dhikr text. Text over art sits on calm sky behind a paper scrim and must measure ≥ 4.5:1. This replaces design.md's blanket "no photographic backgrounds". |
| U4 | Location | **Stays a sheet**, restyled with r1c5's contents: title, subtitle, GPS / Manually radio cards, Confirm Location button. No backdrop art. |
| U5 | Pick Adhan | **Stays a sheet**, restyled with r2c5's panel: radio rows, play button on the selected row, Save. No art. |
| U6 | Dhikr reader pill | Centre = **repetition counter** (tap to count, as now). Chevrons = previous / next dhikr. Header shows position `1 / 11` and a thin progress line. |
| U7 | Mushaf pager | Chevrons follow the book: in the Mushaf, **left = next page**. Swiping stays. |
| U8 | Next-prayer row | **The r2c1 style:** sage row fill, icon tile filled `primary` with an `onPrimary` icon, speaker button on a sage-tint circle. |
| U9 | Spelling | **"Athkar"** in English and French display text (tab, title, category names, "n athkar"). Arabic الأذكار, code identifiers and keys don't change. "Pic k Adhan" is a mock typo; it stays "Pick Adhan". |
| U10 | Icon, splash and header | The **launcher icon** switches to the arch-and-book emblem. The **native splash doesn't change.** After it, a **custom Flutter splash** with the emblem shows while the app and its assets load. **The shared app bar (`NoorHeader`) is removed:** each screen's own header (its `NoorHero`) replaces it. |
| U11 | Splash timing | The custom splash shows only while startup work and asset precaching run, then fades out over 300 ms. No artificial delay. |

---

## 1. Assets you must provide (blocking)

`assets/screens/assets_board.png` is a **style brief, not a source**: its cut-outs have colour fringing and broken alpha. Don't slice it. Commission the art or regenerate each piece cleanly.

### 1.1 Rules for every raster image

- **Format:** WebP with alpha, quality ~80. **≤ 200 KB each** (splash layers ≤ 300 KB).
- **Width 1290 px** (3× a 430 dp phone). Flutter scales it down.
- **Light and dark versions** of the same composition. Light: golden-hour haze on cream. Dark: night, deep green, a few warm lit windows (see `splash_dark.png`).
- **Soft edges:** every edge that meets the UI fades to **fully transparent**, with no hard rectangle. The app's paper colour shows through, so it works with both themes.
- **Writing only where it truly belongs** (Mushaf cover, Kaaba band). If a hero piece has any, mark it in the "Writing?" column so the app never mirrors it (U2). No other text or letters. No people. No flags, emblems or symbols other than mosques, the Kaaba, the Mushaf and plants.
- **Palette:** cream `#F6F3EB`, forest green `#1F5A41`, sage `#E4EDE4`, gold `#C79A3B`. Matte, painterly and low contrast, like the screens.
- Style line for an image model: *"soft matte painterly illustration, warm cream haze, forest-green domes, muted gold light, low contrast, no text, no people, transparent background, edges fading to transparent"*.

### 1.2 Required

| # | Path | What | Size (px) | Fade / placement | Writing? (fill in) |
|---|---|---|---|---|---|
| A1 | `assets/images/art/hero_prayers_light.webp`, `…_dark.webp` | Mosque with dome and two minarets plus a far skyline, sky on the start side (r1c1) | 1290 × 840 | Subject in the right 55%; left 45% calm sky (the wordmark sits there). Bottom 35% fades out. | no |
| A2 | `assets/images/art/hero_quran_light.webp`, `…_dark.webp` | Closed Mushaf on a wooden rehal, olive sprig (r1c2) | 1290 × 720 | Object in the top-right ~40%; the rest fully transparent. | no (cover is ornament only) |
| A3 | `assets/images/art/hero_athkar_light.webp`, `…_dark.webp` | Misty hills with one tall minaret on the right (r1c4) | 1290 × 720 | Left 55% calm. Bottom 40% fades out. | no |
| A4 | `assets/images/art/qibla_skyline_light.webp`, `…_dark.webp` | Kaaba in the centre with the Haram arcades and minarets each side (r2c3) | 1290 × 520 | Sits at the screen bottom behind the nav bar. Top 50% fades out. | never mirrored |
| A5 | `assets/logo/noor_imene_emblem.svg`, `…_dark.svg` | Arch + open book + gold four-point star (splash centre). Flat vector, max 3 colours, no text. | vector, square viewBox | Dark version: lighter green arch and brighter gold, as in `splash_dark.png`. | – |
| A6 | `assets/images/splash/splash_top_light.webp`, `…_dark.webp` | Scalloped arch frame with gold line, girih pattern in the green corners (top of `splash.png`) | 1290 × 900 | Anchored to the top edge. Below the arch line fully transparent. | – |
| A7 | `assets/images/splash/splash_bottom_light.webp`, `…_dark.webp` | Mosque skyline silhouette plus green corner curves with gold line (bottom of `splash.png`) | 1290 × 1000 | Anchored to the bottom edge. Top 50% fades out. | – |
| A8 | `assets/logo/app_icon.png` (replace) | Emblem on cream `#F6F3EB`, no transparency (iOS) | 1024 × 1024 | Emblem ~70% of the canvas. | – |
| A9 | `assets/logo/app_icon_foreground.png` (replace) | Emblem only, transparent | 1024 × 1024 | Inside the central 66% (adaptive safe zone). | – |
| A10 | `assets/images/ornaments/surah_cartouche.svg` | Gold ornamental frame for the surah name, empty centre (r2c2) | vector, ~4:1 | Gold `#C79A3B` + cream fill; strokes ≥ 1 px at 360 dp width. | – |
| A11 | `assets/images/ornaments/page_corner.svg` | One corner flourish (code mirrors it to all four) | vector, square | Gold, single colour. | – |
| A12 | `assets/images/ornaments/divider.svg` | Small centred flourish (under dhikr titles, page foot) | vector, ~6:1 | Gold, single colour. | – |

Single-colour SVGs (A11, A12) use solid fills so the app can recolour them. Strip `<text>`, embedded rasters and editor metadata.

**Interim state (2026-10-27):**
- **Dark art not supplied yet.** Only the `_light.webp` files of A1–A4, A6 and A7 exist, and dark mode uses them too (`NoorArt.of`, contract 2.2). When the `_dark.webp` files land, switch `NoorArt.of` back and nothing else changes.
- **Splash layers are cropped to their content:** `splash_top` is 1290 × 522 and `splash_bottom` is 1290 × 391, not the sizes in the table. Both are anchored to their edge and fit width, so code doesn't care.
- **Sources:** the original PNGs of A1–A4, A6 and A7 are in `assets/screens/art_src/`, which isn't bundled. The WebP files are made from them: resized to 1290 px wide, the fade edges given real alpha, quality 80.

### 1.3 Optional (the plan works without them)

| # | Path | What | If missing |
|---|---|---|---|
| O1 | `assets/images/svg/*.svg` (same 18 filenames as now) | A matched line-icon set (1.5 stroke, 24 grid, solid black) to replace the current nav, prayer and category icons one-for-one | Current icons stay. |
| O2 | `assets/images/svg/fajr.svg`, `asr.svg` | Distinct Fajr (sun under horizon) and Asr (sun past zenith) icons | The current mapping stays. |
| O3 | `assets/fonts/surah_names/*.ttf` + licence line in `assets/fonts/LICENSES.md` | Calligraphic surah-name font for the cartouche | Amiri Bold. |

### 1.4 Copy to confirm (edit the right-hand columns if needed)

| Key | English | Arabic | French |
|---|---|---|---|
| `tagline_prayers` | Closer to Allah, every day | أقرب إلى الله، كل يوم | Plus proche d'Allah, chaque jour |
| `quran_title` | The Noble Quran | القرآن الكريم | Le Noble Coran |
| `tagline_quran` | God's words, a light for your life | كلام الله، نورٌ لحياتك | La parole d'Allah, une lumière pour votre vie |
| `tagline_adhkar` | Peace for the heart, calm for the soul | طمأنينة للقلب، سكينة للروح | Paix pour le cœur, sérénité pour l'âme |
| existing Adhkar labels (U9) | Adhkar → **Athkar** | unchanged | Adhkar → **Athkar** |
| `location_title` | Enter Your Location | حدّد موقعك | Indiquez votre position |
| `location_subtitle` | To get accurate prayer times | للحصول على مواقيت صلاة دقيقة | Pour des horaires de prière précis |
| `gps_subtitle` | Use your current location | استخدم موقعك الحالي | Utiliser votre position actuelle |
| `manual_subtitle` | Pick your city / wilaya | اختر مدينتك / ولايتك | Choisissez votre ville / wilaya |
| `confirm_location` | Confirm Location | تأكيد الموقع | Confirmer la position |
| `qibla_direction` | Qibla direction | اتجاه القبلة | Direction de la Qibla |

### 1.5 Not needed: code draws these

Buttons, cards, pills, toggles, radios, the progress bars, the compass dial and rose, the pin-in-circle on the location page, the splash spinner, the "NOOR IMENE" letter-spaced line and its gold rules, the Arabic name on the splash (Amiri), the splash light rays (a gradient), and the Qibla sky (a gradient). The native splash isn't touched (U10).

### 1.6 Gate

All of A1–A12 are in place (for now: the light versions of A1–A4, A6 and A7; see "Interim state"), the "Writing?" column is filled in, and the section 1.4 copy is confirmed. Prompt 0.A adds `test/art_assets_test.dart`, which fails if any required file is missing or over budget. That test is the gate for Wave 1.

---

## 2. Prompts

| Wave | Run | Prompts |
|---|---|---|
| **0** Foundation | together | 0.A tokens, assets, copy, design.md · 0.B shared widgets |
| **1** Screens | together (7 sessions) | 1.A Prayers · 1.B Quran list · 1.C Mushaf reader · 1.D Athkar · 1.E Qibla · 1.F Location, Settings, Pick Adhan sheets · 1.G Custom splash and icon |
| **2** Finish | one at a time | 2.1 emulator pass and fix batch → 2.2 plan.md Wave 4 |

After each wave: `flutter pub get && flutter analyze && flutter test`, then `git add -A && git commit -m "UI v2 wave N: ..."`.

### 2.1 Ground rules (every prompt says "read this section")

- **plan.md section 3 "Ground rules" applies in full** (persisted data, file ownership, parallel-safe commands, no commits, RTL, ar/fr/en × light/dark × text scale 1.3, final-reply format), with one change: U3 above replaces its "no photographic backgrounds" bullet.
- Art is loaded only through `NoorArt` (section 2.2), never by raw path. Ornament SVGs are recoloured from tokens. No hex literals in feature code.
- Don't change behaviour, data, persistence or alarms. This plan is visual and navigational only.
- Missing art must never break a screen: `NoorHero` and every `Image.asset` use an `errorBuilder` that renders nothing.
- Reference panels: open `assets/screens/screens.png` and look **only at the panels your prompt names**.

### 2.2 Contracts (Wave 0 creates them; Wave 1 relies on them)

**`NoorArt`** (0.A, in `lib/utils/constants/image_strings.dart`): bases `heroPrayers`, `heroQuran`, `heroAthkar`, `qiblaSkyline`, `splashTop`, `splashBottom` (for example `'assets/images/art/hero_prayers'`). `static String of(BuildContext c, String base)` returns `'${base}_light.webp'` or `'${base}_dark.webp'` from `context.noor.isDark`. **For now it always returns `_light`** (no dark art yet; mark it with a `ponytail:` comment naming the switch-back). `static const Set<String> noMirror` holds `qiblaSkyline` plus every hero marked "yes" in table 1.2 (U2). Also add path constants `emblem`, `emblemDark`, `surahCartouche`, `pageCorner`, `divider`. `static List<String> heroes` lists the four art bases for splash precaching.

**`NoorHero`** (0.B, `lib/generals/widgets/noor_hero.dart`). It **is** the screen's header; no app bar sits above it (U10).
```dart
NoorHero({
  String? art,                  // NoorArt base; null = flat sky gradient, paper → 4% sage (Qibla)
  required String title,
  String? subtitle,
  bool wordmark = false,        // title set as the LTR "Noor Imene" wordmark (Prayers, Qibla)
  Widget? leading,              // NoorMark on wordmark screens, small icon on Athkar
  bool settings = false,        // gear icon button at the top end, opens the settings sheet (Prayers, Qibla)
  double height = 240,
  Widget? overlap,              // a 48–56dp child (search field / LocationPill) that overlaps the hero bottom by half its height
})
```
It draws behind the status bar and keeps its content inside the top safe area. The art is aligned top-end, mirrored in RTL unless `NoorArt.noMirror` contains it, and fades in once over 300 ms. A paper scrim runs bottom-up and start-side so the title stays ≥ 4.5:1 even when unmirrored art sits behind it. The title uses `NoorText.display` (or `NoorText.wordmark`), the subtitle `NoorText.meta` in `body`.

**`NoorNavBar`** (0.B): same API. The selected item is a 56 dp `primary` circle with an `onPrimary` icon, raised 14 dp above the bar with `noorShadow`, and a `primary` w600 label under the bar line. Other items are muted icon plus label. The circle slides between items over 250 ms easeOutCubic. The bar stays a floating card with radius 28.

**`NoorPagerPill`** (0.B, `lib/generals/widgets/noor_pager_pill.dart`):
```dart
NoorPagerPill({
  required String label, VoidCallback? onCenterTap,
  VoidCallback? onPrevious, VoidCallback? onNext,
  required String previousTooltip, required String nextTooltip,
  bool split = false,   // false: one primary pill with chevrons inside (r2c4); true: primary centre pill + two gold-tint circles (r2c2)
})
```
All targets are ≥ 48 dp. Chevron direction follows the ambient `Directionality`.

**l10n** (0.A): the section 1.4 keys exist in all three ARB files and `S` is regenerated.

---

### WAVE 0: run 0.A and 0.B together

#### 0.A Tokens, assets, copy, design.md

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: document; mode Operate) for the design.md update.

Read first: PRODUCT.md, design.md, ui-plan.md sections "Decisions", "1. Assets", "2.1 Ground rules", "2.2 Contracts" (NoorArt and l10n parts). Reference panels: look at all of assets/screens/screens.png once, plus splash.png and splash_dark.png.

Task: register the new assets, add NoorArt, add the copy, and record the evolved look in design.md.

You own: pubspec.yaml (flutter.assets list only), lib/utils/constants/image_strings.dart, lib/l10n/intl_{en,ar,fr}.arb, lib/generated/**, design.md, PRODUCT.md (Brand Commitments and References lines only), test/art_assets_test.dart (new).

Steps:
1. pubspec.yaml: add assets/images/art/, assets/images/ornaments/, assets/images/splash/, and the emblem SVGs under assets/logo/. Don't touch fonts or other blocks.
2. image_strings.dart: add NoorArt exactly as in contract 2.2. Fill noMirror from the "Writing?" column of table 1.2.
3. ARB: add the section 1.4 keys with the confirmed texts to all three files. Set the Arabic brand-name value to نور الإيمان (U1). In the en and fr values only, replace the transliteration "Adhkar" with "Athkar" (U9); keys don't change. If category names come from assets/noor.db instead of the ARB files, leave the DB alone and report it. Regenerate the same way plan.md prompt 0.2 did (dart pub global run intl_utils:generate). Don't rename or remove existing keys.
4. design.md: point the reference to assets/screens/screens.png and the splash images. Replace "Don't put text on photographic backgrounds" with rule U3. Replace the NoorHeader component with NoorHero as the per-screen header (U10). Add NoorPagerPill, the raised NoorNavBar, the Mushaf frame, the restyled location and adhan sheets, and the custom splash, each in one or two lines, matching the file's existing style. Keep tokens unless the screens clearly disagree; if you change one, also update lib/utils/theme/noor_theme.dart (you own that file too, colour values only) and keep test/noor_theme_test.dart passing.
5. PRODUCT.md: update the Arabic name, the brand mark (emblem for the app icon and custom splash; star mark beside the wordmark in screen headers) and the reference file names.
6. test/art_assets_test.dart: for every NoorArt light path (the four heroes and the two splash layers) and every A5 and A8–A12 file, assert it exists. Assert .webp files are ≤ 200 KB (splash ≤ 300 KB). Dark paths aren't checked yet (section 1.2 "Interim state").

Acceptance: `flutter analyze lib/utils lib/generated test/art_assets_test.dart` is clean, and `flutter test test/art_assets_test.dart test/noor_theme_test.dart` passes. If art is missing, report exactly which files. Don't create placeholders.
```

#### 0.B Shared widgets

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Operate) for this component work.

Read first: design.md, ui-plan.md sections "Decisions", "2.1 Ground rules", "2.2 Contracts". Reference panels: r1c1, r1c2, r1c4 (heroes and nav), r2c2 and r2c4 (pager pills).

Task: build NoorHero and NoorPagerPill, and restyle NoorNavBar, exactly as contract 2.2 says. Session 0.A adds NoorArt and the l10n keys in parallel. Until it finishes, analyzer errors on those names are expected.

You own: lib/generals/widgets/noor_hero.dart (new), lib/generals/widgets/noor_pager_pill.dart (new), lib/generals/widgets/noor_nav_bar.dart, lib/generals/widgets/location_pill.dart, lib/bottom_navigation.dart (only if the raised circle needs extra bottom space or extendBody, or if it renders an app bar, which goes per U10), test/widgets/noor_hero_test.dart (new).

Steps:
1. NoorHero: Stack inside a fixed-height box that extends under the status bar (the app is already edge-to-edge). It replaces NoorHeader as the screen header (U10), so don't build on NoorHeader; screens drop it in Wave 1 and 2.1 deletes the file. With `art`, load Image.asset(NoorArt.of(...), errorBuilder: → SizedBox.shrink(), frameBuilder: fade in once over 300 ms) and mirror it in RTL unless NoorArt.noMirror contains the base. Without `art`, use the sky gradient. Add a scrim gradient to paper at the bottom and at the start side. The wordmark title stays LTR (mark + "Noor Imene") with the subtitle under the wordmark. The settings gear sits at the top end in a 48 dp button with a tooltip and opens showSettingsSheet. Place `overlap` with a negative bottom offset so the following content isn't covered (the hero reserves the lower half of the overlap height).
2. NoorNavBar per the contract. Keep Semantics(selected, button, label) and 48 dp targets. The raised circle must not be clipped and must not cover page content (check against bottom_navigation.dart).
3. NoorPagerPill per the contract, with tooltips and semantics on the chevrons.
4. LocationPill: match r1c1 (card fill, pin icon at the start, label, mirrored chevron at the end). Only restyle; keep its behaviour.
5. test/widgets/noor_hero_test.dart: pump NoorHero with a missing asset in ar and en at text scale 1.3. Expect no exceptions, the title found, and no overflow.

Acceptance: `flutter analyze lib/generals lib/bottom_navigation.dart test/widgets` is clean apart from the NoorArt/S names that 0.A provides. The hero test passes once 0.A has finished.
```

---

### WAVE 1: run 1.A–1.G together

Every Wave 1 prompt begins: `Read first: design.md, ui-plan.md sections "Decisions", "2.1 Ground rules", "2.2 Contracts".` Every screen prompt (1.A, 1.B, 1.D, 1.E) removes its `NoorHeader` use; the `NoorHero` is the header (U10).

#### 1.A Prayers screen

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Operate). Read and follow its craft floor before editing.

Read first: design.md, ui-plan.md sections "Decisions", "2.1 Ground rules", "2.2 Contracts". Reference panels: r1c1 (screen), r2c1 (next-prayer row style only, decision U8).

Task: rebuild the Prayers tab visuals to match r1c1. Keep all controller logic, day navigation, alarms and sheets as they are.

You own: lib/features/adhan/adhan_screen.dart, lib/features/adhan/widgets/adhan_line.dart, test/adhan_screen_test.dart.

Layout, top to bottom (remove the NoorHeader app bar; the hero is the header):
- NoorHero(art: NoorArt.heroPrayers, wordmark: true, leading: NoorMark, settings: true, title: app name, subtitle: tagline_prayers, overlap: LocationPill)
- Next-prayer card: mosque IconTile, "Next Prayer" meta, "Dhuhr in 1h 10m" row title, time at the end in the Spectral numeral style. Only on today; same data as now.
- Day switcher card: mirrored chevrons at both ends, "Today" or the date in the centre (existing handlers).
- One card containing six rows with hairline dividers. Each row: tinted icon tile, name, time (numeral), speaker icon button (the existing sound/alarm toggle), chevron (existing reminder sheet). Highlight the next prayer as in r2c1 (U8): sage row fill, icon tile filled primary with an onPrimary icon, speaker button on a sage-tint circle.
Keep the existing loading/empty/error states, restyled with EmptyState.

Acceptance: `flutter analyze lib/features/adhan/adhan_screen.dart lib/features/adhan/widgets/adhan_line.dart` is clean. `flutter test test/adhan_screen_test.dart` passes (update finders only if the structure changed; don't weaken assertions).
```

#### 1.B Quran list

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Operate). Read and follow its craft floor before editing.

Read first: design.md, ui-plan.md sections "Decisions", "2.1 Ground rules", "2.2 Contracts". Reference panels: r1c2 (light), r1c3 (dark).

Task: rebuild the Quran tab visuals to match r1c2/r1c3. Keep search, progress, bookmarks and the Surah/Hizb data as they are.

You own: lib/features/quran/quran_screen.dart, lib/features/quran/widgets/surah_line.dart, lib/features/quran/widgets/bookmarks_sheet.dart.

Layout (remove the NoorHeader app bar; the hero is the header):
- NoorHero(art: NoorArt.heroQuran, title: quran_title, subtitle: tagline_quran, overlap: NoorSearchField)
- Continue card: "Last Read" meta at the start and a "Reset reading progress" text button at the end (existing confirm). Then "Al Fatihah · Page 1" row title, "n of 604 pages" meta, NoorProgressBar, then the primary Continue Reading button (arrow icon, mirrored) and a square tonal bookmark button (opens the bookmarks sheet). Hide the card when there's no last read.
- NoorSegmented Surah / Hizb.
- Surah rows: number circle, Arabic name (Amiri), transliteration, "7 verses · Meccan" meta, a 48 dp mini progress bar plus percent (real data only), chevron.

Acceptance: `flutter analyze lib/features/quran/quran_screen.dart lib/features/quran/widgets` is clean, and `flutter test test/quran_progress_test.dart test/quran_hizb_test.dart` passes.
```

#### 1.C Mushaf reader

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Read). Read and follow its craft floor before editing.

Read first: design.md, ui-plan.md sections "Decisions", "2.1 Ground rules", "2.2 Contracts". Reference panel: r2c2.

Task: give the reader the ornamental page from r2c2. Quran text rendering, page logic, the progress recording and bookmarks don't change.

You own: lib/features/quran/screens/read_quran_screen.dart, lib/features/quran/widgets/mushaf_frame.dart (new).

- Top bar (keeps tap-to-toggle chrome): back at the start, centre surah name (row title) over "Page n" (meta), bookmark toggle at the end.
- MushafFrame: a thin gold hairline frame with radius 16 on the mushaf colour, NoorArt.pageCorner in the corners (mirrored per corner), NoorArt.divider at the foot. On a page where a surah starts, show NoorArt.surahCartouche with the surah name (Amiri Bold, or the optional surah font if present in pubspec) above the text, plus the basmala as now.
- Bottom: NoorPagerPill(split: true) with the page number. Per U7, left = next page in the Mushaf. Wire it to the PageController with a 250 ms animation. Swiping stays.
- The text must keep the same font size and line height. The frame takes its space from the margins, not by shrinking the text; check page 2 and a long page (e.g. 50) for overflow at text scale 1.0 and 1.3.

Acceptance: `flutter analyze lib/features/quran/screens lib/features/quran/widgets/mushaf_frame.dart` is clean.
```

#### 1.D Athkar

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Operate for the list, Read for the reader). Read and follow its craft floor before editing.

Read first: design.md, ui-plan.md sections "Decisions", "2.1 Ground rules", "2.2 Contracts". Reference panels: r1c4 (list), r2c4 (reader).

Task: restyle the Athkar list and the dhikr reader. Search, the DB and the counter behaviour stay. Display text says "Athkar" (U9, strings from 0.A); don't rename code identifiers or files.

You own: lib/features/duaa/duaa_screen.dart, lib/features/duaa/adhkar_categories.dart, lib/features/duaa/adhkar_display_screen.dart, lib/features/duaa/data/adhkar_search.dart, test/duaa_categories_test.dart.

- List (remove the NoorHeader app bar; the hero is the header): NoorHero(art: NoorArt.heroAthkar, leading: small praying-hands icon, title: the Athkar title, subtitle: tagline_adhkar, overlap: NoorSearchField). Then category rows as separate cards: tinted icon tile, title, "n athkar" meta from real counts (if the count isn't available yet, add one COUNT query in adhkar_search.dart, not in the shared DB service), mirrored chevron.
- Reader: header with back, category title, "i / total" meta and a 2 dp progress line. One card: dhikr title in primary (Amiri), NoorArt.divider, dhikr text (NoorText.dhikr), centred. Bottom: NoorPagerPill(split: false). The centre is the remaining repetition count and tapping it counts (U6). Chevrons move between adhkar. Keep the existing haptic and auto-advance behaviour if present.

Acceptance: `flutter analyze lib/features/duaa` is clean and `flutter test test/duaa_categories_test.dart` passes.
```

#### 1.E Qibla

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Operate). Read and follow its craft floor before editing.

Read first: design.md, ui-plan.md sections "Decisions", "2.1 Ground rules", "2.2 Contracts". Reference panel: r2c3.

Task: restyle the Qibla tab to r2c3. Sensor, permission, distance and calibration-sheet logic stay.

You own: lib/features/qibla/**, test/qibla_screen_test.dart.

- Top (remove the NoorHeader app bar; the hero is the header): NoorHero(art: null, wordmark: true, leading: NoorMark, settings: true, title: app name, height ≈ 140, overlap: LocationPill). The null art gives the faint sky gradient.
- Compass (code, CustomPainter): cream face, 1.5 dp green ring, 60 ticks with gold majors every 15°, N/E/S/W in Spectral, an 8-point compass rose in the centre (gold and green), a green triangular qibla pointer, and the fixed gold heading tick at the top. Keep the existing animation and smoothing.
- Card: "Qibla direction" meta, degrees in a 48 Spectral numeral, a tonal Calibrate pill at the end (opens the existing sheet), hairline, then "Distance to the Kaaba" with a pin icon and "~ n km" at the end (hidden on failure, as now).
- Footer: NoorArt.qiblaSkyline anchored to the bottom behind the nav bar, not mirrored, IgnorePointer, under all content.
- Small heights (≤ 700 dp): the compass shrinks before the card does; nothing scrolls under the nav bar.

Acceptance: `flutter analyze lib/features/qibla` is clean and `flutter test test/qibla_screen_test.dart` passes.
```

#### 1.F Location, Settings and Pick Adhan sheets

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Operate). Read and follow its craft floor before editing.

Read first: design.md, ui-plan.md sections "Decisions" (U4, U5), "2.1 Ground rules", "2.2 Contracts". Reference panels: r1c5 (location contents), r1c3 (settings sheet), r2c5 (pick adhan panel). All three stay bottom sheets (showNoorSheet); only their contents change. No art in any of them.

You own: lib/generals/location_flow.dart, lib/features/adhan/widgets/location_picker_sheet.dart, lib/generals/widgets/settings_sheet.dart, lib/features/adhan/widgets/sound_picker_sheet.dart, lib/features/adhan/widgets/sound_picker_controller.dart.

1. Location sheet (U4): title location_title and subtitle location_subtitle; two stacked radio cards (IconTile, title gps / manually, subtitle gps_subtitle / manual_subtitle, Radio at the end; the whole card is tappable and selects); then the primary Confirm Location button, disabled until a choice is made. Confirm runs the existing GPS path or the existing manual picker sheet. pickLocation(context) keeps its signature and return contract; the existing loading/error dialogs stay.
2. Settings sheet: title, Dark Mode row (moon icon, label, Switch), "Language" label, three pills (العربية / English / Français) with the selected one primary-filled. Same controllers as now.
3. Pick Adhan sheet (U5): drag handle, "Pick Adhan" title, radio rows (radio, reciter name, a play/stop icon button on the selected row using the existing preview player), then the primary Save button. Save writes via the existing controller and closes the sheet. Dismissing stops the audio and discards. Keep the show function's name and call sites working.

Acceptance: `flutter analyze lib/generals lib/features/adhan/widgets` is clean. Grep that every previous caller of pickLocation and of the sound picker still compiles unchanged.
```

#### 1.G Custom splash and app icon

```text
/ponytail:ponytail ultra
Use the /impeccable skill (mode Experience). Read and follow its craft floor before editing.

Read first: design.md, ui-plan.md sections "Decisions" (U1, U10, U11), "2.1 Ground rules", "2.2 Contracts". Reference: assets/screens/splash.png and splash_dark.png.

You own: lib/generals/splash_screen.dart (new), lib/main.dart and lib/my_app.dart (only the wiring that shows the splash first), the pubspec.yaml flutter_launcher_icons block, and the launcher outputs that `dart run flutter_launcher_icons` regenerates (android/app/src/main/res/mipmap-*/**, android/app/src/main/res/drawable-*/ic_launcher_*, ios/Runner/Assets.xcassets/AppIcon.appiconset/**). Don't touch splash.yaml or any native splash output (U10).

1. App icon: point flutter_launcher_icons at A8/A9 (adaptive background #F6F3EB) and run the generator.
2. Custom splash (SplashScreen), shown right after the native splash: background paper (light) or a deep-green vertical gradient (dark), plus a faint diagonal light-ray gradient (light only). NoorArt.splashTop anchored top and NoorArt.splashBottom anchored bottom, both fit width. Centre column: emblem (light/dark SVG, ~38% of width), the Arabic name (U1) in Amiri Bold 40 (ink, or cream on dark), the "NOOR IMENE" Spectral 18 line with 0.35em letter-spacing between two gold hairlines ending in small diamonds (drawn in code), and a 28 dp thin ring spinner (primary arc fading out).
3. Wiring (U11): the SplashScreen is the first route. It stays up while (a) the app's existing async startup runs and (b) the current theme's art is precached: precacheImage for every NoorArt.heroes base via NoorArt.of, and the two emblem SVGs warmed through flutter_svg's cache. A failed precache is skipped, never fatal. Then fade to the shell over 300 ms. Don't reorder alarm/Workmanager init. Don't add delays. Call FlutterNativeSplash.remove() after the custom splash's first frame. To avoid a jump from the native splash colour (#F6F3EB / #0E1512), its first frame starts on that colour and its art and background fade in over 250 ms.
4. Reduce Motion: the spinner still turns (it's the only progress signal) but the fades become instant.

Acceptance: `flutter analyze lib/main.dart lib/my_app.dart lib/generals/splash_screen.dart` is clean. Report which launcher files the generator changed.
```

---

### WAVE 2: run one at a time, in order

#### 2.1 Emulator pass and one fix batch

```text
/ponytail:ponytail ultra
Use the /impeccable skill (command: polish; mode Operate).

Read first: design.md, ui-plan.md sections "Decisions" and "2.1 Ground rules".

Task: verify the whole UI v2 against assets/screens/screens.png and the splash images on the emulator, then fix everything in one batch. You own all of lib/ for this session; nobody else is running.

1. `flutter run -d emulator-5554`. Capture (adb exec-out screencap -p) all ten panels' screens plus the splash, in en-light, ar-light and ar-dark. Also capture Prayers and Quran at font scale 1.3. Save them to the scratchpad.
2. Compare each to its panel. List every deviation: layout, spacing, colour, type, RTL mirroring (art mirrored except NoorArt.noMirror), scrim contrast under hero text, the nav circle clipping, overflow, and the native → custom splash hand-off.
3. Fix all of them in one batch. Delete lib/generals/widgets/noor_header.dart if nothing imports it any more (U10). Re-capture once and confirm. Stop there; don't loop.
4. `flutter analyze && flutter test`.

Final reply: the deviation list with fixed / not fixed and why, plus anything only a real device can judge (image sharpness on a high-dpi phone, splash hand-off on cold start).
```

#### 2.2 Device audit and final check

Commit, then run **plan.md prompts 4.2 → 4.3 → 4.4** as written there. They now audit the final UI.

---

## 3. Done when

- The art gate test, `flutter analyze` and `flutter test` all pass, and the debug APK builds.
- Each of the ten panels and both splashes match their reference in en / ar × light / dark, with no overflow at text scale 1.3.
- No writing appears mirrored in RTL. Text over art measures ≥ 4.5:1.
- No screen has the old shared app bar; `NoorHeader` is gone.
- No behaviour changed: alarms, preferences, progress, bookmarks and counters work as before (plan.md 4.4 confirms the keys and ids).
