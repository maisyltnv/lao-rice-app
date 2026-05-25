import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';
import '../datasources/remote/api_service.dart';

class BannerRepositoryImpl implements BannerRepository {
  BannerRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<BannerEntity>> fetchActiveBanners() => _api.fetchBanners();

  @override
  Future<BannerEntity> fetchBannerById(int id) => _api.fetchBannerById(id);
}
