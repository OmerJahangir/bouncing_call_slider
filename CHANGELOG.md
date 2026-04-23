## [1.1.1] 

### Changed
- Package now supports `Flutter 3.0.0` and all later versions.
- Ensures wider support across older Flutter 3.x projects.

## [1.1.0] - 2026-04-23

🔧 Updated for latest Android & iOS support

### 🛠️ Changed
- Broadened Dart SDK constraint to `>=3.0.0 <4.0.0` for wider compatibility
- Updated minimum Flutter version to `>=3.10.0`
- Added explicit `platforms` declaration (Android, iOS, Web, Linux, macOS, Windows)
- Added `topics` for better pub.dev discoverability
- Fixed `repository` and `issue_tracker` URLs in pubspec
- Fixed package name reference in README usage example

---

## [1.0.0] - 2025-07-01

🎉 Initial release of **Bouncing Call Slider**

### ✨ Added
- `BouncingCallSlider` widget with vertical swipe support
- Bounce animation for idle state
- Haptic feedback triggered at top/bottom bounce
- Rotation effect on bounce
- Accept and decline callbacks (`onAccept`, `onDecline`)
- Customizable text: `acceptText`, `declineText`
- Customizable icons via `acceptIcon`, `declineIcon`
- Color customizations:
  - `iconColorAccept`, `iconColorDecline`
  - `callBtnBackgroundColor`
  - `acceptTextColor`, `declineTextColor`
- Size/dimension parameters: `height`, `width`, `iconSize`, `buttonSize`
- Fully responsive and theme-friendly design
- Example app in `/example` folder
- Demo GIFs in `/screenshots` folder