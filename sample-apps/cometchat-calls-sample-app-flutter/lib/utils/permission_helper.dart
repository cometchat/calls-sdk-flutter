import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class for requesting and checking runtime permissions.
///
/// On iOS, camera and microphone permissions are handled by the native
/// WebRTC SDK, so this helper is more lenient on iOS — it returns true
/// even when permissions are not explicitly granted.
class PermissionHelper {
  /// Requests both camera and microphone permissions.
  ///
  /// Returns `true` if both permissions are granted (or if running on iOS,
  /// where the native SDK handles permissions).
  static Future<bool> requestCallPermissions() async {
    if (Platform.isIOS) return true;

    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    return cameraGranted && micGranted;
  }

  /// Checks whether camera permission is currently granted.
  static Future<bool> hasCameraPermission() async {
    if (Platform.isIOS) return true;
    return await Permission.camera.isGranted;
  }

  /// Checks whether microphone permission is currently granted.
  static Future<bool> hasMicrophonePermission() async {
    if (Platform.isIOS) return true;
    return await Permission.microphone.isGranted;
  }

  /// Requests the POST_NOTIFICATIONS permission on Android 13+ (API 33).
  ///
  /// Returns `true` if granted, or if running on iOS / older Android versions
  /// where this permission is not required.
  static Future<bool> requestNotificationPermission() async {
    if (Platform.isIOS) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Shows a dialog explaining that a permission was permanently denied,
  /// with an option to open the device's app settings.
  ///
  /// Used on Android when the user has selected "Don't ask again".
  static Future<void> showPermissionDeniedDialog(
    BuildContext context,
    String permissionName,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '$permissionName permission is permanently denied. '
          'Please enable it from app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Shows a SnackBar informing the user that a permission is required.
  ///
  /// Used when the user denies a permission but has not permanently denied it.
  static void showPermissionError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Requests call permissions and handles denied/permanently-denied states.
  ///
  /// Returns `true` if all required permissions are granted.
  /// Shows appropriate UI feedback when permissions are denied.
  static Future<bool> handleCallPermissions(BuildContext context) async {
    if (Platform.isIOS) return true;

    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) return true;

    if (!context.mounted) return false;

    // Handle permanently denied permissions
    if (cameraStatus.isPermanentlyDenied) {
      await showPermissionDeniedDialog(context, 'Camera');
      return false;
    }
    if (micStatus.isPermanentlyDenied) {
      await showPermissionDeniedDialog(context, 'Microphone');
      return false;
    }

    // Handle regular denial
    if (!cameraStatus.isGranted) {
      showPermissionError(
        context,
        'Camera permission is required for video calls.',
      );
      return false;
    }
    if (!micStatus.isGranted) {
      showPermissionError(
        context,
        'Microphone permission is required for calls.',
      );
      return false;
    }

    return false;
  }
}
