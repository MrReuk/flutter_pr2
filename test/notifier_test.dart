import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/models/book.dart';
import 'package:library_app/models/book_query.dart';
import 'package:library_app/models/publisher.dart';
import 'package:library_app/models/simple_query.dart';
import 'package:library_app/state/load_status.dart';
import 'package:library_app/state/paged_list_notifier.dart';

import 'test_helpers.dart';

void main() {
  late PagedListNotifier<Book, BookQuery> notifier;

  setUp(() async {
    final repos = await makeRepositories();
    notifier = PagedListNotifier<Book, BookQuery>(
      initialQuery: const BookQuery(),
      repository: repos.books,
      idOf: (book) => book.id,
    );
  });

  tearDown(() => notifier.dispose());

  test('Загрузка проходит состояния idle, loading, success', () async {
    expect(notifier.status, LoadStatus.idle);

    final future = notifier.applyQuery(const BookQuery(), force: true);
    expect(notifier.status, LoadStatus.loading);

    await future;
    expect(notifier.status, LoadStatus.success);
    expect(notifier.result.items, isNotEmpty);
  });

  test('Пустой результат отличается от ошибки', () async {
    await notifier.applyQuery(const BookQuery(search: 'zzzzzz'), force: true);

    expect(notifier.status, LoadStatus.success);
    expect(notifier.result.items, isEmpty);
    expect(notifier.error, isNull);
  });

  test('Сбой репозитория переводит состояние в ошибку', () async {
    await notifier.applyQuery(const BookQuery(search: '!error'), force: true);

    expect(notifier.status, LoadStatus.error);
    expect(notifier.error, isNotNull);
  });

  test('Выделение сбрасывается при смене условий отбора', () async {
    await notifier.applyQuery(const BookQuery(), force: true);
    notifier.toggleSelection(1);
    expect(notifier.hasSelection, isTrue);

    await notifier.applyQuery(const BookQuery(search: 'и'));

    expect(notifier.hasSelection, isFalse);
  });

  test('Удаление выбранных обновляет список и очищает выделение', () async {
    await notifier.applyQuery(const BookQuery(), force: true);
    final before = notifier.result.total;
    notifier.toggleSelection(1);
    notifier.toggleSelection(2);

    final summary = await notifier.deleteSelected();

    expect(summary.requested, 2);
    expect(summary.deleted, 2);
    expect(notifier.hasSelection, isFalse);
    expect(notifier.result.total, before - 2);
  });

  test('Выделение всей страницы выбирает все видимые записи', () async {
    await notifier.applyQuery(const BookQuery(), force: true);

    notifier.setAllSelected(true);
    expect(notifier.selected.length, notifier.result.items.length);

    notifier.setAllSelected(false);
    expect(notifier.hasSelection, isFalse);
  });

  test('Отказ в удалении возвращает сообщение и не ломает список', () async {
    final repos = await makeRepositories();
    final publishers = PagedListNotifier<Publisher, SimpleQuery>(
      initialQuery: SimpleQuery.initial(
        sortFields: kPublisherSortFields,
        defaultSort: 'name',
      ),
      repository: repos.publishers,
      idOf: (publisher) => publisher.id,
    );
    addTearDown(publishers.dispose);

    await publishers.load();
    final problem = await publishers.softDelete(4);

    expect(problem, isNotNull);
    expect(problem, contains('есть книги'));
    expect(publishers.status, LoadStatus.success);
    expect(publishers.result.items.any((p) => p.id == 4), isTrue);
  });
}
