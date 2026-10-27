# Noor: emulator audit and critique

Single batched pass on emulator-5554 (debug build), ar / en / fr, light and dark.

> **DEGRADED: single-context.** The audit and critique were run in one thread, not as two isolated sub-agents. No `.impeccable/critique` snapshot was written.
> Screenshots: `C:\Users\ECCSTO~1\AppData\Local\Temp\claude\c--Users-ECC-STORE-Desktop-Noor\a9484065-af79-44c0-bc16-02059835b08a\scratchpad\shots\`

**Detector:** `impeccable detect --json lib` returned `[]`. It only parses web markup, so an empty result says nothing about this Dart code. Every finding below comes from the emulator and manual code reads.

**Status after the audit:** the Settings sheet live-theme bug (first Major) was fixed in `lib/generals/widgets/noor_sheet.dart` (colours now read inside the builder, `backgroundColor: Colors.transparent`). That fix is **not built or tested**. Nothing else has been changed.

## Blocker

| Screen | Lang/theme | What is wrong | File |
|---|---|---|---|
| Adhkar reader | all (checked ar light/dark) | The card is a 16:9 box about 290px tall in a roughly 700px area. Long dhikr text is clipped mid-sentence and only scrolls inside the card, with no hint. About 60% of the screen is empty. The carousel gets no `height`, so it falls back to its default aspect ratio. | `lib/features/duaa/adhkar_display_screen.dart:132-139` |
| Qibla, GPS off | ar dark | An endless spinner with no message or action. It only recovers after you leave the tab and come back. | `lib/features/qibla/qibla_controller.dart:66-67`, `qibla_screen.dart:215` |

## Major

| Screen | Lang/theme | What is wrong | File |
|---|---|---|---|
| Settings sheet | ar light↔dark, en | On a live theme switch the sheet background keeps the old colour while the text flips. The title and labels become unreadable, and this persisted past 7s. The title stays Arabic after switching to English. A freshly opened sheet is fine. **Background fix applied, untested.** The title may still be a caller issue. | `lib/generals/widgets/noor_sheet.dart:9-14`, `settings_sheet.dart` |
| Quran, hizb list | ar | Start pages are off by one. Hizb 3 opens page 23, which begins at 2:146. Hizb 3 starts at 2:142, on page 22. The same shift runs through the table. | `lib/features/quran/hizb_pages.dart:2-7` |
| Surah, hizb and adhkar rows | ar light/dark | The trailing chevron points `>` on the left (end) side. Expected `<`. Both `chevron_left` and `chevron_right` flip in RTL, so the `isRtl ?` swap flips twice. Pills are correct. The "continue reading" arrow in ar also points toward its label. | `lib/generals/widgets/noor_list_row.dart:27`, `lib/features/quran/widgets/surah_line.dart:84`, `quran_screen.dart:202` |
| Adhkar reader | ar | The counter "1 / 31" renders as "31 / 1". | `adhkar_display_screen.dart:198` |
| Location permission denied | ar | The system dialog appears twice, then the app jumps to Android App info with no in-app explanation. Prayers and Qibla then repeat the same sentence as caption and button label. | `lib/generals/location_flow.dart`, `lib/features/qibla/qibla_screen.dart` |
| Manual location, offline | ar | A "no internet" dialog disappears after about 1s, with no retry. The screen returns to the untouched empty state. | `lib/generals/location_flow.dart`, `lib/generals/widgets/wait_dialog.dart` |
| Splash, launcher, notification | ar light | The native splash is white with the old purple-glow "نور" disc, not paper `#F6F3EB` with the new logo. The launcher icon and the adhan heads-up notification icon are also old. `splash.yaml` is updated but the native resources were not regenerated. | `splash.yaml`, `android/app/src/main/res/*` |
| Illustrations | all; worst in fr dark | The red-pin/purple-phone Lottie, the pink gear in the location sheet and the lilac offline icon break design.md's "no blue/purple chrome". In dark, the Qibla illustration shows a white blob on `#0E1512`. | `lib/generals/widgets/empty_state.dart`, location-flow assets |
| Surah rows | ar light at 1.3 | The Latin name is cut ("Al Fat…", "Al I…"). In fr dark at default scale the meta line cuts to "Médinoi…". The reference puts the Latin name on a muted second line. | `quran/widgets/surah_line.dart:~98` |
| Accessibility labels | ar | The reader's back and bookmark icon buttons have no semantic label. The header settings, back and info tooltips are hard-coded English ("Settings", "Back", "Info"). The info button is 40dp, under the 48dp target. | `lib/generals/widgets/noor_header.dart:54`, `adhkar_display_screen.dart:169,276`, `quran/screens/read_quran_screen.dart` |
| Contrast | light and dark | Gold "التالية/Next" on card is about 2.5:1 (computed). That fails 4.5:1 at 13px. Tonal CTA text in dark (the "set alarm" button and the Qibla denied button) looks low but was not measured. | `adhan_screen.dart`, `noor_button.dart` |

