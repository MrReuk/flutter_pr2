import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../state/reference_notifier.dart';
import '../widgets/detail_layout.dart';
import 'entity_detail_screen.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final refs = context.watch<ReferenceNotifier>();

    return EntityDetailScreen<Book>(
      title: 'Карточка книги',
      listPath: '/books',
      listLabel: 'К списку книг',
      notFoundMessage: 'Книга не найдена',
      editLocation: (book) => '/books/${book.id}/edit',
      nameOf: (book) => book.title,
      isDeleted: (book) => book.isDeleted,
      fields: (context, book) => [
        DetailField(
          label: 'Авторы',
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final id in book.authorIds)
                ActionChip(
                  label: Text(refs.authorName(id)),
                  onPressed: () => context.push('/authors/$id'),
                ),
            ],
          ),
        ),
        DetailField(
          label: 'Жанры',
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final id in book.genreIds)
                ActionChip(
                  label: Text(refs.genreName(id)),
                  onPressed: () => context.push('/genres/$id'),
                ),
            ],
          ),
        ),
        DetailField(
          label: 'Издательство',
          child: ActionChip(
            label: Text(refs.publisherName(book.publisherId)),
            onPressed: () => context.push('/publishers/${book.publisherId}'),
          ),
        ),
        DetailField(label: 'ISBN', child: Text(book.isbn)),
        DetailField(label: 'Год издания', child: Text('${book.year}')),
        DetailField(label: 'Страниц', child: Text('${book.pages}')),
        DetailField(
          label: 'Экземпляры',
          child: Text('доступно ${book.copiesAvailable} из ${book.copiesTotal}'),
        ),
      ],
    );
  }
}
