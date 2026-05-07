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

    // Audio/Video start state
    .startVideoPaused(false)
    .startAudioMuted(false)

    // Layout
    .setLayout(LayoutType.tile)          // LayoutType.tile, .sidebar, .spotlight

    // Audio mode
    .setAudioMode(AudioMode.speaker)     // AudioMode.speaker, .earpiece, .bluetooth, .headphones

    // Camera
    .setInitialCameraFacing(CameraFacing.front) // CameraFacing.front or .back

    // Idle timeout (seconds)
    .setIdleTimeoutPeriod(300)

    // Low bandwidth mode
    .enableLowBandwidthMode(false)

    // Recording
    .enableAutoStartRecording(false)

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
- `AudioMode.headphones` — Wired headphones

### CameraFacing
- `CameraFacing.front` — Front camera (default)
- `CameraFacing.back` — Rear camera

## Gotchas

- `idleTimeoutPeriod` is in seconds (default 300 = 5 minutes)
- `hideShareInviteButton` and `hideRecordingButton` default to `true`
- `hideChatButton` defaults to `true`
- All other hide options default to `false`
- `enableAutoStartRecording(true)` starts recording when the session begins

## Sample App Reference

- `lib/screens/call_screen.dart` — SessionSettings configuration
- `lib/screens/home_screen.dart` — Voice vs video call selection
