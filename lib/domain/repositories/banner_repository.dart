import '../entities/banner_entity.dart';

abstract class BannerRepository {
  Future<List<BannerEntity>> fetchActiveBanners();

  Future<BannerEntity> fetchBannerById(int id);
}
