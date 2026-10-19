import '../models/book.dart';
import '../models/book_query.dart';
import '../repositories/book_repository.dart';
import 'paged_list_notifier.dart';

class BookListNotifier extends PagedListNotifier<Book, BookQuery> {
  BookListNotifier(BookRepository repository)
      : super(
          initialQuery: const BookQuery(),
          find: repository.find,
          deleteMany: repository.deleteMany,
          softDelete: repository.softDelete,
          hardDelete: repository.hardDelete,
          restore: repository.restore,
          idOf: (book) => book.id,
        );
}
