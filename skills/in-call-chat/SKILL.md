---
name: in-call-chat
description: In-call chat messaging during active CometChat call session in Flutter. Chat button, unread count badge. Triggers on "in-call chat", "chat button", "messaging during call", "unread count", "in call message".
inclusion: manual
---

# CometChat Calls SDK v5 — In-Call Chat (Flutter)

## Overview

Add in-call messaging to an active call session. The Calls SDK provides the chat button, its click event and an unread count badge; the chat UI and the messages themselves come from your app (for example, built on the CometChat Chat SDK).

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
class MyButtonListener extends ButtonClickListeners {
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
  const CallScreenWithChat({super.key, required this.callWidget});
  final Widget callWidget;

  @override
  State<CallScreenWithChat> createState() => _CallScreenWithChatState();
}

class _CallScreenWithChatState extends State<CallScreenWithChat> {
  bool _showChat = false;
  late final _buttons = _ChatButtonListener(() {
    setState(() => _showChat = !_showChat);
  });

  @override
  void initState() {
    super.initState();
    CallSession.getInstance()?.addButtonClickListener(_buttons);
  }

  @override
  void dispose() {
    CallSession.getInstance()?.removeButtonClickListener(_buttons);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.callWidget,
          if (_showChat)
            Positioned(
              bottom: 80,
              right: 16,
              left: 16,
              height: 300,
              child: Card(
                child: YourChatWidget(sessionId: "..."), // your own chat UI
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatButtonListener extends ButtonClickListeners {
  _ChatButtonListener(this.onChat);

  final VoidCallback onChat;

  @override
  void onChatButtonClicked() => onChat();
}
```

## Gotchas

- `hideChatButton` defaults to `true` — you must explicitly set it to `false`
- Use `setChatButtonUnreadCount` to show a badge on the chat button
- Listen for `onChatButtonClicked` and show your own chat widget; the Calls SDK has no API to send or receive messages

## Sample App Reference

- `lib/screens/call_screen.dart` — Chat button configuration
