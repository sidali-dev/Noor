# Noor Imene Design System

Derived from `assets/screens/screens.png` (ten panels) and the custom splash in `assets/screens/splash.png` and `splash_dark.png`. Source of truth in code: `lib/utils/theme/noor_theme.dart` (tokens) and `lib/generals/widgets/` (components).

## Principles
1. **Paper, not screen.** Warm cream ground, near-white cards, deep forest green ink. It should feel like a printed Mushaf page, lit softly.
2. **Green speaks, gold marks.** Forest green is the only action colour. Gold appears only as a small mark of orientation or emphasis (the qibla tick, the Kaaba band, the next prayer).
3. **Quiet depth.** One elevation language: a soft, wide, low-opacity green-tinted shadow. No borders on cards, no stacked shadow plus border.
4. **Serif for the numbers and the name, Arabic display for titles.** Numerals (prayer times, degrees) and the "Noor Imene" wordmark are set in Spectral. Arabic page titles are Amiri bold. Everything else is IBM Plex Sans Arabic.
5. **Generous, even rhythm.** 20dp gutters, 12dp between list items, 24dp between groups. Rows breathe; nothing is dense.
6. **RTL is native.** Layouts use start/end, icons that imply direction mirror, the wordmark stays LTR. Hero art mirrors with the layout, except pieces in `NoorArt.noMirror` (the Qibla skyline).

## Colour (light)
| Token | Hex | Use |
|---|---|---|
| `paper` | `#F6F3EB` | Scaffold background |
| `card` | `#FDFCF8` | Cards, sheets, nav bar |
| `line` | `#ECE7DA` | Hairline dividers, input outlines |
| `ink` | `#14382A` | Titles, selected text (deep green) |
| `body` | `#2A3B33` | Body text |
| `muted` | `#7E8A83` | Subtitles, metadata, inactive icons |
| `primary` | `#1F5A41` | Selected tab fill, primary buttons, progress |
| `onPrimary` | `#F6F3EB` | Text on primary |
| `gold` | `#C79A3B` | Orientation tick, next-prayer mark, Kaaba band |
| tint sage / amber / blue / lilac / mint | `#E4EDE4` `#F8EBD0` `#E3E8F1` `#E9E3F3` `#DDEBE2` | Icon-tile backgrounds |
| tint icons | `#2E6B4F` `#C58A2B` `#4B607E` `#6F5C94` `#2E7A5A` | Icon colour on the matching tile |
| `danger` | `#B3412F` | Destructive and error |

## Colour (dark)
`paper #0E1512`, `card #16211C`, `line #223029`, `ink #EAF1EC`, `body #CFDBD3`, `muted #8FA398`, `primary #3C8A66` (selected fill) with `#EAF1EC` text, `gold #D8B35A`. Tints become 18%-alpha fills of the tint icon colour on `card`. Contrast of `body` on `card` ≥ 9:1, `muted` on `card` ≥ 4.6:1.

## Typography
| Role | Face | Size / weight | Notes |
|---|---|---|---|
| Wordmark | Spectral | 26 / 500 | "Noor Imene", always LTR, single line, scales down to fit |
| Page title | Amiri Bold (ar) · Spectral Medium (fr/en) | 34 | `ink`, centred or start-aligned per screen |
| Section title | Plex Sans Arabic | 20 / 600 | |
| Row title | Plex Sans Arabic | 17 / 600 | |
| Body | Plex Sans Arabic | 15 / 400, line-height 1.5 | |
| Meta | Plex Sans Arabic | 13 / 400 | `muted` |
| Numerals (times, degrees) | Spectral | 22–56 / 500, tabular | |
| Quran page | Quran (bundled) | 22 / line-height 2 | Unchanged |
| Dhikr text | Amiri | 24 / line-height 1.9 | |

## Spacing, shape, motion
- Scale: 4, 8, 12, 16, 20, 24, 32. Screen gutter 20.
- Radius: card 20, row/tile 16, input 14, pill 999, sheet top 28.
- Touch target ≥ 48. Icon tile 48 (circle), icon 22–24, stroke ≈ 1.5.
- Shadow: `0 8 24 rgba(20,56,42,0.07)` light; none in dark (use `line` instead of shadow).
- Motion: 200–300 ms, ease-out-cubic. Page content fades in once; selection changes slide. No looping animation except the compass and the active alarm screen.

