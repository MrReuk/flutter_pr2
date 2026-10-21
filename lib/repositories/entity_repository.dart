import '../models/genre.dart';
import '../models/page_result.dart';
import '../models/publisher.dart';
import '../models/reader.dart';
import '../models/simple_query.dart';

abstract interface class EntityRepository<T, Q> {
  Future<PageResult<T>> find(Q query);
  Future<List<T>> findAll();
  Future<T?> findById(int id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

typedef GenreRepository = EntityRepository<Genre, SimpleQuery>;
typedef PublisherRepository = EntityRepository<Publisher, SimpleQuery>;
typedef ReaderRepository = EntityRepository<Reader, SimpleQuery>;
