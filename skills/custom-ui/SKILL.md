---
name: custom-ui
description: Custom UI for CometChat Calls SDK v5 Flutter. Custom control panel, hide default UI, build your own call controls. Triggers on "custom ui", "custom controls", "hide control panel", "custom layout", "overlay", "custom buttons".
inclusion: manual
---

# CometChat Calls SDK v5 — Custom UI (Flutter)

## Overview

Build custom call controls by hiding the default SDK UI and using `CallSession` methods programmatically. Overlay your own Flutter widgets on top of the call view.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Hide Default UI

```dart
final settings = SessionSettingsBuilder()
    .hideControlPanel(true)    // Hide bottom control bar
    .hideHeaderPanel(true)     // Hide top header
    .build();
```

### Custom Control Panel

```dart
class CustomCallScreen extends StatefulWidget {
  final String sessionId;
  const CustomCallScreen({super.key, required this.sessionId});

  @override
  State<CustomCallScreen> createState() => _CustomCallScreenState();
}

class _CustomCallScreenState extends State<CustomCallScreen> {
  Widget? _callWidget;
  bool _isMuted = false;
  bool _isVideoOff = false;
  late final _statusListener = _CallEndedListener(() {
    if (mounted) Navigator.pop(context);
  });

  @override
  void initState() {
    super.initState();
    _joinSession();
  }

  void _joinSession() {
    final settings = SessionSettingsBuilder()
        .hideControlPanel(true)
        .hideHeaderPanel(true)
        .build();

    CometChatCalls.joinSession(
      sessionId: widget.sessionId,
      sessionSettings: settings,
      onSuccess: (Widget? callWidget) {
        setState(() => _callWidget = callWidget);
        CallSession.getInstance()?.addSessionStatusListener(_statusListener);
      },
      onError: (CometChatCallsException e) => Navigator.pop(context),
    );
  }

  @override
  void dispose() {
    CallSession.getInstance()?.removeSessionStatusListener(_statusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Call video view
          if (_callWidget != null) _callWidget!,

          // Custom controls overlay
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                FloatingActionButton(
                  onPressed: _toggleMute,
                  backgroundColor: _isMuted ? Colors.red : Colors.white,
                  child: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                ),

                // End call button
                FloatingActionButton(
                  onPressed: _endCall,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),

                // Video toggle button
                FloatingActionButton(
                  onPressed: _toggleVideo,
                  backgroundColor: _isVideoOff ? Colors.red : Colors.white,
                  child: Icon(_isVideoOff ? Icons.videocam_off : Icons.videocam),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMute() async {
    final session = CallSession.getInstance();
    await session?.toggleMuteAudio();
    setState(() => _isMuted = session?.isAudioMuted ?? false);
  }

  void _toggleVideo() async {
    final session = CallSession.getInstance();
    await session?.togglePauseVideo();
    setState(() => _isVideoOff = session?.isVideoPaused ?? false);
  }

  void _endCall() async {
    // leave() fires onSessionLeft, which closes the screen.
    await CallSession.getInstance()?.leave();
  }
}

class _CallEndedListener extends SessionStatusListeners {
  _CallEndedListener(this.onEnded);

  final VoidCallback onEnded;

  @override
  void onSessionLeft() => onEnded();

  @override
  void onConnectionClosed() => onEnded();
}
```

### Selectively Hide Buttons

```dart
// Hide specific buttons while keeping the control panel
final settings = SessionSettingsBuilder()
    .hideRaiseHandButton(true)
    .hideShareInviteButton(true)
    .hideRecordingButton(true)
    .hideChangeLayoutButton(true)
    .hideChatButton(true)
    // Keep these visible:
    // hideToggleAudioButton(false)
    // hideToggleVideoButton(false)
    // hideLeaveSessionButton(false)
    .build();
```

## Gotchas

- The call `Widget` must remain in the widget tree for the call to stay active
- Use `Stack` to overlay custom controls on top of the call widget
- `CallSession` methods work regardless of whether the default UI is visible
- Always handle `onSessionLeft` and `onConnectionClosed` to clean up
- Leave with `CallSession.leave()`; `leaveSession()` is deprecated since 5.1.0
- Custom UI state (muted, video off) should be synced with `CallSession` state

## Sample App Reference

- `lib/screens/call_screen.dart` — Default call screen (can be customized)