## Components
- **NoorHero**: the per-screen header; no shared app bar. Illustrated art (`NoorArt`) top-end behind the status bar, title and subtitle on calm sky, a paper scrim bottom-up and start-side. Prayers and Qibla set the title as the LTR wordmark with the star mark and a settings gear; Quran and Athkar use a page title. An `overlap` child (search field, location pill) straddles its bottom edge. No art = faint sky gradient.
- **NoorCard**: `card` fill, radius 20, soft shadow, optional ink-well.
- **IconTile**: 48dp circle in a tint, icon in the tint's icon colour.
- **NoorListRow**: tile or number circle, title (row title), meta line, chevron that mirrors in RTL. Used for adhkar categories, surahs and hizbs.
- **NoorSegmented**: pill track on `card`, selected segment filled `primary` with `onPrimary` text.
- **NoorPill**: location/sound chips: `card` fill, radius 16, leading icon, label, trailing chevron.
- **NoorButton**: `primary` filled / `tonal` / `outline`, height 52, radius 16, label 16/600.
- **NoorSheet** (bottom sheet): `card`, radius 28 top, drag handle, title, content; replaces most dialogs.
- **NoorNavBar**: floating card, radius 28, 4 items. Selected = 56dp `primary` circle with `onPrimary` icon, raised 14dp with the soft shadow, `primary` w600 label beneath; slides between items in 250 ms.
- **NoorPagerPill**: primary pill with chevrons inside and a centre label (dhikr counter); `split` = primary centre pill between two gold-tint circles (Mushaf page). Chevrons follow `Directionality`; in the Mushaf, left = next page.
- **Mushaf frame**: thin gold hairline, radius 16, on the mushaf colour; gold corner flourish mirrored to all four corners, divider at the foot, and a gold cartouche with the surah name where a surah starts.
- **Location and adhan sheets**: still `NoorSheet`, no art. Location: title, subtitle, GPS / Manually radio cards (IconTile, whole card selects), primary Confirm Location. Adhan: radio rows, play button on the selected row, primary Save.
- **Relocate sheet**: `NoorSheet` shown once per launch when the network (IP) location's times differ from the saved city's by 5 min or more. Title, one honest muted sentence ("your network suggests you're near X"), primary "Detect automatically" (GPS flow), outline "Choose manually". Swipe down to dismiss.
- **Custom splash**: after the native one, while startup and art precache run. Paper (light) or deep-green gradient (dark) with a faint ray gradient, arch frame top and mosque skyline bottom, emblem, Arabic name in Amiri Bold, letter-spaced "NOOR IMENE" between gold rules, thin ring spinner. Fades out in 300 ms; no fixed delay.
- **Next-prayer row**: sage row fill, icon tile filled `primary` with `onPrimary` icon, speaker button on a sage-tint circle.
- **NoorSearchField**: `card` fill, radius 14, 48dp, search icon at the start, clear button when non-empty. Overlaps the hero's bottom edge on Athkar and Quran.
- **NoorProgressBar**: 4dp rounded track in `line`, fill in `primary`; paired with a small numeral percentage (surah rows) or "n of 604 pages" (continue-reading card).
- **Calibration sheet**: animated figure-8 guide (a `primary` dot tracing a lemniscate over a faint `line` path), three short steps, then the usual tips.
- **Tab labels**: Quran, Prayers, Athkar, Qibla (ar: القرآن، الصلاة، الأذكار، القبلة). English and French display text spells it "Athkar".
- **EmptyState**: Lottie or icon tile, one sentence, one `NoorButton`.
- **Compass dial**: 1.5dp green ring, 60 ticks (major at 15°), N/E/S/W in Spectral, gold fixed heading tick on top, hub centre, green arrow to the qibla. Aligned (within 3°, released past 6°): the ring turns gold with a soft blurred halo inside the dial, fading in over 250 ms, one vibration, and a "Facing the qibla" live-region label.

## Do / don't
- Do keep one primary button per screen.
- Don't use blue, purple or amber as UI chrome; they only appear inside icon tiles.
- Art appears only in screen heroes (Prayers, Quran, Athkar), the Qibla footer and the custom splash; never behind lists, prayer times, Quran text or dhikr text. Text over art sits on calm sky behind a paper scrim and measures at least 4.5:1.
- Hero art mirrors in RTL unless it carries writing or is listed in `NoorArt.noMirror`.
- Don't use side-stripe borders, gradient text, or emoji as icons.
