---
name: session-settings
description: Configure CometChat call session settings using SessionSettingsBuilder. All options for layouts, session type, audio mode, hide buttons, idle timeout, camera facing. Triggers on "session settings", "SessionSettingsBuilder", "layout", "hide button", "audio mode", "idle timeout".
inclusion: manual
---

# CometChat Calls SDK v5 — Session Settings (Flutter)

## Overview

`SessionSettingsBuilder` configures all aspects of a call session — layout, audio mode, session type, button visibility, idle timeout, and more.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## All Builder Options

```dart
final settings = SessionSettingsBuilder()
    // Session metadata
    .setTitle("Team Standup")
    .setDisplayName("John Doe")

    // Session type
    .setType(SessionType.video)          // SessionType.audio or SessionType.video
    .setPeerCall(false)                  // true for 1:1 calls (5.1)

    // Audio/Video start state
    .startVideoPaused(false)
    .startAudioMuted(false)

    // Layout
    .setLayout(LayoutType.tile)          // LayoutType.tile, .sidebar, .spotlight

    // Audio mode
    .setAudioMode(AudioMode.speaker)     // AudioMode.speaker, .earpiece, .bluetooth

    // Camera
    .setInitialCameraFacing(CameraFacing.front) // CameraFacing.front or .rear

    // Idle timeout (seconds)
    .setIdleTimeoutPeriod(300)

    // Low bandwidth mode
    .enableLowBandwidthMode(false)

    // Recording and transcription
    .enableAutoStartRecording(false)
    .enableAutoStartTranscription(false)
    .setCaptionLanguage("en-US")

    // Hide UI elements
    .hideControlPanel(false)
    .hideHeaderPanel(false)
    .hideLeaveSessionButton(false)
    .hideToggleAudioButton(false)
    .hideToggleVideoButton(false)
    .hideRaiseHandButton(false)
    .hideShareInviteButton(true)
    .hideRecordingButton(true)
    .hideScreenSharingButton(false)
    .hideAudioModeButton(false)
    .hideSwitchCameraButton(false)
    .hideParticipantListButton(false)
    .hideChangeLayoutButton(false)
    .hideChatButton(true)
    .hideSessionTimer(false)
    .hideClosedCaptionButton(true)
    .hideTranscriptionButton(true)

    .build();
```

## Common Configurations

### Video Call (Default)

```dart
final settings = SessionSettingsBuilder()
    .setType(SessionType.video)
    .startVideoPaused(false)
    .startAudioMuted(false)
    .build();
```

### Audio-Only Call

```dart
final settings = SessionSettingsBuilder()
    .setType(SessionType.audio)
    .startVideoPaused(true)
    .startAudioMuted(false)
    .hideToggleVideoButton(true)
    .hideSwitchCameraButton(true)
    .build();
```

### Minimal UI (Custom Controls)

```dart
final settings = SessionSettingsBuilder()
    .hideControlPanel(true)
    .hideHeaderPanel(true)
    .build();
```

### 1:1 Call (5.1)

```dart
final settings = SessionSettingsBuilder()
    .setType(SessionType.video)
    .setPeerCall(true) // when one participant leaves, the session ends for both
    .build();
```

### Webinar / Presenter Mode

```dart
final settings = SessionSettingsBuilder()
    .setLayout(LayoutType.spotlight)
    .hideRaiseHandButton(false)
    .hideRecordingButton(false)
    .enableAutoStartRecording(true)
    .build();
```

## Enums Reference

### SessionType
- `SessionType.audio` — Audio-only session
- `SessionType.video` — Video session (default)

### LayoutType
- `LayoutType.tile` — Grid layout (default)
- `LayoutType.sidebar` — Sidebar layout
- `LayoutType.spotlight` — Spotlight/presenter layout

### AudioMode
- `AudioMode.speaker` — Speaker output (default)
- `AudioMode.earpiece` — Earpiece output
- `AudioMode.bluetooth` — Bluetooth output

### CameraFacing
- `CameraFacing.front` — Front camera (default)
- `CameraFacing.rear` — Rear camera

## Gotchas

- `idleTimeoutPeriod` is in seconds (default 300 = 5 minutes)
- `hideShareInviteButton` and `hideRecordingButton` default to `true`
- `hideChatButton`, `hideClosedCaptionButton` and `hideTranscriptionButton` default to `true`
- All other hide options default to `false`
- `setCaptionLanguage` defaults to `"en-US"`
- `enableAutoStartRecording(true)` starts recording when the session begins
- `setPeerCall` defaults to `false`; set it to `true` for 1:1 calls
- Settings are frozen when a session is prepared (`connect`, or `InitiateCallOptions.sessionSettings` for `initiateCall`): the `sessionSettings` passed to the `joinSession` that takes the prepared session over are not used

## Sample App Reference

- `lib/screens/call_screen.dart` — SessionSettings configuration
- `lib/screens/home_screen.dart` — Voice vs video call selection
