import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/models/book_query.dart';
import 'package:library_app/repositories/in_memory_book_repository.dart';
import 'package:library_app/state/book_list_notifier.dart';
import 'package:library_app/state/load_status.dart';

void main() {
  late BookListNotifier notifier;

  setUp(() {
    notifier = BookListNotifier(InMemoryBookRepository(delay: Duration.zero));
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

    final count = await notifier.deleteSelected();

    expect(count, 2);
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
}
