import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/api_service.dart';
import '../../domain/entities/auth_user_entity.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiService _api;

  static const _kToken = 'auth_token';
  static const _kUsername = 'auth_username';
  static const _kRole = 'auth_role';
  static const _kUserId = 'auth_user_id';

  String? _token;
  String? _username;
  String? _role;
  int? _userId;
  bool _ready = false;

  String? get token => _token;
  String? get username => _username;
  String? get role => _role;
  int? get userId => _userId;
  bool get isReady => _ready;
  bool get isSignedIn => _token != null && _token!.isNotEmpty;
  bool get isAdmin => (_role ?? '').toLowerCase() == 'admin';

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    _username = prefs.getString(_kUsername);
    _role = prefs.getString(_kRole);
    final idStr = prefs.getString(_kUserId);
    _userId = idStr != null ? int.tryParse(idStr) : null;

    if (_token != null && _token!.isNotEmpty) {
      try {
        final me = await _api.fetchMe(_token!);
        await _applyProfile(me, persistExtras: true);
      } catch (_) {
        await _clearSession(prefs);
      }
    }

    _ready = true;
    notifyListeners();
  }

  Future<void> _applyProfile(AuthUserEntity me, {required bool persistExtras}) async {
    _username = me.username;
    _role = me.role;
    _userId = me.id;
    if (persistExtras) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUsername, _username ?? '');
      await prefs.setString(_kRole, _role ?? '');
      await prefs.setString(_kUserId, '${_userId ?? 0}');
    }
    notifyListeners();
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    _token = null;
    _username = null;
    _role = null;
    _userId = null;
    await prefs.remove(_kToken);
    await prefs.remove(_kUsername);
    await prefs.remove(_kRole);
    await prefs.remove(_kUserId);
  }

  Future<void> register(String username, String password, {String role = ''}) async {
    await _api.register(username: username, password: password, role: role);
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username: username, password: password);
    _token = result.token;
    await _applyProfile(result.user, persistExtras: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _token ?? '');
    await prefs.setString(_kUsername, _username ?? '');
    await prefs.setString(_kRole, _role ?? '');
    await prefs.setString(_kUserId, '${_userId ?? 0}');
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_token == null || _token!.isEmpty) return;
    final me = await _api.fetchMe(_token!);
    await _applyProfile(me, persistExtras: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, _username ?? '');
    await prefs.setString(_kRole, _role ?? '');
    await prefs.setString(_kUserId, '${_userId ?? 0}');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
    notifyListeners();
  }
}
