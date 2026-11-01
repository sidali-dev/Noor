# Logos

The Faith logo rebuilt as a cut-paper piece. The dome is a night window framed in white paper, with an inner frame set further back and a few stars. The bolt is a paper cut-out lifted in front of the night, the crescent is brass, and the two wings are lit paper layers at the front. Every layer casts its shadow straight down (`depth-shadow`). The wordmark is "FAITH" in Cormorant Garamond 600, letter-spaced 0.16em and converted to outlines.

- `faith-logo-paper.svg`: full lockup (mark over wordmark) for light grounds (`surface`, `surface-raised`). Inks: frame `surface-raised`, window `window`, crescent `brass` (#7a6436), wordmark `ink` (#1a1c22).
- `faith-logo-night.svg`: full lockup for dark grounds (Night `surface`, `window`). Frame `surface-raised` (#1c1f27), bolt and stars `on-window` (#f7f7f4), crescent `brass` (#cdb588), wordmark `ink` (#eceef2).
- `faith-mark-paper.svg` / `faith-mark-night.svg`: the mark alone, for headers, the splash screen and favicons above 48px.
- `faith-app-icon.svg`: 1024px app-store/home-screen icon, with the mark on `surface` paper in a rounded square. Export to PNG at the sizes each store requires.

Rules:
- Pick the file by ground: paper files on light grounds, night files on dark grounds. Never recolour, and never place the paper lockup on a photo.
- Keep clear space of at least the crescent's width on every side.
- The full lockup needs at least 120px of height; below that use the mark. Below 32px, the depth shadows and stars turn to noise, so use a flat favicon instead.
- Don't stretch, rotate, add outlines, or replace the brass crescent with another colour.
