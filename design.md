# Faith: Hilal design contract

Faith (package `noor`) moves to the Hilal design system: cut paper in layers, one night-sky window, one brass note. This file is the contract for the Flutter port. It contains no Dart; names are the names the code should use.

**Sources.** `hilal-design-system/tokens.json` is the only source of values. `README.md`, `components/bundle.css` and the five `screens/*.png` (plus the Qibla and Athkar-reader HTML) are used for behaviour and for placement. Every value in this file is tagged **[token]** (copied from `tokens.json`), **[bundle]** (from `README.md` / `bundle.css`, not in `tokens.json`), **[mock]** (read off a screen, not in `tokens.json`), or **[computed]** (derived here, with the arithmetic stated). Anything not covered by those four is listed in *Not in tokens.json*, not invented. Visual probing of the running app was skipped; this is a paper contract, verified against the mocks only.

## 0. Rules that override the Hilal README where they differ

1. Hierarchy comes from layered paper and its shadow. Not from colour, not from borders, not from gradients.
2. Gradients: only inside the hero ArchFrame (its paper-shade wash and sky-glow). Nowhere else, including buttons, backgrounds, text and the splash.
3. No glassmorphism, no blur backdrops, no emoji, no purple or blue AI palette. The cool ground is blue-grey (`surface #eef0f4`); it is paper, not an accent.
4. Brass appears at most once per region (a region is one screen area that can be read in one glance: a hero, a list, a card, the dial). See section 6.
5. Copy is warm, calm, brief, sentence case, no exclamation marks. See section 13.
6. Alarms, saved state, alarm IDs and preference keys behave exactly as before (PRODUCT.md principle 4).

## 1. Themes

Two themes, `HilalTheme.paper` and `HilalTheme.night`. Night is first-class, not an inversion; both are built from the same field names. Follow system brightness; the existing manual override stays.

Paper is the daytime and dawn theme. Night is the before-sleep theme. Neither is the "default look": both must be checked on every screen.

## 2. Colour: `HilalTheme` ThemeExtension

Accessor: `context.hilal`. Field names are the camelCase of the token names. All values **[token]**.

| Field | Paper | Night | Role |
|---|---|---|---|
| `surface` | `#eef0f4` | `#101217` | Page ground. Never white in Paper. |
| `surfaceRaised` | `#ffffff` | `#1c1f27` | Cut paper lifted off the ground: cards, sheets, tab bar, ArchFrame, rings. Always carries a shadow. |
| `surfaceSunken` | `#e3e6ec` | `#0a0b0f` | Pressed-in paper: search/text wells, toggle tracks, segmented troughs. Pairs with `shadowInset`. |
| `line` | `#cfd3dc` | `#2c303a` | Hairline dividers and ornament rules. Decorative only, never the sole border of a control. |
| `lineStrong` | `#7d8391` | `#6b7180` | Control borders that must be seen (input at rest, unchecked toggle). |
| `ink` | `#1a1c22` | `#eceef2` | Primary text and icons. |
| `inkMuted` | `#555a66` | `#a3a8b5` | Secondary text, captions, placeholders, inactive tab labels. |
| `window` | `#171a21` | `#07080c` | The night sky seen through a cut-out. |
| `windowRaised` | `#262a33` | `#1f232c` | A layer inside a window. |
| `onWindow` | `#f7f7f4` | `#f7f7f4` | Moon-white content on a window. |
| `onWindowMuted` | `#a6abb8` | `#a6abb8` | Secondary content on a window. |
| `brass` | `#7a6436` | `#cdb588` | The one warm note. |
| `brassSoft` | `#efe8d8` | `#2f2a1f` | Quiet fill behind brass text. |
| `onBrass` | `#ffffff` | `#15171c` | Text on a solid brass fill. Never literal white in Night. |
| `paperShade` | `#e8eaef` | `#13161c` | ArchFrame only: foot of the light wash, back-row paper. |
| `skyGlow` | `rgba(247,247,244,0.16)` | `rgba(247,247,244,0.12)` | ArchFrame only: moonlight halo around the crescent. |
| `depthShadow` | `rgba(23,26,33,0.30)` | `rgba(0,0,0,0.78)` | Shadow each paper layer casts onto the layer behind it inside an ArchFrame. Falls straight down. |
| `success` / `successSoft` | `#2e6a4e` / `#e3efe8` | `#7fc4a2` / `#1a2a22` | Done state. Always with a word or check icon. |
| `danger` / `dangerSoft` | `#9e3a2b` / `#f6e4e0` | `#f0a493` / `#331d19` | Errors, destructive. Always with a word or icon. |

