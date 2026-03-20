import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';

import '../services/app_state.dart';
import '../utils/permission_helper.dart';
import 'call_screen.dart';
import 'login_screen.dart';

/// Home screen with session ID input, join meeting, and start instant meeting.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sessionIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    _sessionIdController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await PermissionHelper.requestCallPermissions();
    await PermissionHelper.requestNotificationPermission();
  }

  Future<void> _joinMeeting() async {
    final sessionId = _sessionIdController.text.trim();
    if (sessionId.isEmpty) {
      _showError('Please enter a Session ID');
      return;
    }

    if (!mounted) return;
    final granted = await PermissionHelper.handleCallPermissions(context);
    if (!granted) return;

    _navigateToCall(sessionId);
  }

  Future<void> _startInstantMeeting() async {
    if (!mounted) return;
    final granted = await PermissionHelper.handleCallPermissions(context);
    if (!granted) return;

    final sessionId = const Uuid().v4();
    _navigateToCall(sessionId);
  }

  void _navigateToCall(String sessionId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(sessionId: sessionId),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    CometChatCalls.logout(
      onSuccess: (_) async {
        await AppState().clearLoggedInUid();
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showError(error.message ?? 'Logout failed');
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Top bar with logout
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: GestureDetector(
                                onTap: _isLoading ? null : _logout,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2C2E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // CometChat logo
                          SvgPicture.asset(
                            'assets/cometchat_logo.svg',
                            width: 240,
                          ),
                          const SizedBox(height: 32),
                          // Meeting card
                          _buildMeetingCard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Session Id',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sessionIdController,
            style: const TextStyle(color: Colors.white),
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Session ID',
            ),
          ),
          const SizedBox(height: 24),
          // Join Meeting button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _joinMeeting,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade700),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Join Meeting',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Or divider
          _buildOrDivider(),
          const SizedBox(height: 16),
          // Start Instant Meeting button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startInstantMeeting,
              child: const Text(
                'Start Instant Meeting',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade700,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
