---
name: ringing-integration
description: Ringing calls with CometChat Calls SDK v5 (5.1+) in Flutter. The Calls SDK owns signalling — initiateCall, connect while ringing, joinSession on answer, endCall to decline/cancel, IncomingCallListener for incoming calls. Triggers on "ringing", "incoming call", "outgoing call", "initiateCall", "accept call", "reject call", "decline call", "cancel call", "endCall".
inclusion: manual
---

# CometChat Calls SDK v5 — Ringing Integration (Flutter)

## Overview

From 5.1.0 the Calls SDK owns call signalling as well as media. The Chat SDK is not needed to ring a call.

- **Caller**: `CometChatCalls.initiateCall` tells the receiver the call is ringing and starts preparing the caller's session. The caller joins with `joinSession` once the callee answers.
- **Callee**: the incoming call arrives on an `IncomingCallListener`. `CometChatCalls.connect` prepares the callee's session while it rings, so answering (`joinSession`) is near-instant.
- **Before the join**: `CometChatCalls.endCall` with an `EndCallStatus` declines (`rejected`, `busy`) or withdraws (`cancelled`, `unanswered`) the call.
- **After the join**: `CallSession.getInstance()?.leave()` hangs up.

On Android and iOS each method runs the native Calls SDK method of the same name. `initiateCall`, `endCall`, `injectIncomingCall`/`injectIncomingCallEnded` and incoming calls are **Android and iOS only**; on web they fail with a `platformNotSupported` error.

## Prerequisites

- Calls SDK 5.1.0+ initialized (`CometChatCalls.init`) and a user logged in (`CometChatCalls.login` / `loginWithAuthToken`)
- To ring a device whose app is in the background or killed: push notifications. The Calls SDK does not receive pushes itself — see https://www.cometchat.com/docs/calls/flutter/overview and the `voip-calling` skill

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### 1. Place a Call (Caller)

```dart
void placeCall(String receiverUid) {
  CometChatCalls.initiateCall(
    receiver: receiverUid, // a UID, or a GUID with ReceiverType.group
    options: InitiateCallOptions(
      type: CallType.video, // or CallType.audio
      receiverType: ReceiverType.user,
      sessionSettings: SessionSettingsBuilder()
          .setType(SessionType.video)
          .setPeerCall(true) // 1:1: the call ends for both when one leaves
          .build(),
    ),
    onSuccess: (InitiatedCall call) {
      // The call exists and is ringing. Show the outgoing call screen
      // and keep call.sessionId.
    },
    onError: (CometChatCallsException e) => debugPrint("Call failed: ${e.message}"),
  );
}
```

- `onSuccess` fires as soon as the call exists, before the prepare settles: `getPrepareStatus()` is then `PrepareStatus.pending`.
- The `sessionSettings` in `InitiateCallOptions` are frozen by the prepare; the join that follows uses them.

### 2. Know When the Callee Answers (Caller)

The caller's prepared session reports events on `CallSession` before it is joined. Register the listener before calling `initiateCall`:

```dart
class OutgoingCallListener extends ParticipantEventListeners {
  OutgoingCallListener({required this.onRinging, required this.onAnswered});

  final VoidCallback onRinging;
  final VoidCallback onAnswered;

  // A callee's device has the call and prepared the session: show "Ringing…".
  @override
  void onParticipantConnected(Participant participant) => onRinging();

  // The callee answered: join the session.
  @override
  void onParticipantJoined(Participant participant) => onAnswered();
}

// Register before initiateCall, and remove it when the call screen closes.
void watchOutgoingCall(OutgoingCallListener listener) {
  CallSession.getInstance()?.addParticipantEventListener(listener);
}

void joinAnsweredCall(String sessionId) {
  CometChatCalls.joinSession(
    sessionId: sessionId,
    // Required, but a session prepared by initiateCall keeps its own settings.
    sessionSettings: SessionSettingsBuilder().build(),
    onSuccess: (Widget? callWidget) {
      // Show callWidget and keep it mounted until the call ends.
    },
    onError: (CometChatCallsException e) => debugPrint("Join failed: ${e.message}"),
  );
}
```

A decline is not delivered to the caller as an event. To find out why a ringing call stopped — for example when the prepared session closes (`SessionStatusListeners.onConnectionClosed`) while it still rings — read the call from the server:

```dart
void readCallStatus(String sessionId) {
  CometChatCalls.getCallDetails(sessionId,
    onSuccess: (List<CallLog> logs) {
      final status = logs.isEmpty ? null : logs.first.status;
      // "rejected" or "busy" = the receiver declined.
    },
    onError: (CometChatCallsException e) => debugPrint("Lookup failed: ${e.message}"),
  );
}
```

### 3. Cancel or Time Out (Caller)

Run your own ring timer from `initiateCall`'s `onSuccess`. To give up before the callee answers:

```dart
void stopRinging(String sessionId, {required bool timedOut, required bool isGroup}) {
  CometChatCalls.endCall(
    sessionId: sessionId,
    // No answer on a 1:1 call is "unanswered"; a user cancel, or any group call, is "cancelled".
    status: timedOut && !isGroup ? EndCallStatus.unanswered : EndCallStatus.cancelled,
    onSuccess: () {
      // Close the outgoing call screen.
    },
    onError: (CometChatCallsException e) => debugPrint("End failed: ${e.message}"),
  );
}
```

