import '../data/seed_data.dart';
import '../models/reader.dart';
import '../models/simple_query.dart';
import 'entity_repository.dart';
import 'persistent_repository.dart';

class PersistentReaderRepository extends PersistentRepository<Reader, SimpleQuery>
    implements ReaderRepository {
  PersistentReaderRepository({
    required super.prefs,
    List<Reader>? seed,
    super.delay,
    super.failingSearch,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now,
        super(
          storageName: 'readers',
          seed: seed ?? seedReaders,
          title: 'Читатели',
        );

  final DateTime Function() _clock;

  @override
  Reader fromJson(Map<String, dynamic> json) => Reader.fromJson(json);

  @override
  Map<String, dynamic> toJson(Reader item) => item.toJson();

  @override
  int idOf(Reader item) => item.id;

  @override
  Reader withId(Reader item, int id) => item.copyWith(id: id);

  @override
  bool isDeleted(Reader item) => item.isDeleted;

  @override
  Reader withDeletedAt(Reader item, DateTime? deletedAt) => deletedAt == null
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
  bool matchesSearch(Reader item, String needle) =>
      item.lastName.toLowerCase().contains(needle) ||
      item.firstName.toLowerCase().contains(needle) ||
      item.email.toLowerCase().contains(needle) ||
      item.card.number.toLowerCase().contains(needle);

  @override
  bool matchesFilters(Reader item, SimpleQuery query) {
    if (query.filter == 'expired') return item.card.isExpiredAt(_clock());
    if (query.filter == 'active') return !item.card.isExpiredAt(_clock());
    return true;
  }

  @override
  int compareItems(Reader a, Reader b, SimpleQuery query) {
    final result = switch (query.sortField) {
      'email' => a.email.toLowerCase().compareTo(b.email.toLowerCase()),
      'expiresAt' => a.card.expiresAt.compareTo(b.card.expiresAt),
      _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
    };
    return query.sortAscending ? result : -result;
  }

  @override
  Map<String, String> conflicts(Reader item, List<Reader> others) {
    final errors = <String, String>{};
    final email = item.email.trim().toLowerCase();
    final number = item.card.number.trim().toLowerCase();
    for (final other in others) {
      if (!errors.containsKey('email') &&
          other.email.trim().toLowerCase() == email) {
        errors['email'] = other.isDeleted
            ? 'Этот email есть у удалённого читателя: ${other.fullName}'
            : 'Читатель с таким email уже есть: ${other.fullName}';
      }
      if (!errors.containsKey('cardNumber') &&
          other.card.number.trim().toLowerCase() == number) {
        errors['cardNumber'] = 'Билет с таким номером уже выдан: ${other.fullName}';
      }
    }
    return errors;
  }
}
