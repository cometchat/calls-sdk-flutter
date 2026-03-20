import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_constants.dart';

class SampleUser {
  final String uid;
  final String name;
  final String avatar;

  SampleUser({required this.uid, required this.name, this.avatar = ''});

  factory SampleUser.fromJson(Map<String, dynamic> json) {
    return SampleUser(
      uid: json['uid'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String? ?? '',
    );
  }
}

class SampleUserService {
  /// Fetches sample users from the CometChat sample data endpoint.
  static Future<List<SampleUser>> fetchSampleUsers() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.sampleUsersUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return parseSampleUsers(json);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Parses a JSON map containing a `users` array into a list of [SampleUser].
  /// Exposed as a static method for property-based testing.
  static List<SampleUser> parseSampleUsers(Map<String, dynamic> json) {
    final List<dynamic> usersJson = json['users'] as List<dynamic>? ?? [];
    return usersJson
        .map((e) => SampleUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
