import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/data/seed_data.dart';
import 'package:library_app/models/author.dart';
import 'package:library_app/models/author_query.dart';
import 'package:library_app/models/book_query.dart';
import 'package:library_app/models/genre.dart';
import 'package:library_app/models/publisher.dart';
import 'package:library_app/models/reader.dart';
import 'package:library_app/models/simple_query.dart';
import 'package:library_app/repositories/repository_exception.dart';

import 'test_helpers.dart';

SimpleQuery readerQuery({String filter = '', String search = ''}) {
  return SimpleQuery(
    sortFields: kReaderSortFields,
    defaultSort: 'lastName',
    sortField: 'lastName',
    filter: filter,
    search: search,
    size: 50,
  );
}

void main() {
  test('Первая страница содержит столько записей, сколько задано размером', () async {
    final repos = await makeRepositories();
    final result = await repos.books.find(const BookQuery());

    expect(result.items.length, 10);
    expect(result.total, seedBooks.length);
    expect(result.hasPrevious, isFalse);
    expect(result.hasNext, isTrue);
  });

  test('Страница за пределами диапазона сводится к последней', () async {
    final repos = await makeRepositories();
    final result = await repos.books.find(const BookQuery(page: 99));

    expect(result.page, result.totalPages);
    expect(result.items, isNotEmpty);
  });

  test('Поиск книг работает по названию и по ISBN', () async {
    final repos = await makeRepositories();

    final byTitle = await repos.books.find(const BookQuery(search: 'ПАПА'));
    expect(byTitle.items.map((b) => b.title), contains('Богатый папа, бедный папа'));

    final isbn = seedBooks.first.isbn;
    final byIsbn = await repos.books.find(BookQuery(search: isbn));
    expect(byIsbn.items.single.id, seedBooks.first.id);
  });

  test('Фильтры книг комбинируются', () async {
    final repos = await makeRepositories();
    final result = await repos.books.find(
      const BookQuery(genreId: 1, yearFrom: 2000, yearTo: 2012, size: 50),
    );

    expect(result.items, isNotEmpty);
    for (final book in result.items) {
      expect(book.genreIds, contains(1));
      expect(book.year, inInclusiveRange(2000, 2012));
    }
  });

  test('Сортировка авторов по убыванию года рождения', () async {
    final repos = await makeRepositories();
    final result = await repos.authors.find(
      const AuthorQuery(sortField: 'birthYear', sortAscending: false, size: 50),
    );
    final years = result.items.map((a) => a.birthYear).toList();

    expect(years, [...years]..sort((a, b) => b.compareTo(a)));
  });

  test('Логическое удаление скрывает запись, восстановление возвращает', () async {
    final repos = await makeRepositories();
    final total = (await repos.books.find(const BookQuery(size: 50))).total;

    await repos.books.softDelete(1);
    final hidden = await repos.books.find(const BookQuery(size: 50));
    expect(hidden.total, total - 1);

    final withDeleted = await repos.books.find(
      const BookQuery(size: 50, includeDeleted: true),
    );
    expect(withDeleted.total, total);

    await repos.books.restore(1);
    expect((await repos.books.find(const BookQuery(size: 50))).total, total);
  });

  test('Жёсткое удаление убирает запись совсем', () async {
    final repos = await makeRepositories();
    await repos.books.hardDelete(1);

    expect(await repos.books.findById(1), isNull);
    final all = await repos.books.find(const BookQuery(size: 50, includeDeleted: true));
    expect(all.items.any((b) => b.id == 1), isFalse);
  });

  test('Сбой поиска имитируется строкой !error', () async {
    final repos = await makeRepositories();

    expect(
      () => repos.books.find(const BookQuery(search: '!error')),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('ISBN должен быть уникальным при создании', () async {
    final repos = await makeRepositories();
    final draft = seedBooks.first.copyWith(id: 0, title: 'Другая книга');

    try {
      await repos.books.create(draft);
      fail('Ожидалась ошибка уникальности');
    } on FieldConflictException catch (e) {
      expect(e.errors.keys, ['isbn']);
      expect(e.errors['isbn'], contains('уже есть'));
    }
  });

  test('ISBN сравнивается без дефисов и пробелов', () async {
    final repos = await makeRepositories();
    final plain = seedBooks.first.isbn.replaceAll('-', '');

    expect(
      () => repos.books.create(seedBooks.first.copyWith(id: 0, isbn: plain)),
      throwsA(isA<FieldConflictException>()),
    );
  });

  test('При редактировании книга может сохранить свой ISBN', () async {
    final repos = await makeRepositories();
    final book = (await repos.books.findById(1))!;

    final saved = await repos.books.update(book.copyWith(title: 'Изменено'));
    expect(saved.title, 'Изменено');

    final other = (await repos.books.findById(2))!;
    expect(
      () => repos.books.update(other.copyWith(isbn: book.isbn)),
      throwsA(isA<FieldConflictException>()),
    );
  });

  test('Email читателя уникален без учёта регистра', () async {
    final repos = await makeRepositories();
    final first = seedReaders.first;
    final draft = Reader(
      id: 0,
      firstName: 'Новый',
      lastName: 'Читатель',
      email: first.email.toUpperCase(),
      phone: '',
      card: LibraryCard(
        number: 'LC-2026-099',
        issuedAt: DateTime(2026, 1, 1),
        expiresAt: DateTime(2027, 1, 1),
      ),
    );

    try {
      await repos.readers.create(draft);
      fail('Ожидалась ошибка уникальности');
    } on FieldConflictException catch (e) {
      expect(e.errors.keys, ['email']);
    }
  });

  test('Номер билета не повторяется, ошибки по двум полям приходят вместе', () async {
    final repos = await makeRepositories();
    final first = seedReaders.first;
    final draft = first.copyWith(id: 0);

    try {
      await repos.readers.create(draft);
      fail('Ожидалась ошибка уникальности');
    } on FieldConflictException catch (e) {
      expect(e.errors.keys.toSet(), {'email', 'cardNumber'});
    }
  });

  test('Читателей можно отфильтровать по сроку действия билета', () async {
    final repos = await makeRepositories();

    final expired = await repos.readers.find(readerQuery(filter: 'expired'));
    final active = await repos.readers.find(readerQuery(filter: 'active'));

    expect(expired.items.map((r) => r.id), containsAll([4, 7]));
    expect(expired.total + active.total, seedReaders.length);
  });

  test('Издательство с книгами нельзя удалить: сообщение содержит число книг', () async {
    final repos = await makeRepositories();
    final booksOfAst = seedBooks.where((b) => b.publisherId == 4).length;

    try {
      await repos.publishers.softDelete(4);
      fail('Ожидался отказ');
    } on DeleteBlockedException catch (e) {
      expect(e.message, contains('$booksOfAst'));
      expect(e.message, contains('АСТ'));
    }

    expect(
      () => repos.publishers.hardDelete(4),
      throwsA(isA<DeleteBlockedException>()),
    );
    expect((await repos.publishers.findById(4))!.isDeleted, isFalse);
  });

  test('Издательство без книг удаляется, массовое удаление пропускает занятые', () async {
    final repos = await makeRepositories();
    final empty = await repos.publishers.create(
      const Publisher(
        id: 0,
        name: 'Пустое издательство',
        country: 'Россия',
        foundedYear: 2020,
        email: 'empty@example.com',
      ),
    );

    final deleted = await repos.publishers.deleteMany([4, empty.id]);

    expect(deleted, 1);
    expect((await repos.publishers.findById(empty.id))!.isDeleted, isTrue);
    expect((await repos.publishers.findById(4))!.isDeleted, isFalse);
  });

  test('Жанр и автор, указанные в книгах, не удаляются навсегда', () async {
    final repos = await makeRepositories();

    expect(
      () => repos.genres.hardDelete(1),
      throwsA(isA<DeleteBlockedException>()),
    );
    expect(
      () => repos.authors.hardDelete(1),
      throwsA(isA<DeleteBlockedException>()),
    );

    await repos.genres.softDelete(1);
    expect((await repos.genres.findById(1))!.isDeleted, isTrue);
  });

  test('Название жанра и издательства уникально', () async {
    final repos = await makeRepositories();

    expect(
      () => repos.genres.create(const Genre(id: 0, name: ' манга ')),
      throwsA(isA<FieldConflictException>()),
    );
    expect(
      () => repos.publishers.create(
        const Publisher(
          id: 0,
          name: 'питер',
          country: 'Россия',
          foundedYear: 1991,
          email: 'other@example.com',
        ),
      ),
      throwsA(isA<FieldConflictException>()),
    );
  });

  test('Автор создаётся и получает следующий номер', () async {
    final repos = await makeRepositories();
    final created = await repos.authors.create(
      const Author(
        id: 0,
        firstName: 'Тест',
        lastName: 'Тестов',
        country: 'Россия',
        birthYear: 1990,
        biography: '',
      ),
    );

    expect(created.id, seedAuthors.length + 1);
  });

  test('Подсчёт книг по издательству, жанру и автору', () async {
    final repos = await makeRepositories();

    expect(
      await repos.books.countByPublisher(4),
      seedBooks.where((b) => b.publisherId == 4).length,
    );
    expect(
      await repos.books.countByGenre(1),
      seedBooks.where((b) => b.genreIds.contains(1)).length,
    );
    expect(
      await repos.books.countByAuthor(9),
      seedBooks.where((b) => b.authorIds.contains(9)).length,
    );
  });
}
