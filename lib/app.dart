import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_repositories.dart';
import 'models/author.dart';
import 'models/author_query.dart';
import 'models/book.dart';
import 'models/book_query.dart';
import 'models/genre.dart';
import 'models/publisher.dart';
import 'models/reader.dart';
import 'models/simple_query.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/entity_repository.dart';
import 'router.dart';
import 'state/paged_list_notifier.dart';
import 'state/reference_notifier.dart';

class LibraryApp extends StatefulWidget {
  const LibraryApp({
    super.key,
    required this.repositories,
    this.initialLocation = '/books',
  });

  final AppRepositories repositories;
  final String initialLocation;

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  late final GoRouter _router = buildRouter(initialLocation: widget.initialLocation);
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = _messengerKey.currentState;
      if (messenger == null) return;
      for (final notice in widget.repositories.notices) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(notice),
            duration: const Duration(seconds: 10),
            showCloseIcon: true,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repos = widget.repositories;

    return MultiProvider(
      providers: [
        Provider<BookRepository>.value(value: repos.books),
        Provider<AuthorRepository>.value(value: repos.authors),
        Provider<GenreRepository>.value(value: repos.genres),
        Provider<PublisherRepository>.value(value: repos.publishers),
        Provider<ReaderRepository>.value(value: repos.readers),
        ChangeNotifierProvider<PagedListNotifier<Book, BookQuery>>(
          create: (_) => PagedListNotifier<Book, BookQuery>(
            initialQuery: const BookQuery(),
            repository: repos.books,
            idOf: (book) => book.id,
          ),
        ),
        ChangeNotifierProvider<PagedListNotifier<Author, AuthorQuery>>(
          create: (_) => PagedListNotifier<Author, AuthorQuery>(
            initialQuery: const AuthorQuery(),
            repository: repos.authors,
            idOf: (author) => author.id,
          ),
        ),
        ChangeNotifierProvider<PagedListNotifier<Genre, SimpleQuery>>(
          create: (_) => PagedListNotifier<Genre, SimpleQuery>(
            initialQuery: SimpleQuery.initial(
              sortFields: kGenreSortFields,
              defaultSort: 'name',
            ),
            repository: repos.genres,
            idOf: (genre) => genre.id,
          ),
        ),
        ChangeNotifierProvider<PagedListNotifier<Publisher, SimpleQuery>>(
          create: (_) => PagedListNotifier<Publisher, SimpleQuery>(
            initialQuery: SimpleQuery.initial(
              sortFields: kPublisherSortFields,
              defaultSort: 'name',
            ),
            repository: repos.publishers,
            idOf: (publisher) => publisher.id,
          ),
        ),
        ChangeNotifierProvider<PagedListNotifier<Reader, SimpleQuery>>(
          create: (_) => PagedListNotifier<Reader, SimpleQuery>(
            initialQuery: SimpleQuery.initial(
              sortFields: kReaderSortFields,
              defaultSort: 'lastName',
            ),
            repository: repos.readers,
            idOf: (reader) => reader.id,
          ),
        ),
        ChangeNotifierProvider<ReferenceNotifier>(
          create: (_) => ReferenceNotifier(
            genres: repos.genres,
            publishers: repos.publishers,
            authors: repos.authors,
            books: repos.books,
          )..load(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Библиотека',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: _messengerKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
