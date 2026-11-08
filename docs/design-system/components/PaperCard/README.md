# PaperCard

A sheet of cut paper lifted off the ground, holding one idea: a prayer time, a countdown, a short reading.

**Consumer provides:** `children`, optional `eyebrow` (short kicker, rendered uppercase), `title` (set in the display face), `elevation` (1 | 2 | 3, default 2), `tone` (`paper` | `night`).

- Elevation is depth order, not emphasis: things that sit closer to the reader get a higher number. A screen usually has many `1`s and `2`s and at most one `3`.
- `tone="night"` is a window into the sky — use it once per screen for the most time-sensitive thing (tonight's event, a countdown). Text inside uses `on-window` / `on-window-muted`.
- Corners are `radius-lg`; padding `space-5` (drop to `space-4` under 360px wide).
- Never add borders to paper-tone cards — the shadow is the edge.
