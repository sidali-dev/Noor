# Plan: replace the Faith (teal/mint) look with the Hilal design system

Source of truth: `hilal-design-system/` (README, `tokens.json`, `tokens.css`, `assets/Logos`, `assets/Motifs`, `components/*/README.md`, `screens/*.png` and the `-html.zip` files).
Decisions made: Hilal **replaces** Faith fully, fonts are **bundled**, screens Hilal does not cover are **derived** with `/impeccable`.
Unchanged: package `noor`, app id `com.sidalidev.noor`, alarm IDs, preference keys, prayer/alarm logic. Visual change only.

**How to use this file:** every block marked `text` under a phase is a complete prompt. Copy it as is and paste it into Claude Code. Nothing else needs to be prepended. Run the phases in order, and finish each one green (`flutter analyze` and `flutter test`) before starting the next.

## Status

Checked against the working tree (not on a device): `flutter analyze` clean, `flutter test` 486 passed.

| Phase | State |
|---|---|
| 0 Checkpoint and baseline | **Done.** Work committed on `rebrand` (9 commits), branch `hilal` created, analyze and test green (`adhan_ring_screen_test` passes). The two html references (Qibla, Athkar reader) were not screenshotted. |
| 1 Design contract | **Done.** `design.md` fully replaced, `PRODUCT.md` updated. |
| 2 Tokens, theme, fonts | **Done, with gaps.** Cormorant 500/600, Jost 400/500, Amiri 400/700 bundled; Spectral and Plex removed; `noor_theme_test` updated. Gaps: the theme extension is still `NoorColors` / `context.noor`, not `HilalTheme` / `context.hilal` as `design.md` §2 says; `design.md` wants Cormorant 600 only and Jost 600, the bundle has Cormorant 500 and no Jost 600. |
| 3 Logo, icon, splash | **Done, with a leftover.** New logo SVGs and PNG marks, app icon, native splash, custom splash. `assets/images/splash/*.svg` (4 files) is not referenced anywhere. |
| 4 Art and ornaments | **Done, with a leftover.** Hero and skyline SVGs (paper and night), ornaments redrawn, `ayah_marker.svg`. The old `hero_*_light.webp` and `qibla_skyline_light.webp` are still on disk, still precached by the splash (`NoorArt.of`) and still tested in `art_assets_test.dart`, while `NoorHero` draws the SVGs. |
| 5 Shared widgets | **Done.** Card, button, nav bar, hero, search, segmented, list row, pill, progress, sheet, dialogs, empty/loading state, pager pill, plus `arch_frame`, `noor_icon`, `noor_pressable`, `noor_star_badge`, `noor_well`, `noor_radio`, `noor_motion`, `noor_layout`. `icon_tile.dart` is gone. |
| 6 Designed screens | **Implemented, not seen on a device.** Prayers, Quran index, Mushaf, Athkar list and reader, Qibla all changed with tests passing. Brass placement per screen is still the unreviewed assignment from Phase 1. |
| 7 Derived screens | **Implemented, not seen on a device.** Ring screen, location and relocate sheets, calibration sheet, empty/loading/permission states (`states_test`, `location_sheet_test`, `permission_notice.dart`). |
| 8 Refinement passes | **Not verified.** No record that critique, audit, harden, adapt, animate or polish were run as passes. `noor_layout.dart`, `noor_motion.dart` and their tests suggest adapt and animate were at least started. |
| 9 Verification gate | **Partly run.** Done: analyze, test, leftover grep (no `faith_emblem`, `Spectral`, `Plex`, `NoorTint`, hero `_light` names outside the legacy webp path), and the diff of `adhan/services` and `local_storage` against the pre-rebrand base (empty). Not done: `flutter build apk --analyze-size` compiled but failed at packaging (no release keystore on this machine); asset sizes instead: fonts 1.7 MB to 1.6 MB, art and splash 0.4 MB to about 0.26 MB. Open: device pass, README and screenshots, the `hilal-design-system/` decision. |

## Phase 1 outcome: what later prompts must follow

`design.md` is now the source of truth. Where a prompt below disagrees with it, **`design.md` wins**. The prompts are not rewritten, so apply this table when you paste them. Section numbers refer to `design.md`.

