---
name: in-call-chat
description: In-call chat messaging during active CometChat call session in Flutter. Chat button, unread count badge. Triggers on "in-call chat", "chat button", "messaging during call", "unread count", "in call message".
inclusion: manual
---

# CometChat Calls SDK v5 — In-Call Chat (Flutter)

## Overview

Enable in-call messaging so participants can send text messages during an active call session. The SDK provides a built-in chat button and unread count badge.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Show Chat Button

```dart
final settings = SessionSettingsBuilder()
    .hideChatButton(false)  // Show the chat button (hidden by default)
    .build();
```

### Set Unread Count Badge

```dart
final session = CallSession.getInstance();
await session?.setChatButtonUnreadCount(5);
```

### Listen for Chat Button Click

```dart
class MyButtonListener implements ButtonClickListeners {
  @override
  void onChatButtonClicked() {
    // Open your custom chat UI or handle the event
    debugPrint("Chat button clicked");
  }
}
```

### Custom Chat Integration

```dart
class CallScreenWithChat extends StatefulWidget {
  @override
  State<CallScreenWithChat> createState() => _CallScreenWithChatState();
}

class _CallScreenWithChatState extends State<CallScreenWithChat>
    implements ButtonClickListeners {
  bool _showChat = false;

  @override
  void onChatButtonClicked() {
    setState(() => _showChat = !_showChat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Call widget here
          if (_showChat)
            Positioned(
              bottom: 80,
              right: 16,
              left: 16,
              height: 300,
              child: Card(
                child: YourChatWidget(sessionId: "..."),
              ),
            ),
        ],
      ),
    );
  }
}
```

## Gotchas

- `hideChatButton` defaults to `true` — you must explicitly set it to `false`
- The built-in chat uses the session's messaging channel
- Use `setChatButtonUnreadCount` to show a badge on the chat button
- For custom chat UI, listen for `onChatButtonClicked` and show your own widget
- In-call chat messages are separate from regular Chat SDK messages

## Sample App Reference

- `lib/screens/call_screen.dart` — Chat button configuration
