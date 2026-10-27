# Noor Design System

Derived from `assets/screens/Noor Islamic App UI Showcase 1-3.png`. Source of truth in code: `lib/utils/theme/noor_theme.dart` (tokens) and `lib/generals/widgets/` (components).

## Principles
1. **Paper, not screen.** Warm cream ground, near-white cards, deep forest green ink. It should feel like a printed Mushaf page, lit softly.
2. **Green speaks, gold marks.** Forest green is the only action colour. Gold appears only as a small mark of orientation or emphasis (the qibla tick, the Kaaba band, the next prayer).
3. **Quiet depth.** One elevation language: a soft, wide, low-opacity green-tinted shadow. No borders on cards, no stacked shadow plus border.
4. **Serif for the numbers and the name, Arabic display for titles.** Numerals (prayer times, degrees) and the "Noor" wordmark are set in Spectral. Arabic page titles are Amiri bold. Everything else is IBM Plex Sans Arabic.
5. **Generous, even rhythm.** 20dp gutters, 12dp between list items, 24dp between groups. Rows breathe; nothing is dense.
6. **RTL is native.** Layouts use start/end, icons that imply direction mirror, the brand header stays LTR.

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
| Wordmark | Spectral | 26 / 500 | "Noor", always LTR |
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
- **NoorHeader**: LTR row, sunburst mark + "Noor" wordmark at the start, settings icon button at the end.
- **NoorCard**: `card` fill, radius 20, soft shadow, optional ink-well.
- **IconTile**: 48dp circle in a tint, icon in the tint's icon colour.
- **NoorListRow**: tile or number circle, title (row title), meta line, chevron that mirrors in RTL. Used for adhkar categories, surahs and hizbs.
- **NoorSegmented**: pill track on `card`, selected segment filled `primary` with `onPrimary` text.
- **NoorPill**: location/sound chips: `card` fill, radius 16, leading icon, label, trailing chevron.
- **NoorButton**: `primary` filled / `tonal` / `outline`, height 52, radius 16, label 16/600.
- **NoorSheet** (bottom sheet): `card`, radius 28 top, drag handle, title, content; replaces most dialogs.
- **NoorNavBar**: floating card, radius 28, 4 items (icon + label), selected = `primary` colour with a 2dp underline pill.
- **EmptyState**: Lottie or icon tile, one sentence, one `NoorButton`.
- **Compass dial**: 1.5dp green ring, 60 ticks (major at 15°), N/E/S/W in Spectral, gold fixed heading tick on top, Kaaba glyph centre, green arrow to the qibla.

## Do / don't
- Do keep one primary button per screen.
- Don't use blue, purple or amber as UI chrome; they only appear inside icon tiles.
- Don't put text on photographic backgrounds. Backgrounds are flat paper.
- Don't use side-stripe borders, gradient text, or emoji as icons.
