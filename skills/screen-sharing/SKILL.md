---
name: screen-sharing
description: Screen sharing in CometChat Calls SDK v5 Flutter. Screen share events, presenter detection. Triggers on "screen share", "screen sharing", "presenter", "share screen".
inclusion: manual
---

# CometChat Calls SDK v5 — Screen Sharing (Flutter)

## Overview

Screen sharing is handled by the native SDK UI. Listen for screen share events to update your app state.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Show/Hide Screen Sharing Button

```dart
final settings = SessionSettingsBuilder()
    .hideScreenSharingButton(false)  // Show screen sharing button (default)
    .build();
```

### Listen for Screen Share Events

```dart
class MyMediaListener implements MediaEventListeners {
  @override
  void onScreenShareStarted() {
    debugPrint("Local screen sharing started");
  }

  @override
  void onScreenShareStopped() {
    debugPrint("Local screen sharing stopped");
  }
}

class MyParticipantListener implements ParticipantEventListeners {
  @override
  void onParticipantStartedScreenShare(Participant participant) {
    debugPrint("${participant.name} started screen sharing");
  }

  @override
  void onParticipantStoppedScreenShare(Participant participant) {
    debugPrint("${participant.name} stopped screen sharing");
  }
}
```

## Platform Notes

### Android
- Screen sharing uses `MediaProjection` API
- The SDK handles the system permission dialog automatically
- Requires `FOREGROUND_SERVICE` permission in AndroidManifest

### iOS
- Screen sharing uses `ReplayKit`
- May require a Broadcast Upload Extension for system-wide sharing
- The SDK handles in-app screen sharing automatically

## Gotchas

- Screen sharing is initiated via the built-in SDK button
- `hideScreenSharingButton(false)` is the default — button is visible
- Both local (`MediaEventListeners`) and remote (`ParticipantEventListeners`) events are available
- Screen sharing replaces the camera feed for the sharing participant

## Sample App Reference

- `lib/screens/call_screen.dart` — Screen sharing event handling
