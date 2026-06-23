import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/profile_avatar_store.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../domain/entities/auth_user_entity.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiService _api;

  static const _kToken = 'auth_token';
  static const _kUsername = 'auth_username';
  static const _kPhone = 'auth_phone';
  static const _kRole = 'auth_role';
  static const _kUserId = 'auth_user_id';

  String? _token;
  AuthUserEntity? _me;
  bool _ready = false;
  String? _localAvatarPath;

  String? get token => _token;
  String? get username => _me?.username ?? '';
  String? get phone => _me?.displayPhone;
  String? get role => _me?.role;
  int? get userId => _me?.id;
  AuthUserEntity? get profile => _me;
  String get recipientName => _me?.recipientName ?? '';
  String get addressDetail => _me?.addressDetail ?? '';
  double get deliveryLatitude => _me?.deliveryLatitude ?? 0;
  double get deliveryLongitude => _me?.deliveryLongitude ?? 0;
  bool get hasSavedShipping => _me?.hasSavedShipping ?? false;
  bool get hasDeliveryPin => _me?.hasDeliveryPin ?? false;
  bool get isReady => _ready;
  bool get isSignedIn => _token != null && _token!.isNotEmpty;
  bool get isAdmin => (_me?.role ?? '').toLowerCase() == 'admin';
  String? get localAvatarPath => _localAvatarPath;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);

    if (_token != null && _token!.isNotEmpty) {
      try {
        final me = await _api.fetchMe(_token!);
        await _applyProfile(me, persistExtras: true);
      } catch (_) {
        await _clearSession(prefs);
      }
    }

    _ready = true;
    await _loadLocalAvatar();
    notifyListeners();
  }

  Future<void> _loadLocalAvatar() async {
    _localAvatarPath = await ProfileAvatarStore.loadPath(userId);
  }

  Future<void> saveLocalAvatar(List<int> bytes) async {
    final id = userId;
    if (id == null) throw StateError('not signed in');
    _localAvatarPath = await ProfileAvatarStore.save(id, bytes);
    notifyListeners();
  }

  Future<void> clearLocalAvatar() async {
    await ProfileAvatarStore.clear(userId);
    _localAvatarPath = null;
    notifyListeners();
  }

  Future<void> _applyProfile(AuthUserEntity me, {required bool persistExtras}) async {
    _me = me;
    if (persistExtras) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUsername, me.username);
      await prefs.setString(_kPhone, me.displayPhone);
      await prefs.setString(_kRole, me.role);
      await prefs.setString(_kUserId, '${me.id}');
    }
    await _loadLocalAvatar();
    notifyListeners();
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    _token = null;
    _me = null;
    _localAvatarPath = null;
    await prefs.remove(_kToken);
    await prefs.remove(_kUsername);
    await prefs.remove(_kPhone);
    await prefs.remove(_kRole);
    await prefs.remove(_kUserId);
  }

  Future<void> register(String username, String password, {String role = ''}) async {
    await _api.register(username: username, password: password, role: role);
  }

  Future<void> sendPhoneOtp(String phone) async {
    await _api.sendPhoneOtp(phone);
  }

  Future<void> loginWithPhoneOtp(String phone, String code) async {
    final result = await _api.verifyPhoneOtp(phone: phone, code: code);
    _token = result.token;
    await _applyProfile(result.user, persistExtras: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _token ?? '');
    await prefs.setString(_kPhone, phone);
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username: username, password: password);
    _token = result.token;
    await _applyProfile(result.user, persistExtras: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _token ?? '');
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_token == null || _token!.isEmpty) return;
    final me = await _api.fetchMe(_token!);
    await _applyProfile(me, persistExtras: true);
  }

  Future<void> updateCustomerProfile({
    required String recipientName,
    required String shippingPhone,
    required String addressDetail,
    required double deliveryLatitude,
    required double deliveryLongitude,
    String province = 'ນະຄອນຫຼວງວຽງຈັນ',
  }) async {
    if (_token == null || _token!.isEmpty) {
      throw StateError('not signed in');
    }
    final updated = await _api.updateCustomerProfile(
      accessToken: _token!,
      recipientName: recipientName,
      shippingPhone: shippingPhone,
      addressDetail: addressDetail,
      province: province,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );
    await _applyProfile(updated, persistExtras: true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
    notifyListeners();
  }

  /// Permanently deletes the account on the server, then clears the local session.
  Future<void> deleteAccount() async {
    if (_token == null || _token!.isEmpty) {
      throw StateError('not signed in');
    }
    await _api.deleteAccount(_token!);
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
    notifyListeners();
  }
}
