---
name: background-handling
description: Background call handling in CometChat Calls SDK v5 Flutter. Keep calls alive in background, OngoingCallService declaration, CometChatOngoingCallService, lifecycle management. Triggers on "background", "foreground service", "keep alive", "app lifecycle", "background call", "OngoingCallService".
inclusion: manual
---

# CometChat Calls SDK v5 — Background Handling (Flutter)

## Overview

Keep calls alive when the app goes to the background. On Android this needs the plugin's ongoing call service, which **the app declares in its own manifest** from 5.1.0, plus `CometChatOngoingCallService` to start it. On iOS it needs the `audio` background mode.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Platform Configuration

### Android — Declare the Ongoing Call Service

The plugin no longer declares the service, so the app chooses the foreground service types it can justify on Google Play. Add it inside `<application>` in `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <service
        android:name="com.cometchatcalls.cometchatcalls_plugin.services.OngoingCallService"
        android:exported="false"
        android:foregroundServiceType="microphone|camera" />
</application>
```

Without it, calls work only while the app is in the foreground: when the app goes to the background, Android stops the microphone and camera, so the other participants hear and see nothing. Apps upgrading from 5.0.x must add it.

The plugin merges `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MICROPHONE` and `FOREGROUND_SERVICE_CAMERA` into the app manifest. At runtime the service:

- uses `microphone`, and adds `camera` only for video calls — each only when that runtime permission is granted;
- never asks for a type the manifest declaration does not list (declare `microphone` only and a video call gets `microphone` only);
- adds `mediaPlayback` only when the app opts in: list `mediaPlayback` in `android:foregroundServiceType` **and** declare the `FOREGROUND_SERVICE_MEDIA_PLAYBACK` permission. It needs no runtime permission, so a call answered with the microphone denied keeps its notification.

```xml
<!-- Optional opt-in to mediaPlayback -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />

<service
    android:name="com.cometchatcalls.cometchatcalls_plugin.services.OngoingCallService"
    android:exported="false"
    android:foregroundServiceType="microphone|camera|mediaPlayback" />
```

### iOS

Add the `audio` background mode in `Info.plist` so a joined call keeps running in the background:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

Add `voip` only if your app receives PushKit VoIP pushes (see the `voip-calling` skill).

## Implementation

### Start and Stop the Ongoing Call Service

Start the service when the call starts. It shows the "Call in progress" notification with Mute/Unmute and Hang up actions, and tapping it returns to the call:

```dart
void joinAndKeepAlive(String sessionId, bool isVideo) {
  CometChatCalls.joinSession(
    sessionId: sessionId,
    sessionSettings: SessionSettingsBuilder()
        .setType(isVideo ? SessionType.video : SessionType.audio)
        .build(),
    onSuccess: (Widget? callWidget) {
      // Android only; a no-op on iOS and web.
      // isVideo: false keeps the service to the microphone type.
      CometChatOngoingCallService.launch(isVideo: isVideo);
      // Show callWidget.
    },
    onError: (CometChatCallsException e) => debugPrint("Join failed: ${e.message}"),
  );
}

Future<void> stopKeepAlive() async {
  await CometChatOngoingCallService.abort();
}
```

The plugin stops the service by itself when the session is left, closed or timed out, so `abort()` is only needed if you stop it earlier. `launch()` and `abort()` log errors instead of throwing.

### Picture-in-Picture When Leaving the App

On Android the plugin switches the call to the PiP layout when the activity enters PiP and back when the window expands; closing the PiP window keeps the call running with this user's video paused until the app is on screen again. The app only decides when to enter PiP:

```dart
class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.callWidget});
  final Widget callWidget;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Android: inactive arrives while the activity is still visible, which
    // is when Android lets an app enter PiP.
    if (state == AppLifecycleState.inactive) {
      _enterPip();
    }
  }

  Future<void> _enterPip() async {
    final session = CallSession.getInstance();
    if (session != null && await session.isPipSupported()) {
      await session.enterPipMode();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: widget.callWidget);
}
```

The activity needs `android:supportsPictureInPicture="true"` (see the `picture-in-picture` skill).

## Gotchas

- Android: no `OngoingCallService` declaration = no background audio or video. This is the most common 5.1.0 upgrade break
- Android 14+ only lets an app add the microphone or camera service type while it is in the foreground: start the service while the call screen is visible
- Do not call `disablePictureInPictureLayout()` when the app returns to the foreground on Android: the plugin already restores the layout, and that call also turns off entering PiP for the call (`enterPipMode()` then returns `false`) until `enablePictureInPictureLayout()`
- `CometChatOngoingCallService` is Android only; on iOS the `audio` background mode keeps the call alive
- Keep the call widget mounted while the app is in the background: removing it ends the call
- Use `WidgetsBindingObserver` to detect app lifecycle changes

## Sample App Reference

- `lib/screens/call_screen.dart` — Lifecycle handling
