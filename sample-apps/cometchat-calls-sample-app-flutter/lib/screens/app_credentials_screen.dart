import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/app_state.dart';
import 'login_screen.dart';

/// Screen where users enter their CometChat App ID, Region, and Auth Key.
class AppCredentialsScreen extends StatefulWidget {
  const AppCredentialsScreen({super.key});

  @override
  State<AppCredentialsScreen> createState() => _AppCredentialsScreenState();
}

class _AppCredentialsScreenState extends State<AppCredentialsScreen> {
  String? _selectedRegion;
  final _appIdController = TextEditingController();
  final _authKeyController = TextEditingController();
  bool _isLoading = false;

  static const _regions = [
    ('us', '🇺🇸 US'),
    ('eu', '🇪🇺 EU'),
    ('in', '🇮🇳 IN'),
  ];

  @override
  void dispose() {
    _appIdController.dispose();
    _authKeyController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_selectedRegion == null) {
      _showError('Please select a region');
      return;
    }
    final appId = _appIdController.text.trim();
    if (appId.isEmpty) {
      _showError('Please enter App ID');
      return;
    }
    final authKey = _authKeyController.text.trim();
    if (authKey.isEmpty) {
      _showError('Please enter Auth Key');
      return;
    }

    setState(() => _isLoading = true);

    await AppState().saveCredentials(appId, _selectedRegion!, authKey);
    final success = await AppState().initializeSDK(appId, _selectedRegion!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _showError('SDK initialization failed. Please check your credentials.');
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          // CometChat logo
                          SvgPicture.asset(
                            'assets/cometchat_logo.svg',
                            width: 240,
                          ),
                          const SizedBox(height: 32),
                          _buildCredentialsCard(),
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

  Widget _buildCredentialsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Region',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _regions.map((r) {
              final (code, label) = r;
              final isSelected = _selectedRegion == code;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: r != _regions.last ? 8 : 0,
                  ),
                  child: _RegionCard(
                    label: label,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedRegion = code),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'App ID',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _appIdController,
            style: const TextStyle(color: Colors.white),
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter App ID'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Auth Key',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _authKeyController,
            style: const TextStyle(color: Colors.white),
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter Auth Key'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
