---
name: join-session
description: Join a CometChat call session using CometChatCalls.joinSession with SessionSettingsBuilder and Widget container. Use when joining calls, configuring session settings, voice vs video calls. Triggers on "join session", "join call", "start call", "SessionSettingsBuilder", "Widget".
inclusion: manual
---

# CometChat Calls SDK v5 — Join Session (Flutter)

## Overview

Join a call session using `CometChatCalls.joinSession()`. Returns a `Widget` that renders the call UI. Supports joining by session ID (token generated internally) or by a pre-generated `CallToken`.

## Prerequisites

- Calls SDK initialized and user logged in
- A valid session ID (from Chat SDK's `Call.sessionId` or your backend)

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Join with Session ID

```dart
final settings = SessionSettingsBuilder()
    .setTitle("Team Meeting")
    .startVideoPaused(false)
    .startAudioMuted(false)
    .build();

CometChatCalls.joinSession(
  sessionId: sessionId,
  sessionSettings: settings,
  onSuccess: (Widget? callWidget) {
    // Navigate to a screen that displays callWidget
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(body: callWidget),
    ));
  },
  onError: (CometChatCallsException e) {
    debugPrint("Failed to join: ${e.message}");
  },
);
```

### Join with Pre-Generated Call Token

```dart
// First generate a token
CometChatCalls.generateCallToken(sessionId,
  onSuccess: (CallToken token) {
    // Then join with the token
    CometChatCalls.joinSession(
      callToken: token,
      sessionSettings: settings,
      onSuccess: (Widget? callWidget) {
        // Display callWidget
      },
      onError: (e) => debugPrint("Join failed: ${e.message}"),
    );
  },
  onError: (e) => debugPrint("Token generation failed: ${e.message}"),
);
```

### Voice Call vs Video Call

```dart
// Video call
final videoSettings = SessionSettingsBuilder()
    .setType(SessionType.video)
    .startVideoPaused(false)
    .startAudioMuted(false)
    .build();

// Voice call
final voiceSettings = SessionSettingsBuilder()
    .setType(SessionType.audio)
    .startVideoPaused(true)
    .startAudioMuted(false)
    .build();
```

### Register Listeners After Joining

```dart
CometChatCalls.joinSession(
  sessionId: sessionId,
  sessionSettings: settings,
  onSuccess: (Widget? callWidget) {
    final session = CallSession.getInstance();
    session?.addSessionStatusListener(myStatusListener);
    session?.addButtonClickListener(myButtonListener);
    // Navigate to call screen
  },
  onError: (e) => debugPrint("Join failed: ${e.message}"),
);
```

### Full Call Screen Example

```dart
class CallScreen extends StatefulWidget {
  final String sessionId;
  const CallScreen({super.key, required this.sessionId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    implements SessionStatusListeners, ButtonClickListeners {
  Widget? _callWidget;

  @override
  void initState() {
    super.initState();
    _joinSession();
  }

  void _joinSession() {
    final settings = SessionSettingsBuilder()
        .setTitle("CometChat Call")
        .startVideoPaused(false)
        .startAudioMuted(false)
        .build();

    CometChatCalls.joinSession(
      sessionId: widget.sessionId,
      sessionSettings: settings,
      onSuccess: (Widget? callWidget) {
        setState(() => _callWidget = callWidget);
        final session = CallSession.getInstance();
        session?.addSessionStatusListener(this);
        session?.addButtonClickListener(this);
      },
      onError: (e) {
        debugPrint("Join failed: ${e.message}");
        Navigator.pop(context);
      },
    );
  }

  @override
  void onSessionLeft() => Navigator.pop(context);

  @override
  void onConnectionClosed() => Navigator.pop(context);

  @override
  void onLeaveSessionButtonClicked() {
    CallSession.getInstance()?.leaveSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _callWidget ?? const Center(child: CircularProgressIndicator()),
    );
  }
}
```

## Gotchas

- `joinSession` returns a `Widget?` — embed it in your widget tree
- Provide exactly one of `sessionId` or `callToken`, not both
- All participants must use the same session ID to join the same call
- Call `joinSession` only after SDK is initialized and user is logged in
- Register listeners in the `onSuccess` callback of `joinSession`

## Sample App Reference

- `lib/screens/call_screen.dart` — Call screen with Widget rendering
- `lib/screens/home_screen.dart` — Session ID input and call initiation
