---
name: screen-sharing
description: Screen sharing in CometChat Calls SDK v5 Flutter. Screen share events, presenter detection. Triggers on "screen share", "screen sharing", "presenter", "share screen".
inclusion: manual
---

# CometChat Calls SDK v5 — Screen Sharing (Flutter)

## Overview

Screen sharing starts from the built-in screen share button, or from your own controls with `CallSession` methods. Listen for screen share events to update your app state. On Android, local screen sharing is opt-in (see Platform Notes).

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

### Start/Stop from Your Own Controls

```dart
final session = CallSession.getInstance();

await session?.startScreenShare();
await session?.stopScreenShare();
await session?.toggleScreenShare();

bool sharing = session?.isScreenSharing ?? false;
```

### Listen for Screen Share Events

```dart
class MyMediaListener extends MediaEventListeners {
  @override
  void onScreenShareStarted() {
    debugPrint("Local screen sharing started");
  }

  @override
  void onScreenShareStopped() {
    debugPrint("Local screen sharing stopped");
  }
}

class MyParticipantListener extends ParticipantEventListeners {
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
- Screen sharing uses the `MediaProjection` API, which on Android 10+ needs a foreground service of type `mediaProjection`
- The plugin removes that service from the merged manifest, so apps that never share the screen don't have to justify screen recording on Google Play. To enable local screen sharing, add to your app's `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />

<application>
    <service
        android:name="com.oney.WebRTCModule.MediaProjectionService"
        android:exported="false"
        android:foregroundServiceType="mediaProjection" />
</application>
```

- Without it, the screen share button is hidden at runtime on Android 10+
- The SDK handles the system permission dialog automatically

### iOS
- Screen sharing uses `ReplayKit`
- May require a Broadcast Upload Extension for system-wide sharing
- The SDK handles in-app screen sharing automatically

## Gotchas

- Screen sharing is started from the built-in SDK button or `CallSession.startScreenShare()`
- Android: no `MediaProjectionService` declaration = no local screen sharing (viewing others' shares still works)
- `hideScreenSharingButton(false)` is the default — button is visible
- Both local (`MediaEventListeners`) and remote (`ParticipantEventListeners`) events are available
- Screen sharing replaces the camera feed for the sharing participant

## Sample App Reference

- `lib/screens/call_screen.dart` — Screen sharing event handling