Also on the extension: `shadow1`, `shadow2`, `shadow3`, `shadowInset` (section 5), the `text` ramp (section 3), and `HilalSpace`, `HilalRadius` constants (section 4).

### 2.1 Material `ColorScheme` mapping (so stock widgets inherit the right colours)

`useMaterial3: true`, `surfaceTint: transparent` (M3 tinting would add colour-based elevation, which breaks rule 1), `splashFactory: NoSplash` (press feedback is the paper moving, section 7).

| ColorScheme | Paper | Night |
|---|---|---|
| `surface`, `background`-role | `surface` | `surface` |
| `surfaceContainer*` | `surfaceRaised` | `surfaceRaised` |
| `onSurface` | `ink` | `ink` |
| `onSurfaceVariant` | `inkMuted` | `inkMuted` |
| `primary` | `window` | `onWindow` (inverted, see 6.2) |
| `onPrimary` | `onWindow` | `window` |
| `secondary` / `tertiary` | `brass` | `brass` |
| `outline` | `lineStrong` | `lineStrong` |
| `outlineVariant` | `line` | `line` |
| `error` / `onError` | `danger` / `surfaceRaised` | `danger` / `surface` |

The old `NoorColors` extension, `NoorTint` enum and the five icon-tile tints are retired (section 15). There is no replacement tint set: Hilal has no tint colours.

### 2.2 Contrast **[computed]** (WCAG, from the hex values above)

Text and meaningful-icon pairs that the contract allows:

| Pair | Paper | Night | Verdict |
|---|---|---|---|
| `ink` on `surface` | 14.93 | 16.13 | text |
| `ink` on `surfaceRaised` | 17.03 | 14.18 | text |
| `inkMuted` on `surface` / `surfaceRaised` / `surfaceSunken` | 6.05 / 6.91 / 5.52 | 7.87 / 6.92 / 8.27 | text |
| `onWindow` on `window` / `windowRaised` | 16.22 / 13.39 | 18.65 / 14.66 | text |
| `onWindowMuted` on `window` / `windowRaised` | 7.58 / 6.25 | 8.71 / 6.85 | text |
| `brass` on `surface` / `surfaceRaised` / `surfaceSunken` | 4.97 / 5.67 / 4.54 | 9.42 / 8.29 / 9.89 | text |
| `brass` on `brassSoft` | 4.65 | 7.18 | text |
| `onBrass` on `brass` | 5.67 | 9.02 | text |
| `success` on `successSoft` | 5.41 | 7.38 | text |
| `danger` on `dangerSoft` / `surfaceRaised` | 5.52 / 6.79 | 7.84 / 8.19 | text |
| `lineStrong` on `surface` / `surfaceRaised` / `surfaceSunken` | 3.33 / 3.80 / 3.04 | 3.84 / 3.37 / 4.03 | control edge (≥ 3:1) |

Pairs the contract forbids:

| Pair | Paper | Night | Why |
|---|---|---|---|
| `inkMuted` on `window` | 2.52 | 8.41 | Paper: use `onWindowMuted` on a window. |
| `ink` on `window` | 1.02 | 17.23 | Never rely on it; use `onWindow`. |
| `brass` on `window` | 3.07 | 10.07 | Paper: icon or ornament only (≥ 3:1), never brass text on a window. Night: fine. |
| `brass` on `windowRaised` | 2.53 | 7.91 | Paper: not allowed at all. |
| `brass` on `onWindow` | 5.28 | 1.85 | Night: never brass on a moon-white fill. |
| `window` vs `surface` / `surfaceRaised` (edge only) | 15.26 / 17.41 | **1.07 / 1.22** | See 6.1: the Night window problem. |
| `line` vs `surface` | 1.31 | 1.42 | Decorative only, as the token says. |

## 3. Typography

### 3.1 Faces and bundling

Bundle three families in `pubspec.yaml`; do not use `google_fonts` (offline-first app, dawn use on weak signal). Retire Plex, Spectral and the Plex weights; keep Amiri (already bundled) and the `Quran` font untouched.

- **Cormorant Garamond** (display), weight 600 [token: every display style in tokens.json is 600].
- **Jost** (interface), 400, 500, 600.
- **Amiri** (Arabic), 400 and 700 only. Amiri has no 500 or 600.
- **Quran** (Mushaf): unchanged, never restyled.

### 3.2 Arabic font fallback (resolved)

Jost and Cormorant Garamond have no Arabic glyphs. Amiri has Arabic and also has basic Latin. Rules:

