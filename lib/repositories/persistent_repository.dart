import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/page_result.dart';
import 'entity_repository.dart';
import 'repository_exception.dart';

const int kStorageVersion = 2;

abstract class PersistentRepository<T, Q> implements EntityRepository<T, Q> {
  PersistentRepository({
    required this.prefs,
    required this.storageName,
    required this.seed,
    required this.title,
    this.delay = const Duration(milliseconds: 250),
    this.failingSearch = '!error',
  });

  final SharedPreferences prefs;
  final String storageName;
  final List<T> seed;
  final String title;
  final Duration delay;
  final String failingSearch;

  final List<T> _items = [];
  int _nextId = 1;
  bool _loaded = false;
  String? restoreNotice;

  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T item);
  int idOf(T item);
  T withId(T item, int id);
  bool isDeleted(T item);
  T withDeletedAt(T item, DateTime? deletedAt);

  String searchOf(Q query);
  bool includeDeletedOf(Q query);
  int pageOf(Q query);
  int sizeOf(Q query);
  bool matchesSearch(T item, String needle);
  int compareItems(T a, T b, Q query);

  bool matchesFilters(T item, Q query) => true;

  Map<String, String> conflicts(T item, List<T> others) => const {};

  Future<String?> deleteBlocker(T item, {required bool permanent}) async => null;

  String get currentKey => '${storageName}_v$kStorageVersion';

  String get legacyKey => '${storageName}_v1';

  void load() {
    if (_loaded) return;
    _loaded = true;

    final current = prefs.getString(currentKey);
    if (current != null) {
      final parsed = _parse(current, wrapped: true);
      if (parsed == null) {
        _resetToSeed(
          'Сохранённые данные раздела «$title» повреждены или имеют другой формат. Загружен начальный набор.',
        );
      } else {
        _items
          ..clear()
          ..addAll(parsed);
      }
    } else {
      final legacy = prefs.getString(legacyKey);
      if (legacy == null) {
        _resetToSeed(null);
      } else {
        final parsed = _parse(legacy, wrapped: false);
        if (parsed == null) {
          _resetToSeed(
            'Данные раздела «$title» устаревшего формата не удалось перенести. Загружен начальный набор.',
          );
        } else {
          _items
            ..clear()
            ..addAll(parsed);
          restoreNotice =
              'Данные раздела «$title» перенесены на новый формат хранения.';
          unawaited(_persist());
        }
        unawaited(prefs.remove(legacyKey));
      }
    }

    var maxId = 0;
    for (final item in _items) {
      if (idOf(item) > maxId) maxId = idOf(item);
    }
    _nextId = maxId + 1;
  }

  void _resetToSeed(String? notice) {
    _items
      ..clear()
      ..addAll(seed);
    restoreNotice = notice;
    unawaited(_persist());
  }

  List<T>? _parse(String raw, {required bool wrapped}) {
    try {
      final decoded = jsonDecode(raw);
      final List list;
      if (wrapped) {
        if (decoded is! Map || decoded['version'] != kStorageVersion) {
          return null;
        }
        list = decoded['items'] as List;
      } else {
        list = decoded as List;
      }
      return <T>[
        for (final element in list) fromJson(Map<String, dynamic>.from(element as Map)),
      ];
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    final payload = jsonEncode({
      'version': kStorageVersion,
      'items': [for (final item in _items) toJson(item)],
    });
    await prefs.setString(currentKey, payload);
  }

  int _indexOf(int id) => _items.indexWhere((item) => idOf(item) == id);

  void _checkConflicts(T item) {
    final others = _items.where((e) => idOf(e) != idOf(item)).toList();
    final found = conflicts(item, others);
    if (found.isNotEmpty) throw FieldConflictException(found);
  }

  @override
  Future<PageResult<T>> find(Q query) async {
    await Future.delayed(delay);
    load();

    final needle = searchOf(query).trim();
    if (failingSearch.isNotEmpty && needle == failingSearch) {
      throw const RepositoryException('Сервер недоступен (имитация ошибки)');
    }

    var rows = _items
        .where((e) => includeDeletedOf(query) || !isDeleted(e))
        .where((e) => matchesFilters(e, query))
        .toList();

    if (needle.isNotEmpty) {
      final lower = needle.toLowerCase();
      rows = rows.where((e) => matchesSearch(e, lower)).toList();
    }

    rows.sort((a, b) {
      final result = compareItems(a, b, query);
      return result != 0 ? result : idOf(a).compareTo(idOf(b));
    });

    return PageResult.slice(rows, page: pageOf(query), size: sizeOf(query));
  }

  @override
  Future<List<T>> findAll() async {
    load();
    return List<T>.unmodifiable(_items);
  }

  @override
  Future<T?> findById(int id) async {
    await Future.delayed(delay);
    load();
    final i = _indexOf(id);
    return i == -1 ? null : _items[i];
  }

  @override
  Future<T> create(T item) async {
    load();
    _checkConflicts(item);
    final created = withDeletedAt(withId(item, _nextId++), null);
    _items.add(created);
    await _persist();
    return created;
  }

  @override
  Future<T> update(T item) async {
    load();
    final i = _indexOf(idOf(item));
    if (i == -1) throw RepositoryException('Запись №${idOf(item)} не найдена');
    _checkConflicts(item);
    _items[i] = item;
    await _persist();
    return item;
  }

  @override
  Future<void> softDelete(int id) async {
    load();
    final i = _indexOf(id);
    if (i == -1) throw RepositoryException('Запись №$id не найдена');
    final blocker = await deleteBlocker(_items[i], permanent: false);
    if (blocker != null) throw DeleteBlockedException(blocker);
    _items[i] = withDeletedAt(_items[i], DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    load();
    final i = _indexOf(id);
    if (i == -1) return;
    final blocker = await deleteBlocker(_items[i], permanent: true);
    if (blocker != null) throw DeleteBlockedException(blocker);
    _items.removeAt(i);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    load();
    final i = _indexOf(id);
    if (i == -1) throw RepositoryException('Запись №$id не найдена');
    _items[i] = withDeletedAt(_items[i], null);
    await _persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    load();
    var count = 0;
    for (final id in ids) {
      final i = _indexOf(id);
      if (i == -1 || isDeleted(_items[i])) continue;
      final blocker = await deleteBlocker(_items[i], permanent: false);
      if (blocker != null) continue;
      _items[i] = withDeletedAt(_items[i], DateTime.now());
      count++;
    }
    if (count > 0) await _persist();
    return count;
  }
}
