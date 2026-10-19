import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../state/detail_notifier.dart';
import '../state/load_status.dart';
import '../widgets/detail_layout.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/state_views.dart';

class AuthorDetailScreen extends StatelessWidget {
  const AuthorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<DetailNotifier<Author>>();

    return LibraryScaffold(
      title: 'Карточка автора',
      showBack: true,
      body: switch (detail.status) {
        LoadStatus.idle || LoadStatus.loading => const LoadingView(),
        LoadStatus.error => ErrorView(
            message: detail.error ?? 'Неизвестная ошибка',
            onRetry: detail.load,
          ),
        LoadStatus.success => _content(context, detail.item),
      },
    );
  }

  Widget _content(BuildContext context, Author? author) {
    if (author == null) {
      return EmptyView(
        message: 'Автор не найден',
        actionLabel: 'К списку авторов',
        onAction: () => context.go('/authors'),
      );
    }
    return DetailLayout(
      title: author.fullName,
      children: [
        if (author.isDeleted)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Chip(label: Text('Запись помечена как удалённая')),
          ),
        DetailField(label: 'Страна', child: Text(author.country)),
        DetailField(label: 'Год рождения', child: Text('${author.birthYear}')),
        DetailField(label: 'Биография', child: Text(author.biography)),
      ],
    );
  }
}
