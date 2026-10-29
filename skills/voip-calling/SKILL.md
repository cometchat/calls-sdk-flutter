---
name: voip-calling
description: VoIP push notifications and system call integration for CometChat Calls SDK v5 Flutter. Ringing in the background or killed state, handing pushed calls to the SDK (injectIncomingCall), CallKit audio on iOS. Triggers on "voip", "VoIP", "push notification", "CallKit", "ConnectionService", "killed state", "incoming call notification".
inclusion: manual
---

# CometChat Calls SDK v5 — VoIP Calling (Flutter)

## Overview

Ringing a device whose app is in the background or killed needs push notifications: FCM on Android, PushKit VoIP pushes and CallKit on iOS. The Calls SDK does not receive pushes itself. For the push setup, see the CometChat docs: https://www.cometchat.com/docs/calls/flutter/overview

What the Calls SDK (5.1+) provides for the layer that receives the call push:

- `CometChatCalls.injectIncomingCall(payload)` — hands a ringing call to the SDK from the push's data payload. Registered `IncomingCallListener`s get `onIncomingCallReceived`.
- `CometChatCalls.injectIncomingCallEnded(payload, reason)` — tells the SDK the ringing call ended before it was joined. Listeners get `onIncomingCallEnded`.
- `CometChatCalls.connect` (prepare while ringing), `joinSession` (answer), `endCall` (decline) — see the `ringing-integration` skill.
- iOS: `setCallKitAudioEnabled`, `notifyCallKitAudioActivated` and `notifyCallKitAudioDeactivated`, for apps that report calls to CallKit.

These are Android and iOS only.

## Prerequisites

- Calls SDK 5.1.0+ initialized and a user logged in when the push is handled
- Push notifications configured for your CometChat app (FCM for Android, APNs/PushKit for iOS)

## Implementation

### Hand a Pushed Call to the SDK

The injection methods are meant for the push notifications layer, not for app UI code. `payload` is the call push's data, as a `Map<String, String>`:

```dart
Future<void> onCallPush(Map<String, String> payload) async {
  final call = await CometChatCalls.injectIncomingCall(payload);
  if (call == null) return; // the payload has no session ID
  // IncomingCallListener.onIncomingCallReceived(call) fires.
}

Future<void> onCallEndedPush(Map<String, String> payload, String reason) async {
  await CometChatCalls.injectIncomingCallEnded(payload, reason);
  // IncomingCallListener.onIncomingCallEnded(call, reason) fires.
}
```

Both throw a `CometChatCallsException` on failure, and `platformNotSupported` on web.

### Handle the Incoming Call

```dart
class IncomingCalls extends IncomingCallListener {
  @override
  void onIncomingCallReceived(InitiatedCall call) {
    // call.sessionId, call.sender, call.callerName, call.callerAvatarUrl,
    // call.isVideo, call.isPeerCall. Show the incoming call UI, then prepare:
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
    // Dismiss the incoming call UI.
  }
}

void registerIncomingCalls() {
  CometChatCalls.addIncomingCallListener("incoming_calls", IncomingCalls());
}
```

Answer with `joinSession(sessionId: call.sessionId, ...)`; decline with `endCall(sessionId: call.sessionId, status: EndCallStatus.rejected, ...)`.

### iOS — CallKit Audio

When your app reports calls to CallKit itself (its own `CXProvider`, in native code or through a CallKit plugin), let CallKit own the audio session and forward its activation to the SDK:

```dart
Future<void> useCallKitAudio() async {
  // iOS only; throws platformNotSupported elsewhere. Off by default.
  await CometChatCalls.setCallKitAudioEnabled(true);
}

// Forward from your CXProvider delegate:
//   provider(_:didActivate:)   -> CometChatCalls.notifyCallKitAudioActivated()
//   provider(_:didDeactivate:) -> CometChatCalls.notifyCallKitAudioDeactivated()
Future<void> onCallKitAudioActivated() => CometChatCalls.notifyCallKitAudioActivated();
Future<void> onCallKitAudioDeactivated() => CometChatCalls.notifyCallKitAudioDeactivated();
```

With it enabled, WebRTC starts audio only once CallKit activates the audio session. The two `notify` methods do nothing on Android and web.

Background modes in `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
    <string>remote-notification</string>
</array>
```

`voip` is for PushKit VoIP pushes and `remote-notification` for regular pushes; both matter only to the layer that receives them. `audio` keeps a joined call running in the background.

### Android

- Declare the ongoing call service so a call keeps its microphone and camera in the background (see the `setup` and `background-handling` skills).
- Android 13+ needs the `POST_NOTIFICATIONS` runtime permission to show notifications.
- The plugin removes `MANAGE_OWN_CALLS` from the merged manifest: it backs a Telecom `ConnectionService` in the native SDK that is never registered or called.

## Gotchas

- The Calls SDK does not detect incoming calls on its own: without something calling `injectIncomingCall`, `IncomingCallListener` never fires
- The SDK must be initialized and the user logged in before a pushed call is prepared or joined; on a cold start from a push, run `init` and `login` first
- `onIncomingCallEnded`'s `reason` differs between Android and iOS (see `IncomingCallListener`)
- iOS requires a VoIP push certificate or key from the Apple Developer Portal for PushKit
- Test push and killed-state ringing on real devices

## Sample App Reference

- This sample demonstrates standalone calling without VoIP
- Push notification setup: https://www.cometchat.com/docs/calls/flutter/overview
