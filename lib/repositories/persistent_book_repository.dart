import '../data/seed_data.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import 'book_repository.dart';
import 'persistent_repository.dart';

String normalizeIsbn(String value) =>
    value.replaceAll('-', '').replaceAll(' ', '').toLowerCase();

class PersistentBookRepository extends PersistentRepository<Book, BookQuery>
    implements BookRepository {
  PersistentBookRepository({
    required super.prefs,
    List<Book>? seed,
    super.delay,
    super.failingSearch,
  }) : super(
          storageName: 'books',
          seed: seed ?? seedBooks,
          title: 'Книги',
        );

  @override
  Book fromJson(Map<String, dynamic> json) => Book.fromJson(json);

  @override
  Map<String, dynamic> toJson(Book item) => item.toJson();

  @override
  int idOf(Book item) => item.id;

  @override
  Book withId(Book item, int id) => item.copyWith(id: id);

  @override
  bool isDeleted(Book item) => item.isDeleted;

  @override
  Book withDeletedAt(Book item, DateTime? deletedAt) => deletedAt == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: deletedAt);

  @override
  String searchOf(BookQuery query) => query.search;

  @override
  bool includeDeletedOf(BookQuery query) => query.includeDeleted;

  @override
  int pageOf(BookQuery query) => query.page;

  @override
  int sizeOf(BookQuery query) => query.size;

  @override
  bool matchesSearch(Book item, String needle) =>
      item.title.toLowerCase().contains(needle) ||
      item.isbn.toLowerCase().contains(needle);

  @override
  bool matchesFilters(Book item, BookQuery query) {
    if (query.genreId != null && !item.genreIds.contains(query.genreId)) {
      return false;
    }
    if (query.publisherId != null && item.publisherId != query.publisherId) {
      return false;
    }
    if (query.yearFrom != null && item.year < query.yearFrom!) return false;
    if (query.yearTo != null && item.year > query.yearTo!) return false;
    return true;
  }

  @override
  int compareItems(Book a, Book b, BookQuery query) {
    final result = switch (query.sortField) {
      'year' => a.year.compareTo(b.year),
      'pages' => a.pages.compareTo(b.pages),
      _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    };
    return query.sortAscending ? result : -result;
  }

  @override
  Map<String, String> conflicts(Book item, List<Book> others) {
    final wanted = normalizeIsbn(item.isbn);
    for (final other in others) {
      if (normalizeIsbn(other.isbn) == wanted) {
        return {
          'isbn': other.isDeleted
              ? 'Книга с таким ISBN есть среди удалённых: «${other.title}»'
              : 'Книга с таким ISBN уже есть: «${other.title}»',
        };
      }
    }
    return const {};
  }

  Future<int> _count(bool Function(Book) test, bool includeDeleted) async {
    final all = await findAll();
    return all.where((b) => (includeDeleted || !b.isDeleted) && test(b)).length;
  }

  @override
  Future<int> countByPublisher(int publisherId, {bool includeDeleted = false}) =>
      _count((b) => b.publisherId == publisherId, includeDeleted);

  @override
  Future<int> countByGenre(int genreId, {bool includeDeleted = false}) =>
      _count((b) => b.genreIds.contains(genreId), includeDeleted);

  @override
  Future<int> countByAuthor(int authorId, {bool includeDeleted = false}) =>
      _count((b) => b.authorIds.contains(authorId), includeDeleted);
}
