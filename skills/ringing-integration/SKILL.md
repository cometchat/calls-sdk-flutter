---
name: ringing-integration
description: Integrate CometChat Calls SDK with Chat SDK for ringing calls in Flutter. Dual SDK setup, initiateCall, accept/reject/cancel, incoming/outgoing call handling. Triggers on "ringing", "incoming call", "outgoing call", "initiateCall", "accept call", "reject call", "Chat SDK".
inclusion: manual
---

# CometChat Calls SDK v5 — Ringing Integration (Flutter)

## Overview

Ringing calls require both the CometChat Chat SDK (for signaling) and the Calls SDK (for media). The Chat SDK handles call initiation, acceptance, and rejection. The Calls SDK handles the actual audio/video session.

## Prerequisites

- Both Chat SDK and Calls SDK initialized
- User logged in to both SDKs
- Push notifications configured for background call delivery

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
// Chat SDK import depends on your Chat SDK package
```

## Implementation

### 1. Initialize Both SDKs

```dart
// Initialize Chat SDK first
// CometChat.init(...)

// Then initialize Calls SDK
final callsSettings = CallAppSettingsBuilder()
    .setAppId("APP_ID")
    .setRegion("REGION")
    .build();

CometChatCalls.init(callsSettings,
  onSuccess: (_) => debugPrint("Calls SDK ready"),
  onError: (e) => debugPrint("Calls init failed: ${e.message}"),
);
```

### 2. Initiate an Outgoing Call (via Chat SDK)

```dart
// Use Chat SDK to initiate the call
// This sends a call signal to the receiver
// The sessionId from the Chat SDK call object is used to join the Calls SDK session

// Example (Chat SDK API):
// final call = Call(receiverUid: "user123", type: "video");
// CometChat.initiateCall(call, onSuccess: (Call call) {
//   // Show outgoing call UI
//   // call.sessionId is used to join the Calls SDK session
// });
```

### 3. Accept an Incoming Call

```dart
void acceptCall(String sessionId) {
  // Accept via Chat SDK first
  // CometChat.acceptCall(sessionId, onSuccess: (Call call) {
  //   joinCallSession(call.sessionId);
  // });

  joinCallSession(sessionId);
}

void joinCallSession(String sessionId) {
  final settings = SessionSettingsBuilder()
      .setType(SessionType.video)
      .startVideoPaused(false)
      .startAudioMuted(false)
      .build();

  CometChatCalls.joinSession(
    sessionId: sessionId,
    sessionSettings: settings,
    onSuccess: (Widget? callWidget) {
      // Navigate to call screen
    },
    onError: (e) => debugPrint("Join failed: ${e.message}"),
  );
}
```

### 4. Reject an Incoming Call

```dart
void rejectCall(String sessionId) {
  // Reject via Chat SDK
  // CometChat.rejectCall(sessionId, status: "rejected", onSuccess: ...);
}
```

### 5. Cancel an Outgoing Call

```dart
void cancelCall(String sessionId) {
  // Cancel via Chat SDK
  // CometChat.rejectCall(sessionId, status: "cancelled", onSuccess: ...);
}
```

### 6. Listen for Incoming Calls (Chat SDK)

```dart
// Register a call listener with the Chat SDK
// CometChat.addCallListener("unique_listener_id", CallListener(
//   onIncomingCallReceived: (Call call) {
//     // Show incoming call UI
//     showIncomingCallScreen(call.sessionId, call.type);
//   },
//   onOutgoingCallAccepted: (Call call) {
//     // Other party accepted — join the session
//     joinCallSession(call.sessionId);
//   },
//   onOutgoingCallRejected: (Call call) {
//     // Other party rejected — dismiss outgoing UI
//   },
//   onIncomingCallCancelled: (Call call) {
//     // Caller cancelled — dismiss incoming UI
//   },
// ));
```

### 7. End Call and Notify

```dart
void endCall(String sessionId) {
  // Leave the Calls SDK session
  CallSession.getInstance()?.leaveSession();

  // Notify via Chat SDK that call ended
  // CometChat.rejectCall(sessionId, status: "ended", onSuccess: ...);
}
```

## Flow Summary

1. **Outgoing**: Chat SDK `initiateCall` → show outgoing UI → on accepted → Calls SDK `joinSession`
2. **Incoming**: Chat SDK listener `onIncomingCallReceived` → show incoming UI → accept → Calls SDK `joinSession`
3. **End**: Calls SDK `leaveSession` → Chat SDK notify ended

## Gotchas

- The Chat SDK handles signaling (call initiation, acceptance, rejection)
- The Calls SDK handles media (audio/video session)
- Always accept/reject via Chat SDK before joining/leaving Calls SDK session
- The `sessionId` from Chat SDK's `Call` object is the same one used in `CometChatCalls.joinSession`
- Push notifications are needed for incoming calls when app is in background
- Both SDKs must use the same App ID and Region

## Sample App Reference

- This sample app demonstrates standalone calling (without Chat SDK ringing)
- For ringing integration, add the Chat SDK and follow the flow above
