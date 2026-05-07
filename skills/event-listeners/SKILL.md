---
name: event-listeners
description: CometChat Calls SDK v5 event listeners for Flutter. SessionStatusListeners, ParticipantEventListeners, MediaEventListeners, ButtonClickListeners, LayoutListeners. Triggers on "listener", "event", "callback", "onSessionJoined", "onParticipantJoined", "onAudioModeChanged".
inclusion: manual
---

# CometChat Calls SDK v5 — Event Listeners (Flutter)

## Overview

The SDK provides 5 focused listener protocols for different event categories. Register them on `CallSession.getInstance()` after joining a session.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Listener Types

### 1. SessionStatusListeners

Session lifecycle and connection events:

```dart
class MySessionListener implements SessionStatusListeners {
  @override
  void onSessionJoined() {}

  @override
  void onSessionLeft() {}

  @override
  void onConnectionLost() {}

  @override
  void onConnectionRestored() {}

  @override
  void onConnectionClosed() {}

  @override
  void onSessionTimedOut() {}
}
```

### 2. ParticipantEventListeners

Participant join/leave and state changes:

```dart
class MyParticipantListener implements ParticipantEventListeners {
  @override
  void onParticipantListChanged(List<Participant> participants) {}

  @override
  void onParticipantJoined(Participant participant) {}

  @override
  void onParticipantLeft(Participant participant) {}

  @override
  void onParticipantAudioMuted(Participant participant) {}

  @override
  void onParticipantAudioUnmuted(Participant participant) {}

  @override
  void onParticipantVideoPaused(Participant participant) {}

  @override
  void onParticipantVideoResumed(Participant participant) {}

  @override
  void onParticipantHandRaised(Participant participant) {}

  @override
  void onParticipantHandLowered(Participant participant) {}

  @override
  void onParticipantStartedScreenShare(Participant participant) {}

  @override
  void onParticipantStoppedScreenShare(Participant participant) {}

  @override
  void onParticipantStartedRecording(Participant participant) {}

  @override
  void onParticipantStoppedRecording(Participant participant) {}

  @override
  void onDominantSpeakerChanged(Participant participant) {}
}
```

### 3. MediaEventListeners

Local media state changes:

```dart
class MyMediaListener implements MediaEventListeners {
  @override
  void onRecordingStarted() {}

  @override
  void onRecordingStopped() {}

  @override
  void onScreenShareStarted() {}

  @override
  void onScreenShareStopped() {}

  @override
  void onAudioModeChanged(AudioMode audioMode) {}

  @override
  void onCameraFacingChanged(CameraFacing facing) {}

  @override
  void onAudioMuted() {}

  @override
  void onAudioUnMuted() {}

  @override
  void onVideoPaused() {}

  @override
  void onVideoResumed() {}
}
```

### 4. ButtonClickListeners

UI button interaction events:

```dart
class MyButtonListener implements ButtonClickListeners {
  @override
  void onLeaveSessionButtonClicked() {}

  @override
  void onRaiseHandButtonClicked() {}

  @override
  void onShareInviteButtonClicked() {}

  @override
  void onChangeLayoutButtonClicked() {}

  @override
  void onParticipantListButtonClicked() {}

  @override
  void onToggleAudioButtonClicked() {}

  @override
  void onToggleVideoButtonClicked() {}

  @override
  void onSwitchCameraButtonClicked() {}

  @override
  void onRecordingToggleButtonClicked() {}

  @override
  void onChatButtonClicked() {}
}
```

### 5. LayoutListeners

Layout change events:

```dart
class MyLayoutListener implements LayoutListeners {
  @override
  void onCallLayoutChanged(LayoutType layoutType) {}

  @override
  void onParticipantListVisible() {}

  @override
  void onParticipantListHidden() {}

  @override
  void onPictureInPictureLayoutEnabled() {}

  @override
  void onPictureInPictureLayoutDisabled() {}
}
```

## Registration

Register listeners after joining a session:

```dart
CometChatCalls.joinSession(
  sessionId: sessionId,
  sessionSettings: settings,
  onSuccess: (Widget? widget) {
    final session = CallSession.getInstance();
    session?.addSessionStatusListener(mySessionListener);
    session?.addParticipantEventListener(myParticipantListener);
    session?.addMediaEventsListener(myMediaListener);
    session?.addButtonClickListener(myButtonListener);
    session?.layoutListener = myLayoutListener;
  },
  onError: (e) => debugPrint("Error: ${e.message}"),
);
```

## Removal

Remove listeners when done:

```dart
final session = CallSession.getInstance();
session?.removeSessionStatusListener(mySessionListener);
session?.removeParticipantEventListener(myParticipantListener);
session?.removeMediaEventsListener(myMediaListener);
session?.removeButtonClickListener(myButtonListener);
session?.layoutListener = null;

// Or clear all at once
session?.clearAllListeners();
```

## Gotchas

- Register listeners in the `onSuccess` callback of `joinSession`
- A class can implement multiple listener interfaces
- `LayoutListeners` uses a setter (single listener), not add/remove
- All listener methods have default empty implementations — override only what you need
- Use `setState()` for UI updates from listener callbacks

## Sample App Reference

- `lib/screens/call_screen.dart` — Listener registration and handling
