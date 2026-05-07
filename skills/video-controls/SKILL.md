---
name: video-controls
description: Video controls for CometChat Calls SDK v5 Flutter. Camera on/off, switch camera (front/back), pause/resume video. Triggers on "camera", "video", "switch camera", "pause video", "resume video", "front camera", "back camera".
inclusion: manual
---

# CometChat Calls SDK v5 — Video Controls (Flutter)

## Overview

Control video during an active call session — pause/resume camera and switch between front/back cameras.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Pause/Resume Video

```dart
final session = CallSession.getInstance();

// Pause (turn off camera)
await session?.pauseVideo();

// Resume (turn on camera)
await session?.resumeVideo();

// Toggle
await session?.togglePauseVideo();

// Check state
bool isPaused = session?.isVideoPaused ?? false;
```

### Switch Camera

```dart
final session = CallSession.getInstance();

// Switch between front and back camera
await session?.switchCamera();

// Alias method
await session?.toggleCameraSource();
```

### Set Initial Camera in Settings

```dart
final settings = SessionSettingsBuilder()
    .setInitialCameraFacing(CameraFacing.front) // or CameraFacing.back
    .startVideoPaused(false)
    .build();
```

### Listen for Video Events

```dart
class MyMediaListener implements MediaEventListeners {
  @override
  void onVideoPaused() {
    debugPrint("Video paused");
  }

  @override
  void onVideoResumed() {
    debugPrint("Video resumed");
  }

  @override
  void onCameraFacingChanged(CameraFacing facing) {
    debugPrint("Camera switched to: ${facing.value}");
  }
}
```

## CameraFacing Enum

- `CameraFacing.front` — Front-facing camera
- `CameraFacing.back` — Rear-facing camera

## Gotchas

- Video controls only work during an active session
- `isVideoPaused` reflects the local video state
- Camera permission must be granted before starting video
- `switchCamera()` toggles between front and back — no explicit set

## Sample App Reference

- `lib/screens/call_screen.dart` — Video control integration
