import 'dart:async';

import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_constants.dart';

/// Singleton service managing credential persistence and SDK initialization.
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  static const String _keyAppId = 'cc_app_id';
  static const String _keyRegion = 'cc_region';
  static const String _keyAuthKey = 'cc_auth_key';
  static const String _keyLoggedInUid = 'cc_logged_in_uid';

  // --- Credential persistence ---

  Future<void> saveCredentials(
      String appId, String region, String authKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppId, appId);
    await prefs.setString(_keyRegion, region);
    await prefs.setString(_keyAuthKey, authKey);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final appId = prefs.getString(_keyAppId);
    final region = prefs.getString(_keyRegion);
    final authKey = prefs.getString(_keyAuthKey);
    if (appId == null || region == null || authKey == null) return null;
    if (appId.isEmpty || region.isEmpty || authKey.isEmpty) return null;
    return {'appId': appId, 'region': region, 'authKey': authKey};
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppId);
    await prefs.remove(_keyRegion);
    await prefs.remove(_keyAuthKey);
  }

  // --- Login state persistence ---

  Future<void> saveLoggedInUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoggedInUid, uid);
  }

  Future<String?> getLoggedInUid() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_keyLoggedInUid);
    if (uid == null || uid.isEmpty) return null;
    return uid;
  }

  Future<void> clearLoggedInUid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedInUid);
  }

  // --- Checks ---

  bool hasValidAppConstants() {
    return AppConstants.appId.isNotEmpty &&
        AppConstants.region.isNotEmpty &&
        AppConstants.authKey.isNotEmpty;
  }

  Future<bool> hasSavedCredentials() async {
    final credentials = await getSavedCredentials();
    return credentials != null;
  }

  // --- SDK initialization ---

  Future<bool> initializeSDK(String appId, String region) async {
    final completer = Completer<bool>();
    final callAppSettings = (CallAppSettingBuilder()
          ..appId = appId
          ..region = region)
        .build();

    CometChatCalls.init(
      callAppSettings,
      onSuccess: (_) {
        if (!completer.isCompleted) completer.complete(true);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    return completer.future;
  }

  /// Re-initializes the SDK after a call session ends.
  /// The SDK's internal state can get cleared after a session, so this
  /// ensures subsequent calls work properly.
  Future<void> reinitializeSDK() async {
    String appId;
    String region;

    if (hasValidAppConstants()) {
      appId = AppConstants.appId;
      region = AppConstants.region;
    } else {
      final credentials = await getSavedCredentials();
      if (credentials == null) return;
      appId = credentials['appId']!;
      region = credentials['region']!;
    }

    await initializeSDK(appId, region);
  }

  /// Returns the current auth key — from AppConstants if valid,
  /// otherwise from saved credentials.
  Future<String?> getAuthKey() async {
    if (hasValidAppConstants()) return AppConstants.authKey;
    final credentials = await getSavedCredentials();
    return credentials?['authKey'];
  }
}
