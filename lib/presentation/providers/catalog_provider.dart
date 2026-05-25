import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/rice_images.dart';
import '../../core/utils/product_image_url_resolver.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository);

  final CatalogRepository _repository;

  List<CategoryEntity> _categories = const [];
  List<ProductEntity> _products = const [];
  int _total = 0;
  bool _loading = false;
  String? _error;
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _disposed = false;
  Timer? _searchDebounce;
  int _requestGen = 0;

  List<CategoryEntity> get categories => _categories;
  List<ProductEntity> get products => _products;
  int get total => _total;
  bool get isLoading => _loading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.trim().isNotEmpty;

  List<({int? id, String label})> get categoryChips {
    return [
      (id: null, label: 'ທັງໝົດ'),
      ..._categories.map((c) => (id: c.id, label: c.name)),
    ];
  }

  Future<void> load() => _fetchProducts();

  void setSearchQuery(String query) {
    _searchQuery = query;
    _safeNotify();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (_disposed) return;
      _fetchProducts();
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _fetchProducts();
  }

  void selectCategory(int? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final gen = ++_requestGen;
    final q = _searchQuery.trim();

    _loading = true;
    _error = null;
    _safeNotify();

    try {
      if (_categories.isEmpty) {
        _categories = await _repository.fetchCategories();
      }

      final page = await _repository.fetchProducts(
        limit: 200,
        offset: 0,
        categoryId: _selectedCategoryId,
        q: q.isEmpty ? null : q,
      );

      if (gen != _requestGen || _disposed) return;

      _products = page.items;
      _total = page.total;
      _error = null;
      unawaited(_preloadImageUrls(_products));
    } catch (e) {
      if (gen != _requestGen || _disposed) return;
      _error = e is ApiException ? e.messageOrBody : e.toString();
      _products = const [];
      _total = 0;
    } finally {
      if (gen == _requestGen && !_disposed) {
        _loading = false;
        _safeNotify();
      }
    }
  }

  Future<void> _preloadImageUrls(List<ProductEntity> products) async {
    final urls = products
        .map((p) => p.imageUrl)
        .where(
          (u) =>
              u.trim().isNotEmpty &&
              !RiceImages.isBundledAssetPath(u) &&
              !RiceImages.shouldUseAsset(u),
        )
        .toSet();
    await Future.wait(urls.map(ProductImageUrlResolver.shared.resolve));
  }

  Future<ProductEntity?> fetchProductById(int id) async {
    try {
      return await _repository.fetchProductById(id);
    } catch (_) {
      return _products.where((p) => p.id == id).firstOrNull;
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchDebounce?.cancel();
    super.dispose();
  }
}