| Topic | Decision | Affects |
|---|---|---|
| Digits | Western 0–9 in every locale, ar included. Numbers laid out LTR. Display numerals in Cormorant 600, inline numerals in Amiri (ar) or Jost (fr/en). No Arabic-Indic. §3.4 | Phases 2, 6 |
| Fonts | Cormorant Garamond **600 only**, Jost 400/500/600, Amiri 400/700 (Amiri has no 500/600, so 500+ maps to 700). Quran font untouched. No `google_fonts`. §3.1–3.2 | Phase 2 (prompt says Cormorant 500/600, Jost 400/500) |
| Arabic ramp | Not in tokens.json; from the mocks: title 28/40, heading 18/30, bodySm and label 15/22, caption 12/18, dhikr 24/52. §3.3, §12 | Phases 2, 6 (reader prompt says 24 / 1.9) |
| Theme extension | `HilalTheme`, accessor `context.hilal`. `NoorColors`, `NoorTint` and the icon tints are retired. §2, §15 | Phase 2 (renaming `noor_theme.dart` is fine) |
| Primary action colour | `window` fill in Paper. In **Night it inverts** to `onWindow` fill with `window` content: primary button, active tab, checked toggle, pager. §6.1 | Phases 5, 6 |
| Window in Night | Always framed by a `surfaceRaised` ring plus shadow; Night adds a 1 dp `line` seam. Legibility comes from the content, not the edge. §6.1 | Phase 5 |
| Brass | One current thing per region, no glow, never on `onWindow` in Night, no brass text on a window in Paper. One element per screen: Prayers = next prayer, Quran index = continue-reading marker, Mushaf = bookmark, Athkar list = none, reader = repeat badge, Qibla = the pointer. §6.2 | Phases 4, 5, 6 |
| Brass the prompts overuse | Remove: brass star badge on every surah row, brass progress fill, brass Mushaf frame and corner stars, brass ayah markers, brass morning icon tile, brass progress line in the reader, brass aligned ring. Mushaf frame and ornaments use `line`; progress fill uses `window`. | Phases 4, 6 |
| Icon tiles | Gone. Leading icons are plain `ink` at 22–24 dp, no tinted or window-filled round tiles. §8 | Phase 5 (`icon_tile.dart`), Phase 6 |
| Hero art | Only Prayers keeps a hero (`HilalArchFrame`, twinkle there only). Quran, Athkar and Qibla get **plain headers** on `surface` (owner decision). SkyHeader exists only in the mocks and is not built. §9 | **Phase 4** (skip art for Quran/Athkar/Qibla), **Phase 5** (`noor_hero.dart`), Phase 6 |
| Search field | `surfaceSunken` + inset shadow, **radius 8** (token, owner decision), not 14 | Phase 5 |
| Qibla aligned | No mint or brass ring, no halo. A `success` word and check icon, one vibration, live-region label, 250 ms fade. Brass pointer stays. N in `danger`. §8.1 | Phase 6 (prompt says brass ring + halo) |
| Tab bar | Floating `surfaceRaised` pill, `shadow1`, active = `window` pill (Night inverts). No raised circle. Amiri 12 sp labels in ar (small, check on device) | Phase 5 |
| Splash | Flat `surface` / `window` ground, logo lockup, no gradient, ray or arch; 300 ms fade, no fixed delay | Phase 3 (the splash `shape` prompt proposes an ArchFrame; that conflicts, decide with the owner) |
| Logos | Rasterise to PNG at 1x/2x/3x for splash and headers (`flutter_svg` ignores `feDropShadow`); SVGs stay as masters; app-icon SVG only for native export. Pick Paper/Night from the active `HilalTheme`. §10 | Phase 3 |
| Motion | Not in tokens.json; from README/bundle: enter 180–240 ms ease-out with a 4–8 dp rise, press 1 dp + `shadow1` in 120 ms, no ripples. §7 | Phases 5, 8 |
| Spacing, radii | Margin 16, card gap 24, section gap 32; radii 8/14/24/999. Off-scale mock values are snapped, not copied | all |
| `eyebrow` | Defined, never used. No uppercase or letter-spacing in Arabic | all |

Open items to verify while implementing (not blocking):
- Whether the bundled Cormorant Garamond has lining and tabular figures; if not, times use Jost (Phase 2).
- Amiri 12 sp tab labels may be too small (Phase 5).
- Which tool rasterises the logos; if none, the prompt must stop (Phase 3).
- Arabic title, heading and dhikr sizes are mock-derived; confirm after the first device pass (Phases 2, 6).
- The per-screen brass assignments are mine; the owner may move them (Phase 6).

## What changes (Faith to Hilal)

| | Faith now | Hilal |
|---|---|---|
| Idea | clear water, teal ink, mint mark | cut paper, night window, one brass accent |
| Ground / card | `#F2F8F8` / `#FCFEFE` | `surface #eef0f4` / `surface-raised #fff` (dark: `#101217` / `#1c1f27`) |
| Action colour | `primary` teal-blue | `window #171a21` (night sky): primary button, active tab, next-prayer card |
| Accent | mint `mark` | `brass #7a6436` (dark `#cdb588`), small doses only |
| Fonts | Spectral, IBM Plex Sans Arabic, Amiri | Cormorant Garamond (display, numbers), Jost (UI, Latin), Amiri (Arabic) |
| Depth | one soft teal shadow | `shadow-1/2/3` + `shadow-inset`, hero shadow box |
| Logo | mint-teal-blue emblem | paper dome window, brass crescent, bolt, wings, "FAITH" wordmark |
| Dark | deep teal | Night theme, every token has a Night value |

Gaps to handle on purpose:
- **Arabic is the default language** and Jost/Cormorant have no Arabic glyphs. Every text style needs `fontFamilyFallback: [Amiri]`.
- ~~Hilal's screenshots show Arabic-Indic digits in text.~~ **Resolved:** Western digits in every locale (design.md §3.4).
- Athkar reader and Qibla have **no PNG**, only html zips.
- The hero art (mosque skyline, open book, tasbih) only exists inside the PNGs, so it must be redrawn from `Motifs` or lifted from the html's inline SVG.
- Hilal allows no gradients except inside `ArchFrame`. The emblem's mint-teal-blue gradient goes away.

---

## Phase 0: checkpoint and baseline (manual, no prompt)

- [ ] Commit the current rebrand work on `rebrand` (169 changed files). Include `hilal-design-system/` as a tracked reference folder (untracked today).
- [ ] `git switch -c hilal`
- [ ] `flutter pub get && flutter analyze && flutter test`. `adhan_ring_screen_test.dart` ("15:34" not found) failed in the last run: find out if it is a real regression or a 12h/24h locale problem and fix it **before** restyling.
- [ ] Unzip the five `screens/*-html.zip` files into a scratch folder (not the repo), open `ArQibla.dc.html` and `ArAthkarReader.dc.html` in a browser, and screenshot them as the Qibla and Athkar-reader references.

