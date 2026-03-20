import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_calls_sample_app_flutter/screens/splash_screen.dart';

void main() {
  group('SplashScreen.determineDestination', () {
    test('no credentials → appCredentials', () {
      expect(
        SplashScreen.determineDestination(
          hasCredentials: false,
          sdkInitSuccess: false,
          hasLoggedInUser: false,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('no credentials ignores sdkInitSuccess and hasLoggedInUser', () {
      expect(
        SplashScreen.determineDestination(
          hasCredentials: false,
          sdkInitSuccess: true,
          hasLoggedInUser: true,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('credentials + SDK init failure → appCredentials', () {
      expect(
        SplashScreen.determineDestination(
          hasCredentials: true,
          sdkInitSuccess: false,
          hasLoggedInUser: false,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('credentials + SDK init failure ignores hasLoggedInUser', () {
      expect(
        SplashScreen.determineDestination(
          hasCredentials: true,
          sdkInitSuccess: false,
          hasLoggedInUser: true,
        ),
        SplashDestination.appCredentials,
      );
    });

    test('credentials + SDK init success + no user → login', () {
      expect(
        SplashScreen.determineDestination(
          hasCredentials: true,
          sdkInitSuccess: true,
          hasLoggedInUser: false,
        ),
        SplashDestination.login,
      );
    });

    test('credentials + SDK init success + logged-in user → home', () {
      expect(
        SplashScreen.determineDestination(
          hasCredentials: true,
          sdkInitSuccess: true,
          hasLoggedInUser: true,
        ),
        SplashDestination.home,
      );
    });
  });
}
