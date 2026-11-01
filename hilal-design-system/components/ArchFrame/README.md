# ArchFrame

The signature: a layered paper shadow box. Up to three nested, scalloped, pointed arches are cut from white paper, each set further back than the one before. Behind them is a night window with a glowing crescent, stars and a paper skyline, and its base is hidden behind a cloud scroll and a lace border.

**Consumer provides:** `width` in px (default 280; height follows the 240:266 artwork), optional `children` (centred text over the sky), `contentTop` (CSS length from the top of the figure, default `42%`), `label` (accessible description; omit when purely decorative), `layers` (1 | 2 | 3 nested frames, default 3), and switches `moon`, `glow`, `stars`, `skyline`, `clouds`, `lace` (all default `true`).

## How the depth works

- **One light, from straight above.** Every layer casts a short shadow downward onto the layer behind it in `depth-shadow`. The outer frame and the lace cast a deeper one. Never offset these shadows sideways.
- **Front to back:** lace border → front clouds → back clouds (`paper-shade`) → outer frame → inner frames → domes → wall and minarets (`paper-shade`) → night window.
- **Light wash:** frames shade from `surface-raised` at the top to `paper-shade` at the base, so the paper looks lit from above. This gradient and the moon's `sky-glow` halo are the only gradients in the system.
- The whole box casts the large `shadow-3`-strength shadow onto the page.

## Usage

- One per screen, as the hero: splash, greeting, onboarding, an occasion screen. Never in a list or repeated grid.
- Text inside is `on-window`: one `eyebrow`, one `display-lg`-class line (34–40px), and optionally one `arabic-display` line. Three lines maximum. Use `contentTop` (about `29%` for three lines) so it clears the crescent.
- Under 220px wide, use `layers={1}` and turn off `skyline` and `lace`; the detail turns to noise when small.
- Keep `space-7` of ground around it so the shadows have room.
- Stars twinkle gently unless the viewer prefers reduced motion.
