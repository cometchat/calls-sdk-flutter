---
name: migration-v4-to-v5
description: Migrate from CometChat Calls SDK v4 to v5 in Flutter. Replace deprecated APIs, CallSettings to SessionSettings, CometChatCallsEventsListener to v5 listeners. Triggers on "migration", "upgrade", "v4 to v5", "deprecated", "CallSettings", "CometChatCallsEventsListener".
inclusion: manual
---

# CometChat Calls SDK v5 — Migration Guide (v4 → v5, Flutter)

## Overview

The v5 SDK introduces a new API surface while maintaining backward compatibility with v4 APIs (marked as deprecated). This guide covers the key changes.

## Key Changes

| v4 API | v5 API |
|--------|--------|
| `CometChatCalls.generateToken(sessionId, authToken)` | `CometChatCalls.generateCallToken(sessionId)` |
| `CometChatCalls.startSession(token, callSettings)` | `CometChatCalls.joinSession(callToken: token, sessionSettings: settings)` |
| `CometChatCalls.endSession()` | `CallSession.getInstance()?.leaveSession()` |
| `CallSettings` / `CallSettingsBuilder` | `SessionSettings` / `SessionSettingsBuilder` |
| `CometChatCallsEventsListener` (single mixin) | 5 focused listeners |
| Auth token passed manually | Auth token managed internally after `login()` |

## Authentication

### v4
```dart
// Auth token passed to every API call
CometChatCalls.generateToken(sessionId, authToken,
  onSuccess: (GenerateToken token) { ... },
  onError: (e) { ... },
);
```

### v5
```dart
// Login once — auth token managed internally
CometChatCalls.login(uid: "user_uid", authKey: "AUTH_KEY",
  onSuccess: (User? user) { ... },
  onError: (e) { ... },
);

// Then generate token without passing auth token
CometChatCalls.generateCallToken(sessionId,
  onSuccess: (CallToken token) { ... },
  onError: (e) { ... },
);
```

## Joining a Session

### v4
```dart
final callSettings = CallSettingsBuilder()
  ..listener = myV4Listener
  ..build();

CometChatCalls.startSession(tokenString, callSettings,
  onSuccess: (Widget? widget) { ... },
  onError: (e) { ... },
);
```

### v5
```dart
final settings = SessionSettingsBuilder()
    .setTitle("Meeting")
    .startVideoPaused(false)
    .build();

CometChatCalls.joinSession(
  sessionId: sessionId,  // or callToken: token
  sessionSettings: settings,
  onSuccess: (Widget? widget) {
    // Register listeners
    final session = CallSession.getInstance();
    session?.addSessionStatusListener(myListener);
  },
  onError: (e) { ... },
);
```

## Event Listeners

### v4 (Single Mixin)
```dart
class MyListener with CometChatCallsEventsListener {
  @override
  void onCallEnded() {}
  @override
  void onCallEndButtonPressed() {}
  @override
  void onUserJoined(RTCUser user) {}
  @override
  void onUserLeft(RTCUser user) {}
  @override
  void onAudioModeChanged(List<AudioMode> devices) {}
  // ... all in one class
}
```

### v5 (Focused Listeners)
```dart
class MySessionListener implements SessionStatusListeners {
  @override
  void onSessionJoined() {}
  @override
  void onSessionLeft() {}
  @override
  void onConnectionClosed() {}
}

class MyParticipantListener implements ParticipantEventListeners {
  @override
  void onParticipantJoined(Participant participant) {}
  @override
  void onParticipantLeft(Participant participant) {}
}

class MyMediaListener implements MediaEventListeners {
  @override
  void onAudioModeChanged(AudioMode audioMode) {}
}

class MyButtonListener implements ButtonClickListeners {
  @override
  void onLeaveSessionButtonClicked() {}
}
```

## Session Settings

### v4
```dart
final settings = CallSettingsBuilder()
  ..setType("VIDEO")
  ..build();
```

### v5
```dart
final settings = SessionSettingsBuilder()
    .setType(SessionType.video)
    .setLayout(LayoutType.tile)
    .setAudioMode(AudioMode.speaker)
    .build();
```

## Ending a Session

### v4
```dart
CometChatCalls.endSession(
  onSuccess: (msg) { ... },
  onError: (e) { ... },
);
```

### v5
```dart
await CallSession.getInstance()?.leaveSession();
```

## Call Logs

### v4
```dart
final builder = CallLogRequestBuilder()
  ..authToken = authToken  // manually set
  ..build();
```

### v5
```dart
// Auth token resolved internally after login()
final request = CallLogRequestBuilder().build();
request.fetchNext(
  onSuccess: (logs) { ... },
  onError: (e) { ... },
);
```

## Backward Compatibility

The v5 SDK includes deprecated v4 APIs that still work:
- `CometChatCalls.generateToken()` — calls `generateCallToken` internally
- `CometChatCalls.startSession()` — calls `joinSession` internally
- `CometChatCalls.endSession()` — calls `leaveSession` internally
- `CallSettings` / `CallSettingsBuilder` — converts to `SessionSettings`
- `CometChatCallsEventsListener` — bridged via `V4EventListenerAdapter`

These deprecated APIs will be removed in a future release.

## Gotchas

- v4 deprecated APIs still work but log deprecation warnings
- `login()` or `loginWithAuthToken()` must be called before using v5 APIs
- v4's `RTCUser` is replaced by `Participant` in v5
- v4's `GenerateToken` is replaced by `CallToken` in v5
- The `listener` property on `CallSettingsBuilder` is deprecated — use focused listeners instead

## Sample App Reference

- This sample app uses the v5 API exclusively
- See `lib/screens/call_screen.dart` for v5 patterns
