---
name: voip-calling
description: VoIP push notifications and system call integration for CometChat Calls SDK v5 Flutter. CallKit (iOS), ConnectionService (Android), push notifications. Triggers on "voip", "VoIP", "push notification", "CallKit", "ConnectionService", "incoming call notification".
inclusion: manual
---

# CometChat Calls SDK v5 — VoIP Calling (Flutter)

## Overview

VoIP calling enables system-level call integration — incoming call notifications even when the app is killed, native call UI on iOS (CallKit), and ConnectionService on Android.

## Prerequisites

- Both Chat SDK and Calls SDK initialized
- Push notification service configured (FCM for Android, APNs/PushKit for iOS)
- VoIP certificate (iOS) or FCM server key (Android)

## Implementation

### iOS — CallKit Integration

The native iOS SDK handles CallKit automatically when configured. Add to `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
    <string>remote-notification</string>
</array>
```

### Android — ConnectionService

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.MANAGE_OWN_CALLS" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Push Notification Handling

When a push notification arrives for an incoming call:

```dart
// 1. Parse the push payload to extract call data
// 2. Show incoming call UI (or trigger system call UI)
// 3. On accept: initialize SDK if needed, login, then joinSession

void handleIncomingCallPush(Map<String, dynamic> payload) {
  final sessionId = payload['sessionId'];
  final callerName = payload['callerName'];
  final callType = payload['callType']; // "audio" or "video"

  // Show your incoming call screen
  showIncomingCallScreen(
    sessionId: sessionId,
    callerName: callerName,
    callType: callType,
  );
}

void acceptCallFromPush(String sessionId, String callType) async {
  // Ensure SDK is initialized and user is logged in
  // Then join the session
  final settings = SessionSettingsBuilder()
      .setType(callType == "audio" ? SessionType.audio : SessionType.video)
      .build();

  CometChatCalls.joinSession(
    sessionId: sessionId,
    sessionSettings: settings,
    onSuccess: (Widget? widget) {
      // Navigate to call screen
    },
    onError: (e) => debugPrint("Join failed: ${e.message}"),
  );
}
```

## Platform-Specific Packages

Consider using these Flutter packages for VoIP integration:

- `flutter_callkit_incoming` — Show native incoming call UI on both platforms
- `firebase_messaging` — FCM push notifications
- `flutter_voip_push_notification` — iOS VoIP push handling

## Gotchas

- VoIP push notifications require server-side configuration
- iOS requires a VoIP certificate from Apple Developer Portal
- Android 13+ requires `POST_NOTIFICATIONS` runtime permission
- The SDK must be initialized before joining a session from a push notification
- CallKit on iOS shows the native green phone UI for incoming calls
- Test VoIP on real devices — simulators don't support push notifications

## Sample App Reference

- This sample demonstrates standalone calling without VoIP
- For VoIP integration, add push notification handling and system call UI
