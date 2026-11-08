# TabBar

The app's bottom navigation: a flat paper strip with the active tab cut out as a piece of night sky.

**Consumer provides:** `items` (3–5 of `{ id, label, icon }`), and either `active` + `onChange(id)` (controlled) or `defaultActive`; optional `label` for the nav landmark (default "Main").

- Labels are one word; icons come from the `Icon` set.
- Float it `space-4` above the bottom safe area with `space-4` side margins — it's a paper strip, not a full-bleed bar.
- The active tab carries `aria-current="page"`.
