---
name: setup
description: Set up CometChat Calls SDK v5 for Flutter. Use when adding SDK dependency, configuring CallAppSettings, CometChatCalls.init, platform permissions. Triggers on "setup calls sdk", "add cometchat dependency", "initialize calls", "pubspec".
inclusion: manual
---

# CometChat Calls SDK v5 — Setup (Flutter)

## Overview

Install and initialize the CometChat Calls SDK v5 in a Flutter project. Covers dependency setup, platform permissions, and `CometChatCalls.init()`.

## Prerequisites

- Flutter 3.10+, Dart 3.0+
- Android minSdk 26, iOS 13.0+
- App ID and Region from CometChat Dashboard

## Key Imports

```dart
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
```

## Implementation

### 1. Add Dependency (pubspec.yaml)

```yaml
dependencies:
  cometchat_calls_sdk: ^5.0.2
```

Then run `flutter pub get`.

### 2. Android Configuration

In `android/app/build.gradle`:

```groovy
android {
    compileSdk 34
    defaultConfig {
        minSdk 26
    }
}
```

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 3. iOS Configuration

In `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for voice and video calls</string>
```

In `ios/Podfile`, set minimum iOS version:

```ruby
platform :ios, '13.0'
```

### 4. Initialize SDK

Call once at app startup:

```dart
final settings = CallAppSettingsBuilder()
    .setAppId("APP_ID")
    .setRegion("REGION")  // "us", "eu", or "in"
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
- If using both Chat SDK and Calls SDK, initialize both separately
- The SDK is available on pub.dev
- Android requires `minSdk 26` or higher

## Sample App Reference

- `lib/services/app_state.dart` — SDK initialization and login flow
- `lib/app_constants.dart` — Credential storage
- `lib/main.dart` — App entry point
