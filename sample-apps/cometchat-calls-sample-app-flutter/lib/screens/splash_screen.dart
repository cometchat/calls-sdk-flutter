import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_constants.dart';
import '../services/app_state.dart';
import 'app_credentials_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// The destination the splash screen should navigate to.
enum SplashDestination { appCredentials, login, home }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Pure routing logic extracted for testability (Property 1).
  ///
  /// Rules:
  /// - No credentials → AppCredentialsScreen
  /// - Credentials + SDK init failure → AppCredentialsScreen
  /// - Credentials + SDK init success + no logged-in user → LoginScreen
  /// - Credentials + SDK init success + logged-in user → HomeScreen
  static SplashDestination determineDestination({
    required bool hasCredentials,
    required bool sdkInitSuccess,
    required bool hasLoggedInUser,
  }) {
    if (!hasCredentials) return SplashDestination.appCredentials;
    if (!sdkInitSuccess) return SplashDestination.appCredentials;
    if (hasLoggedInUser) return SplashDestination.home;
    return SplashDestination.login;
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final appState = AppState();

    // 1. Determine credentials source
    String? appId;
    String? region;
    bool hasCredentials = false;

    if (appState.hasValidAppConstants()) {
      appId = AppConstants.appId;
      region = AppConstants.region;
      hasCredentials = true;
    } else {
      final saved = await appState.getSavedCredentials();
      if (saved != null) {
        appId = saved['appId'];
        region = saved['region'];
        hasCredentials = true;
      }
    }

    // 2. Initialize SDK if we have credentials
    bool sdkInitSuccess = false;
    if (hasCredentials && appId != null && region != null) {
      sdkInitSuccess = await appState.initializeSDK(appId, region);
    }

    // 3. Check logged-in user
    bool hasLoggedInUser = false;
    if (sdkInitSuccess) {
      final uid = await appState.getLoggedInUid();
      hasLoggedInUser = uid != null;
    }

    // 4. Determine destination and navigate
    final destination = SplashScreen.determineDestination(
      hasCredentials: hasCredentials,
      sdkInitSuccess: sdkInitSuccess,
      hasLoggedInUser: hasLoggedInUser,
    );

    if (!mounted) return;

    final Widget screen;
    switch (destination) {
      case SplashDestination.appCredentials:
        screen = const AppCredentialsScreen();
      case SplashDestination.login:
        screen = const LoginScreen();
      case SplashDestination.home:
        screen = const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CometChat logo
            SvgPicture.asset(
              'assets/cometchat_logo.svg',
              width: 240,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
