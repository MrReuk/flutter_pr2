import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/author.dart';
import 'models/author_query.dart';
import 'models/book.dart';
import 'models/book_query.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'screens/author_detail_screen.dart';
import 'screens/author_list_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/not_found_screen.dart';
import 'state/detail_notifier.dart';

final appRouter = GoRouter(
  initialLocation: '/books',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/books',
    ),
    GoRoute(
      path: '/books',
      builder: (context, state) => BookListScreen(
        query: BookQuery.fromParams(state.uri.queryParameters),
      ),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return NotFoundScreen(location: state.uri.toString());
            }
            return ChangeNotifierProvider<DetailNotifier<Book>>(
              create: (context) =>
                  BookDetailNotifier(context.read<BookRepository>(), id)..load(),
              child: const BookDetailScreen(),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/authors',
      builder: (context, state) => AuthorListScreen(
        query: AuthorQuery.fromParams(state.uri.queryParameters),
      ),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return NotFoundScreen(location: state.uri.toString());
            }
            return ChangeNotifierProvider<DetailNotifier<Author>>(
              create: (context) =>
                  AuthorDetailNotifier(context.read<AuthorRepository>(), id)..load(),
              child: const AuthorDetailScreen(),
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
);
