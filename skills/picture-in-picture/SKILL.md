---
name: picture-in-picture
description: Picture-in-Picture (PiP) mode in CometChat Calls SDK v5 Flutter. Enable/disable PiP layout, enter system PiP mode. Triggers on "picture in picture", "pip", "PiP", "floating window", "mini player".
inclusion: manual
---

# CometChat Calls SDK v5 — Picture-in-Picture (Flutter)

## Overview

Enable Picture-in-Picture (PiP) mode to show a floating call window when the user navigates away from the call screen.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Enable/Disable PiP Layout

```dart
final session = CallSession.getInstance();

// Enable PiP layout
await session?.enablePictureInPictureLayout();

// Disable PiP layout
await session?.disablePictureInPictureLayout();
```

### Enter System PiP Mode

```dart
final session = CallSession.getInstance();

// Enter system PiP mode (returns true if successful)
bool entered = await session?.enterPipMode() ?? false;
```

### Check PiP Support

```dart
final session = CallSession.getInstance();
bool supported = await session?.isPipSupported() ?? false;
```

### Listen for PiP Events

```dart
class MyLayoutListener implements LayoutListeners {
  @override
  void onPictureInPictureLayoutEnabled() {
    debugPrint("PiP enabled");
  }

  @override
  void onPictureInPictureLayoutDisabled() {
    debugPrint("PiP disabled");
  }
}
```

### Auto-Enter PiP on Background

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // App going to background — enter PiP
    CallSession.getInstance()?.enterPipMode();
  }
}
```

## Platform Notes

### Android
- Requires `android:supportsPictureInPicture="true"` in AndroidManifest activity
- Available on Android 8.0+ (API 26+)

### iOS
- PiP is handled via AVKit framework
- Available on iOS 15+

## Gotchas

- Check `isPipSupported()` before attempting to enter PiP
- PiP may not be available on all devices (e.g., some tablets)
- System PiP mode is different from the in-app PiP layout
- Register `LayoutListeners` to track PiP state changes

## Sample App Reference

- `lib/screens/call_screen.dart` — PiP integration
