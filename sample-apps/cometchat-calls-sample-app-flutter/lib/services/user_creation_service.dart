import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for creating CometChat users via the REST API.
///
/// Used when login fails because the user does not yet exist.
class UserCreationService {
  /// Creates a user on the CometChat platform via the REST API.
  ///
  /// Sends an HTTP POST to `https://{appId}.api-{region}.cometchat.io/v3/users`
  /// with the provided [uid] and [name].
  ///
  /// Returns `true` if the user was created successfully (HTTP 200),
  /// `false` otherwise.
  static Future<bool> createUser(
    String uid,
    String name,
    String appId,
    String region,
    String authKey,
  ) async {
    try {
      final url = Uri.parse(
        'https://$appId.api-$region.cometchat.io/v3/users',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'appId': appId,
          'apiKey': authKey,
        },
        body: jsonEncode({
          'uid': uid,
          'name': name,
        }),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
