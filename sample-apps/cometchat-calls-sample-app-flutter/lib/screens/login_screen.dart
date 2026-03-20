import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_constants.dart';
import '../services/app_state.dart';
import '../services/sample_user_service.dart';
import '../services/user_creation_service.dart';
import 'app_credentials_screen.dart';
import 'home_screen.dart';

/// Login screen where users authenticate via sample user selection or manual UID.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<SampleUser> _sampleUsers = [];
  SampleUser? _selectedUser;
  final _uidController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSampleUsers();
  }

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _fetchSampleUsers() async {
    final users = await SampleUserService.fetchSampleUsers();
    if (mounted) {
      setState(() => _sampleUsers = users);
    }
  }

  void _onUserSelected(SampleUser user) {
    setState(() {
      _selectedUser = _selectedUser?.uid == user.uid ? null : user;
      _uidController.clear();
    });
  }

  Future<void> _onContinue() async {
    final uid = _selectedUser?.uid ?? _uidController.text.trim();
    if (uid.isEmpty) {
      _showError('Please select a user or enter a UID');
      return;
    }

    setState(() => _isLoading = true);

    final authKey = await AppState().getAuthKey();
    if (authKey == null || authKey.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Auth key not found. Please set app credentials.');
      }
      return;
    }

    _performLogin(uid, authKey);
  }

  void _performLogin(String uid, String authKey) {
    CometChatCalls.login(
      uid: uid,
      authKey: authKey,
      onSuccess: (_) async {
        await AppState().saveLoggedInUid(uid);
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      onError: (error) {
        // Attempt to create user and retry login
        _createUserAndRetry(uid, authKey);
      },
    );
  }

  Future<void> _createUserAndRetry(String uid, String authKey) async {
    final appState = AppState();
    String appId;
    String region;

    if (appState.hasValidAppConstants()) {
      appId = AppConstants.appId;
      region = AppConstants.region;
    } else {
      final creds = await appState.getSavedCredentials();
      if (creds == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('App credentials not found');
        }
        return;
      }
      appId = creds['appId']!;
      region = creds['region']!;
    }

    final name = _selectedUser?.name ?? uid;
    final created = await UserCreationService.createUser(
      uid,
      name,
      appId,
      region,
      authKey,
    );

    if (!mounted) return;

    if (created) {
      // Retry login after user creation
      CometChatCalls.login(
        uid: uid,
        authKey: authKey,
        onSuccess: (_) async {
          await AppState().saveLoggedInUid(uid);
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        onError: (retryError) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showError(retryError.message ?? 'Login failed');
        },
      );
    } else {
      setState(() => _isLoading = false);
      _showError('Login failed. Could not create user.');
    }
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
                        children: [
                          const SizedBox(height: 32),
                          // CometChat logo
                          SvgPicture.asset(
                            'assets/cometchat_logo.svg',
                            width: 240,
                          ),
                          const SizedBox(height: 32),
                          // Sample users section
                          if (_sampleUsers.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Choose a sample user',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSampleUsersGrid(),
                            const SizedBox(height: 16),
                            _buildOrDivider(),
                            const SizedBox(height: 16),
                          ],
                          // UID text field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter your UID',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _uidController,
                            style: const TextStyle(color: Colors.white),
                            autocorrect: false,
                            decoration: const InputDecoration(
                              hintText: 'Enter UID',
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && _selectedUser != null) {
                                setState(() => _selectedUser = null);
                              }
                            },
                          ),
                          const SizedBox(height: 100),
                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onContinue,
                              child: const Text('Continue'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Change App Credentials link
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AppCredentialsScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Change ',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  'App Credentials',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildSampleUsersGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: _sampleUsers.length,
      itemBuilder: (context, index) {
        final user = _sampleUsers[index];
        final isSelected = _selectedUser?.uid == user.uid;
        return _SampleUserCard(
          user: user,
          isSelected: isSelected,
          onTap: () => _onUserSelected(user),
        );
      },
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
            'OR',
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

class _SampleUserCard extends StatelessWidget {
  const _SampleUserCard({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  final SampleUser user;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple.withValues(alpha: 0.15)
              : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar with checkmark overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade700,
                  backgroundImage: user.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : null,
                  child: user.avatar.isEmpty
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (isSelected)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1C1C1E),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // User name
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // User UID
            Text(
              user.uid,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
