# Faith: Hilal design contract

Faith (package `noor`) moves to the Hilal design system: cut paper in layers, one night-sky window, one brass note. This file is the contract for the Flutter port. It contains no Dart; names are the names the code should use.

**Sources.** `docs/design-system/tokens.json` is the only source of values. `README.md`, `components/bundle.css` and the five `screens/*.png` (plus the Qibla and Athkar-reader HTML) are used for behaviour and for placement. Every value in this file is tagged **[token]** (copied from `tokens.json`), **[bundle]** (from `README.md` / `bundle.css`, not in `tokens.json`), **[mock]** (read off a screen, not in `tokens.json`), or **[computed]** (derived here, with the arithmetic stated). Anything not covered by those four is listed in *Not in tokens.json*, not invented. Visual probing of the running app was skipped; this is a paper contract, verified against the mocks only.

## 0. Rules that override the Hilal README where they differ

1. Hierarchy comes from layered paper and its shadow. Not from colour, not from borders, not from gradients.
2. Gradients: only inside the hero ArchFrame (its paper-shade wash and sky-glow), plus the alarm ring screen's moon glow, plus the splash (its baked plate and the fade on its loading ring, `HilalSplash`, decided by the owner, 2026-11-10). Nowhere else, including buttons, backgrounds and text.
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
| `surfaceSunken` | `#e3e6ec` | `#0a0b0f` | Pressed-in paper: toggle tracks, segmented troughs, sunken tiles. Pairs with `shadowInset`. |
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
| `eyebrow` | Jost | 12 / 16 | 500 | 1.6 | 1.333 | The splash tagline only, in sentence case. Used nowhere else. |

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

Hit area: the whole box of a tile, card, row or button takes the tap, padding and empty space included (`NoorPressable` is `HitTestBehavior.opaque`).

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

Flutter note: `BoxShadow.blurRadius` is twice the Gaussian sigma, matching CSS `blur`, so values copy 1:1. `shadowInset` has no native widget: implement it once as a `HilalInsetShadow` painter (clip, then paint an offset inverted shadow), used by the `HilalSegmented` trough and toggle track. Do not fake it with a border.

## 6. Window, brass, and the Night problem

### 6.1 What "window" means (resolved)

A window is a cut-out through the paper, showing the night sky. It is a **place for content, not an edge**. In Paper it is a dark shape on pale paper (15:1) and reads as itself. In Night it is `#07080c` against a ground of `#101217` (1.07:1) and a raised layer of `#1c1f27` (1.22:1): the shape is nearly invisible, so the contract does not ask the colour to make the edge. Four rules:

1. **Never bare on the ground.** A window always sits inside a `surfaceRaised` frame (the ArchFrame ring, the card, the pill's 3–4 dp ring seen in the mock's `inset 0 0 0 3px surface-raised`). The ring is paper; the shadow under the ring (`shadow3` for front-most, `shadow2` otherwise) carries the lift.
2. **Night adds one decorative seam.** [bundle: `hl-card-night`] In Night a window card also gets a 1 dp inset `line` hairline at the ring/window seam, in addition to the shadow. This is the system's own ornament-rule use of `line`, not a control border, and it appears in Night only.
3. **Legibility comes from the content, not the shape.** Content on a window is `onWindow` (18.65:1) and `onWindowMuted` (8.71:1) in Night. A window with nothing readable in it is decoration, not information.
4. **Interactive windows invert.** [bundle: lines 21, 94–95, 105] In Night, the primary button and the checked toggle swap to `onWindow` fill with `window` content (moon-white pill, near-black glyph, 18.65:1). In Paper they stay `window` fill with `onWindow` content. So the "primary" action is always the highest-contrast filled shape on the screen in both themes. The reader's prev/next buttons in the mock already do this.

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
| Athkar reader | The bead about to be said, on the tasbih counter. |
| Qibla | The qibla pointer (arrow plus Kaaba marker). Aligned state adds a `success` word and check icon, not more brass. |

## 7. Motion

tokens.json has **no motion tokens**. These come from `README.md` / `bundle.css` **[bundle]**:

- Enter: fade from 0 while rising 4–8 dp, 180–240 ms, ease-out. Use `Curves.easeOut` (matches CSS `ease-out`). No bounce, no elastic, no spin.
- Press: the paper moves 1 dp down and drops to `shadow1`, 120 ms ease. This replaces ripples (`NoSplash`).
- Toggle and trough thumb: 180 ms.
- Twinkle: ArchFrame stars 0.85 ↔ 1.0 opacity over 4 s, staggered. Allowed in the Prayers hero and the alarm ring screen's sky only; every other loop is out.
- Loops allowed: the compass (it follows the sensor), the active alarm screen, as before, and the splash's loading ring (one turn a second, still under Reduce Motion). Nothing else loops.
- Reduce Motion (`MediaQuery.disableAnimations`): twinkle off, entrance becomes an instant or a 100 ms crossfade, press stays (it is feedback), the compass still rotates (it is the instrument, not a flourish).
- Never animate layout; animate opacity and translate.

