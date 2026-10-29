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
| `CometChatCalls.endSession()` | `CallSession.getInstance()?.leave()` |
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
final callSettings = (CallSettingsBuilder()
      ..listener = myV4Listener)
    .build();

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
class MySessionListener extends SessionStatusListeners {
  @override
  void onSessionJoined() {}
  @override
  void onSessionLeft() {}
  @override
  void onConnectionClosed() {}
}

class MyParticipantListener extends ParticipantEventListeners {
  @override
  void onParticipantJoined(Participant participant) {}
  @override
  void onParticipantLeft(Participant participant) {}
}

class MyMediaListener extends MediaEventListeners {
  @override
  void onAudioModeChanged(AudioMode audioMode) {}
}

class MyButtonListener extends ButtonClickListeners {
  @override
  void onLeaveSessionButtonClicked() {}
}
```

## Session Settings

### v4
```dart
final settings = (CallSettingsBuilder()
      ..setAudioOnlyCall = false
      ..enableDefaultLayout = true)
    .build();
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
await CallSession.getInstance()?.leave();
```

## Call Logs

### v4
```dart
final request = (CallLogRequestBuilder()
      ..authToken = authToken) // manually set
    .build();
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
- `CometChatCalls.endSession()` — calls `CallSession.leave()` internally
- `CallSettings` / `CallSettingsBuilder` — converts to `SessionSettings`
- `CometChatCallsEventsListener` — bridged via `V4EventListenerAdapter`

These deprecated APIs will be removed in a future release.

## Upgrading from 5.0.x to 5.1

| 5.0.x | 5.1 |
|-------|-----|
| `CallSession.getInstance()?.leaveSession()` | `CallSession.getInstance()?.leave()` (`leaveSession()` deprecated) |
| `CallSession.getInstance()?.isCallSessionActive()` | `await CallSession.getInstance()?.isSessionActive()` (deprecated) |
| `CometChatCalls.connect(... onSuccess: (String status) {...})` | `onSuccess: (CallSession session) {...}`; the old status is `await session.getPrepareStatus()` |
| `CometChatCalls.endCall(... onSuccess: (EndedCall call) {...})` | `onSuccess: () {...}`; `EndedCall` is removed |
| Ringing through the Chat SDK | `CometChatCalls.initiateCall` / `endCall` / `IncomingCallListener` (see `ringing-integration`) |

Build changes:

- **iOS builds with Swift Package Manager only.** Swift Package Manager is on by default from Flutter 3.44; otherwise run `flutter config --enable-swift-package-manager`. No Podfile or `pod install` step for the Calls SDK.
- **Android apps declare the ongoing call service** inside `<application>`; without it the microphone and camera stop in the background:

```xml
<service
    android:name="com.cometchatcalls.cometchatcalls_plugin.services.OngoingCallService"
    android:exported="false"
    android:foregroundServiceType="microphone|camera" />
```

- **Android Gradle Plugin 8.9.1 or later** (through `connectivity_plus` 7).

## Gotchas

- v4 deprecated APIs still work but are marked `@Deprecated`, so the analyzer warns on them
- `login()` or `loginWithAuthToken()` must be called before using v5 APIs
- v4's `RTCUser` is replaced by `Participant` in v5
- v4's `GenerateToken` is replaced by `CallToken` in v5
- The `listener` property on `CallSettingsBuilder` is deprecated — use focused listeners instead

## Sample App Reference

- This sample app uses the v5 API exclusively
- See `lib/screens/call_screen.dart` for v5 patterns
