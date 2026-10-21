import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/persistent_author_repository.dart';
import 'repositories/persistent_book_repository.dart';
import 'repositories/persistent_genre_repository.dart';
import 'repositories/persistent_publisher_repository.dart';
import 'repositories/persistent_reader_repository.dart';

class AppRepositories {
  AppRepositories(
    SharedPreferences prefs, {
    Duration delay = const Duration(milliseconds: 250),
    String failingSearch = '!error',
  }) {
    books = PersistentBookRepository(
      prefs: prefs,
      delay: delay,
      failingSearch: failingSearch,
    );
    authors = PersistentAuthorRepository(
      prefs: prefs,
      books: books,
      delay: delay,
      failingSearch: failingSearch,
    );
    genres = PersistentGenreRepository(
      prefs: prefs,
      books: books,
      delay: delay,
      failingSearch: failingSearch,
    );
    publishers = PersistentPublisherRepository(
      prefs: prefs,
      books: books,
      delay: delay,
      failingSearch: failingSearch,
    );
    readers = PersistentReaderRepository(
      prefs: prefs,
      delay: delay,
      failingSearch: failingSearch,
    );

    books.load();
    authors.load();
    genres.load();
    publishers.load();
    readers.load();
  }

  late final PersistentBookRepository books;
  late final PersistentAuthorRepository authors;
  late final PersistentGenreRepository genres;
  late final PersistentPublisherRepository publishers;
  late final PersistentReaderRepository readers;

  List<String> get notices => [
        ?books.restoreNotice,
        ?authors.restoreNotice,
        ?genres.restoreNotice,
        ?publishers.restoreNotice,
        ?readers.restoreNotice,
      ];
}
