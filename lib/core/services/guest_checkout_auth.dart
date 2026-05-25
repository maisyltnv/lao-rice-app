import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/api_service.dart';

/// Creates a per-device guest account so `POST /orders` can run without a login screen.
/// Order lookup for customers uses `GET /ordersbyphone` (phone on the shipping address).
class GuestCheckoutAuth {
  GuestCheckoutAuth(this._api);

  final ApiService _api;
  static const _pwPrefix = 'guest_pw_';

  Future<String> accessTokenForPhone(String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) {
      throw ArgumentError('phone number too short');
    }
    final username = 'guest_$digits';
    final prefs = await SharedPreferences.getInstance();
    var password = prefs.getString('$_pwPrefix$digits');
    password ??= _randomPassword();
    await prefs.setString('$_pwPrefix$digits', password);

    try {
      final session = await _api.login(username: username, password: password);
      return session.token;
    } catch (_) {
      try {
        await _api.register(username: username, password: password);
      } catch (_) {}
      final session = await _api.login(username: username, password: password);
      return session.token;
    }
  }

  String _randomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return List.generate(24, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
