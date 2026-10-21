import '../data/seed_data.dart';
import '../models/author.dart';
import '../models/author_query.dart';
import 'author_repository.dart';
import 'book_repository.dart';
import 'persistent_repository.dart';

class PersistentAuthorRepository
    extends PersistentRepository<Author, AuthorQuery>
    implements AuthorRepository {
  PersistentAuthorRepository({
    required super.prefs,
    required this.books,
    List<Author>? seed,
    super.delay,
    super.failingSearch,
  }) : super(
          storageName: 'authors',
          seed: seed ?? seedAuthors,
          title: 'Авторы',
        );

  final BookRepository books;

  @override
  Author fromJson(Map<String, dynamic> json) => Author.fromJson(json);

  @override
  Map<String, dynamic> toJson(Author item) => item.toJson();

  @override
  int idOf(Author item) => item.id;

  @override
  Author withId(Author item, int id) => item.copyWith(id: id);

  @override
  bool isDeleted(Author item) => item.isDeleted;

  @override
  Author withDeletedAt(Author item, DateTime? deletedAt) => deletedAt == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: deletedAt);

  @override
  String searchOf(AuthorQuery query) => query.search;

  @override
  bool includeDeletedOf(AuthorQuery query) => query.includeDeleted;

  @override
  int pageOf(AuthorQuery query) => query.page;

  @override
  int sizeOf(AuthorQuery query) => query.size;

  @override
  bool matchesSearch(Author item, String needle) =>
      item.lastName.toLowerCase().contains(needle) ||
      item.firstName.toLowerCase().contains(needle) ||
      item.country.toLowerCase().contains(needle);

  @override
  int compareItems(Author a, Author b, AuthorQuery query) {
    final result = switch (query.sortField) {
      'country' => a.country.toLowerCase().compareTo(b.country.toLowerCase()),
      'birthYear' => a.birthYear.compareTo(b.birthYear),
      _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
    };
    return query.sortAscending ? result : -result;
  }

  @override
  Future<String?> deleteBlocker(Author item, {required bool permanent}) async {
    if (!permanent) return null;
    final count = await books.countByAuthor(item.id, includeDeleted: true);
    if (count == 0) return null;
    return 'Нельзя удалить навсегда автора «${item.fullName}»: он указан в книгах ($count). Сначала уберите его из этих книг.';
  }
}