## 8. Components

`Hilal*` replaces `Noor*`. Flutter widget name → what it is → rules.

| Widget | Replaces | Spec |
|---|---|---|
| `HilalScaffold` | the scaffold and `NoorHero` mount | `surface` ground, safe areas, no shared app bar. |
| `HilalCard` | `NoorCard` | `surfaceRaised`, `radius-lg` 24, `shadow2`, cut as a `NoorPagePanel` (8.2) so every paper card gets the panel, the stars and the arabesque band without asking. Ink-well becomes the press-down (section 7). No nested cards. The night tone (next prayer) keeps its window and carries the band along its foot. |
| `HilalListGroup` / `HilalListRow` | `NoorListRow` | One `surfaceRaised` group with `shadow1`, `radius-md` 14. Rows separated by `line` hairlines (decorative rule). Row: leading (number or icon), title `heading`, secondary `bodySm` in `inkMuted`, trailing chevron that mirrors in RTL. Vertical padding `s3`. Used for adhkar categories, surahs, hizbs, prayers. Leading is a `CloudMedallion` at 56 dp: `IndexNumber` for a number, `NoorCloudIcon` for an icon (8.2). A list group is not cut as a page: it scrolls and carries too many rows. |
| `HilalButton` | `NoorButton` | Variants `primary` (`window` fill, `onWindow` text; Night inverts, 6.1), `secondary` (`surfaceRaised` with `shadow2`, `ink` text), `ghost` (text only). `radius-md` 14, `label` style, `shadow2`, min height 48. One `primary` per screen. |
| `HilalSegmented` | `NoorSegmented` | Trough `surfaceSunken` + `shadowInset`; selected segment `surfaceRaised` + `shadow1`. Selection is paper, not colour. |
| `HilalField` / `HilalSearchField` | `NoorSearchField` | A `NoorCartouche` (8.2) to type in, 56 dp, filling the hero slot: search icon at the start, a star at the end that gives way to a `plain` `NoorCloudButton` to clear: 40 dp on the disc alone, because the ornament cannot fit in a 56 dp pill. Text and cursor `onWindow`, hint and icon `onWindowMuted`, so no brass sits on the window. Focus: brass ring outside the pill plus a settle to `shadow1`. Decided by the owner, 2026-11-02. |
| `HilalChip` / `HilalBadge` | `NoorPill` | `radius-sm` 8, `brassSoft`/`brass` tone for the one current thing, `surfaceSunken`/`inkMuted` otherwise. |
| `HilalLocationPill` | `NoorPill` (location) | A `NoorCartouche` (8.2) in the same hero slot as search, 56 dp: location icon, label, trailing chevron (mirrors). Decided by the owner, 2026-11-02. `NoorPill` stays raised paper for everything else, such as the adhan sound. |
| `HilalTabBar` | `NoorNavBar` | Cut like the text field (`NoorCartouche`): a floating capsule of `surfaceRaised` paper (`radius-pill`, `shadow2`, `s1` thick) holding a pressed-in capsule `NoorWell` trough (`surfaceSunken` + `shadowInset`, `s1` padding), so the bar is three layers: ring, trough, selector. Four items: Quran, Prayers, Athkar, Qibla (ar: القرآن، الصلاة، الأذكار، القبلة). Each item is its icon over its `caption` label, `inkMuted` when inactive, lying in the trough. The selector is one capsule of `window` on `shadow1` that slides to the chosen tab (300 ms, ease-out cubic, the direction mirroring in RTL; instant under Reduce Motion), its icon and label turning `onWindow` as it arrives, label at weight 600 so the choice is never colour alone. In Night the selector is `onWindow` and its content `window`. No brass, no glow, no raised circle. Revised, 2026-11-03: the flat strip and the per-tab pill are replaced by this ring, trough and travelling selector; rounded to capsules at the owner's request.
| `HilalSheet` | `NoorSheet` | `surfaceRaised`, `radius-lg` top corners, `shadow3`, no drag handle, title in `title`, cut as a `NoorPagePanel` (8.2) with content inset `s5`. The arabesque band runs along the top edge, above the scrolling content (the panel's `cloudsAtTop`: the same band the same way up, its light still from above, no corner stars), and gives way to the keyboard. Replaces most dialogs. Swipe down dismisses, from the title area. Decided by the owner, 2026-11-02. |
| `HilalArchFrame` | `NoorHero` | The one hero. Nested arch rings of `surfaceRaised` over a `window`, each ring on `depthShadow`. The only place a gradient exists (top `surfaceRaised` → bottom `paperShade`), plus `skyGlow` around the crescent, plus twinkle (Prayers only). Front-most layer: `shadow3`. |
| `HilalOrnament` | | Thin `line` rule with a small diamond; section divider in the reader. |
| `CloudMedallion` | Brass star ayah marker and surah number | A number or icon on the owner's arabesque ornament (8.2): stacked paper round a raised disc, baked with its shadow. `plain` is the disc alone. Ayah markers (30 dp, scaled with text, `plain`: the ornament cannot hold a number at that size in a line of Quran); index rows and list icons (56 dp); buttons (64 dp); counters (64 and 132 dp). No brass of its own. Decided by the owner, 2026-11-05. |
| `HilalPager` | `NoorPagerPill` | Replaced by `NoorCounterRow` (8.2) on the Mushaf page and in the Athkar reader; no screen uses the pill now. Decided by the owner, 2026-11-02. In the Mushaf, left = next page, as before. |
| `HilalProgress` | `NoorProgressBar` | 4 dp rounded track in `surfaceSunken`, fill `window` (Night: `onWindow`). Not brass. Paired with a numeral percentage or "n of 604 pages". |
| `HilalCompass` | Compass dial | See 8.1. |
| `HilalToast` | | `radius-md`, `surfaceRaised`, `shadow2`. `success` / `danger` tones always carry a word or icon. |
| `HilalSplash` | Custom splash | The owner's splash, rebuilt from `tool/sources/splash_reference.jpg` (decided 2026-11-10, superseding "flat, no gradient, no arch"). A full-bleed plate of layered cut-paper arches, clouds and the mosque (`splash_bg_paper.webp` / `splash_bg_night.webp`, the reference with its foreground removed, and its Night twin; baked, not drawn). On it, centred at fractions of the screen's height read off the reference: the mark (`NoorMark`, 0.71 of the width, held to 0.33 of the height) at 0.405; "Faith" at 0.613 (`displayXl` 56/60, Cormorant 600, `ink`, Latin in every locale); the tagline at 0.662 (`eyebrow`, `muted`, between two 48 dp `line` hairlines, localized: "Your Islamic Companion", "Votre compagnon musulman", "رفيقك الإسلامي"); a 24 dp loading ring at 0.94 (a `brass` arc fading behind its head over a 18 % `brass` circle, one turn a second). **Entrance (decided 2026-11-10):** it takes over from the native splash at once. The native splash waits only for the one picture that copies it (no app work runs under it); the first Flutter frame is that copy (the emblem centred on the screen, the same size, on the same ground), and the native splash is removed. It stands as that picture until the plate is decoded, then plays a 2200 ms entrance, no bounce: the mark grows from the native size to its own while it glides up to its place (0-1500 ms, scale and translate, ease-in-out, since it starts from rest), the plate fades in around it (300-1400), "Faith" fades in rising 6 dp (1000-1700), the tagline (1200-1900), the ring (1500-2200); the fades ease out. Only then does the app's startup run (data, alarms, icons; the 1.8 MB Mushaf data parsed off the UI thread), under the turning ring, with a hold of at least 1200 ms; the shell then fades in over it in 400 ms (that is the splash's exit). Reduce Motion shows everything at once and keeps the ring still. Android 12 and later let the app draw nothing but an icon on a colour, so there the first frame copies that icon exactly (`splash_icon*.png`, 240 dp canvas, emblem 120 dp, no shadow, screen centre; MainActivity passes the API level as a Dart entrypoint argument), the mark's shadow fades in under it (0-500), only then does the icon fade out over the identical emblem (500-900), and the system's own exit animation is switched off (`setOnExitAnimationListener`) so the hand-off is a cut. Before Android 12 and on iOS the splash image is the same emblem at 0.8 of a 288 dp canvas (230 dp), and the mark grows from that. No other fixed delay. Text is fixed size (no text scaling), like the artwork. |

