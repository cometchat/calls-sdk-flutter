# CometChat Calls SDK v5 — Flutter Skills

Agent skills for building with the CometChat Calls SDK v5 on Flutter. Install individually or browse all available skills.

## How It Works

Skills are bundled in this repository under `skills/`. When you clone the repo and open it in a supported AI coding assistant, skills auto-trigger based on what you're doing — mention "join session" and the join-session skill loads, ask about "VoIP calling" and the voip-calling skill loads. No manual activation needed.

To use these skills in your own project, copy the `skills/` folder into your project root:

```bash
cp -r skills/ /path/to/your/project/skills/
```

## Available Skills

### Core

| Skill | Triggers On |
|-------|-------------|
| `setup` | SDK dependency, CallAppSettings, CometChatCalls.init, permissions |
| `join-session` | CometChatCalls.joinSession, SessionSettingsBuilder, Widget container |
| `ringing-integration` | initiateCall, connect while ringing, joinSession to answer, endCall to decline/cancel, IncomingCallListener |
| `session-settings` | All SessionSettingsBuilder options: layouts, session type, audio mode, hide buttons |
| `event-listeners` | SessionStatusListeners, ParticipantEventListeners, MediaEventListeners, ButtonClickListeners, LayoutListeners |
| `call-logs` | CallLogRequest, fetching and displaying call history |

### Migration

| Skill | Triggers On |
|-------|-------------|
| `migration-v4-to-v5` | Upgrading from Calls SDK v4 to v5, replacing deprecated APIs, CallSettings to SessionSettings |

### Advanced

| Skill | Triggers On |
|-------|-------------|
| `recording` | Auto-start recording, recording events |
| `screen-sharing` | Screen share viewing, presenter status |
| `picture-in-picture` | PiP mode configuration |
| `background-handling` | Background modes, OngoingCallService declaration, CometChatOngoingCallService, keeping calls alive |
| `voip-calling` | VoIP push notifications, injectIncomingCall, CallKit audio (iOS), killed-state ringing |
| `audio-controls` | Mute/unmute, audio mode switching |
| `video-controls` | Camera on/off, switch camera |
| `participant-management` | Participant list, mute/kick, raise hand |
| `custom-ui` | Custom control panel, layout customization |
| `in-call-chat` | In-call messaging during active session |

## How Auto-Detection Works

Each skill has a `description` field in its YAML frontmatter that lists trigger keywords. When you mention something related (like "join a call" or "add VoIP support"), the agent reads the description, decides the skill is relevant, and loads its full content. You never need to manually select a skill.

## Compatibility

- CometChat Calls SDK v5 (5.1.0+)
- The Chat SDK is not required: from 5.1 the Calls SDK rings calls itself. Apps that also use the Chat SDK v4 on iOS need `CometChatSDK` 4.1.3+
- Flutter 3.44+ (Swift Package Manager on by default), Dart 3.2+
- Android minSdk 26, Android Gradle Plugin 8.9.1+
- iOS 15.1+, Swift Package Manager only (on by default from Flutter 3.44), Xcode 26.1.1 or later
- Available on pub.dev: https://pub.dev/packages/cometchat_calls_sdk
- Works with: Kiro, Claude Code, Cursor, Copilot, and other AI coding assistants that support the skills ecosystem