## Phase 1: rewrite the design contract (DONE)

Result: `design.md` and `PRODUCT.md` rewritten; owner decisions taken (Western digits, plain headers, search radius 8, logos rasterised). See "Phase 1 outcome" above. The prompt is kept for reference; do not re-run it.

Goal: `design.md` and `PRODUCT.md` describe Hilal, so every later prompt has the right source of truth.

```text
/impeccable shape

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed, in short moments, at dawn and before sleep.

Task: write the design contract for moving the app to the Hilal design system. Inputs: hilal-design-system/README.md, tokens.json, the five screens/*.png, and the current design.md and PRODUCT.md (both still describe the old teal/mint Faith look and are to be replaced). Output: a new design.md (Flutter terms: ThemeExtension fields, widget names, dp instead of px, Paper and Night themes, type scale, spacing, radii, shadows, motion, components, do/don't) and the edited sections of PRODUCT.md (Brand Commitments for the new logo, brass and paper/night; also fix the stale line about assets/noor.db, the adhkar live in assets/data/adhkar.json). Resolve and write down explicitly: the Arabic font fallback (Jost and Cormorant have no Arabic glyphs, Amiri covers them), which digit style each locale uses, what "window" means in Night where it is almost the same colour as the ground, and how brass is used in Night.

Rules: hierarchy comes from layered paper and its shadow, not from colour, borders or gradients. No gradients except inside the hero ArchFrame, no glassmorphism, no emoji, no purple/blue AI palette. Brass at most once per region. Every value comes from tokens.json; if one is missing, say so instead of inventing it. Copy is warm, calm, brief, sentence case, no exclamation marks. Do not write any Dart in this step. Finish with a short list of what you changed and what you left alone.
```

## Phase 2: tokens, theme and fonts (no visual redesign yet)

Do by hand or in the prompt: add Cormorant Garamond (500, 600) and Jost (400, 500) TTFs to `assets/fonts/`, remove Spectral and Plex, update `pubspec.yaml` and `assets/fonts/LICENSES.md` (OFL). If the TTFs cannot be downloaded in the session, the prompt will stop and tell you; drop them in `assets/fonts/` and re-run it.

```text
/impeccable extract

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed, in short moments. Read PRODUCT.md, design.md (the new Hilal version from Phase 1), hilal-design-system/README.md and hilal-design-system/tokens.json first.

Task: turn hilal-design-system/tokens.json into lib/utils/theme/noor_theme.dart for Paper (light) and Night (dark). Keep the existing ThemeExtension pattern and public shape where it makes sense. Add window, windowRaised, onWindow, onWindowMuted, brass, brassSoft, paperShade, depthShadow, success/danger and their soft fills; remove mark, mushaf and the five icon tints. Add shadow helpers (shadow1, shadow2, shadow3, inset) as List<BoxShadow> and spacing (4/8/12/16/24/32/48/64) and radius (8/14/24/999) constants. Text styles from tokens.json: displayXl, displayLg, title, heading, body, bodySm, label, eyebrow, caption, arabicDisplay, arabicBody; times and big numbers use the display face; every style sets fontFamilyFallback to Amiri so Arabic never falls to a system font. Fonts: Cormorant Garamond (500, 600) and Jost (400, 500) bundled under assets/fonts/ and declared in pubspec.yaml (use forward slashes), Spectral and Plex removed, assets/fonts/LICENSES.md updated; if you cannot obtain the font files, stop and tell me what to drop where. Then fix compile errors in widgets that used removed tokens by renaming only, without restyling. Update test/noor_theme_test.dart to the new tokens, including a WCAG contrast check for the text pairs tokens.json documents (4.5:1) and line-strong (3:1).

Rules: every value comes from tokens.json; if one is missing, stop and say so. No visual redesign of widgets in this step. Do not change behaviour: alarm IDs, preference keys, controllers, scheduling, localisation keys. Finish with: the list of removed Faith tokens and which widgets referenced them, then flutter analyze and flutter test results.
```

## Phase 3: logo, app icon, splash

Run the native tools only after the logo is final: `flutter_native_splash` rewrites resources under `android/` and `ios/`.

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md and hilal-design-system/assets/Logos/README.md first.

Task: install the Hilal Faith logo. Copy faith-logo-paper.svg, faith-logo-night.svg, faith-mark-paper.svg, faith-mark-night.svg and faith-app-icon.svg from hilal-design-system/assets/Logos into assets/logo/, delete the old faith_logo.svg and faith_emblem.svg, and update the pubspec.yaml assets list. Update lib/generals/widgets/noor_mark.dart so it loads the mark by theme (paper on light, night on dark); headers use the mark alone, never the full lockup. Render faith-app-icon.svg to assets/logo/app_icon.png (1024) and produce app_icon_foreground.png with adaptive-icon safe-zone padding; set adaptive_icon_background in pubspec.yaml to #eef0f4; run dart run flutter_launcher_icons. Update splash.yaml: color #eef0f4, color_dark #101217, images are the mark on those grounds, Android 12 icon likewise; run dart run flutter_native_splash:create --path=splash.yaml, then show git diff --stat for android/ and ios/ so I can check what it rewrote.