1. **Locale `ar`:** every text style uses the `arabic` family (Amiri). The Latin faces appear only for explicitly Latin content: the "Faith" wordmark, compass letters N/E/S/W, and nothing else. Latin runs inside an Arabic sentence (rare) render in Amiri; that is accepted.
2. **Locales `fr`, `en`:** text styles use Jost (interface) and Cormorant Garamond (display), each with `fontFamilyFallback: [Amiri]`, so Arabic strings that appear inside fr/en screens (surah names, the Arabic name نور الإيمان, dhikr text, Quran refs) never fall to a system font.
3. **Dhikr text and Quran text** are Arabic content in every locale: Amiri for dhikr, the `Quran` font for the Mushaf, regardless of UI locale.
4. **Weights in Amiri:** only 400 and 700 exist. Map every Hilal weight: 400 → 400; 500, 600, 700 → 700. No synthetic bold.
5. **Hilal's own mock does this:** `[dir="rtl"] .hl-tab, .hl-btn, .hl-badge` switch to Amiri. In Flutter the whole `ar` text ramp is Amiri-based, which covers that rule and extends it to headings, body and captions.
6. **No letter-spacing and no uppercase in Arabic.** Letter-spacing breaks joining; eyebrow uppercase has no meaning. `eyebrow` is not used at all (section 13).

### 3.3 Type scale

`TextStyle.height` = lineHeight ÷ fontSize. Sizes are in sp, scale with the system text scale. Latin ramp for fr/en **[token]**:

| Style (`context.hilal.text.*`) | Face | Size / line | Weight | Letter-spacing | Height | Use |
|---|---|---|---|---|---|---|
| `displayXl` | Cormorant | 56 / 60 | 600 | -0.5 | 1.071 | One greeting per screen, inside a hero ArchFrame or the splash |
| `displayLg` | Cormorant | 40 / 44 | 600 | 0 | 1.1 | Screen titles with a hero |
| `title` | Cormorant | 28 / 34 | 600 | 0 | 1.214 | Section and sheet titles |
| `heading` | Jost | 18 / 24 | 500 | 0 | 1.333 | Card headings, list group headers |
| `body` | Jost | 16 / 24 | 400 | 0 | 1.5 | Default reading text |
| `bodySm` | Jost | 14 / 20 | 400 | 0 | 1.429 | Supporting text, hints, list secondary lines |
| `label` | Jost | 15 / 20 | 500 | 0.2 | 1.333 | Buttons, field labels |
| `caption` | Jost | 12 / 16 | 400 | 0 | 1.333 | Hijri dates, tab labels, timestamps |
| `eyebrow` | Jost | 12 / 16 | 500 | 1.6 | 1.333 | **Defined, not used** |

Arabic ramp for `ar` **[token]** where tokens.json defines it, otherwise tagged:

| Style | Size / line | Weight | Height | Source |
|---|---|---|---|---|
| `arabicDisplay` | 40 / 64 | 700 | 1.6 | [token] |
| `arabicBody` | 19 / 34 | 400 | 1.789 | [token] |
| `title` (ar) | 28 / 40 | 700 | 1.43 | [mock] Hilal has no Arabic `title`; mock headings (26/40, 24/34) are Amiri 700. Line 40 keeps diacritics clear. Flagged in section 12. |
| `heading` (ar) | 18 / 30 | 700 | 1.667 | [mock] same reason |
| `body` (ar) | `arabicBody` | | | [token] |
| `bodySm` (ar) | 15 / 22 | 400 | 1.467 | [mock] muted lines in the mocks are 15/22 |
| `label` (ar) | 15 / 22 | 700 | 1.467 | [mock] |
| `caption` (ar) | 12 / 18 | 400 | 1.5 | [mock] tab labels. Amiri at 12 sp is small: flagged. |
| `dhikr` | 24 / 52 | 400 | 2.167 | [mock] Athkar reader text. The app's old dhikr style was 24 / 1.9. Flagged. |

Rule for headings: Latin display uses Cormorant 600; Arabic display and titles use Amiri 700. Never mix a Cormorant title with an Amiri subtitle on the same line.

### 3.4 Digits (resolved, decided by the owner)

Every locale uses Western digits 0–9. This matches intl 0.20.2, where `ar` and `ar_DZ` have `ZERO_DIGIT` `'0'`, and what Algerian Arabic readers use day to day. No custom digit conversion is needed anywhere.

| Locale | Digits | Display numerals (times, degrees, counters) | Inline numerals |
|---|---|---|---|
| `ar` | Western 0–9 | Cormorant Garamond 600, set LTR | Amiri, inside the Arabic sentence |
| `fr` | Western 0–9 | Cormorant Garamond 600 | Jost |
| `en` | Western 0–9 | Cormorant Garamond 600 | Jost |