## Minor

- **Prayers header:** inset about 20dp more than the other tabs, in every language and theme (`adhan_screen.dart:151-156` pads `NoorHeader` again).
- **Quran reader:** the page-number pill overlaps the last text line on p.50, in both themes.
- **Destructive confirms:** the reset-progress sheet uses a primary green "ثبت"/"Confirm" instead of the danger style.
- **Bookmarks:** deleting an entry has no confirm or undo.
- **Search:** it keeps the continue-reading card and segmented control, so about one result shows above the keyboard. Focus reopens the keyboard when returning from the reader. Empty results show bare "لا نتائج". Text hits have no highlight and clipped snippets.
- **Qibla:** the distance renders as "km 3931 ~" in ar (`qibla_screen.dart:335`). The pill is narrow and centred, while Prayers uses full width. The dial ring is heavier than the reference and the centre is a pin glyph, not a Kaaba. The tab icon is a pin, not a compass.
- **Icons:** the settings icon is sliders, where the reference has a gear. The manual-location tile uses a gear.
- **Prayers rows:** the reminder stepper reads "+10 د" garbled in ar. The collapsed row shows no reminder indicator.
- **Mixed scripts:** "Algeria, الجزائر العاصمة", and country and state lists are in Latin inside the Arabic UI.
- **Ring screen:** Fajr and Asr tints (amber) differ from the Prayers rows (`adhan_ring_screen.dart` `_prayerTint`). "إغلاق" calls `SystemNavigator.pop`, which exits the app even if it was open.
- **Copy:** the en/fr title "El Adhkar". The fr Qibla CTA truncates. DB titles "اذكار الصباح/المساء" lack the hamza that "أذكار الصلاة" has. "Prayer" and "After prayer" adhkar share an icon.
- **Dark and light polish:** dark adhkar tile icons and the Quran progress track are low contrast. The light "off" switch thumb is faint. The calibration sheet repeats its steps in the tips.
- **Dead code:** `lib/features/quran/screens/list_by_hizb.dart` and the old surah list are still present.

## Matches the reference and design.md

- Adhkar list: centred title and subtitle, search field, tinted icon-tile rows.
- Quran: pill segmented control, numbered circles, progress bar with percent.
- Qibla: Spectral N/E/S/W, gold north tick, green arrow, large numeral card, calibrate chip. The bearing of 105.41° matches a hand calculation for Algiers (105.4°).
- Dark and light tokens, floating nav bar, the figure-8 calibration animation, and the ring screen layout.
- Behaviour that worked:
  - Reading progress: page 23 gave 1/604 and Baqarah 2%, and page 50 counted after a >5s stay.
  - Search by title and by text, including "الحمد لله" typed without diacritics.
  - Counting down to the next card, the info sheet, sound preview, and adding and removing a reminder.
  - Language and theme switching.

## Alarm check

`adb shell dumpsys alarm`, `RTC_WAKEUP` pending alarms for `com.sidalidev.noor`:

- **After setting a location with a Fajr reminder:** 16 in the 3-day window.
  - 4 adhans today (Dhuhr, Asr, Maghrib, Isha), 5 tomorrow and 5 the day after, with Shuruq off.
  - 2 reminders, tomorrow and the day after, because today's Fajr had passed.
- **After removing the reminder:** 14.
- **After Dhuhr fired:** 13.

## Ring screen

The emulator clock was shifted to 70s before Dhuhr with `cmd alarm set-time`. The ring screen appeared, and the clock was restored afterwards (it reads 10:24, correct).

## Scores

- **Audit:** Accessibility 2/4, Theming 3/4, Platform conformance 2/4. Performance and adaptivity were not scored: no frame times were measured and landscape/tablet were not tested.
- **Critique:** heuristics 24/40 (Acceptable). Error recovery is the weakest at 1/4 (offline, GPS off, permission denied). The paper, green and serif system is clearly authored for this product. The stock illustrations and the unmirrored RTL details are what break it.

## Not verifiable on the emulator

- An adhan firing in the background after a reboot, in Doze, or after an OEM task kill.
- Exact-alarm and battery-optimisation behaviour on real devices.
- The real compass sensor: heading, magnetic interference and the effect of calibration.
- Real GPS accuracy. `geo fix` was used, and the GPS-success fetch path was not run.
- TalkBack. Only the semantics tree was read.

## Coverage gaps

en and fr versions of the sheets, the readers and the hizb list were not captured. Tabs were covered in ar, en and fr, light and dark. Qibla "granted" was captured only in ar.

## State left on the device

- The app is in ar dark, with Algeria / Algiers set and the reading progress and bookmark created during the audit.
- Font scale is back to 1.0, wifi and data are on, and GPS is on.
- Gboard has Arabic added.
