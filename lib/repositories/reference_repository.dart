import '../models/genre.dart';
import '../models/publisher.dart';

abstract interface class ReferenceRepository {
  Future<List<Genre>> genres();
  Future<List<Publisher>> publishers();
}