Rules: (a) a number is always laid out LTR (`105.37°`, `05:34`), even inside an RTL line, as the Qibla mock does; (b) the Mushaf keeps the `Quran` font's own page and ayah numbering; (c) the compass letters N/E/S/W and the "Faith" wordmark stay Latin in every locale; (d) the mocks write some Arabic numbers in Arabic-Indic (`٦ درجات`, `البقرة ١٤٤`). Those are mock copy, not the contract: render them 6 and 144. If the owner later wants Arabic-Indic in `ar`, it needs one locale-aware formatter used by every screen, since intl will not do it.

Large numerals (next prayer time, qibla degrees, counters) set `FontFeature.tabularFigures()` so they do not jitter, and for Cormorant also `FontFeature.liningFigures()` (Cormorant's default figures can be old-style). **Unverified:** whether the bundled Cormorant Garamond static file carries the `lnum` and `tnum` features. Check the font before relying on it; otherwise set times in Jost.

## 4. Spacing and radii

Spacing **[token]**, `HilalSpace`, dp: `s1` 4, `s2` 8, `s3` 12, `s4` 16, `s5` 24, `s6` 32, `s7` 48, `s8` 64.

| Use | Token |
|---|---|
| Screen side margin | `s4` (16) |
| Card padding (phones) | `s4` (16) |
| Gap between cards | `s5` (24) |
| Gap between sections | `s6` (32) |
| Gap between sibling buttons, list row vertical padding | `s3` (12) |
| Icon-to-label gap in chips | `s1` (4) |
| Label-to-field gap, badge padding | `s2` (8) |
| Breathing room around a hero ArchFrame | `s7` (48) |
| Top and bottom padding on splash and greeting screens | `s8` (64) |

The old 20 dp gutter is gone. Off-scale values the mocks use (6, 10, 14, 18, 20, 22, 28) are not tokens: snap to the nearest token in code (see Not in tokens.json).

Radii **[token]**, `HilalRadius`: `sm` 8 (badges, text fields, small chips), `md` 14 (buttons, list groups, toasts), `lg` 24 (paper cards and bottom sheets), `pill` 999 (toggles, tab-bar active pill, avatar discs). Sheets: `lg` on the top corners only.

Touch targets are at least 48 dp. The mocks draw 44 dp discs (settings, back, prev/next); keep the 44 dp visual and pad the hit area to 48 dp (`minimumSize`/`SizedBox` around), never shrink the target.

Safe areas: nothing interactive inside the system gesture insets; the floating tab bar sits above the bottom inset with `s4` (16) clearance.

## 5. Shadows **[token]**

Flutter has no CSS-style `inset`; and a shadow list is a `List<BoxShadow>`. Each token is a two-layer list (blur radius = CSS blur, no spread). Every raised layer gets exactly one of 1 / 2 / 3; layers stack 1 → 2 → 3 as they come forward.

| Field | Paper layers | Night layers |
|---|---|---|
| `shadow1` | y1 blur1 rgba(23,26,33,.06) + y2 blur5 rgba(23,26,33,.07) | y1 blur1 black .45 + y2 blur5 black .35 |
| `shadow2` | y2 blur4 rgba(23,26,33,.06) + y8 blur18 rgba(23,26,33,.09) | y2 blur4 black .50 + y8 blur18 black .45 |
| `shadow3` | y6 blur10 rgba(23,26,33,.08) + y20 blur40 rgba(23,26,33,.14) | y6 blur10 black .55 + y20 blur40 black .55 |
| `shadowInset` | inset y2 blur4 rgba(23,26,33,.10) | inset y2 blur4 black .60 |

Placement **[token]**: `shadow1` flat paper (list groups, inputs on raised paper, the tab bar); `shadow2` cards and buttons, the default lift; `shadow3` the front-most layer (hero ArchFrame, sheets, dialogs); `shadowInset` sunken wells.

Flutter note: `BoxShadow.blurRadius` is twice the Gaussian sigma, matching CSS `blur`, so values copy 1:1. `shadowInset` has no native widget: implement it once as a `HilalInsetShadow` painter (clip, then paint an offset inverted shadow), used by `HilalField`, `HilalSegmented` trough and toggle track. Do not fake it with a border.

## 6. Window, brass, and the Night problem

### 6.1 What "window" means (resolved)

A window is a cut-out through the paper, showing the night sky. It is a **place for content, not an edge**. In Paper it is a dark shape on pale paper (15:1) and reads as itself. In Night it is `#07080c` against a ground of `#101217` (1.07:1) and a raised layer of `#1c1f27` (1.22:1): the shape is nearly invisible, so the contract does not ask the colour to make the edge. Four rules:

1. **Never bare on the ground.** A window always sits inside a `surfaceRaised` frame (the ArchFrame ring, the card, the pill's 3–4 dp ring seen in the mock's `inset 0 0 0 3px surface-raised`). The ring is paper; the shadow under the ring (`shadow3` for front-most, `shadow2` otherwise) carries the lift.
2. **Night adds one decorative seam.** [bundle: `hl-card-night`] In Night a window card also gets a 1 dp inset `line` hairline at the ring/window seam, in addition to the shadow. This is the system's own ornament-rule use of `line`, not a control border, and it appears in Night only.
3. **Legibility comes from the content, not the shape.** Content on a window is `onWindow` (18.65:1) and `onWindowMuted` (8.71:1) in Night. A window with nothing readable in it is decoration, not information.
4. **Interactive windows invert.** [bundle: lines 21, 94–95, 105] In Night, the primary button, the active tab pill and the checked toggle swap to `onWindow` fill with `window` content (moon-white pill, near-black glyph, 18.65:1). In Paper they stay `window` fill with `onWindow` content. So the "primary" action is always the highest-contrast filled shape on the screen in both themes. The reader's prev/next buttons in the mock already do this.

Non-interactive windows (hero ArchFrame, compass hub, counter pill) keep `window` in both themes; rules 1–3 carry them in Night.

### 6.2 Brass

Brass means **the one current thing**: the next prayer, the place you left off, the direction of the qibla, the count you are on. Not decoration, not branding.

- At most once per region. A single object counts once even if drawn in two pieces (the qibla arrow and its Kaaba marker are one pointer).
- Brass as text: on `surface`, `surfaceRaised`, `surfaceSunken`, `brassSoft`. Fine in both themes (Paper ≥ 4.54, Night ≥ 7.18).
- Brass on a window: **Night** text and icons are fine (10.07:1). **Paper**: non-text only (3.07:1), so a brass pointer or ornament may sit on a window but brass words may not.
- Solid brass fill: text is `onBrass`. Night's `onBrass` is near-black, never white.
- Never brass on `onWindow` (Night 1.85:1) and never brass on `windowRaised` in Paper (2.53:1).
- **Night brass is a lighter ink, not a glow.** `#cdb588` is lighter than its Paper twin so the same rule (one per region) still reads; it never gets a halo, shadow or blur.
- The focus ring is brass ([token]: focus ring, links, selected date). It is a transient state, so it does not count against the "once per region" budget, but it must not be the only way a control shows it is focused in a way that depends on hue: also change the shadow.
- No brass inside tab bars, buttons or page headings; brass links in body copy are fine.

Brass placement per screen (reassigned from the mocks, where several screens spent it twice):

| Screen | The one brass thing |
|---|---|
| Prayers | The next prayer's time and its marker. The date, Hijri date and other times stay `ink` / `inkMuted`. |
| Quran index | The "continue reading" progress marker only (computed from pages the user dwelled on; no invented numbers). |
| Quran page | The bookmark / current-position marker. The Mushaf frame uses `line`, not brass. |
| Athkar list | None. The search field's focus ring is the only brass that can appear. |
| Athkar reader | The repeat-count badge (`brassSoft` fill, `brass` text): the count you are on. Step bar uses `window`. |
| Qibla | The qibla pointer (arrow plus Kaaba marker). Aligned state adds a `success` word and check icon, not more brass. |

## 7. Motion

tokens.json has **no motion tokens**. These come from `README.md` / `bundle.css` **[bundle]**:

- Enter: fade from 0 while rising 4–8 dp, 180–240 ms, ease-out. Use `Curves.easeOut` (matches CSS `ease-out`). No bounce, no elastic, no spin.
- Press: the paper moves 1 dp down and drops to `shadow1`, 120 ms ease. This replaces ripples (`NoSplash`).
- Toggle and trough thumb: 180 ms.
- Twinkle: ArchFrame stars 0.85 ↔ 1.0 opacity over 4 s, staggered. Allowed in the Prayers hero only; every other loop is out.
- Loops allowed: the compass (it follows the sensor) and the active alarm screen, as before. Nothing else loops.
- Reduce Motion (`MediaQuery.disableAnimations`): twinkle off, entrance becomes an instant or a 100 ms crossfade, press stays (it is feedback), the compass still rotates (it is the instrument, not a flourish).
- Never animate layout; animate opacity and translate.

## 8. Components

`Hilal*` replaces `Noor*`. Flutter widget name → what it is → rules.

| Widget | Replaces | Spec |
|---|---|---|
| `HilalScaffold` | the scaffold and `NoorHero` mount | `surface` ground, safe areas, no shared app bar. |
| `HilalCard` | `NoorCard` | `surfaceRaised`, `radius-lg` 24, `shadow2`, padding `s4`. Ink-well becomes the press-down (section 7). No nested cards. |
| `HilalListGroup` / `HilalListRow` | `NoorListRow` | One `surfaceRaised` group with `shadow1`, `radius-md` 14. Rows separated by `line` hairlines (decorative rule). Row: leading (number or icon), title `heading`, secondary `bodySm` in `inkMuted`, trailing chevron that mirrors in RTL. Vertical padding `s3`. Used for adhkar categories, surahs, hizbs. Icon tiles (48 dp tinted circles) are gone: leading is a plain `ink` icon at 22–24 dp. |
| `HilalButton` | `NoorButton` | Variants `primary` (`window` fill, `onWindow` text; Night inverts, 6.1), `secondary` (`surfaceRaised` with `shadow2`, `ink` text), `ghost` (text only). `radius-md` 14, `label` style, `shadow2`, min height 48. One `primary` per screen. |
| `HilalSegmented` | `NoorSegmented` | Trough `surfaceSunken` + `shadowInset`; selected segment `surfaceRaised` + `shadow1`. Selection is paper, not colour. |
| `HilalField` / `HilalSearchField` | `NoorSearchField` | `surfaceSunken` well + `shadowInset`, `radius-sm` 8 (token), 48 dp, leading search icon, clear button when non-empty. Focus ring brass. Placeholder `inkMuted` (≥ 5.52:1). |
| `HilalChip` / `HilalBadge` | `NoorPill` | `radius-sm` 8, `brassSoft`/`brass` tone for the one current thing, `surfaceSunken`/`inkMuted` otherwise. |
| `HilalLocationPill` | `NoorPill` (location) | `surfaceRaised`, `radius-md` 14, 48 dp, `shadow1`, leading pin, label, trailing chevron (mirrors). |
| `HilalTabBar` | `NoorNavBar` | Floating `surfaceRaised` pill, `radius-pill`, `shadow1`, four items: Quran, Prayers, Athkar, Qibla (ar: القرآن، الصلاة، الأذكار، القبلة). Active tab: `window` pill with `onWindow` icon and label (Night inverts). Inactive: `inkMuted`. No raised 56 dp circle, no 14 dp lift. Labels `caption`. Respect safe area; clamp text scale on the labels only. |
| `HilalSheet` | `NoorSheet` | `surfaceRaised`, `radius-lg` top corners, `shadow3`, drag handle, title in `title`. Replaces most dialogs. Swipe down dismisses. |
| `HilalArchFrame` | `NoorHero` | The one hero. Nested arch rings of `surfaceRaised` over a `window`, each ring on `depthShadow`. The only place a gradient exists (top `surfaceRaised` → bottom `paperShade`), plus `skyGlow` around the crescent, plus twinkle (Prayers only). Front-most layer: `shadow3`. |
| `HilalOrnament` | | Thin `line` rule with a small diamond; section divider in the reader. |
| `HilalPager` | `NoorPagerPill` | Dhikr counter and Mushaf page controls: `window` pill (Night inverts to `onWindow` pill with `window` glyphs), prev/next circles in `onWindow` fill with `window` glyph (mock), `shadow3`, `surfaceRaised` 3 dp ring. Chevrons follow `Directionality`; in the Mushaf, left = next page, as before. |
| `HilalProgress` | `NoorProgressBar` | 4 dp rounded track in `surfaceSunken`, fill `window` (Night: `onWindow`). Not brass. Paired with a numeral percentage or "n of 604 pages". |
| `HilalCompass` | Compass dial | See 8.1. |
| `HilalToast` | | `radius-md`, `surfaceRaised`, `shadow2`. `success` / `danger` tones always carry a word or icon. |
| `HilalSplash` | Custom splash | Flat `surface` or `window`, no gradient, no ray, no arch. The logo lockup (section 10), then crossfade out in 300 ms; no fixed delay, unchanged logic. |

Behaviours that stay, restyled only: Mushaf frame (its flourish and cartouche become `line` ornament; no mint), location sheet (GPS / Manually radio cards, primary Confirm location), adhan sheet (radio rows, play on the selected row), relocate sheet (once per launch, 5 min difference, one honest muted sentence, Detect automatically primary, Choose manually secondary), calibration sheet (figure-8 guide, three short steps, never claims the sensor is calibrated), the alarm ring screen and Open Adhkar action, EmptyState (one sentence, one button), "Athkar" spelling in en/fr.

### 8.1 `HilalCompass`

Outer disc `surfaceRaised` + `shadow3`; an inset `surfaceSunken` ring + `shadowInset`; 72 ticks (every 6th is major) in `lineStrong`; N in `danger`, E/S/W in `inkMuted` (Jost 14–16, always Latin); fixed heading tick on top in `ink`; the qibla pointer in `brass`; hub is a `window` disc inside a 4 dp `surfaceRaised` ring with `shadow2` and a moon icon in `onWindow`. In Night the dial's disc and sunken ring are the Night `surfaceRaised`/`surfaceSunken` (1.14 apart); the pointer and ticks carry it, not the disc edge.

Aligned (within 3°, released past 6°, as now): a `success` check and the live-region label "Facing the qibla", one vibration, a 250 ms fade. The mint ring and the blurred halo are dropped; sky-glow is ArchFrame-only. Keep `NoorArt.noMirror`-style handling: the compass never mirrors.

## 9. Screens

Region map, with where each token-level tool is spent.

| Screen | Hero / window | `shadow3` | Brass |
|---|---|---|---|
| Prayers | `HilalArchFrame` with the wordmark and the next-prayer time (`displayXl` in Latin, `arabicDisplay` in ar) | the ArchFrame | next prayer |
| Quran index | Title only, no ArchFrame | none (sheets only) | continue reading |
| Quran page | No hero | the pager | bookmark |
| Athkar list | Title only | none | none |
| Athkar reader | Card as the page, step bar on top, `HilalPager` below | the reading card and the pager (both appear in the mock) | repeat badge |
| Qibla | Title, location pill, compass | the compass | qibla pointer |

**Headers.** Hilal's `SkyHeader` exists only in the mocks (it is not in `bundle.js` or `tokens.json`). Title-only screens use a plain header on `surface`: `displayLg` / `arabicDisplay` title, optional single `bodySm` line. No sky halo, no art. The Prayers screen uses the real `ArchFrame`. This drops the old `NoorHero` art, the sunrise photos, and the Qibla skyline photo; the Quran hero art is retired too. Decided by the owner: plain headers.

Everything else (list content, Quran text, dhikr text) sits on plain `surface` or `surfaceRaised`, never over art.

## 10. Logo and assets

New brand files in `hilal-design-system/assets/Logos/`: `faith-logo-paper.svg`, `faith-logo-night.svg` (lockup, for Paper/Night), `faith-mark-paper.svg`, `faith-mark-night.svg` (mark alone), `faith-app-icon.svg`. Motifs in `assets/Motifs/`: `arch-window.svg`, `cloud-scroll.svg`, `crescent.svg`, `star-8.svg`.

- Pick the Paper or Night variant from the active `HilalTheme`, not from `Brightness` alone, so a manual override still picks the right file.
- **flutter_svg limit.** The `faith-mark-paper.svg` file uses `feDropShadow` filters (three of them) and a gradient; `flutter_svg` does not render SVG filters. Decided: rasterise the logos to PNG at 1x/2x/3x for the splash and headers; keep the SVGs as masters. The app-icon SVG is used only for native icon export.
- Native Android splash/icon assets in the working tree are already changed; they must match the new app icon and ground colour (`surface` Paper, `window`-near ground in Night). Do not touch the application id (`com.sidalidev.noor`) or the Dart package (`noor`).
- Old `assets/logo/faith_logo.svg` / `faith_emblem.svg` and the teal-mint splash art are retired once the new files are wired.

## 11. Accessibility

- Body text ≥ 4.5:1, large text ≥ 3:1, both themes (section 2.2 holds for every allowed pair; the forbidden pairs fail).
- 48 dp targets, system text scale respected (clamp only the tab labels and the pager counter).
- No information by colour alone: `success`/`danger` always with a word or icon; the qibla "aligned" state is a word plus a check plus a vibration plus a live-region announcement; N on the compass is a letter, not just red.
- Reduce Motion handled (section 7).
- RTL native: start/end insets only, chevrons mirror, the compass and the wordmark never mirror, the Mushaf page-turn direction is unchanged.
- Hit areas and focus: brass focus ring plus a shadow change, visible on both `surface` and `surfaceRaised`.

## 12. Not in tokens.json

Values the mocks or code need that `tokens.json` does not define. The contract uses the nearest token unless stated; the owner should confirm.

1. **Arabic title and heading sizes.** tokens.json has only `arabic-display` (40/64) and `arabic-body` (19/34). The mocks use Amiri 700 at 36/48 (Qibla h1), 26/40, 24/34 (reader), and 24/52 (dhikr). Contract: `title` ar = 28/40, `heading` ar = 18/30, `dhikr` = 24/52, `bodySm`/`label` ar = 15/22, `caption` ar = 12/18. These are mock-derived, not tokens.
2. **Digit style per locale**: not a token; decided in 3.4.
3. **Motion**: durations and curves come from README/bundle.css, not tokens.json.
4. **Geometry of ArchFrame, SkyHeader, Compass**: ring insets, arch curves, 280 dp dial, 13 dp ring inset, 98 dp hub. In the mock/bundle only.
5. **Off-scale spacing in the mocks**: 6, 10, 14, 18, 20, 22, 28. Snap to the scale; if a screen then looks off, extend `HilalSpace`, do not hard-code.
6. **44 dp icon discs, 60 dp nav height, 22 dp icons, 4 dp progress track**: mock/bundle values with no token.
7. **Search field radius.** Decided by the owner: follow the token, `radius-sm` 8.
8. **No warning/info colours, no tints.** Hilal has only `success` and `danger`. The old five icon tints are dropped.
9. **No tabular/lining numeral feature data** for Cormorant.
10. **Logo lockup sizes** (splash, header): not specified.

## 13. Copy

Warm, calm, brief, sentence case, no exclamation marks, no emoji. Say what happened and what to do, in as few words as the language allows. Examples: "Facing the qibla", "Your network suggests you're near Algiers. Detect automatically?", "No results", "Next prayer: Dhuhr". Use "Athkar" in English and French display text. Titles are not uppercase; the eyebrow style is not used, so there are no tracked all-caps kickers. Arabic copy is written natively, not translated from the English; keep it as short as the English.

Forbidden: "Oops", "Awesome", "Let's get started", exclamation marks, "blessed" decoration, emoji as icons.

## 14. Do / don't

Do
- Build hierarchy with raised paper and one shadow token per layer.
- Keep one `primary` button per screen.
- Frame every window in `surfaceRaised`; let Night buttons and tabs invert.
- Spend brass once per region, on the current thing.
- Use Amiri for all Arabic, Latin faces only for Latin content, Western digits 0–9 in every locale.
- Use only tokens.json values; list the rest in section 12.

Don't
- Don't use a border to separate or elevate. `line` is a decorative rule and a Night seam, never a control's only edge. `lineStrong` is for controls.
- Don't use gradients outside `HilalArchFrame`, and none on text, buttons, backgrounds or the splash.
- Don't use glass, blur backdrops, emoji icons, side-stripe borders, gradient text, or a purple/blue palette.
- Don't put brass text on a window in Paper, or brass on moon-white in Night.
- Don't use `ink` or `inkMuted` on a window; use `onWindow` / `onWindowMuted`.
- Don't place art behind lists, prayer times, Quran text or dhikr text.
- Don't nest cards, and don't raise a layer without a shadow.
- Don't add colour tints for icon tiles.
- Don't use letter-spacing or uppercase on Arabic.

## 15. Migration map (old → new)

| Old | New |
|---|---|
| `NoorColors` / `noor_theme.dart` | `HilalTheme` (ThemeExtension), `context.hilal` |
| `NoorTint`, icon tiles | removed; plain `ink` icons |
| `paper`, `card` | `surface`, `surfaceRaised` |
| `line` (card edge) | shadow; `line` only as decorative rule |
| `ink`, `body`, `muted` | `ink`, `ink`, `inkMuted` (one body colour) |
| `primary` `#0B6A8E`, `onPrimary` | `window` / `onWindow` (Night inverts) |
| `mark` mint | `brass` (once per region) |
| `mushaf` | `surfaceRaised` page, `line` frame; font unchanged |
| `danger` | `danger` / `dangerSoft` |
| Plex / Spectral | Jost / Cormorant Garamond; Amiri for Arabic |
| gutter 20 | `s4` (16) |
| radii 20/16/14/28 | `lg` 24 / `md` 14 / `sm` 8 / `lg` top |
| soft teal shadow, none in dark | `shadow1`–`shadow3`, `shadowInset`, with Night variants |
| `NoorHero`, `NoorArt` | `HilalArchFrame` (Prayers) or plain header |
| `NoorNavBar` raised circle | `HilalTabBar` window pill |
| teal/mint splash | `HilalSplash` with the logo lockup |
