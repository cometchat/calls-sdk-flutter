import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
import 'package:flutter/material.dart';

import '../services/app_state.dart';

/// Call screen that hosts the active call session and handles all SDK event listeners.
class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    implements SessionStatusListeners, ButtonClickListeners {
  Widget? _videoContainer;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isLeavingSession = false;
  CallSession? _callSession;

  @override
  void initState() {
    super.initState();
    _joinSession();
  }

  @override
  void dispose() {
    _unregisterListeners();
    CometChatOngoingCallService.abort();
    super.dispose();
  }

  void _joinSession() {
    final sessionSettings = (SessionSettingsBuilder()
          .setTitle('CometChat Meeting')
          .startVideoPaused(false)
          .startAudioMuted(false))
        .build();

    CometChatCalls.joinSession(
      sessionId: widget.sessionId,
      sessionSettings: sessionSettings,
      onSuccess: (Widget? videoWidget) {
        if (!mounted) return;
        setState(() {
          _videoContainer = videoWidget;
          _isLoading = false;
          _hasError = false;
        });
        _registerListeners();
        CometChatOngoingCallService.launch();
      },
      onError: (CometChatCallsException error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = error.message ?? 'Failed to join session';
        });
      },
    );
  }

  void _registerListeners() {
    _callSession = CallSession.getInstance();
    _callSession?.addSessionStatusListener(this);
    _callSession?.addButtonClickListener(this);
  }

  void _unregisterListeners() {
    _callSession?.removeSessionStatusListener(this);
    _callSession?.removeButtonClickListener(this);
  }

  Future<void> _leaveAndGoBack() async {
    if (_isLeavingSession) return;
    _isLeavingSession = true;

    try {
      await _callSession?.leaveSession();
    } catch (_) {
      // Best-effort leave
    }

    await CometChatOngoingCallService.abort();
    _navigateBack();
  }

  void _navigateBack() {
    if (!mounted) return;
    Navigator.of(context).pop();
    AppState().reinitializeSDK();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- SessionStatusListeners ---

  @override
  void onSessionJoined() {
    debugPrint('CallScreen: onSessionJoined');
    CometChatOngoingCallService.launch();
  }

  @override
  void onSessionLeft() {
    CometChatOngoingCallService.abort();
    _navigateBack();
  }

  @override
  void onConnectionClosed() {
    CometChatOngoingCallService.abort();
    _navigateBack();
  }

  @override
  void onConnectionLost() {
    _showSnackBar('Connection lost');
  }

  @override
  void onConnectionRestored() {
    _showSnackBar('Connection restored');
  }

  @override
  void onSessionTimedOut() {
    _showSnackBar('Session timed out');
    CometChatOngoingCallService.abort();
    _navigateBack();
  }

  // --- ButtonClickListeners ---

  @override
  void onLeaveSessionButtonClicked() {
    _leaveAndGoBack();
  }

  @override
  void onChangeLayoutButtonClicked() {}

  @override
  void onChatButtonClicked() {}

  @override
  void onParticipantListButtonClicked() {}

  @override
  void onRaiseHandButtonClicked() {}

  @override
  void onRecordingToggleButtonClicked() {}

  @override
  void onShareInviteButtonClicked() {}

  @override
  void onSwitchCameraButtonClicked() {}

  @override
  void onToggleAudioButtonClicked() {}

  @override
  void onToggleVideoButtonClicked() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 16),
            Text(
              'Joining session...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'An error occurred',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppState().reinitializeSDK();
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Success state — show video container
    if (_videoContainer != null) {
      return SizedBox.expand(child: _videoContainer);
    }

    return const SizedBox.shrink();
  }
}