Rules: never recolour, stretch or outline the logo; keep clear space of at least the crescent width; the full lockup needs at least 120 px height, below that use the mark. Do not change the application id or package name. If you have no tool to render SVG to PNG, stop and tell me which one to install instead of faking the file. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable shape

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json and hilal-design-system/components/ArchFrame and Cover first.

Task: redesign the custom Flutter splash (lib/generals/splash_screen.dart) that follows the native one. Paper and Night. One hero moment only: the ArchFrame shadow-box treatment around the Faith mark from assets/logo, then the Arabic name نور الإيمان and the Latin wordmark "FAITH". It fades out in 300 ms when startup and art precache are done: keep the existing readiness logic and do not add a fixed delay. First propose two directions as short ASCII sketches with one paragraph each and wait for my pick before writing code; after my pick implement it and update test/splash_screen_test.dart.

Rules: no gradients except inside the ArchFrame, no glassmorphism, no emoji, no looping animation (a one-time paper-settle and a gentle star twinkle in the sky only, off when MediaQuery.disableAnimationsOf is true). Every value comes from tokens.json. Do not change startup behaviour, alarm scheduling or preference keys. Finish with a short list of what you changed and what you left alone.
```

## Phase 4: art and ornaments

Hilal's hero art is a night skyline with a cloud-scroll base: mosque and minarets (prayers), open book on a rest (Quran), tasbih (athkar), skyline (qibla, stays in `NoorArt.noMirror`). Prefer SVG built from `Motifs` (`flutter_svg` is already a dependency) so Paper and Night share one asset.

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md, hilal-design-system/README.md, hilal-design-system/assets/Motifs/README.md and the hero bands in hilal-design-system/screens/*.png first.

Task: create the hero art for Prayers (mosque with two minarets), Quran (open book on a rest), Athkar (tasbih) and Qibla (city skyline) from the Motifs in hilal-design-system/assets/Motifs and the hero bands in the reference PNGs: night sky, a few stars, one crescent with a sky-glow halo, a white paper cloud-scroll base. Write them as SVGs under assets/images/art/, each under about 40 KB, readable at 390 dp wide, with the title zone on the start side kept calm. Replace the old hero_*_light.webp and qibla_skyline_light.webp, plus the splash_top/splash_bottom webps, and update lib/utils/constants/image_strings.dart (NoorArt, keep qiblaSkyline in noMirror) and test/art_assets_test.dart (file names and size budgets; drop the _light suffix logic if the art becomes theme-agnostic) and the pubspec.yaml assets list. Also redraw assets/images/ornaments/divider.svg, page_corner.svg and surah_cartouche.svg as brass hairline work, and make an ayah end marker from the brass eight-point star (star-8.svg). Render each hero at Paper and Night and show them to me before deleting the old files.

Rules: no people, one crescent, stars in two sizes only, no gradients except the soft sky-glow halo, brass only on ornaments. Every colour is a Hilal token. Do not change layout code in this step. Finish with a short list of what you changed and what you left alone.
```

## Phase 5: shared widgets (`lib/generals/widgets/`)

The Hilal components are React (`hilal-design-system/components/<Name>/README.md` and `preview.html`); the prompts re-implement them in Flutter, they don't wrap them. Run these in order.

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json and hilal-design-system/components/PaperCard and Button (README.md and preview.html) first.

Task: reimplement lib/generals/widgets/noor_card.dart as the Hilal PaperCard (surface-raised, shadow-2, no border, radius 24, plus a tone: night variant) and lib/generals/widgets/noor_button.dart as the Hilal Button (primary = window fill with on-window text, tonal, outline; pressed = moves 1 px down and drops to shadow-1; disabled = 45% opacity and no shadow; visible focus ring in brass, 2 px, offset 2). Keep each widget's public constructor unless it blocks the design; if so, list the call-site changes and make them. RTL-safe, 48 dp touch target, honours text scale 1.3. Add one widget test per widget for the state that is easiest to break (disabled, pressed or RTL).

