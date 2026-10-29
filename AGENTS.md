# CometChat Calls SDK v5 — Flutter

This repository contains the CometChat Calls SDK sample apps for Flutter. When working with this codebase, use the agent skills in the `skills/` directory for SDK-specific guidance.

## Skills

Load the relevant skill based on the task:

### Core
- `skills/setup/SKILL.md` — SDK dependency, CallAppSettings, CometChatCalls.init, permissions
- `skills/join-session/SKILL.md` — CometChatCalls.joinSession, SessionSettingsBuilder, Widget container
- `skills/ringing-integration/SKILL.md` — Calls SDK 5.1 ringing: initiateCall, connect while ringing, joinSession to answer, endCall to decline/cancel, IncomingCallListener
- `skills/session-settings/SKILL.md` — All SessionSettingsBuilder options: layouts, session type, audio mode, hide buttons
- `skills/event-listeners/SKILL.md` — SessionStatus, Participant, Media, ButtonClick, Layout listeners
- `skills/call-logs/SKILL.md` — CallLogRequest, fetching and displaying call history

### Migration
- `skills/migration-v4-to-v5/SKILL.md` — Upgrading from v4 to v5 and from 5.0.x to 5.1, deprecated API mapping

### Advanced
- `skills/recording/SKILL.md` — Auto-start recording, recording events
- `skills/screen-sharing/SKILL.md` — Screen share viewing, presenter status
- `skills/picture-in-picture/SKILL.md` — PiP mode configuration
- `skills/background-handling/SKILL.md` — OngoingCallService declaration (Android), CometChatOngoingCallService, lifecycle management
- `skills/voip-calling/SKILL.md` — VoIP push notifications, injectIncomingCall, CallKit audio (iOS)
- `skills/audio-controls/SKILL.md` — Mute/unmute, audio mode switching
- `skills/video-controls/SKILL.md` — Camera on/off, switch camera
- `skills/participant-management/SKILL.md` — Participant list, mute/kick, raise hand
- `skills/custom-ui/SKILL.md` — Custom control panel, hide default UI, overlay controls
- `skills/in-call-chat/SKILL.md` — In-call messaging during active session

## Key Rules

- SDK available on pub.dev: https://pub.dev/packages/cometchat_calls_sdk — `cometchat_calls_sdk: ^5.1.0`
- `SessionType.audio` / `SessionType.video`
- `LayoutType.tile` / `LayoutType.sidebar` / `LayoutType.spotlight`
- `AudioMode.speaker` / `AudioMode.earpiece` / `AudioMode.bluetooth`
- `CameraFacing.front` / `CameraFacing.rear`
- `joinSession` returns a `Widget?` — embed in widget tree
- `CallSession.getInstance()` for session controls after joining; leave with `leave()` (`leaveSession()` is deprecated)
- Listener classes (`SessionStatusListeners`, `ParticipantEventListeners`, ...) have empty defaults — `extends` them, don't `implements`
- Ringing (5.1): `CometChatCalls.initiateCall` / `connect` / `joinSession` / `endCall(status: EndCallStatus.*)` / `addIncomingCallListener`; no Chat SDK needed. `initiateCall`, `endCall` and the incoming-call APIs are Android and iOS only
- Language: Dart 3.2+, Flutter 3.44+ (Swift Package Manager on by default for iOS)
- Android minSdk 26, Android Gradle Plugin 8.9.1+; the app declares `com.cometchatcalls.cometchatcalls_plugin.services.OngoingCallService` in its manifest
- iOS 15.1+, Swift Package Manager only (no Podfile / `pod install` for the Calls SDK)
- Documentation: https://www.cometchat.com/docs/calls/flutter/overview
