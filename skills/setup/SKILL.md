---
name: setup
description: Set up CometChat Calls SDK v5 for Flutter. Use when adding SDK dependency, configuring CallAppSettings, CometChatCalls.init, platform permissions. Triggers on "setup calls sdk", "add cometchat dependency", "initialize calls", "pubspec".
inclusion: manual
---

# CometChat Calls SDK v5 — Setup (Flutter)

## Overview

Install and initialize the CometChat Calls SDK v5 in a Flutter project. Covers dependency setup, platform permissions, and `CometChatCalls.init()`.

## Prerequisites

- Flutter 3.44 or later, where Swift Package Manager is on by default (older Flutter versions need it turned on for iOS); Dart 3.2+
- Android minSdk 26 and Android Gradle Plugin 8.9.1+
- iOS 15.1+, built with Swift Package Manager (on by default from Flutter 3.44)
- App ID and Region from CometChat Dashboard

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### 1. Add Dependency (pubspec.yaml)

```yaml
dependencies:
  cometchat_calls_sdk: ^5.1.0
```

Then run `flutter pub get`.

### 2. Android Configuration

In `android/app/build.gradle`:

```groovy
android {
    compileSdk flutter.compileSdkVersion
    defaultConfig {
        minSdk 26
    }
}
```

The app needs Android Gradle Plugin 8.9.1 or later (the `com.android.application` plugin version in `android/settings.gradle`).

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

Declare the plugin's ongoing call service inside `<application>`, with the foreground service types your app can justify on Google Play:

```xml
<application>
    <service
        android:name="com.cometchatcalls.cometchatcalls_plugin.services.OngoingCallService"
        android:exported="false"
        android:foregroundServiceType="microphone|camera" />
</application>
```

The plugin no longer declares this service (5.1.0). Without it, calls work only while the app is in the foreground: when the app goes to the background, Android stops the microphone and camera. The `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_MICROPHONE` / `FOREGROUND_SERVICE_CAMERA` permissions are merged in by the plugin. See the `background-handling` skill.

### 3. iOS Configuration

The plugin builds with **Swift Package Manager only**: the native Calls SDK 5.1 is published as a Swift package, not on the CocoaPods trunk. Swift Package Manager is on by default from Flutter 3.44; on an older Flutter, or if your app turned it off, run:

```bash
flutter config --enable-swift-package-manager
```

Your app can still use CocoaPods for its other plugins. If Swift Package Manager is off, `pod install` stops and prints these steps.

Set the minimum iOS version to 15.1: `IPHONEOS_DEPLOYMENT_TARGET = 15.1` for the Runner target in Xcode (Runner > General > Minimum Deployments).

In `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for voice and video calls</string>
```

### 4. Initialize SDK

Call once at app startup:

```dart
final settings = (CallAppSettingBuilder()
      ..appId = "APP_ID"
      ..region = "REGION") // "us", "eu", or "in"
    .build();

CometChatCalls.init(settings,
  onSuccess: (String message) {
    debugPrint("Calls SDK initialized: $message");
  },
  onError: (CometChatCallsException e) {
    debugPrint("Init failed: ${e.message}");
  },
);
```

### 5. Authentication

Login with UID + Auth Key (dev only):

```dart
CometChatCalls.login(
  uid: "user_uid",
  authKey: "AUTH_KEY",
  onSuccess: (User? user) {
    debugPrint("Logged in as: ${user?.uid}");
  },
  onError: (CometChatCallsException e) {
    debugPrint("Login failed: ${e.message}");
  },
);
```

Or login with Auth Token (production):

```dart
CometChatCalls.loginWithAuthToken(
  authToken: "AUTH_TOKEN",
  onSuccess: (User? user) {
    debugPrint("Logged in as: ${user?.uid}");
  },
  onError: (CometChatCallsException e) {
    debugPrint("Login failed: ${e.message}");
  },
);
```

### 6. Check Logged-In User

```dart
final user = await CometChatCalls.getLoggedInUser();
if (user != null) {
  // User is already logged in
}
```

### 7. Logout

```dart
CometChatCalls.logout(
  onSuccess: (String message) {
    debugPrint("Logged out");
  },
  onError: (CometChatCallsException e) {
    debugPrint("Logout failed: ${e.message}");
  },
);
```

## Gotchas

- Request camera and microphone permissions at runtime using `permission_handler` package
- Call `CometChatCalls.init()` before any other SDK method
- The Calls SDK has its own `init` and `login`; ringing calls (`initiateCall`, `endCall`) do not need the Chat SDK
- If your app also uses the Chat SDK, initialize and log in to both separately. On iOS, the Chat SDK v4 must be `CometChatSDK` 4.1.3 or later
- The builder is `CallAppSettingBuilder` (singular "Setting") and is configured with cascades (`..appId`, `..region`), not setter methods
- The SDK is available on pub.dev
- Android requires `minSdk 26` or higher and Android Gradle Plugin 8.9.1 or later
- iOS: no Podfile or `pod install` step is needed for the Calls SDK; it resolves through Swift Package Manager

## Sample App Reference

- `lib/services/app_state.dart` — SDK initialization and login flow
- `lib/app_constants.dart` — Credential storage
- `lib/main.dart` — App entry point
