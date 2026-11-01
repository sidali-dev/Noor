# TextField

A labelled input cut into the page: a `surface-sunken` well with an inset shadow.

**Consumer provides:** `label` (always — no placeholder-only fields), optional `hint` (helper line), `error` (replaces the hint, turns the border `danger`, adds an alert icon and `aria-invalid`), and any native input props (`value`, `onChange`, `placeholder`, `type`).

- The resting border is `line-strong` so the field is visible on every surface.
- Focus draws the brass ring 2px outside the well.
- Error copy says how to fix it: "Enter a number from 0 to 60." — not "Invalid input".
- Place on `surface` or `surface-raised`; never inside a night window.
