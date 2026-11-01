Hilal is a cut-paper design system: matte white card-stock, layered in depth, with windows cut through it onto a still night sky. It is quiet, festive without being loud, and monochrome except for one warm brass note. Everything should look like it could be cut with a craft knife and lifted with a shadow.

## Principles

1. **Depth is the material.** Hierarchy comes from layers of paper and their shadows, not from colour or borders. Something more important sits closer to the reader, and the hero is a full shadow box of stacked layers lit from above.
2. **Night through paper.** The dark `window` colour is always a cut-out: framed by white paper, never floating on the ground. It holds the most time-sensitive or celebratory thing on screen.
3. **Monochrome first, one brass accent.** Paper and night carry the interface. `brass` appears in small doses: the focus ring, a star ornament, an occasion badge.
4. **Scallops, not squares.** The signature silhouette is the multifoil pointed arch and the cloud scroll. Rectangles are softened with `radius-lg`; the arch is reserved for heroes.
5. **Still, not static.** Motion is a gentle settle (paper lowering onto the page), never a bounce or spin.

## Content fundamentals

- Voice: warm, calm and brief. Speak like a thoughtful host: "Maghrib in 1 h 20 min", "Eid Mubarak", "Reminder set".
- Sentence case everywhere except `eyebrow` kickers, which are uppercase via CSS.
- Address the reader as "you" when needed; the app never says "I".
- Bilingual by design: a Latin greeting in `display-*` pairs with Arabic in `arabic-display` directly beneath, centred, at the same visual weight. Arabic text always gets `dir="rtl"` and `lang="ar"`.
- Dates: show the Hijri date in `caption` under the Gregorian one ("10 Dhul Hijjah 1448").
- No emoji. Use the crescent and the eight-point star as decoration instead.
- No exclamation marks except in a greeting ("Eid Mubarak!" is acceptable once, on the greeting itself).

## Color

Two themes: **Paper** (light, the default) and **Night** (dark). Every token has a value in both.

- Ground: `surface`. Raised paper: `surface-raised` + one `shadow-*`. Pressed-in wells: `surface-sunken` + `shadow-inset`.
- Text: `ink` and `ink-muted` on any of the three surfaces. On night: `on-window` and `on-window-muted`.
- `window` is the night sky. Place it inside paper (an `ArchFrame`, a `PaperCard tone="night"`), as the primary button fill in Paper, or as the active tab. In the Night theme it sits close to `surface`, so it must be framed: a paper border, `shadow-3`, or a `line` hairline.
- `brass` is the only warm colour. Use it for one accent per view region: focus ring, `Ornament` star, `Badge tone="brass"`, a selected date, inline links. Text on a solid brass fill uses `on-brass`.
- `success` / `danger` are for state only and always come with a word and an icon (`check`, `alert`). They sit on `surface-raised` or their `-soft` fills.
- `line` is decorative only; any border that a person must see to use a control is `line-strong`.

All text pairs named in token notes are at least 4.5:1 in both themes; `line-strong` is at least 3:1 on every surface.

## Typography

Three families, all on Google Fonts (loaded by `components/bundle.css`):

- **Cormorant Garamond** (`display`): an elegant high-contrast serif for greetings, screen titles and big numbers (prayer times, countdowns). Styles: `display-xl`, `display-lg`, `title`. Never below 24px.
- **Jost** (`sans`): a geometric sans for everything functional. Styles: `heading`, `body`, `body-sm`, `label`, `eyebrow`, `caption`.
- **Amiri** (`arabic`): a classical Naskh for Arabic. Styles: `arabic-display`, `arabic-body`, with tall line heights for diacritics.

Pair one `display-*` line with at most one `eyebrow` above and one `body-sm` or Arabic line below. Numbers in times and counts use the display face; units and labels use the sans.

## Spacing and layout

