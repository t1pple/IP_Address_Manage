import 'package:flutter/foundation.dart';
import '../models/ip_address.dart';
import '../repositories/ip_repository.dart';
import 'settings_provider.dart';

class IpAddressesProvider extends ChangeNotifier {
  final _repo = IpRepository();
  List<IpAddress> _items = [];
  String _search = '';
  String? _versionFilter; // 'IPv4' | 'IPv6' | null
  bool _favoriteOnly = false;
  SortMode _sortMode = SortMode.updatedDesc;

  List<IpAddress> get items => _sorted(_items);
  String get search => _search;
  String? get versionFilter => _versionFilter;
  bool get favoriteOnly => _favoriteOnly;
  SortMode get sortMode => _sortMode;

  Future<void> load() async {
    _items = await _repo.getAll(
      query: _search,
      version: _versionFilter,
      favoriteOnly: _favoriteOnly,
    );
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    load();
  }

  void setVersionFilter(String? v) {
    _versionFilter = v;
    load();
  }

  void toggleFavoriteOnly() {
    _favoriteOnly = !_favoriteOnly;
    load();
  }

  void setSortMode(SortMode m) {
    _sortMode = m;
    notifyListeners();
  }

  Future<void> add(IpAddress ip) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _repo.insert(ip.copyWith(createdAt: now, updatedAt: now));
    await load();
  }

  Future<void> update(IpAddress ip) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _repo.update(ip.copyWith(updatedAt: now));
    await load();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    await load();
  }

  List<IpAddress> _sorted(List<IpAddress> list) {
    final copy = [...list];
    switch (_sortMode) {
      case SortMode.updatedDesc:
        copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortMode.labelAsc:
        copy.sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );
        break;
      case SortMode.prefixAsc:
        copy.sort((a, b) => a.prefix.compareTo(b.prefix));
        break;
      case SortMode.favoriteFirst:
        copy.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return a.label.toLowerCase().compareTo(b.label.toLowerCase());
          }
          return a.isFavorite ? -1 : 1;
        });
        break;
    }
    return copy;
  }
}