`endCall` leaves the session first when it is the one in progress, whatever the network result. Its `onSuccess` gets no data (`EndedCall` was removed in 5.1.0).

### 4. Receive an Incoming Call (Callee)

```dart
class IncomingCalls extends IncomingCallListener {
  @override
  void onIncomingCallReceived(InitiatedCall call) async {
    // Already in a call? Decline as busy instead of preparing this one:
    // a connect() with a different session ID replaces the current prepare.
    final state = await CometChatCalls.getSessionState();
    if (state != SessionState.idle) {
      CometChatCalls.endCall(
        sessionId: call.sessionId,
        status: EndCallStatus.busy,
        onSuccess: () {},
        onError: (CometChatCallsException e) {},
      );
      return;
    }

    // Show the incoming call UI: call.callerName, call.sender, call.isVideo.

    // Prepare the session while it rings. Calling connect again with the
    // same session ID reuses the prepare.
    CometChatCalls.connect(
      sessionId: call.sessionId,
      sessionSettings: SessionSettingsBuilder()
          .setType(call.isVideo ? SessionType.video : SessionType.audio)
          .setPeerCall(call.isPeerCall)
          .build(),
      onSuccess: (CallSession session) {},
      onError: (CometChatCallsException e) => debugPrint("Prepare failed: ${e.message}"),
    );
  }

  @override
  void onIncomingCallEnded(InitiatedCall call, String reason) {
    // The call stopped ringing here: cancelled by the caller, answered on
    // another device, timed out... Dismiss the incoming call UI.
  }
}

void registerIncomingCalls() {
  CometChatCalls.addIncomingCallListener("incoming_calls", IncomingCalls());
}
```

Incoming calls reach `IncomingCallListener` only when they are handed to the SDK with `CometChatCalls.injectIncomingCall` (and their end with `injectIncomingCallEnded`). That is the job of the layer that receives the call push; the Calls SDK does not detect incoming calls on its own. See the `voip-calling` skill.

### 5. Answer or Decline (Callee)

```dart
void answer(InitiatedCall call) {
  CometChatCalls.joinSession(
    sessionId: call.sessionId,
    sessionSettings: SessionSettingsBuilder().build(), // the prepared settings win
    onSuccess: (Widget? callWidget) {
      // Show callWidget and keep it mounted until the call ends.
    },
    onError: (CometChatCallsException e) => debugPrint("Join failed: ${e.message}"),
  );
}

void decline(InitiatedCall call) {
  CometChatCalls.endCall(
    sessionId: call.sessionId,
    status: EndCallStatus.rejected, // the default
    onSuccess: () {},
    onError: (CometChatCallsException e) => debugPrint("Decline failed: ${e.message}"),
  );
}
```

### 6. Hang Up (Either Side, After the Join)

```dart
Future<void> hangUp() async {
  await CallSession.getInstance()?.leave();
}
```

With `setPeerCall(true)` the session ends for both participants when one leaves.

## Flow Summary

1. **Outgoing**: `initiateCall` → outgoing UI → `onParticipantConnected` (ringing) → `onParticipantJoined` (answered) → `joinSession`
2. **Incoming**: push layer → `injectIncomingCall` → `IncomingCallListener.onIncomingCallReceived` → `connect` → answer = `joinSession`, decline = `endCall(rejected)`
3. **Give up**: caller `endCall(cancelled)` or `endCall(unanswered)`
4. **End**: `CallSession.leave()`

## Gotchas

- `CometChatCalls.endCall` is for calls that are not joined yet; after the join, use `CallSession.leave()`
- `EndCallStatus`, `CallType`, `ReceiverType`, `SessionState` and `PrepareStatus` are string constants (`EndCallStatus.rejected == 'rejected'`)
- `getActiveSession()` returns the session while one is preparing, prepared, joining or joined; `getSessionState()` returns `idle`, `preparing`, `prepared`, `joining` or `joined`
- `onIncomingCallEnded`'s `reason` differs per platform: Android sends `cancelled`, `rejected`, `busy`, `ended`, `unanswered` or `ongoing` (answered on another device); iOS sends `answered`, `answeredElsewhere`, `cancelled`, `declined`, `timedOut`, `remoteEnded`, `failed` or `filtered`
- `CometChatCalls.connect` reports a `CallSession` (5.1.0); the old string status is `session.getPrepareStatus()`
- A cancelled prepare (a `leave()` before it completed) still succeeds, with `getPrepareStatus()` reporting `cancelled`
- Register `CallSession` listeners before `initiateCall` or `connect`: `onConnected` and `onParticipantConnected` fire before any join
- `CallSession` is a singleton and its listeners stay registered across calls: remove them when the call screen closes
- Register the `IncomingCallListener` once, after `init`; registering the same listener ID again replaces it
- On web, use `connect` + `joinSession` with a session ID you share yourself; there is no ringing

## Sample App Reference

- This sample app demonstrates standalone calling (joining a session by ID), without ringing
- Package documentation: https://www.cometchat.com/docs/calls/flutter/overview
