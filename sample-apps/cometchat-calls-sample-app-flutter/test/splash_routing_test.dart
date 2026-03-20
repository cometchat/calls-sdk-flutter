// Standalone test for splash routing logic.
// Tests the determineDestination logic without importing the full splash screen
// (which depends on the CometChat SDK that may not be available in CI).

import 'package:flutter_test/flutter_test.dart';

/// Mirrors SplashDestination from splash_screen.dart.
enum SplashDestination { appCredentials, login, home }

/// Mirrors SplashScreen.determineDestination — same logic, standalone.
SplashDestination determineDestination({
  required bool hasCredentials,
  required bool sdkInitSuccess,
  required bool hasLoggedInUser,
}) {
  if (!hasCredentials) return SplashDestination.appCredentials;
  if (!sdkInitSuccess) return SplashDestination.appCredentials;
  if (hasLoggedInUser) return SplashDestination.home;
  return SplashDestination.login;
}

void main() {
  group('determineDestination', () {
    test('no credentials → appCredentials', () {
      expect(
        determineDestination(
          hasCredentials: false,
          sdkInitSuccess: false,
          hasLoggedInUser: false,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('no credentials ignores sdkInitSuccess and hasLoggedInUser', () {
      expect(
        determineDestination(
          hasCredentials: false,
          sdkInitSuccess: true,
          hasLoggedInUser: true,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('credentials + SDK init failure → appCredentials', () {
      expect(
        determineDestination(
          hasCredentials: true,
          sdkInitSuccess: false,
          hasLoggedInUser: false,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('credentials + SDK init failure ignores hasLoggedInUser', () {
      expect(
        determineDestination(
          hasCredentials: true,
          sdkInitSuccess: false,
          hasLoggedInUser: true,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('credentials + SDK init success + no user → login', () {
      expect(
        determineDestination(
          hasCredentials: true,
          sdkInitSuccess: true,
          hasLoggedInUser: false,
        ),
        SplashDestination.login,
      );
    });

    test('credentials + SDK init success + logged-in user → home', () {
      expect(
        determineDestination(
          hasCredentials: true,
          sdkInitSuccess: true,
          hasLoggedInUser: true,
        ),
        SplashDestination.home,
      );
    });

    // Exhaustive: all 8 combinations of 3 booleans
    test('exhaustive truth table', () {
      final cases = <(bool, bool, bool, SplashDestination)>[
        (false, false, false, SplashDestination.appCredentials),
        (false, false, true, SplashDestination.appCredentials),
        (false, true, false, SplashDestination.appCredentials),
        (false, true, true, SplashDestination.appCredentials),
        (true, false, false, SplashDestination.appCredentials),
        (true, false, true, SplashDestination.appCredentials),
        (true, true, false, SplashDestination.login),
        (true, true, true, SplashDestination.home),
      ];

      for (final (hasCreds, sdkOk, hasUser, expected) in cases) {
        expect(
          determineDestination(
            hasCredentials: hasCreds,
            sdkInitSuccess: sdkOk,
            hasLoggedInUser: hasUser,
          ),
          expected,
          reason:
              'hasCredentials=$hasCreds, sdkInitSuccess=$sdkOk, hasLoggedInUser=$hasUser',
        );
      }
    });
  });
}
