---
name: recording
description: Call recording in CometChat Calls SDK v5 Flutter. Start/stop recording, auto-start recording, recording events. Triggers on "recording", "record", "start recording", "stop recording", "auto record".
inclusion: manual
---

# CometChat Calls SDK v5 — Recording (Flutter)

## Overview

Record call sessions — start/stop manually or auto-start when the session begins. Listen for recording state changes.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Manual Recording Control

```dart
final session = CallSession.getInstance();

// Start recording
await session?.startRecording();

// Stop recording
await session?.stopRecording();

// Check state
bool isRecording = session?.isRecording ?? false;
```

### Auto-Start Recording

Configure in session settings:

```dart
final settings = SessionSettingsBuilder()
    .enableAutoStartRecording(true)
    .hideRecordingButton(false)  // Show the recording button
    .build();
```

### Listen for Recording Events

```dart
class MyMediaListener implements MediaEventListeners {
  @override
  void onRecordingStarted() {
    debugPrint("Recording started");
  }

  @override
  void onRecordingStopped() {
    debugPrint("Recording stopped");
  }
}

class MyParticipantListener implements ParticipantEventListeners {
  @override
  void onParticipantStartedRecording(Participant participant) {
    debugPrint("${participant.name} started recording");
  }

  @override
  void onParticipantStoppedRecording(Participant participant) {
    debugPrint("${participant.name} stopped recording");
  }
}
```

### Access Recordings via Call Logs

```dart
final request = CallLogRequestBuilder()
  ..hasRecording = true
  ..build();

request.fetchNext(
  onSuccess: (List<CallLog> logs) {
    for (final log in logs) {
      if (log.recordings != null) {
        for (final recording in log.recordings!) {
          debugPrint("Recording URL: ${recording.url}");
        }
      }
    }
  },
  onError: (e) => debugPrint("Error: ${e.message}"),
);
```

## Gotchas

- Recording requires appropriate plan/permissions on CometChat Dashboard
- `enableAutoStartRecording(true)` starts recording when session begins
- `hideRecordingButton(true)` is the default — set to `false` to show it
- Recordings are available via call logs after the session ends
- Both `MediaEventListeners` and `ParticipantEventListeners` have recording callbacks

## Sample App Reference

- `lib/screens/call_screen.dart` — Recording controls
