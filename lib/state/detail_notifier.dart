import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import 'load_status.dart';

class DetailNotifier<T> extends ChangeNotifier {
  DetailNotifier(this._loader);

  final Future<T?> Function() _loader;

  LoadStatus _status = LoadStatus.idle;
  T? _item;
  String? _error;
  bool _disposed = false;

  LoadStatus get status => _status;
  T? get item => _item;
  String? get error => _error;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _item = await _loader();
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить запись: $e';
      _status = LoadStatus.error;
    }
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

class BookDetailNotifier extends DetailNotifier<Book> {
  BookDetailNotifier(BookRepository repository, int id)
      : super(() => repository.findById(id));
}

class AuthorDetailNotifier extends DetailNotifier<Author> {
  AuthorDetailNotifier(AuthorRepository repository, int id)
      : super(() => repository.findById(id));
}
