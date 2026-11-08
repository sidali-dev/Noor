# Button

A raised paper tab you press into the page; primary is a piece of night sky, secondary is white paper.

**Consumer provides:** `children` (the label, verb first, sentence case: "Set reminder"), optional `variant` (`primary` | `secondary` | `ghost`, default `primary`), `size` (`md` | `sm`), `icon` (any `Icon` name), and any native button props (`onClick`, `disabled`, `type`).

- One `primary` per screen region — the action the screen exists for. In Night it flips to a moon-white fill with `window` text.
- `secondary` for parallel choices; `ghost` for dismissals ("Not now") and toolbar actions.
- Pressing drops the button from `shadow-2` to `shadow-1` and 1px down — the paper is pushed in. Don't add colour changes on hover.
- Don't put a primary button inside an `ArchFrame` window — the window is already the night; use `secondary` there.
- Height 44px (36px for `sm`) keeps a comfortable touch target.
