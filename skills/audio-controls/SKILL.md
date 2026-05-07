---
name: audio-controls
description: Audio controls for CometChat Calls SDK v5 Flutter. Mute/unmute audio, switch audio mode (speaker, earpiece, bluetooth). Triggers on "mute", "unmute", "audio", "speaker", "earpiece", "bluetooth", "audio mode".
inclusion: manual
---

# CometChat Calls SDK v5 — Audio Controls (Flutter)

## Overview

Control audio during an active call session — mute/unmute microphone and switch audio output device.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Mute/Unmute Audio

```dart
final session = CallSession.getInstance();

// Mute
await session?.muteAudio();

// Unmute
await session?.unMuteAudio();

// Toggle
await session?.toggleMuteAudio();

// Check state
bool isMuted = session?.isAudioMuted ?? false;
```

### Switch Audio Mode

```dart
final session = CallSession.getInstance();

// Switch to speaker
await session?.setAudioModeType(AudioMode.speaker);

// Switch to earpiece
await session?.setAudioModeType(AudioMode.earpiece);

// Switch to bluetooth
await session?.setAudioModeType(AudioMode.bluetooth);

// Switch to headphones
await session?.setAudioModeType(AudioMode.headphones);
```

### Listen for Audio Events

```dart
class MyMediaListener implements MediaEventListeners {
  @override
  void onAudioMuted() {
    debugPrint("Audio muted");
  }

  @override
  void onAudioUnMuted() {
    debugPrint("Audio unmuted");
  }

  @override
  void onAudioModeChanged(AudioMode audioMode) {
    debugPrint("Audio mode changed to: ${audioMode.value}");
  }
}
```

## AudioMode Enum

- `AudioMode.speaker` — Phone speaker
- `AudioMode.earpiece` — Phone earpiece
- `AudioMode.bluetooth` — Bluetooth device
- `AudioMode.headphones` — Wired headphones

## Gotchas

- Audio controls only work during an active session
- `isAudioMuted` reflects the local mute state
- Audio mode changes may not be available on all devices
- Bluetooth audio requires the device to be paired and connected

## Sample App Reference

- `lib/screens/call_screen.dart` — Audio control integration
