import '../data/seed_data.dart';
import '../models/genre.dart';
import '../models/simple_query.dart';
import 'book_repository.dart';
import 'entity_repository.dart';
import 'persistent_repository.dart';

class PersistentGenreRepository extends PersistentRepository<Genre, SimpleQuery>
    implements GenreRepository {
  PersistentGenreRepository({
    required super.prefs,
    required this.books,
    List<Genre>? seed,
    super.delay,
    super.failingSearch,
  }) : super(
          storageName: 'genres',
          seed: seed ?? seedGenres,
          title: 'Жанры',
        );

  final BookRepository books;

  @override
  Genre fromJson(Map<String, dynamic> json) => Genre.fromJson(json);

  @override
  Map<String, dynamic> toJson(Genre item) => item.toJson();

  @override
  int idOf(Genre item) => item.id;

  @override
  Genre withId(Genre item, int id) => item.copyWith(id: id);

  @override
  bool isDeleted(Genre item) => item.isDeleted;

  @override
  Genre withDeletedAt(Genre item, DateTime? deletedAt) => deletedAt == null
      ? item.copyWith(clearDeletedAt: true)
      : item.copyWith(deletedAt: deletedAt);

  @override
  String searchOf(SimpleQuery query) => query.search;

  @override
  bool includeDeletedOf(SimpleQuery query) => query.includeDeleted;

  @override
  int pageOf(SimpleQuery query) => query.page;

  @override
  int sizeOf(SimpleQuery query) => query.size;

  @override
  bool matchesSearch(Genre item, String needle) =>
      item.name.toLowerCase().contains(needle) ||
      item.description.toLowerCase().contains(needle);

  @override
  int compareItems(Genre a, Genre b, SimpleQuery query) {
    final result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return query.sortAscending ? result : -result;
  }

  @override
  Map<String, String> conflicts(Genre item, List<Genre> others) {
    final wanted = item.name.trim().toLowerCase();
    for (final other in others) {
      if (other.name.trim().toLowerCase() == wanted) {
        return {'name': 'Жанр с таким названием уже есть'};
      }
    }
    return const {};
  }

  @override
  Future<String?> deleteBlocker(Genre item, {required bool permanent}) async {
    if (!permanent) return null;
    final count = await books.countByGenre(item.id, includeDeleted: true);
    if (count == 0) return null;
    return 'Нельзя удалить навсегда жанр «${item.name}»: он указан в книгах ($count). Сначала уберите его из этих книг.';
  }
}
