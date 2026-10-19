import '../data/seed_data.dart';
import '../models/genre.dart';
import '../models/publisher.dart';
import 'reference_repository.dart';

class InMemoryReferenceRepository implements ReferenceRepository {
  @override
  Future<List<Genre>> genres() async => seedGenres;

  @override
  Future<List<Publisher>> publishers() async => seedPublishers;
}
