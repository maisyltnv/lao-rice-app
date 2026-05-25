import 'package:flutter/foundation.dart';

import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';

class BannersProvider extends ChangeNotifier {
  BannersProvider(this._repository);

  final BannerRepository _repository;

  List<BannerEntity> _banners = const [];
  bool _loading = false;
  String? _error;
  bool _disposed = false;

  List<BannerEntity> get banners => _banners;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get hasBanners => _banners.isNotEmpty;

  Future<void> load() async {
    _loading = true;
    _error = null;
    _safeNotify();

    try {
      final items = await _repository.fetchActiveBanners();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _banners = items;
    } catch (e) {
      _error = e.toString();
      _banners = const [];
    } finally {
      _loading = false;
      _safeNotify();
    }
  }

  Future<BannerEntity?> fetchById(int id) async {
    try {
      return await _repository.fetchBannerById(id);
    } catch (_) {
      return null;
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
