import '../data/seed_data.dart';
import '../models/author.dart';
import '../models/author_query.dart';
import '../models/page_result.dart';
import 'author_repository.dart';
import 'repository_exception.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  InMemoryAuthorRepository({
    this.delay = const Duration(milliseconds: 250),
    this.failingSearch = '!error',
  });

  final Duration delay;
  final String failingSearch;
  final List<Author> _authors = [...seedAuthors];
  int _nextId = seedAuthors.length + 1;

  @override
  Future<PageResult<Author>> find(AuthorQuery q) async {
    await Future.delayed(delay);

    if (failingSearch.isNotEmpty && q.search.trim() == failingSearch) {
      throw const RepositoryException('Сервер недоступен (имитация ошибки)');
    }

    var rows = _authors.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((a) =>
              a.lastName.toLowerCase().contains(needle) ||
              a.country.toLowerCase().contains(needle))
          .toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'country' => a.country.toLowerCase().compareTo(b.country.toLowerCase()),
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      final directed = q.sortAscending ? result : -result;
      return directed != 0 ? directed : a.id.compareTo(b.id);
    });

    return PageResult.slice(rows, page: q.page, size: q.size);
  }

  @override
  Future<List<Author>> findAll() async => List.unmodifiable(_authors);

  @override
  Future<Author?> findById(int id) async {
    await Future.delayed(delay);
    final i = _authors.indexWhere((a) => a.id == id);
    return i == -1 ? null : _authors[i];
  }

  @override
  Future<Author> create(Author author) async {
    final created = author.copyWith(id: _nextId++, clearDeletedAt: true);
    _authors.add(created);
    return created;
  }

  @override
  Future<Author> update(Author author) async {
    final i = _authors.indexWhere((a) => a.id == author.id);
    if (i == -1) throw RepositoryException('Автор ${author.id} не найден');
    _authors[i] = author;
    return author;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw RepositoryException('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _authors.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _authors.indexWhere((a) => a.id == id);
    if (i == -1) throw RepositoryException('Автор $id не найден');
    _authors[i] = _authors[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        _authors[i] = _authors[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
