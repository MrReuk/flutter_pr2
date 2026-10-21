import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/app_repositories.dart';
import 'package:library_app/data/seed_data.dart';
import 'package:library_app/models/genre.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  test('Первый запуск заполняет хранилище начальными данными', () async {
    final repos = await makeRepositories();

    expect((await repos.books.findAll()).length, seedBooks.length);
    expect((await repos.genres.findAll()).length, seedGenres.length);
    expect((await repos.readers.findAll()).length, seedReaders.length);
    expect(repos.notices, isEmpty);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('books_v2'), isNotNull);
    expect(prefs.getString('readers_v2'), isNotNull);
  });

  test('Созданная запись сохраняется и видна после «перезапуска»', () async {
    final first = await makeRepositories();
    final created = await first.genres.create(const Genre(id: 0, name: 'Детектив'));
    expect(created.id, seedGenres.length + 1);

    final prefs = await SharedPreferences.getInstance();
    final second = AppRepositories(prefs, delay: Duration.zero);
    final names = (await second.genres.findAll()).map((g) => g.name);

    expect(names, contains('Детектив'));
    expect(second.notices, isEmpty);
  });

  test('Изменение и удаление тоже сохраняются', () async {
    final first = await makeRepositories();
    final book = (await first.books.findById(1))!;
    await first.books.update(book.copyWith(title: 'Новое название'));
    await first.books.softDelete(2);
    await first.books.hardDelete(3);

    final prefs = await SharedPreferences.getInstance();
    final second = AppRepositories(prefs, delay: Duration.zero);

    expect((await second.books.findById(1))!.title, 'Новое название');
    expect((await second.books.findById(2))!.isDeleted, isTrue);
    expect(await second.books.findById(3), isNull);
  });

  test('Номер удалённой записи не выдаётся повторно', () async {
    final repos = await makeRepositories();
    final temporary = await repos.genres.create(const Genre(id: 0, name: 'Временный'));
    await repos.genres.hardDelete(temporary.id);
    final next = await repos.genres.create(const Genre(id: 0, name: 'Новый'));

    expect(next.id, greaterThan(temporary.id));
    final ids = (await repos.genres.findAll()).map((g) => g.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('Данные старого формата переносятся с сообщением', () async {
    final repos = await makeRepositories({
      'genres_v1': jsonEncode([
        {'id': 1, 'name': 'Старый жанр'},
      ]),
    });

    final genres = await repos.genres.findAll();
    expect(genres.single.name, 'Старый жанр');
    expect(genres.single.description, '');
    expect(repos.genres.restoreNotice, contains('перенесены'));
    expect(repos.notices, isNotEmpty);

    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('genres_v1'), isNull);
    expect(prefs.getString('genres_v2'), isNotNull);
  });

  test('Повреждённые данные не роняют приложение и заменяются начальными', () async {
    final repos = await makeRepositories({'books_v2': 'это не json'});

    expect((await repos.books.findAll()).length, seedBooks.length);
    expect(repos.books.restoreNotice, contains('повреждены'));
  });

  test('Данные другой версии заменяются начальными с сообщением', () async {
    final repos = await makeRepositories({
      'readers_v2': jsonEncode({'version': 99, 'items': []}),
    });

    expect((await repos.readers.findAll()).length, seedReaders.length);
    expect(repos.readers.restoreNotice, isNotNull);
  });

  test('Записи с пропущенными полями читаются без ошибок', () async {
    final repos = await makeRepositories({
      'authors_v2': jsonEncode({
        'version': 2,
        'items': [
          {'id': 1, 'lastName': 'Тестов'},
          {'id': 2},
        ],
      }),
    });

    final authors = await repos.authors.findAll();
    expect(authors.length, 2);
    expect(authors.first.firstName, '');
    expect(repos.authors.restoreNotice, isNull);
  });
}