Rules: hierarchy comes from layered paper and its shadow, not from colour, borders or gradients. No gradients, no glassmorphism, no emoji. Brass only for the focus ring. Every value comes from tokens.json. Do not restyle neighbouring widgets and do not change behaviour. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json and hilal-design-system/components/TabBar (README.md and preview.html) and screens/*.png (bottom bar) first.

Task: reimplement lib/generals/widgets/noor_nav_bar.dart as the Hilal TabBar: floating space-4 above the bottom safe area and inset space-4 from the sides, surface-raised with shadow-1, four items (Quran, Prayers, Athkar, Qibla; ar: القرآن، الصلاة، الأذكار، القبلة), the active item is a window pill with icon and label in on-window, inactive items show icon and label in ink-muted. Selection change animates in 200 to 240 ms ease-out, no bounce. Keep the public API used by lib/bottom_navigation.dart and update test/bottom_navigation_test.dart. RTL order must mirror, 48 dp touch targets, labels stay readable at text scale 1.3.

Rules: no gradients, no glassmorphism, no emoji, brass only for the focus ring. Every value comes from tokens.json. Do not change navigation behaviour or tab order. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json, hilal-design-system/components/ArchFrame, Cover and Ornament, the hero art in assets/images/art/ and the hero bands in screens/*.png first.

Task: reimplement lib/generals/widgets/noor_hero.dart as the Hilal screen header: a night band with the hero art behind the status bar, a white paper cloud-scroll base, the page title in Amiri (Arabic) or Cormorant Garamond (fr/en) on the start side, one short verse or line as subtitle in on-window-muted, a settings button as a white disc at the top start, and an optional overlap child (search field or location pill) that straddles the bottom edge. No art falls back to a flat window fill. Keep the widget's public constructor unless it blocks the design; update call sites. Hero art mirrors with the layout except pieces in NoorArt.noMirror. Stars may twinkle (0.85 to 1 opacity over 4 s, staggered), switched off when MediaQuery.disableAnimationsOf is true. Add a widget test for RTL and for the no-art fallback.

Rules: the hero is the one shadow-box moment per screen; no gradients except the soft sky-glow halo; no glassmorphism, no emoji; brass at most once. Every value comes from tokens.json. Do not change behaviour or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json, hilal-design-system/components/TextField, Badge, Icon, Toggle and PaperCard READMEs and the Quran, Athkar and Prayers PNGs first.

Task: reimplement these widgets in lib/generals/widgets/ in the Hilal style: noor_search_field.dart (surface-sunken well with shadow-inset, search icon at the start, clear button when non-empty, 48 dp, radius 14), noor_segmented.dart (sunken trough, raised selected segment), noor_list_row.dart (title in heading, meta line in body-sm, chevron that mirrors in RTL, hairline line dividers inside one grouped paper list), icon_tile.dart (round; window fill when selected, brass-soft for the morning tile, surface-sunken otherwise), noor_progress_bar.dart (4 dp, line track, brass fill, with a small numeral percentage), noor_pill.dart and location_pill.dart (raised paper chips with a leading icon and a trailing chevron). Keep public constructors unless they block the design; update call sites. RTL-safe, 48 dp touch targets, text scale 1.3. Add one widget test for the search field (clear button) and one for the list row (RTL chevron).

Rules: hierarchy comes from layered paper and its shadow, not borders; controls that must be seen use line-strong, never line. No gradients, no glassmorphism, no emoji; brass at most once per region. Every value comes from tokens.json. Do not change behaviour. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md and tokens.json first.

Task: reimplement these widgets in lib/generals/widgets/ in the Hilal style: noor_sheet.dart (surface-raised, shadow-3, radius 24 at the top, drag handle, title in the display face, content; replaces most dialogs), check_dialog.dart and wait_dialog.dart (paper cards, one primary action, danger only with an icon and a word), empty_state.dart (one icon or motif, one sentence, one button), noor_pager_pill.dart (window pill with chevrons that follow Directionality and a centre label; split variant = window centre pill between two raised circles, in the Mushaf left = next page), settings_sheet.dart. Keep public constructors unless they block the design; update call sites. Add one widget test for the sheet (dismiss by swipe) and one for the pager pill (RTL chevron order).

Rules: no gradients, no glassmorphism, no emoji; success and danger are for state only and always come with an icon and a word. Brass at most once per region. Every value comes from tokens.json. Do not change behaviour, controllers or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, hilal-design-system/components/Icon/README.md and tokens.json first.

Task: do two things. (1) Icons: Hilal ships 12 line icons (home, compass, calendar, bookmark, settings, moon, star, search, bell, check, alert, plus) at 24 px, stroke 1.6, round caps. Audit every icon used in lib/ (iconsax and assets/images/svg), map the ones Hilal covers to the Hilal look, keep iconsax Linear style only where Hilal has no equivalent, and never mix filled and line icons; list the final mapping. (2) Motion: add one small helper in lib/utils/theme/ for "paper settles" (fade from 0 and move up 4 to 8 px, 180 to 240 ms, ease-out) that does nothing when MediaQuery.disableAnimationsOf(context) is true, and a 1 px press-down for tappable paper. Do not apply the motion to screens yet.

Rules: no bounces, spins or parallax; nothing loops except the compass and the active alarm screen. Every value comes from tokens.json. Do not change behaviour. Finish with a short list of what you changed and what you left alone.
```

## Phase 6: the designed screens (one prompt per screen)

Each prompt compares against its reference. Run `flutter analyze` and the screen's test after each.

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed, in short moments. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json and look at hilal-design-system/screens/الصلاة · Prayer times@1x.png first.

Task: restyle the Prayers screen (lib/features/adhan/adhan_screen.dart and lib/features/adhan/widgets/) to the Hilal reference. Hierarchy from the reference: night hero with a short verse; location pill; a window "next prayer" card (time in display size, countdown "Maghrib in 44 minutes", moon tile); a day switcher with the Hilal date under the Gregorian one; six prayer rows in one grouped paper list (icon tile, name, time in the display face, bell toggle, chevron), the current prayer row on surface-sunken with its time in brass. Use the shared widgets from lib/generals/widgets/ and extend them rather than forking. Spacing: space-4 side margins, space-5 between cards, space-6 between sections. Do not copy the reference's placeholder text or numbers: use the real localised strings and real prayer times only. Update test/adhan_screen_test.dart. Check it in Paper and Night, ar (RTL), fr and en.

Rules: hierarchy comes from layered paper and its shadow, not from colour, borders or gradients. No gradients except inside the hero, no glassmorphism, no emoji, no identical card grids. Brass at most once per region. Every value comes from tokens.json. Do not change prayer-time calculation, alarm IDs, preference keys, controllers or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed, in short moments. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json and look at hilal-design-system/screens/القرآن · Quran index@1x.png first.

Task: restyle the Quran index (lib/features/quran/quran_screen.dart and lib/features/quran/widgets/) to the Hilal reference: night hero with a verse, a search well overlapping the hero's bottom edge, a continue-reading card (last-read label, surah and page, a thin brass progress line, "n of 604 pages", a window primary button "Continue reading", a bookmark tile), a Surah/Hizb segmented control, and rows with a brass eight-point star number badge, the Arabic and Latin names, verses and revelation place, a progress percentage and a mirrored chevron. Reuse the shared widgets and extend them rather than forking. Progress is computed only from pages the user actually read: never show invented numbers. Update test/quran_progress_test.dart and test/read_quran_screen_test.dart as needed. Check it in Paper and Night, ar (RTL), fr and en.

Rules: hierarchy comes from layered paper and its shadow, not from colour, borders or gradients. No gradients except inside the hero, no glassmorphism, no emoji. Brass at most once per region. Every value comes from tokens.json. Do not change Quran data, progress logic, bookmarks, preference keys, controllers or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json, hilal-design-system/assets/Motifs/README.md and look at hilal-design-system/screens/سورة الفاتحة · Quran page@1x.png first.

Task: restyle the Mushaf reading screen (lib/features/quran/screens/ and lib/features/quran/widgets/) to the Hilal reference: a white paper page on the ground, a thin brass hairline frame with a brass eight-point star in each corner, the surah name as a window cartouche with two small stars where a surah starts, ayah end markers as a brass star-8 with the verse number, a hairline divider with a star and the page number at the foot. Keep the bundled Quran font and its 22 / line-height 2 setting, the page pager pill and the bookmark behaviour. Night theme: surface-raised page, ink text, brass dark value. Update test/read_quran_screen_test.dart. Check it in Paper and Night, ar (RTL), and at text scale 1.3 (text must not clip).

Rules: reading text is never decorated, ornaments stay in the margins; no gradients, no glassmorphism, no emoji; brass only on ornaments. Every value comes from tokens.json. Do not change Quran text, page data, bookmarks, last-read tracking, preference keys or controllers. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json and look at hilal-design-system/screens/الأذكار · Athkar list@1x.png first.

Task: restyle the Athkar list (lib/features/duaa/duaa_screen.dart, adhkar_categories.dart and the matching widgets) to the Hilal reference: night hero with the tasbih art and a verse, a search well overlapping the bottom edge, one grouped paper list of categories (title, count line, mirrored chevron, round icon tile: morning = brass-soft, evening = window, the rest surface-sunken). Search runs over the real adhkar data. Reuse the shared widgets and extend them rather than forking. Update test/duaa_categories_test.dart and test/adhkar_data_test.dart if they depend on the old look. Check it in Paper and Night, ar (RTL), fr and en.

Rules: hierarchy comes from layered paper and its shadow, not from colour, borders or gradients. No gradients except inside the hero, no glassmorphism, no emoji, no identical card grids. Brass at most once per region. Every value comes from tokens.json. Do not change adhkar data, search logic, preference keys, controllers or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed, often in the dark before sleep. Read PRODUCT.md, design.md, hilal-design-system/README.md and tokens.json first. The reference for this screen is the html in hilal-design-system/screens/أذكار المسجد · Athkar reader-html.zip: unzip it into the scratchpad directory (not the repo) and open ArAthkarReader.dc.html.

Task: restyle the Athkar reader (lib/features/duaa/adhkar_display_screen.dart and widgets) to the reference: calm, one dhikr at a time, the dhikr text in Amiri 24 / line-height 1.9 centred on paper, the translation or source in body-sm ink-muted, a repetition counter as a window pill with chevrons, the count as a display-face numeral, progress as a thin brass line. Keep the existing counter logic and haptics. Respect text scale up to 1.3 and keep the text selectable if it is today. Check it in Paper and Night, ar (RTL), fr and en.

Rules: nothing flashes or competes with the text of worship; no gradients, no glassmorphism, no emoji; brass at most once. Every value comes from tokens.json. Do not change adhkar data, counter logic, preference keys, controllers or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable craft

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md and tokens.json first. The reference for this screen is the html in hilal-design-system/screens/القبلة · Qibla-html.zip: unzip it into the scratchpad directory (not the repo) and open ArQibla.dc.html.

Task: restyle the Qibla screen (lib/features/qibla/qibla_screen.dart and lib/features/qibla/widgets/) to the reference: night hero with the skyline art (it never mirrors, it is in NoorArt.noMirror), a compass dial built from paper and a window disc (ring, 60 ticks with majors at 15 degrees, N/E/S/W in the display face, fixed heading tick, hub, arrow to the qibla), the location pill, and the calibration sheet with the animated figure-8 guide. The aligned state (within 3 degrees, released past 6) uses brass instead of mint: ring turns brass with a soft halo fading in over 250 ms, one vibration and a "Facing the qibla" live-region label, as today. Check it in Paper and Night, ar (RTL), fr and en. Update test/qibla_screen_test.dart and test/qibla_alignment_and_drift_test.dart only for the look, never the logic.

Rules: the compass and the calibration guide are the only looping animations; no gradients except the soft halo; no glassmorphism, no emoji; the calibration sheet guides the user but never claims to calibrate the sensor. Every value comes from tokens.json. Do not change the alignment thresholds, location-drift logic, permissions flow, preference keys or controllers. Finish with a short list of what you changed and what you left alone.
```

## Phase 7: screens Hilal does not cover

Each prompt first proposes two layouts and waits for your pick, so you steer the look before any code is written.

```text
/impeccable shape

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed, often just after waking, in a bright or dark room, sometimes on a locked phone. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json, hilal-design-system/components/ArchFrame and Cover, lib/features/adhan/adhan_ring_screen.dart and test/adhan_ring_screen_test.dart first.

Task: design the adhan ring screen, which Hilal has no reference for. First write a 5-line brief: the one thing the user must do, the single hero moment, what stays at everyday depth. Then propose two layouts as ASCII sketches and wait for my pick before coding. Direction to explore: full-bleed window (night) ground, an ArchFrame shadow box with the prayer name in display-xl and the time beneath, Arabic and Latin names stacked at equal weight, two actions: Stop (primary) and Open adhkar (secondary). After my pick, implement it and update test/adhan_ring_screen_test.dart so it passes with no overflow at text scale 1.3.

Rules: ArchFrame once per screen; no gradients except inside it; no glassmorphism, no emoji, no exclamation marks; brass at most once. Every value comes from tokens.json. Do not change alarm behaviour, alarm IDs, the stop/snooze logic or preference keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable shape

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json, lib/generals/widgets/settings_sheet.dart, lib/generals/location_flow.dart, lib/generals/location_drift.dart and the adhan sound and calibration sheets under lib/features/ first.

Task: design the remaining sheets in the Hilal language, which has no reference for them: settings sheet, location sheet (GPS or Manual choice, Confirm), adhan sound sheet (radio rows, play button on the selected row, Save), relocate sheet (shown once per launch when the network location's prayer times differ from the saved city's by 5 minutes or more: one honest muted sentence, primary "Detect automatically", outline "Choose manually", swipe down to dismiss) and the calibration sheet. First write a 5-line brief per sheet, then propose one layout per sheet as ASCII sketches and wait for my pick before coding. After my pick implement them on top of NoorSheet and update the related tests.

Rules: sheets sit at shadow-3 and carry no hero art; one primary button per sheet; no gradients, no glassmorphism, no emoji. Every value comes from tokens.json. Do not change location, permission or alarm logic, preference keys or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable shape

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed. Read PRODUCT.md, design.md, hilal-design-system/README.md, tokens.json, lib/generals/widgets/empty_state.dart and every place in lib/ that shows an error, empty list, loading state, offline state or denied permission (location, notifications, exact alarms) first.

Task: design the empty, loading, error and permission-denied states in the Hilal language. First list every such state that exists in the app, then propose a small consistent pattern as ASCII sketches (one motif or icon, one calm sentence, one button) and wait for my pick before coding. After my pick implement it everywhere and keep the copy warm, calm and brief, in ar, fr and en (add localisation keys for new strings, regenerate with the project's existing flutter_intl setup).

Rules: danger colour only with an icon and a word, never colour alone; no gradients, no glassmorphism, no emoji, no exclamation marks; never show invented data. Every value comes from tokens.json. Do not change permission flows or any logic. Finish with a short list of what you changed and what you left alone.
```

## Phase 8: refinement passes over all screens

Run these in order, applying the fixes between prompts. Each covers every screen, so there is nothing to fill in.

```text
/impeccable critique

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Used one-handed, in short moments. Read PRODUCT.md, design.md, hilal-design-system/README.md and tokens.json first.

Task: critique the whole restyled UI against Hilal and against "generic AI UI" tells. Screens to review: Prayers (lib/features/adhan/adhan_screen.dart), Adhan ring (adhan_ring_screen.dart), Quran index (lib/features/quran/quran_screen.dart), Mushaf page (lib/features/quran/screens/), Athkar list (lib/features/duaa/duaa_screen.dart), Athkar reader (adhkar_display_screen.dart), Qibla (lib/features/qibla/), the custom splash and the sheets. Judge: repeated card-grid rhythm, decoration without a job, contrast dips, inconsistent radii or spacing, shadows that do not fall straight down, more than one brass accent per region, more than one hero per screen, Arabic that looks like a fallback, and anything that would look at home in any other app. Output a ranked list by user impact with file and line, then ask which to fix. Change no code.

Rules: Hilal principles are the standard: depth from paper and shadow, monochrome plus one brass note, scallops for heroes only, calm motion. Every value must come from tokens.json.
```

```text
/impeccable audit

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md and hilal-design-system/tokens.json first.

Task: audit the restyled app for accessibility and consistency across Prayers, Adhan ring, Quran index, Mushaf page, Athkar list, Athkar reader, Qibla, the custom splash and every sheet. Check: contrast of every text and icon pair in Paper and Night (4.5:1 text, 3:1 line-strong and focus ring), 48 dp touch targets, behaviour at system text scale 1.3 and 2.0, RTL mirroring of chevrons, pagers and layouts (the wordmark stays LTR), screen-reader labels and live regions (the qibla alignment label), no information carried by colour alone, reduce-motion honoured everywhere. Fix what is clear-cut and list what needs my decision. Keep each fix minimal and run flutter analyze and flutter test at the end.

Rules: do not change behaviour, alarm IDs, preference keys, controllers or localisation keys. Every value comes from tokens.json. Finish with a short list of what you fixed, what you left and why.
```

```text
/impeccable harden

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md and hilal-design-system/tokens.json first.

Task: harden the restyled screens against real-world input: very long surah, city and category names, French strings that run 30% longer than English, zero, one and many items, no location, location permission denied, offline with cached prayer times, no cached times at all, exact-alarm permission missing, a tiny 320 dp phone, system font at 200%, and a screen reader. Find what overflows, clips or looks broken, fix it in the shared widgets first and the screens second, and add widget tests only for the three worst cases. Run flutter analyze and flutter test at the end.

Rules: no gradients, no glassmorphism, no emoji; error states use danger only with an icon and a word. Every value comes from tokens.json. Do not change behaviour, permission flows, alarm IDs, preference keys or localisation keys. Finish with a short list of what you fixed and what you left alone.
```

```text
/impeccable adapt

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md and hilal-design-system/README.md first.

Task: adapt the restyled UI beyond a normal portrait phone: 320 dp wide phones, large phones, tablets in portrait and landscape, and foldables. Hilal's mobile margins are space-4 with the TabBar floating space-4 above the safe area; on wide screens keep content at a comfortable reading width (about 600 dp, centred) instead of stretching paper cards, and keep the hero art cropped from the start side. Landscape: the hero must not eat the screen; make it collapse. Check Prayers, Quran index, Mushaf page, Athkar list and reader, Qibla, the adhan ring screen and the sheets. Fix in the shared widgets first. Run flutter analyze and flutter test at the end.

Rules: no new layouts that duplicate a screen; no gradients, no glassmorphism, no emoji. Every value comes from tokens.json. Do not change behaviour or localisation keys. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable animate

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md and hilal-design-system/README.md (Motion section) first.

Task: add motion to the restyled UI, the Hilal way: "paper settles", elements enter by fading from 0 and moving up 4 to 8 px over 180 to 240 ms with ease-out (use the helper in lib/utils/theme/ from Phase 5), buttons press 1 px down and drop to shadow-1, the tab pill slides between items, sheets rise onto the page, stars in the hero twinkle between 0.85 and 1 opacity over 4 s, staggered. Apply it on Prayers, Quran index, Athkar list, Qibla, the splash and the sheets. Nothing bounces, spins or parallaxes, nothing loops except the compass, the calibration guide, the active alarm screen and the hero stars; everything is off when MediaQuery.disableAnimationsOf(context) is true. Verify that no animation runs while a screen is off-stage (check tickers are disposed).

Rules: calm over clever, nothing may compete with the text of worship, so no motion on the Mushaf page text or the Athkar reader text. Every value comes from tokens.json. Do not change behaviour. Finish with a short list of what you changed and what you left alone.
```

```text
/impeccable polish

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md, hilal-design-system/README.md and tokens.json first.

Task: do the last pass over every restyled screen (Prayers, Adhan ring, Quran index, Mushaf page, Athkar list, Athkar reader, Qibla, splash, sheets): spacing on the 4 px grid and the screen rhythm (space-4 margins, space-5 between cards, space-6 between sections), alignment, tabular numerals for times and counts, radius consistency (8/14/24/pill), shadow consistency (same light, always straight down, shadow-1/2/3 by depth), copy (sentence case, warm and brief, no exclamation marks, Hijri date under the Gregorian one), leftover Faith colours (teal, mint) or old fonts (Spectral, Plex) anywhere in lib/ or test/, dead code and unused assets. Remove leftovers, do not add features. Run flutter analyze and flutter test at the end.

Rules: no gradients except inside the hero ArchFrame, no glassmorphism, no emoji. Every value comes from tokens.json. Do not change behaviour, alarm IDs, preference keys, controllers or localisation keys. Finish with a short list of what you changed and what you left alone.
```

Only if a screen came out busier than its reference:

```text
/impeccable distill

Project: Flutter app "Faith" (package noor): prayer times, adhan, Quran, adhkar, qibla. Arabic (RTL) is the default language, also fr and en. Read PRODUCT.md, design.md, hilal-design-system/README.md and the reference PNGs in hilal-design-system/screens/ first.

Task: compare each restyled screen (Prayers, Quran index, Mushaf page, Athkar list) with its reference PNG and remove everything the reference does not need: extra cards, extra icons, extra borders, extra ornaments, extra copy, a second hero or a second brass accent. List what you removed and why; do not add anything.

Rules: Hilal is quiet: one obvious action per screen, everything else a quiet secondary. Do not change behaviour or localisation keys. Finish with a short list of what you changed and what you left alone.
```

## Phase 9: verification gate (manual, before merging)

- [ ] `flutter analyze` clean, `flutter test` green.
- [ ] Run the app (`/run`): every tab and every sheet in Paper and Night, ar / fr / en, text scale 1.0 and 1.3, one small phone.
- [ ] Alarms: schedule one, let it ring, check the ring screen, stop it. `git diff` over `lib/features/adhan/services` and `lib/utils/local_storage` should be empty or cosmetic.
- [ ] `flutter build apk --analyze-size`: fonts and art should not grow the APK by more than about 1 MB.
- [ ] `grep` finds no `faith_emblem`, `Spectral`, `Plex` or removed tint names.
- [ ] README and screenshots updated; decide whether `hilal-design-system/` stays in the repo as reference.

## Suggested commit sequence

1. checkpoint rebrand 2. design contract 3. tokens + fonts 4. logo, icon, splash 5. art 6. widgets (one commit per prompt) 7. screens (one per screen) 8. derived screens 9. refinement passes 10. cleanup and docs.

## Risks

- **Night theme**: `window` (`#07080c`) nearly equals the ground (`#101217`). Hilal says it must always be framed by paper, a `line` hairline or `shadow-3`. Check every `window` surface in Night.
- **Arabic typography**: if Amiri at UI sizes looks too light for row titles, use Amiri Bold; do not switch family without updating `design.md`.
- **Native splash tool** overwrites Android and iOS resources: run it once, after the logo is final.
- **Scope**: Phases 5 to 7 are most of the work. Ship Phases 2 to 6 first; Phase 7 can follow in a second pass.
