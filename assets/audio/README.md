# Audio assets

No audio is bundled yet. Add only approved/licensed audio here:

- `judging.mp3`: short seamless judging loop
- `cold.mp3`, `good.mp3`, `laugh.mp3`, `genius.mp3`, `legend.mp3`: short result effects

These names are mapped in `lib/services/judging_sound.dart`. Missing files are
silently skipped. Rebuild the app after adding assets. No network audio is used.
Sound defaults to OFF and can be enabled in Settings. Test on Android and iOS,
including mute, backgrounding, returning, and leaving the judging/result screen.
