# Faith audit plan

Ordered by risk to the user. Status is updated as items land.

## P0 — Adhan reliability
| # | Issue | Fix | Status |
|---|-------|-----|--------|
| 1 | First launch scheduled nothing: `sync()` exits without notification permission and nothing re-synced after the grant | Sync after the grant in the nav controller and on resume in `PermissionNotice` | done |
| 2 | Cold-start ring lost: `ringStream` is a non-replaying broadcast | Listen to `Alarm.ringing` (replays) | done |
| 3 | Ring navigation died after `Get.offAll`: static `_subscription ??=` stayed cancelled | Instance subscription created in `onInit` | done |
| 4 | Ring screen stayed open after the alarm ended elsewhere (notification stop) | Pop when `Alarm.ringing` no longer holds the alarm | done |
| 5 | Android: ringing adhan opened over the lock screen only as a notification (`showWhenLocked=false`) | RING intent filter; `MainActivity` shows over keyguard only for `ACTION_RING`, cleared in `onStop` | done |
| 6 | iOS: no background audio / BG task / notification delegate → alarms never ring in background | `UIBackgroundModes`, `BGTaskSchedulerPermittedIdentifiers`, AppDelegate setup, iOS 13 target | done |
| 7 | Workmanager registered on iOS (unsupported config) | Android only, guarded | done |
| 8 | Duplicate timing parser in controller and scheduler | One public `AdhanScheduler.parseTiming` | done |

Known limits (cannot be fixed in code): OEM battery killers, iOS after force-quit, Play policy review of `USE_EXACT_ALARM` / `USE_FULL_SCREEN_INTENT`.

## P1 — Rename to Faith
Arabic app name removed (unused `noor` l10n key, splash text, README, PRODUCT.md, launch config). Every user-visible name is Faith.
Not done on purpose: renaming the Dart package, `Noor*` design-system classes, Kotlin package, applicationId and iOS bundle id. They are internal, not user-visible, and changing the ids orphans installs and scheduled alarms.

## P2 — Cleanup
Removed: `*_light.webp` heroes and `NoorArt.of`, splash precache of them, unused `SImageString` entries and SVGs, orphan splash/ornament assets, linux/macos/web/windows scaffolds, duplicate gradle `defaultConfig`. All dependencies are used.

## Verification
`flutter analyze`, `flutter test` (baseline 506 passing), `flutter build apk --debug`. iOS cannot be built on Windows.
