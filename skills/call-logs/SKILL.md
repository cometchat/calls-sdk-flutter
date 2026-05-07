---
name: call-logs
description: Fetch and display call history using CallLogRequest and CallLogRequestBuilder. Use when showing call logs, call history, filtering by type/status/direction. Triggers on "call logs", "call history", "CallLogRequest", "fetchNext", "call records".
inclusion: manual
---

# CometChat Calls SDK v5 — Call Logs (Flutter)

## Overview

Fetch call history using `CallLogRequest` with pagination and filtering. Supports filtering by call type, status, direction, and whether recordings exist.

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### Basic Fetch

```dart
final request = CallLogRequestBuilder().build();

request.fetchNext(
  onSuccess: (List<CallLog> callLogs) {
    for (final log in callLogs) {
      debugPrint("Session: ${log.sessionId}, Status: ${log.status}");
    }
  },
  onError: (CometChatCallsException e) {
    debugPrint("Error: ${e.message}");
  },
);
```

### With Filters

```dart
final request = CallLogRequestBuilder()
  ..callType = "video"           // "audio" or "video"
  ..callStatus = "ended"         // "initiated", "ongoing", "ended", "cancelled"
  ..callDirection = "outgoing"   // "incoming" or "outgoing"
  ..hasRecording = true          // only logs with recordings
  ..limit = 20                   // results per page (default 30, max 100)
  ..uid = "user123"              // filter by specific user
  ..build();
```

### Pagination

```dart
class _CallLogsScreenState extends State<CallLogsScreen> {
  final CallLogRequest _request = CallLogRequestBuilder().build();
  final List<CallLog> _logs = [];
  bool _isLoading = false;

  void _loadMore() {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    _request.fetchNext(
      onSuccess: (List<CallLog> callLogs) {
        setState(() {
          _logs.addAll(callLogs);
          _isLoading = false;
        });
      },
      onError: (e) {
        setState(() => _isLoading = false);
        debugPrint("Error: ${e.message}");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return ListTile(
          title: Text(log.sessionId ?? "Unknown"),
          subtitle: Text("${log.status} • ${log.type}"),
          trailing: Text(_formatDuration(log.totalDurationInMinutes)),
        );
      },
    );
  }

  String _formatDuration(double? minutes) {
    if (minutes == null) return "0:00";
    final mins = minutes.toInt();
    final secs = ((minutes - mins) * 60).toInt();
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }
}
```

### CallLog Properties

```dart
// Available properties on CallLog:
log.sessionId          // String? — unique session identifier
log.status             // String? — "initiated", "ongoing", "ended", "cancelled"
log.type               // String? — "audio" or "video"
log.mode               // String? — call category/mode
log.direction          // String? — "incoming" or "outgoing"
log.startedAt          // int? — timestamp when call started
log.endedAt            // int? — timestamp when call ended
log.totalDurationInMinutes  // double? — call duration
log.participants       // List<Participant>? — participants in the call
log.recordings         // List<Recording>? — recordings for this call
log.initiator          // CallUser? — who initiated the call
log.receiver           // CallUser? — who received the call
```

## Gotchas

- User must be logged in before fetching call logs
- `fetchNext()` handles pagination automatically — keep calling it for more results
- Returns empty list when no more pages are available
- `limit` max is 100, default is 30
- `fetchPrevious()` is also available for backward pagination

## Sample App Reference

- `lib/screens/home_screen.dart` — Call log display (if implemented)
