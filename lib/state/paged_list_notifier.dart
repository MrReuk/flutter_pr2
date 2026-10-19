import 'package:flutter/foundation.dart';

import '../models/page_result.dart';
import 'load_status.dart';

class PagedListNotifier<T, Q> extends ChangeNotifier {
  PagedListNotifier({
    required Q initialQuery,
    required Future<PageResult<T>> Function(Q query) find,
    required Future<int> Function(List<int> ids) deleteMany,
    required Future<void> Function(int id) softDelete,
    required Future<void> Function(int id) hardDelete,
    required Future<void> Function(int id) restore,
    required int Function(T item) idOf,
  })  : _query = initialQuery,
        _find = find,
        _deleteMany = deleteMany,
        _softDelete = softDelete,
        _hardDelete = hardDelete,
        _restore = restore,
        _idOf = idOf;

  final Future<PageResult<T>> Function(Q query) _find;
  final Future<int> Function(List<int> ids) _deleteMany;
  final Future<void> Function(int id) _softDelete;
  final Future<void> Function(int id) _hardDelete;
  final Future<void> Function(int id) _restore;
  final int Function(T item) _idOf;

  Q _query;
  PageResult<T> _result = PageResult<T>.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};
  int _requestId = 0;
  bool _disposed = false;

  Q get query => _query;
  PageResult<T> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    final requestId = ++_requestId;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _find(_query);
      if (requestId != _requestId) return;
      _result = loaded;
      _status = LoadStatus.success;
    } catch (e) {
      if (requestId != _requestId) return;
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(Q next, {bool force = false}) async {
    if (!force && next == _query) return;
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  void setAllSelected(bool value) {
    final ids = _result.items.map(_idOf);
    if (value) {
      _selected.addAll(ids);
    } else {
      _selected.removeAll(ids);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }

  Future<void> softDelete(int id) => _perform(() => _softDelete(id), id);

  Future<void> hardDelete(int id) => _perform(() => _hardDelete(id), id);

  Future<void> restore(int id) => _perform(() => _restore(id), id);

  Future<int> deleteSelected() async {
    final ids = _selected.toList();
    try {
      final count = await _deleteMany(ids);
      _selected.clear();
      await load();
      return count;
    } catch (e) {
      _fail(e);
      return 0;
    }
  }

  Future<void> _perform(Future<void> Function() action, int id) async {
    try {
      await action();
      _selected.remove(id);
      await load();
    } catch (e) {
      _fail(e);
    }
  }

  void _fail(Object e) {
    _error = 'Не удалось выполнить операцию: $e';
    _status = LoadStatus.error;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