- 4px base: `space-1` to `space-8` (4, 8, 12, 16, 24, 32, 48, 64).
- Mobile screens: `space-4` side margins, `space-5` between cards, `space-6` between sections.
- Hero `ArchFrame`: centred, with `space-7` of ground around it.
- `TabBar` floats `space-4` above the bottom safe area, inset `space-4` from the sides.

## Shape and depth

Depth is what makes Hilal feel like paper rather than flat UI. It works at two strengths:

**Everyday depth (all screens).** Each piece of UI is one sheet of paper above the page.
- Radii: `radius-sm` (badges, fields), `radius-md` (buttons), `radius-lg` (cards, sheets), `radius-pill` (toggles, discs).
- Shadows stack with depth: `shadow-1` flat paper (tab bar, list groups), `shadow-2` cards and buttons, `shadow-3` the front-most layer (sheets, dialogs). `shadow-inset` for pressed-in wells.
- No borders on paper cards; the shadow is the edge.

**Shadow-box depth (hero moments only).** `ArchFrame` builds a small diorama: several paper layers stacked one behind the other, each casting its own shadow onto the next.
- One light source, straight above. Every cast shadow falls downward in `depth-shadow`, never sideways.
- Layers further back sit in `paper-shade`, and layers in front in `surface-raised`, so distance reads even without the shadows.
- Lit paper carries a soft top-to-bottom wash from `surface-raised` to `paper-shade`. The moon carries a `sky-glow` halo. These two are the only gradients allowed, and only inside `ArchFrame`.
- Use the shadow box once per screen. Everywhere else stays at everyday depth, so the hero stands out.

## Motion

- Paper settles: elements enter by fading from 0 and moving up 4–8px, 180–240ms, ease-out. Pressing a button moves it 1px down and drops it to `shadow-1`.
- The sky may twinkle: stars at 0.85 ↔ 1 opacity over 4s, staggered (`ArchFrame` does this). Turn it off under `prefers-reduced-motion`.
- No bounces, spins or parallax.

## Focus and states

- Focus: a solid 2px `brass` outline, offset 2px, on every interactive element. On night fills it still reads (≥ 3:1).
- Disabled: 45% opacity, no shadow.
- Errors: `danger` border plus an alert icon and a fix-it message under the field.

## Iconography

- Use the system's own 24px line set (`Hilal.Icon`): 1.6 stroke, round caps and joins, inheriting `color`. Twelve icons ship: home, compass, calendar, bookmark, settings, moon, star, search, bell, check, alert, plus.
- Extend in the same style: draw on a 24px grid, a single stroke weight, no fills. Lucide icons at `stroke-width="1.6"` are the closest match if you need more quickly.
- Decorative motifs (arch, crescent, eight-point star, cloud scroll) live in `assets/Motifs` and inside `ArchFrame`/`Ornament`. Don't use them as UI icons.

## Imagery

- Prefer illustration built from the motifs (arches, domes, minarets, crescents, clouds) in paper white over night. Generic silhouettes only; no depictions of people.
- If you use photography, mask it in `arch-window.svg` and frame it in white paper; desaturate it toward the monochrome palette.

## Logo

The product logo is **Faith** (`assets/Logos`): a domed night window in a white paper frame, with a paper lightning bolt, a brass crescent above and two paper wings below, over the wordmark "FAITH" in letter-spaced Cormorant Garamond.
- Use `faith-logo-paper.svg` / `faith-mark-paper.svg` on light grounds and the `-night` files on dark grounds.
- Use the full lockup on splash, onboarding and about screens; the mark alone in app bars and headers; `faith-app-icon.svg` for the home screen.
- Keep clear space of at least the crescent's width on every side. Never recolour or stretch it. The logo follows the same lighting as the UI: light from above, shadows falling down.

## Using the components

Components live in `components/bundle.js` as `window.Hilal` (React 18), styled by `components/bundle.css`, which also loads the three fonts. Tokens are CSS custom properties (`--surface`, `--space-4`, `--shadow-2`, `--font-display`…); switch theme with `data-theme="paper"` or `data-theme="night"` on `<html>`.