**Hero objects.** Every `NoorHero` art has one main object in the Qibla header's manner: big, in stepped arches of cut paper that each cast a shadow on the layer behind, the object lit and standing out from the sky. Quran: a pointed mihrab holding the Mushaf. Prayers: a tall round arch holding the mosque. Revised, 2026-11-03: the Quran and Prayers objects are authored cut-paper vector art, `object_quran.svg` and `object_mosque.svg`, in the Kaaba's manner and laid over the hero art by `NoorHero` in its upright overlay table, the way the Kaaba is (the owner's raster `.webp` objects are gone). Each is flat layered shapes: three stepped black shadow copies baked in, a shaded face and a lit face in a gradient, and one ornament layer. The Mushaf is a closed book, navy faces with a cream eight-point star, frame and page edge, on two stepped slabs; the mosque is cream shaded and lit faces with a dome, two small domes, two minarets and navy bands and openings. The hero SVGs hold the sky and the stepped arch each sits in: a pointed arch for the Mushaf, a round one for the mosque, each cut to the object's height so it fills its niche and stands in the cloud base like the Kaaba. The niche is chosen for contrast, a light plate behind the navy book (Paper) and the lighter night niche in Night, and the dark window behind the cream mosque in both themes. The overlay keeps its place in RTL and is never mirrored; its shadows are baked in, so like the Kaaba's they keep falling right and down and do not follow the moon. Redrawn, 2026-11-03, because the first pass read as generated clip art (a dome split down the middle into one dark and one light half, flat plates, ghost-stepped shadows): both objects and both niches are rebuilt as stacked paper with one light. On the objects the moon is on the left: lit faces are on the left and every cast shadow falls right and down, as the Kaaba's do; they do not mirror. The niche mirrors with the layout in RTL, so its light comes from straight above: a recessed stair of three paper rings round a deep window, each ring on stepped shadow copies that fall straight down on the ring behind it, and a rim of light along the top of each edge that fades out down the sides. The Prayers niche holds a further, dimmer mosque in the window (a spire and a dome in the sky's own tones) so the near mosque has something to stand in front of. The mosque is two planes (the minarets behind, the hall in front, each casting a soft shadow on the one behind it), with a lit and a shaded half to every dome and shaft, ribs on the dome, piers standing proud of the facade, recessed windows with a lit sill and a framed portal. The Mushaf has a lit spine with raised bands, a bevelled cover with a double frame, an eight-point star and a rosette, ruled page edges, a ribbon, and two slabs. The Quran niche carries a second arch line and a row of dots along it. `flutter_svg` has no blur, so a soft shadow is five offset copies, darkest nearest. Every `NoorHero` now carries a settings button, on the Quran and Athkar headers as well. Athkar: a round window holding a misbaha with a brass tassel. Paper draws the object dark on a light arch; Night inverts it. Stars stay inside the window (`noorHeroStars`, checked by `tool/hero_art.py`). Decided by the owner, 2026-11-02.

**Hero art.** Supersedes the sky, cloud base and object rules elsewhere in this file for `NoorHero`. Redrawn, 2026-11-06, after the owner's references `assets/day_states.png` (the five skies) and `assets/screen_bg.png` (the four tabs), approximated in code rather than traced. The band is the page's own paper, so the title is `ink` and the subtitle `muted`, centred beside the arch, and the status bar follows the theme. Each tab has its own onion (ogee) arch at the end of the band: a pointed tip with a finial that flares, swells at the shoulders and drops on straight sides, cut as three face sheets and three reveal sheets stepping in to the window, each casting a soft shadow down, with a cut-paper cloud behind each shoulder. Prayers a tall arch over a white mosque (onion dome, side domes, four minarets, far wings in shade); Quran a narrower arch over a distant mosque, with an open Mushaf on a wooden rehal standing out in front; Athkar a fuller-shouldered arch over a mosque, with an amber misbaha and tassel thrown across its foot; Qibla a rounder arch over the Kaaba (gold band and door) between two storeys of arcades and minarets. Nothing on them is false text: the Kaaba band and the Mushaf pages are lattice and stars. Night uses a charcoal twin of every sheet and cloud; the mosque, sun and moon stay white in both themes. One sky of the hour shows through every window, by the nearest prayer, as a smooth wash with a glowing sun or moon, soft clouds and birds: Fajr lavender into gold with the sun on the horizon, Dhuhr clear blue with the sun high, Asr amber with the sun low, Maghrib plum into orange over dark hills, Isha navy with a crescent and painted, twinkling stars (`noorHeroStars`, kept in step with `STARS` in the tool, which checks they show in the window). A bank of paper clouds runs along the foot as a seamless tile (`hero_clouds_*`), over the arches, stopping above the search or location pill; its foot fades to the exact page colour, so the band joins the page. The arabesque frieze is retired from the hero. **The art is baked, not vector:** `flutter_svg` has no blur and a live blur on every tab janks, so `tool/hero_art.py` renders the layers to WebP in the exact paper colours, checks every sun and star lands in every window and that the cloud tile has no seam, and `art_assets_test` fails if the palette drifts or a seam shows. The frames are opaque paper around a see-through window and symmetric, so the sky needs no clipping and RTL only moves them. The splash warms the current theme's images.

**Alarm ring screen.** A `window` sky with a crescent and about fifteen twinkling stars above a mosque entrance: a carved pointed (ogee) arch in ivory (`#F3EFE6` in Paper, the `card` in Night) with a shade arch behind it, each casting a `depthShadow`, its band carved with a hairline each side and two crossing vines with a rosette at every crossing, standing on small capitals on a full-width ivory panel. A hollow niche cut into the arch in `window`, with an inner top shadow so it reads as carved, holds the prayer name (Latin and Arabic) and the time in `onWindow`, and its own stars. On the panel, the note and the primary Stop adhan and outline Open Adhkar buttons. Revised, 2026-11-02, after the owner's reference image. Motion: stars flicker out of step (two flickers a cycle, 30–100% opacity and a slight size change), the moon's glow breathes, and the niche's stars twinkle on their own offset; Reduce Motion leaves all of it still. The `NoorTwinkle` cycle drives it; the Twinkle rule in the motion section covers the whole sky here, and the deeper flicker is this screen's own. The page never pops and scrolls when the text is large. Decided by the owner, 2026-11-02.

**Quran last-read card.** The card is `NoorCardTone.night` (the dark `window` fill of the other big cards), with its text, progress bar and continue button in `onWindow` tones. Under them one row: the continue button, then a bookmarks button and a reset button (`NoorGlyph.reset`, a `NoorCloudButton`). Reset opens a confirm sheet (danger Confirm, outline Cancel) before it clears anything; it is no longer a text button. **Adhan rows.** A prayer's own icon is a flat 26 dp mark in `muted`; only the bell is a `NoorCloudButton`, so the ornament always means tappable. Revised, 2026-11-03: each prayer has its own mark, drawn in `NoorGlyph` after SF Symbols and in the same 1.6 line: Fajr `moonHaze` (the moon over a horizon haze), Sunrise `sunrise` (an arrow up), Dhuhr `sun` (the high sun), Asr `sunHaze` (the sun low, in haze), Maghrib `sunset` (an arrow down), Isha `moonStars`. They are line icons, never filled. Past Isha the page moves on to tomorrow once a day (Fajr is then the next prayer, and the next-prayer card and highlight show on that day); stepping back to today shows neither. Dec 31 does not roll, as the calendar holds one year. Decided by the owner, 2026-11-02.

Behaviours that stay, restyled only: Mushaf frame (its flourish and cartouche become `line` ornament; no mint), location sheet (GPS / Manually radio cards, primary Confirm location), adhan sheet (radio rows, play on the selected row), relocate sheet (once per launch, 5 min difference, one honest muted sentence, Detect automatically primary, Choose manually secondary), calibration sheet (figure-8 guide, three short steps, never claims the sensor is calibrated), the alarm ring screen and Open Adhkar action, EmptyState (one sentence, one button), "Athkar" spelling in en/fr.

### 8.1 `HilalCompass`

Outer disc `surfaceRaised` + `shadow3`; an inset `surfaceSunken` ring + `shadowInset`; 72 ticks (every 6th is major) in `lineStrong`; N in `danger`, E/S/W in `inkMuted` (Jost 14–16, always Latin); fixed heading tick on top in `ink`; the qibla pointer in `brass`; hub is a `window` disc inside a 4 dp `surfaceRaised` ring with `shadow2` holding a cut-paper prayer rug (fringe, border, mihrab arch) in `windowRaised`, `onWindowMuted` and `onWindow`, no brass. The qibla pointer ends in a Kaaba (front, side and top faces in `brass` at three strengths, the band and door cut out to the well), drawn upright at the pointer's tip between the letters and the heading tick. In Night the dial's disc and sunken ring are the Night `surfaceRaised`/`surfaceSunken` (1.14 apart); the pointer and ticks carry it, not the disc edge.

Aligned (within 3°, released past 6°, as now): the compass's outer disc rim turns `success`, with the live-region label, one vibration and a 250 ms ease on the colour. There is no chip, check or text card, no halo; sky-glow is ArchFrame-only (the ring screen's moon glow is its own radial wash). The compass never mirrors. Neither does the header's Kaaba: it carries writing, so `NoorHero` draws it over the mirrored skyline, at the end side of the band, instead of flipping it. State: `QiblaController` holds one `QiblaStatus` (checking, sensorMissing, sensorError, gpsOff, denied, deniedForever, failed, ready) and the screen maps it to a view. The system prompt shows only on first open and on the Allow button; once the user has chosen "don't ask again" the button opens system settings, and coming back from settings re-checks with the compass kept up.

### 8.2 Shared pieces: use these, do not redraw them

Every screen builds from these widgets in `lib/core/widgets/`. A new icon button, screen title, count or paper card takes the widget below, and a new look goes here first. Decided by the owner, 2026-11-02: the Athkar reader's language applies to the whole app, each piece on the surfaces named here (icon buttons and list icons on the ornament; the title pill on search, location and reader titles; the page cut on paper cards and sheets; the counter on the Athkar reader and the Mushaf page controls). Proposed, to confirm: the sizes and details not fixed by the reader, namely the 52 dp band on cards and sheets, the 56 dp list ornament, the sheet's `s5` inset, and the 64 dp Mushaf counter without brass. `test/design_system_test.dart` fails if `IconButton(` returns to `lib/`.

| For | Widget | Spec |
|---|---|---|
| Any tappable icon | `NoorCloudButton` | A `CloudMedallion` on the ornament, 64 dp everywhere with a 64 dp target, holding the icon at 18 dp, because the disc is under half the ornament: 48 dp would leave an icon of 13 dp. In `ink` unless the icon sets its own colour, `line` with no `onTap`; it glows while pressed. One exception: `plain`, 40 dp on the disc alone with a 22 dp icon and a 48 dp target, for the clear button inside a 56 dp pill. Decided by the owner, 2026-11-05. |
| A list row's leading icon | `NoorCloudIcon` | The icon at 16 dp on a 56 dp ornament. Except the adhan rows: a prayer's sun or moon is a flat 26 dp mark in `muted`, so the bell is the only ornament and the only thing that reads as tappable. Small marks inside a line of text (a calendar beside a date, a location beside a distance) and icons inside a button or `NoorPill` stay bare. |
| A screen title or a hero control | `NoorCartouche` | A `window` pill in a 4 dp `surfaceRaised` ring (3 dp plus a `line` seam in Night), `shadow2`, 56 dp, stars in `onWindowMuted` either side unless replaced. `NoorCartouche.title` is one line of `heading` at 20 in `onWindow`, held to 280 dp and centred, and sits beside a `NoorCloudButton` for back: Athkar reader, Mushaf top bar. Without `maxWidth` it fills the hero slot: search, location. `SurahCartouche` is the same pill in Amiri where a surah starts. |
| Raised paper with content | `NoorPagePanel`, through `NoorCard` and `NoorSheet` | An inset `line` panel pressed into the paper (`s2` in, `radius-md`), a 14 dp star in `line` in each top corner, an optional folio between them ("3 / 31", numeral 15 in `inkMuted`), and the arabesque band (`NoorMotifBand`) along the foot, 52 dp (72 dp in the Athkar reader, where the counter rises into it). The band is the owner's border cut to a seamless tile: embossed paper with real holes and its shadow baked in, white in Paper and a charcoal twin in Night, baked by `tool/motif_art.py`. Content stops at the band's crown, so no ornament touches a word. A short window drops the band, as the hero drops its art. It shrinks to its content, or fills a parent that fixes its size. Sheets set `cloudsAtTop`: the band runs along the head and the foot is plain. Not for list groups, the night card, dialogs or the Mushaf page, which has its own frame. |
| A count | `TasbihCloud` | A tasbih on the ornament, its beads on the raised ring round the disc, with the count at its centre, the large bead and tassel at the foot, the string running the way the language reads. Up to 33: said beads `ink`, the next `brass`, unsaid pearls with a `lineStrong` edge. Past 33: a `line` thread with an `ink` arc and a head dot, `brass` unless `accent: false`, for a screen whose brass is spent elsewhere. 132 dp when it can be tapped to count, 64 dp when it only shows a place. |
| A count with previous and next | `NoorCounterRow` | `TasbihCloud` between two `NoorCloudButton` chevrons standing on its foot, held close to it however wide the window. |
| Between parts of a text | `NoorOrnament` | A 160 dp `line` rule broken by a 14 dp star. |

Not on the ornament: the compass, the `primary` button, and anything brass.

**The class names stay.** `NoorCloudButton`, `NoorCloudIcon`, `CloudMedallion`, `TasbihCloud` and `cloudHeight` keep the names they had when they drew clouds; no cloud is drawn any more. The two reference images, `assets/images/Bordure arabesque blanche en relief.png` and `Bouton ornemental arabesque en relief.png`, are the source of the baked art and are not bundled.

## 9. Screens

Region map, with where each token-level tool is spent.

| Screen | Hero / window | `shadow3` | Brass |
|---|---|---|---|
| Prayers | `HilalArchFrame` with the wordmark and the next-prayer time (`displayXl` in Latin, `arabicDisplay` in ar) | the ArchFrame | next prayer |
| Quran index | Sky header with the mihrab, lamp and Mushaf (see Hero objects), search overlapping its edge | none | the mushaf cover; continue reading |
| Quran page | No hero | none | bookmark |
| Athkar list | Title only | none | none |
| Athkar reader | Mushaf-cut sheet with the arabesque band, cartouche above, tasbih counter rising into the band | none | the next bead |
| Qibla | Title, location pill, compass | the compass | qibla pointer |

**Headers.** Hilal's `SkyHeader` exists only in the mocks (it is not in `bundle.js` or `tokens.json`). Title-only screens use a plain header on `surface`: `displayLg` / `arabicDisplay` title, optional single `bodySm` line. No sky halo, no art. The Prayers screen uses the real `ArchFrame`. This drops the old `NoorHero` art, the sunrise photos, and the Qibla skyline photo; the Quran hero art is retired too. Decided by the owner: plain headers.

**Quran header (the dune, rehal and leaves art below is superseded by Hero objects; the join and Night rules still hold).** The Quran index keeps its sky header (`NoorHero`), its art following the Quran index mock's `SkyHeader` scene as layered cut paper: a far dune, the rehal, a brass cover, a block of leaves and the shared cloud base, each sheet of the book and rehal casting a shadow on the one behind (the clouds cast none). Rule 2 stretches here to the mock's page wash, a `surfaceRaised` → `paperShade` fill on the pages (`onWindowMuted` → `lineStrong` in Night). In Night the rehal and the back leaf are `lineStrong` at 55% over `window`, flattened to `#3f4450`. `flutter_svg` has no filters, so the shadows are baked into `hero_quran_paper.svg` and `hero_quran_night.svg`. Decided by the owner, 2026-11-02.

**`NoorHero` join.** A `NoorHero` with art casts no shadow on the page, on any screen, and its cloud bank's foot is `surface` rather than `surfaceRaised`, so the clouds run into the body with no edge. The Qibla skyline's centre is a Kaaba in a cloud-framed arch window between two minarets, redrawn from `docs/design-system/original.jpg`. The Quran and Athkar art has no curls on that row: the search field would cut them to fragments. The flat band, which has no art (short windows, missing art), keeps `shadow3`: in Night it is what frames the `window` fill. Decided by the owner, 2026-11-02.

**Prayers header (supersedes the region table and the plain-header note for this screen).** Prayers keeps the mock's sky band with the mosque, not an ArchFrame, and the next prayer stays on its own card. The art has no curls on its front cloud row, for the same reason as Quran and Athkar: the location pill would cut them to fragments. Every `NoorHero` with art is the same height, with or without a disc. Decided by the owner, 2026-11-02.

**Settings button.** Decided by the owner, 2026-11-02: a `NoorCloudButton` like every other icon button. This supersedes the earlier `windowRaised` disc, which replaced the mock's white paper disc. Art under it keeps that corner empty: the Prayers mosque has no minaret on that side, so the button clears the skyline on a notched phone without a taller band.

**Next prayer card.** Decided by the owner, 2026-11-02: centred content, the arabesque band along the foot, and a time that is no longer brass. The band stays below the text, never behind it. Brass on a window is forbidden in Paper (6.2), so the time is `onWindow` and the screen's brass is the next prayer's time in the list, as in the mock. Proposed, to confirm: the 56 sp numeral, the 4 dp `surfaceRaised` ring from the mock, and no label above the time, since the countdown names the prayer. Decided by the owner: it animates out when the selected day is not today. Proposed, to confirm: it fades out, then the page closes up, 200 ms in all.

**Day picker.** Decided by the owner, 2026-11-02: tapping the day opens a calendar. Revised, 2026-11-03: the well that holds the day arrows is a capsule (`radius-pill`) with the two buttons at its ends, and the date carries no calendar icon: the sheet it opens says what it is. Proposed, to confirm: a `HilalSheet` holding Flutter's `CalendarDatePicker`, Gregorian, limited to the selected year as the day arrows are; choosing a day applies it and closes the sheet.

**Reminders.** Decided by the owner, 2026-11-02: tapping a prayer opens a `HilalSheet` with its alarms and a stepper; rows no longer expand. A prayer still has two reminder slots (rule 6). The stepper's value is also a text field: a bare number keeps the direction and a leading minus means before the adhan.

**Athkar list icons.** Decided by the owner, 2026-11-02: each category icon is a `NoorCloudIcon`, and the old mixed set (filled, stroked and traced art, two icons shared, sunrise and sunset alike at 24 dp) is replaced by one line set in `NoorGlyph`, with one icon per category. Proposed, to confirm: the drawings themselves.

**Athkar reader (supersedes the mock's step bar, repeat badge and `HilalPager` for this screen).** Decided by the owner, 2026-11-02: back and title in a row (`NoorCloudButton`, `NoorCartouche.title`), the dhikr on a `NoorCard` with its folio and a 72 dp arabesque band, and a `NoorCounterRow` whose 132 dp counter rises 64 dp into the band. A tap anywhere on the card still counts and swiping still pages. A short window drops the band and keeps the same space for the counter.

**Mushaf top bar and page controls.** Decided by the owner, 2026-11-02: tapping the page brings up `NoorCloudButton` back, `NoorCartouche.title` with the surah name and `NoorCloudButton` bookmark, and at the foot a `NoorCounterRow` with a `TasbihCloud` of the juz's pages. Revised, 2026-11-02: the top row has no strip and the foot no backing; the buttons and the title float over the page and the text shows between them. The counter runs to the end of the juz, not the Mushaf, and a tap on it raises a `NoorCartouche.title` snackbar above it with the hizb number and the surah the hizb starts in (the `quran` package has no hizb names). Proposed, to confirm: a 64 dp counter, `accent: false` because the page's brass is the bookmark, whose top meets the page's text limit so it covers no ayah; the page number on the counter alone, dropped from the top row; the saved bookmark as a `brassSoft` disc on its puff.

Everything else (list content, Quran text, dhikr text) sits on plain `surface` or `surfaceRaised`, never over art.

## 10. Logo and assets

New brand files in `docs/design-system/assets/Logos/`: `faith-logo-paper.svg`, `faith-logo-night.svg` (lockup, for Paper/Night), `faith-mark-paper.svg`, `faith-mark-night.svg` (mark alone), `faith-app-icon.svg`. Motifs in `assets/Motifs/`: `arch-window.svg`, `cloud-scroll.svg`, `crescent.svg`, `star-8.svg`.

- Pick the Paper or Night variant from the active `HilalTheme`, not from `Brightness` alone, so a manual override still picks the right file.
- **flutter_svg limit.** The `faith-mark-paper.svg` file uses `feDropShadow` filters (three of them) and a gradient; `flutter_svg` does not render SVG filters. Decided: rasterise the logos to PNG at 1x/2x/3x for the splash and headers; keep the SVGs as masters. The app-icon SVG is used only for native icon export.
- Native Android splash/icon assets in the working tree are already changed; they must match the new app icon and ground colour (`surface` Paper, `window`-near ground in Night). Do not touch the application id (`com.sidalidev.noor`) or the Dart package (`noor`).
- Old `assets/logo/faith_logo.svg` / `faith_emblem.svg` and the teal-mint splash art are retired once the new files are wired.
- **The mark, 2026-11-10.** Decided by the owner: the app's mark is the core of the owner's two logo renders (`tool/sources/faith_logo_paper.jpg`, `faith_logo_night.jpg`), not the SVG masters. The core is the emblem alone (arch shield, night window, bolt, stars, brass crescent, the two wings) cut out of its app-icon tile and baked with a soft depth shadow by `tool/splash_art.py`: `assets/logo/faith-mark-{paper,night}.png` at 1x, 2x and 3x (220, 440, 660 px tall, 0.824 wide over tall, the clear space and shadow room included). The same cut-out makes the native splash images, the Android 12 splash icon and the launcher icons (emblem on `surface`). The SVGs in `docs/design-system/assets/Logos/` stay as the lockup masters and are no longer the source of the app's rasters. Paper and Night are two renders (the Night window is darker and the wings charcoal), not one recoloured.

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
7. **Search field radius.** Decided by the owner, 2026-11-02: a pill, `radius-pill`. This replaces the earlier `radius-sm` 8.
8. **No warning/info colours, no tints.** Hilal has only `success` and `danger`. The old five icon tints are dropped.
9. **No tabular/lining numeral feature data** for Cormorant.
10. **Logo lockup sizes** (splash, header): not specified. The splash's are the fractions in section 8 (`HilalSplash`), read off the owner's reference. Its plate is a generated image at 720 x 1280, covered to the screen. The generated plates came out in cream and a warm charcoal, so `tool/splash_art.py` recolours them onto the app's ground: the plate's open paper is `surface` (`#eef0f4` Paper, `#101217` Night), its shade steps darker from that, its highlights go to white (Paper) or moon-white (the Night mosque). Only the warm light in the mosque's windows keeps a warm tone. The first frame, the native splash, is the same `surface`.
11. **Shared piece sizes (8.2)**: ornaments of 56, 64, 132 and 136 dp, a 40 dp plain disc, a 56 dp cartouche, bands of 44, 52 and 72 dp. Design values with no token, listed here so they are not read as hard-coding by accident.

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
- Build icon buttons, list icons, screen titles, hero controls, counts and paper cards from the widgets in 8.2.

Don't
- Don't use a border to separate or elevate. `line` is a decorative rule and a Night seam, never a control's only edge. `lineStrong` is for controls.
- Don't use gradients outside `HilalArchFrame`, the ring screen's moon glow and the splash (`HilalSplash`), and none on text, buttons or backgrounds.
- Don't use glass, blur backdrops, emoji icons, side-stripe borders, gradient text, or a purple/blue palette.
- Don't put brass text on a window in Paper, or brass on moon-white in Night.
- Don't use `ink` or `inkMuted` on a window; use `onWindow` / `onWindowMuted`.
- Don't place art behind lists, prayer times, Quran text or dhikr text.
- Don't nest cards, and don't raise a layer without a shadow.
- Don't add colour tints for icon tiles.
- Don't use a raw `IconButton`, a bare leading icon in a list row, or a hand-built title bar, counter or card.
- Don't use letter-spacing or uppercase on Arabic.

## 15. Migration map (old → new)

| Old | New |
|---|---|
| `NoorColors` / `noor_theme.dart` | `HilalTheme` (ThemeExtension), `context.hilal` |
| `NoorTint`, icon tiles | removed; `NoorCloudIcon` |
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
| `NoorNavBar` cloud-medallion tab | `HilalTabBar` window pill |
| teal/mint splash | `HilalSplash`: the plate, the mark, "Faith", the tagline and the loading ring (section 8) |
