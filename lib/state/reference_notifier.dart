import 'package:flutter/foundation.dart';

import '../models/named_option.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/entity_repository.dart';

const String kDeletedSuffix = ' (удалено)';

class ReferenceNotifier extends ChangeNotifier {
  ReferenceNotifier({
    required GenreRepository genres,
    required PublisherRepository publishers,
    required AuthorRepository authors,
    required BookRepository books,
  })  : _genres = genres,
        _publishers = publishers,
        _authors = authors,
        _books = books;

  final GenreRepository _genres;
  final PublisherRepository _publishers;
  final AuthorRepository _authors;
  final BookRepository _books;

  Map<int, String> _genreNames = const {};
  Map<int, String> _publisherNames = const {};
  Map<int, String> _authorNames = const {};
  Set<int> _deletedGenres = const {};
  Set<int> _deletedPublishers = const {};
  Set<int> _deletedAuthors = const {};
  Map<int, Set<int>> _authorsByPublisher = const {};
  List<String> _countries = const [];
  bool _ready = false;
  bool _failed = false;
  bool _disposed = false;

  bool get ready => _ready;
  bool get failed => _failed;
  List<String> get countries => _countries;

  String genreName(int id) => _label(_genreNames, _deletedGenres, id, '—');
  String publisherName(int id) =>
      _label(_publisherNames, _deletedPublishers, id, '—');
  String authorName(int id) =>
      _label(_authorNames, _deletedAuthors, id, 'Неизвестный автор');

  String genreNames(List<int> ids) => ids.map(genreName).join(', ');
  String authorNames(List<int> ids) => ids.map(authorName).join(', ');

  List<NamedOption> genreOptions({Iterable<int> keep = const []}) =>
      _options(_genreNames, _deletedGenres, keep);

  List<NamedOption> publisherOptions({Iterable<int> keep = const []}) =>
      _options(_publisherNames, _deletedPublishers, keep);

  List<NamedOption> authorOptions({Iterable<int> keep = const []}) =>
      _options(_authorNames, _deletedAuthors, keep);

  List<NamedOption> authorOptionsForPublisher(
    int? publisherId, {
    Iterable<int> keep = const [],
  }) {
    final ids = publisherId == null ? null : _authorsByPublisher[publisherId];
    if (ids == null || ids.isEmpty) return const [];
    return _options(_authorNames, _deletedAuthors, keep)
        .where((o) => ids.contains(o.id) || keep.contains(o.id))
        .toList();
  }

  Future<void> load() async {
    try {
      final genres = await _genres.findAll();
      final publishers = await _publishers.findAll();
      final authors = await _authors.findAll();
      final books = await _books.findAll();

      _genreNames = {for (final g in genres) g.id: g.name};
      _publisherNames = {for (final p in publishers) p.id: p.name};
      _authorNames = {for (final a in authors) a.id: a.fullName};
      _deletedGenres = {for (final g in genres) if (g.isDeleted) g.id};
      _deletedPublishers = {for (final p in publishers) if (p.isDeleted) p.id};
      _deletedAuthors = {for (final a in authors) if (a.isDeleted) a.id};

      final byPublisher = <int, Set<int>>{};
      for (final book in books) {
        if (book.isDeleted) continue;
        byPublisher.putIfAbsent(book.publisherId, () => <int>{}).addAll(book.authorIds);
      }
      _authorsByPublisher = byPublisher;

      final countries = <String>{
        for (final p in publishers)
          if (!p.isDeleted && p.country.trim().isNotEmpty) p.country,
      }.toList()
        ..sort();
      _countries = countries;

      _failed = false;
      _ready = true;
    } catch (_) {
      _failed = true;
    }
    notifyListeners();
  }

  String _label(Map<int, String> names, Set<int> deleted, int id, String fallback) {
    final name = names[id];
    if (name == null) return fallback;
    return deleted.contains(id) ? '$name$kDeletedSuffix' : name;
  }

  List<NamedOption> _options(
    Map<int, String> names,
    Set<int> deleted,
    Iterable<int> keep,
  ) {
    final keepSet = keep.toSet();
    final list = <NamedOption>[
      for (final entry in names.entries)
        if (!deleted.contains(entry.key) || keepSet.contains(entry.key))
          (
            id: entry.key,
            name: deleted.contains(entry.key)
                ? '${entry.value}$kDeletedSuffix'
                : entry.value,
          ),
    ];
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
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
