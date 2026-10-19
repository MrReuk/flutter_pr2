import 'package:flutter/foundation.dart';

import '../repositories/author_repository.dart';
import '../repositories/reference_repository.dart';

typedef NamedOption = ({int id, String name});

class ReferenceNotifier extends ChangeNotifier {
  ReferenceNotifier(this._references, this._authors);

  final ReferenceRepository _references;
  final AuthorRepository _authors;

  Map<int, String> _genreNames = const {};
  Map<int, String> _publisherNames = const {};
  Map<int, String> _authorNames = const {};
  bool _failed = false;
  bool _disposed = false;

  bool get failed => _failed;

  List<NamedOption> get genreOptions => _options(_genreNames);
  List<NamedOption> get publisherOptions => _options(_publisherNames);

  String genreName(int id) => _genreNames[id] ?? '—';
  String publisherName(int id) => _publisherNames[id] ?? '—';
  String authorName(int id) => _authorNames[id] ?? 'Неизвестный автор';

  String genreNames(List<int> ids) => ids.map(genreName).join(', ');
  String authorNames(List<int> ids) => ids.map(authorName).join(', ');

  Future<void> load() async {
    try {
      final genres = await _references.genres();
      final publishers = await _references.publishers();
      final authors = await _authors.findAll();
      _genreNames = {for (final g in genres) g.id: g.name};
      _publisherNames = {for (final p in publishers) p.id: p.name};
      _authorNames = {for (final a in authors) a.id: a.fullName};
      _failed = false;
    } catch (_) {
      _failed = true;
    }
    notifyListeners();
  }

  List<NamedOption> _options(Map<int, String> source) {
    return [
      for (final entry in source.entries) (id: entry.key, name: entry.value),
    ];
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
