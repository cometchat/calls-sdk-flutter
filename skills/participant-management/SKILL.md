---
name: participant-management
description: Manage participants in CometChat Calls SDK v5 Flutter. Participant list, mute participant, pause participant video, pin/unpin, raise/lower hand. Triggers on "participant", "mute participant", "pin", "raise hand", "kick", "participant list".
inclusion: manual
---

# CometChat Calls SDK v5 — Participant Management (Flutter)

## Overview

Manage participants during an active call — view participant list, mute others, pin/unpin video, and raise/lower hand.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Mute a Participant

```dart
final session = CallSession.getInstance();
await session?.muteParticipant("participant_id");
```

### Pause Participant Video

```dart
final session = CallSession.getInstance();
await session?.pauseParticipantVideo("participant_id");
```

### Pin/Unpin Participant

```dart
final session = CallSession.getInstance();

// Pin a participant to the main view
await session?.pinParticipant("participant_id");

// Unpin the currently pinned participant
await session?.unPinParticipant();
```

### Raise/Lower Hand

```dart
final session = CallSession.getInstance();

// Raise hand
await session?.raiseHand();

// Lower hand
await session?.lowerHand();

// Toggle
await session?.toggleRaiseHand();

// Check state
bool isRaised = session?.isHandRaised ?? false;
```

### Listen for Participant Events

```dart
class MyParticipantListener implements ParticipantEventListeners {
  @override
  void onParticipantListChanged(List<Participant> participants) {
    // Full updated participant list
    debugPrint("Participants: ${participants.length}");
  }

  @override
  void onParticipantJoined(Participant participant) {
    debugPrint("${participant.name} joined");
  }

  @override
  void onParticipantLeft(Participant participant) {
    debugPrint("${participant.name} left");
  }

  @override
  void onParticipantAudioMuted(Participant participant) {}

  @override
  void onParticipantAudioUnmuted(Participant participant) {}

  @override
  void onParticipantVideoPaused(Participant participant) {}

  @override
  void onParticipantVideoResumed(Participant participant) {}

  @override
  void onParticipantHandRaised(Participant participant) {
    debugPrint("${participant.name} raised hand");
  }

  @override
  void onParticipantHandLowered(Participant participant) {}

  @override
  void onDominantSpeakerChanged(Participant participant) {}
}
```

### Participant Model

```dart
// Available properties on Participant:
participant.uid        // String? — user ID
participant.name       // String? — display name
participant.avatar     // String? — avatar URL
participant.isAudioMuted  // bool
participant.isVideoPaused // bool
participant.isHandRaised  // bool
```

## Gotchas

- Participant management only works during an active session
- `muteParticipant` and `pauseParticipantVideo` require appropriate permissions
- `pinParticipant(null)` can be used to unpin
- `onParticipantListChanged` fires with the full list on any change
- The local user is included in the participant list

## Sample App Reference

- `lib/screens/call_screen.dart` — Participant interaction
