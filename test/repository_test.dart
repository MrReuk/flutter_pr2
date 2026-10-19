import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/data/seed_data.dart';
import 'package:library_app/models/author_query.dart';
import 'package:library_app/models/book_query.dart';
import 'package:library_app/repositories/in_memory_author_repository.dart';
import 'package:library_app/repositories/in_memory_book_repository.dart';
import 'package:library_app/repositories/repository_exception.dart';

void main() {
  late InMemoryBookRepository books;
  late InMemoryAuthorRepository authors;

  setUp(() {
    books = InMemoryBookRepository(delay: Duration.zero);
    authors = InMemoryAuthorRepository(delay: Duration.zero);
  });

  test('Начальные наборы достаточного размера', () {
    expect(seedBooks.length, greaterThanOrEqualTo(20));
    expect(seedAuthors.length, greaterThanOrEqualTo(8));
  });

  test('Первая страница содержит столько записей, сколько задано размером', () async {
    final result = await books.find(const BookQuery());

    expect(result.items.length, 10);
    expect(result.total, seedBooks.length);
    expect(result.totalPages, (seedBooks.length / 10).ceil());
    expect(result.hasPrevious, isFalse);
    expect(result.hasNext, isTrue);
  });

  test('Страница за пределами диапазона сводится к последней', () async {
    final result = await books.find(const BookQuery(page: 99));

    expect(result.page, result.totalPages);
    expect(result.items, isNotEmpty);
  });

  test('Поиск работает по названию без учёта регистра', () async {
    final result = await books.find(const BookQuery(search: 'ПАПА'));

    expect(result.items.map((b) => b.title), contains('Богатый папа, бедный папа'));
  });

  test('Поиск работает по ISBN', () async {
    final isbn = seedBooks.first.isbn;
    final result = await books.find(BookQuery(search: isbn));

    expect(result.items.single.id, seedBooks.first.id);
  });

  test('Фильтры комбинируются между собой и с поиском', () async {
    final result = await books.find(
      const BookQuery(genreId: 1, yearFrom: 2000, yearTo: 2012, size: 50),
    );

    expect(result.items, isNotEmpty);
    for (final book in result.items) {
      expect(book.genreIds, contains(1));
      expect(book.year, inInclusiveRange(2000, 2012));
    }

    final narrowed = await books.find(
      const BookQuery(genreId: 1, yearFrom: 2000, yearTo: 2012, search: 'блич'),
    );
    expect(narrowed.items.length, 1);
  });

  test('Сортировка по убыванию года', () async {
    final result = await books.find(
      const BookQuery(sortField: 'year', sortAscending: false, size: 50),
    );
    final years = result.items.map((b) => b.year).toList();

    expect(years, [...years]..sort((a, b) => b.compareTo(a)));
  });

  test('Логическое удаление скрывает запись, восстановление возвращает', () async {
    await books.softDelete(1);

    final hidden = await books.find(const BookQuery(size: 50));
    expect(hidden.items.any((b) => b.id == 1), isFalse);

    final shown = await books.find(const BookQuery(size: 50, includeDeleted: true));
    expect(shown.items.any((b) => b.id == 1 && b.isDeleted), isTrue);

    await books.restore(1);
    final restored = await books.find(const BookQuery(size: 50));
    expect(restored.items.any((b) => b.id == 1 && !b.isDeleted), isTrue);
  });

  test('Физическое удаление стирает запись насовсем', () async {
    await books.hardDelete(1);

    expect(await books.findById(1), isNull);
    final all = await books.find(const BookQuery(size: 50, includeDeleted: true));
    expect(all.items.any((b) => b.id == 1), isFalse);
  });

  test('Множественное удаление считает только действительно удалённые записи', () async {
    await books.softDelete(1);

    final count = await books.deleteMany([1, 2, 3]);

    expect(count, 2);
    final shown = await books.find(const BookQuery(size: 50, includeDeleted: true));
    expect(shown.items.where((b) => b.isDeleted).length, 3);
  });

  test('Имитация ошибки выбрасывает исключение репозитория', () {
    expect(
      () => books.find(const BookQuery(search: '!error')),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('Поиск авторов работает по фамилии и стране', () async {
    final byName = await authors.find(const AuthorQuery(search: 'кийос'));
    expect(byName.items.single.lastName, 'Кийосаки');

    final byCountry = await authors.find(const AuthorQuery(search: 'польша'));
    expect(byCountry.items.single.lastName, 'Сапковский');
  });

  test('Сортировка авторов по году рождения', () async {
    final result = await authors.find(
      const AuthorQuery(sortField: 'birthYear', size: 50),
    );
    final years = result.items.map((a) => a.birthYear).toList();

    expect(years, [...years]..sort());
  });

  test('Создание книги присваивает новый идентификатор', () async {
    final created = await books.create(seedBooks.first);

    expect(created.id, seedBooks.length + 1);
    expect(await books.findById(created.id), isNotNull);
  });
}
