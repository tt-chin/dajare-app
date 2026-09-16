# Audio assets

Official audio extracted unchanged from the supplied `dajare_app_audio.zip`:

- `background.mp3`: loop on ordinary screens
- `judging.mp3`: loop only while waiting for the actual judgment response

These names are mapped in `lib/services/judging_sound.dart`. Missing files are
silently skipped. Tracks restart from the beginning when resumed. Only one track
plays at a time. Result screens stop judging music; leaving restores background.
Optional future `cold.mp3`, `good.mp3`, `laugh.mp3`, `genius.mp3`, `legend.mp3`
effects must also be explicitly registered in pubspec.yaml. They are not supplied.
Rebuild the app after adding assets. No network audio is used.
Sound defaults to OFF and can be enabled in Settings. Test on Android and iOS,
including mute, backgrounding, returning, and leaving the judging/result screen.
ZIPs and this README are not registered as Flutter assets.
