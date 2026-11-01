# Toggle

An on/off switch: a paper disc that slides along a pressed-in track; when on, the track becomes night sky (moon-white in the Night theme).

**Consumer provides:** `label`, and either `checked` + `onChange(checked)` (controlled) or `defaultChecked` (uncontrolled); optional `disabled`.

- Use for settings that take effect immediately (notifications, Hijri date). For choices that need a Save, use a checkbox pattern instead.
- The label describes the on state: "Adhan notifications", not "Turn off adhan".
- Renders a real `input type="checkbox" role="switch"`, so keyboard and screen readers work with no extra props.
