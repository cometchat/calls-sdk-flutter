---
name: background-handling
description: Background call handling in CometChat Calls SDK v5 Flutter. Keep calls alive in background, OngoingCallService, lifecycle management. Triggers on "background", "foreground service", "keep alive", "app lifecycle", "background call".
inclusion: manual
---

# CometChat Calls SDK v5 — Background Handling (Flutter)

## Overview

Keep calls alive when the app goes to background. The SDK provides `OngoingCallService` and platform-specific mechanisms to maintain the call connection.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### App Lifecycle Handling

```dart
class CallScreen extends StatefulWidget {
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App going to background
        _handleBackground();
        break;
      case AppLifecycleState.resumed:
        // App coming to foreground
        _handleForeground();
        break;
      default:
        break;
    }
  }

  void _handleBackground() {
    // Enter PiP if supported
    CallSession.getInstance()?.enterPipMode();
  }

  void _handleForeground() {
    // Restore full UI
    CallSession.getInstance()?.disablePictureInPictureLayout();
  }
}
```

## Platform Configuration

### Android

Add foreground service permission in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL" />
```

The SDK's native Android layer uses `CometChatOngoingCallService` to keep the call alive via a foreground notification.

### iOS

Add background modes in `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```

The SDK maintains the audio session in background via `AVAudioSession`.

## Gotchas

- Background handling is mostly managed by the native SDK layer
- Use `WidgetsBindingObserver` to detect app lifecycle changes
- PiP mode is the recommended UX for background calls
- On Android, a foreground service notification is shown during background calls
- On iOS, the audio background mode keeps the call alive
- Without proper background configuration, calls may disconnect after ~30 seconds

## Sample App Reference

- `lib/screens/call_screen.dart` — Lifecycle handling
