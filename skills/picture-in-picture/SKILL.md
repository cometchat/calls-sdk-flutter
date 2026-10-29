---
name: picture-in-picture
description: Picture-in-Picture (PiP) mode in CometChat Calls SDK v5 Flutter. Enable/disable PiP layout, enter system PiP mode. Triggers on "picture in picture", "pip", "PiP", "floating window", "mini player".
inclusion: manual
---

# CometChat Calls SDK v5 — Picture-in-Picture (Flutter)

## Overview

Enable Picture-in-Picture (PiP) mode to show a floating call window when the user navigates away from the call screen.

There are two parts: the **PiP layout** (a compact call layout inside the call view) and **system PiP** (Android's floating window, entered with `enterPipMode()`). From 5.1.0 the Android plugin switches the layout by itself when the activity enters and leaves PiP, so apps only decide when to enter PiP.

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
class MyLayoutListener extends LayoutListeners {
  @override
  void onPictureInPictureLayoutEnabled() {
    debugPrint("PiP enabled");
  }

  @override
  void onPictureInPictureLayoutDisabled() {
    debugPrint("PiP disabled");
  }
}

void listenForPip() {
  // A single listener, set as a property (not add/remove).
  CallSession.getInstance()?.layoutListener = MyLayoutListener();
}
```

### Auto-Enter PiP on Background

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  // Android: inactive arrives while the activity is still visible, which is
  // when Android lets an app enter PiP.
  if (state == AppLifecycleState.inactive) {
    CallSession.getInstance()?.enterPipMode();
  }
}
```

When the window expands again, or the app comes back after the PiP window was closed, the Android plugin restores the full layout and resumes video it paused; there is nothing to undo here.

## Platform Notes

### Android
- Requires `android:supportsPictureInPicture="true"` on the activity in AndroidManifest
- Available on Android 8.0+ (API 26+); `isPipSupported()` reports `false` on low-RAM (Android Go) devices
- Closing the PiP window keeps the call running with this user's video paused until the app is on screen again

### iOS
- The plugin implements the PiP layout methods (`enablePictureInPictureLayout` / `disablePictureInPictureLayout`) but not system PiP: `isPipSupported()` reports `false` and `enterPipMode()` throws a `CometChatCallsException`

## Gotchas

- Check `isPipSupported()` before attempting to enter PiP
- System PiP mode is different from the in-app PiP layout
- On Android, `disablePictureInPictureLayout()` also turns off entering PiP for the call (`enterPipMode()` returns `false`) until `enablePictureInPictureLayout()`; don't call it to "restore" the layout, the plugin does that
- Set `CallSession.getInstance()?.layoutListener` to track PiP state changes

## Sample App Reference

- `lib/screens/call_screen.dart` — PiP integration
