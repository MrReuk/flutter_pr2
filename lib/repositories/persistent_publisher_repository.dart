import '../data/seed_data.dart';
import '../models/publisher.dart';
import '../models/simple_query.dart';
import 'book_repository.dart';
import 'entity_repository.dart';
import 'persistent_repository.dart';

class PersistentPublisherRepository
    extends PersistentRepository<Publisher, SimpleQuery>
    implements PublisherRepository {
  PersistentPublisherRepository({
    required super.prefs,
    required this.books,
    List<Publisher>? seed,
    super.delay,
    super.failingSearch,
  }) : super(
          storageName: 'publishers',
          seed: seed ?? seedPublishers,
          title: 'Издательства',
        );

  final BookRepository books;

  @override
  Publisher fromJson(Map<String, dynamic> json) => Publisher.fromJson(json);

  @override
  Map<String, dynamic> toJson(Publisher item) => item.toJson();

  @override
  int idOf(Publisher item) => item.id;

  @override
  Publisher withId(Publisher item, int id) => item.copyWith(id: id);

  @override
  bool isDeleted(Publisher item) => item.isDeleted;

  @override
  Publisher withDeletedAt(Publisher item, DateTime? deletedAt) =>
      deletedAt == null
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
  bool matchesSearch(Publisher item, String needle) =>
      item.name.toLowerCase().contains(needle) ||
      item.country.toLowerCase().contains(needle) ||
      item.email.toLowerCase().contains(needle);

  @override
  bool matchesFilters(Publisher item, SimpleQuery query) =>
      query.filter.isEmpty || item.country == query.filter;

  @override
  int compareItems(Publisher a, Publisher b, SimpleQuery query) {
    final result = switch (query.sortField) {
      'foundedYear' => a.foundedYear.compareTo(b.foundedYear),
      'country' => a.country.toLowerCase().compareTo(b.country.toLowerCase()),
      _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };
    return query.sortAscending ? result : -result;
  }

  @override
  Map<String, String> conflicts(Publisher item, List<Publisher> others) {
    final wanted = item.name.trim().toLowerCase();
    for (final other in others) {
      if (other.name.trim().toLowerCase() == wanted) {
        return {'name': 'Издательство с таким названием уже есть'};
      }
    }
    return const {};
  }

  @override
  Future<String?> deleteBlocker(
    Publisher item, {
    required bool permanent,
  }) async {
    final count = await books.countByPublisher(
      item.id,
      includeDeleted: permanent,
    );
    if (count == 0) return null;
    return 'Нельзя удалить издательство «${item.name}»: у него есть книги ($count). Сначала измените издательство у этих книг или удалите их.';
  }
}
