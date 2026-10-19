import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../state/detail_notifier.dart';
import '../state/load_status.dart';
import '../state/reference_notifier.dart';
import '../widgets/detail_layout.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/state_views.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<DetailNotifier<Book>>();
    final refs = context.watch<ReferenceNotifier>();

    return LibraryScaffold(
      title: 'Карточка книги',
      showBack: true,
      body: switch (detail.status) {
        LoadStatus.idle || LoadStatus.loading => const LoadingView(),
        LoadStatus.error => ErrorView(
            message: detail.error ?? 'Неизвестная ошибка',
            onRetry: detail.load,
          ),
        LoadStatus.success => _content(context, detail.item, refs),
      },
    );
  }

  Widget _content(BuildContext context, Book? book, ReferenceNotifier refs) {
    if (book == null) {
      return EmptyView(
        message: 'Книга не найдена',
        actionLabel: 'К списку книг',
        onAction: () => context.go('/books'),
      );
    }
    return DetailLayout(
      title: book.title,
      children: [
        if (book.isDeleted)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Chip(label: Text('Запись помечена как удалённая')),
          ),
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
              for (final id in book.genreIds) Chip(label: Text(refs.genreName(id))),
            ],
          ),
        ),
        DetailField(
          label: 'Издательство',
          child: Text(refs.publisherName(book.publisherId)),
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
