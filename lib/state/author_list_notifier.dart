import '../models/author.dart';
import '../models/author_query.dart';
import '../repositories/author_repository.dart';
import 'paged_list_notifier.dart';

class AuthorListNotifier extends PagedListNotifier<Author, AuthorQuery> {
  AuthorListNotifier(AuthorRepository repository)
      : super(
          initialQuery: const AuthorQuery(),
          find: repository.find,
          deleteMany: repository.deleteMany,
          softDelete: repository.softDelete,
          hardDelete: repository.hardDelete,
          restore: repository.restore,
          idOf: (author) => author.id,
        );
}
