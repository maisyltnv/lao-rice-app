import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the customer's profile photo on device (keyed by user id).
abstract final class ProfileAvatarStore {
  ProfileAvatarStore._();

  static String _key(int userId) => 'profile_avatar_path_$userId';

  static Future<String?> loadPath(int? userId) async {
    if (userId == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key(userId));
    if (path != null && File(path).existsSync()) return path;
    if (path != null) await prefs.remove(_key(userId));
    return null;
  }

  static Future<String> save(int userId, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_avatar_$userId.jpg');
    await file.writeAsBytes(bytes, flush: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), file.path);
    return file.path;
  }

  static Future<void> clear(int? userId) async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key(userId));
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
      await prefs.remove(_key(userId));
    }
  }
}
