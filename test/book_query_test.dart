import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/models/book_query.dart';

void main() {
  test('Параметры адреса разбираются в условия отбора', () {
    final q = BookQuery.fromParams({
      'search': 'папа',
      'genreId': '2',
      'sort': 'year,desc',
      'page': '3',
    });

    expect(q.search, 'папа');
    expect(q.genreId, 2);
    expect(q.sortField, 'year');
    expect(q.sortAscending, isFalse);
    expect(q.page, 3);
  });

  test('Условия отбора переживают запись в адрес и чтение обратно', () {
    const original = BookQuery(
      search: 'богатый папа',
      genreId: 1,
      publisherId: 2,
      yearFrom: 1800,
      yearTo: 1900,
      sortField: 'pages',
      sortAscending: false,
      page: 2,
      size: 25,
      includeDeleted: true,
    );

    final location = original.toLocation('/books');
    final restored = BookQuery.fromParams(Uri.parse(location).queryParameters);

    expect(restored, original);
  });

  test('Условия по умолчанию дают чистый адрес', () {
    expect(const BookQuery().toLocation('/books'), '/books');
  });

  test('Некорректные параметры заменяются значениями по умолчанию', () {
    final q = BookQuery.fromParams({
      'page': '-4',
      'size': '7',
      'sort': 'hack,asc',
      'genreId': 'abc',
    });

    expect(q.page, 1);
    expect(q.size, 10);
    expect(q.sortField, 'title');
    expect(q.genreId, isNull);
  });

  test('Смена условий возвращает на первую страницу', () {
    const q = BookQuery(page: 5);

    expect(q.copyWith(search: 'a').page, 1);
    expect(q.copyWith(page: 4).page, 4);
  });

  test('Фильтр можно сбросить, не передавая значение случайно', () {
    const q = BookQuery(genreId: 2);

    expect(q.copyWith(genreId: null).genreId, isNull);
    expect(q.copyWith(search: 'x').genreId, 2);
  });
}
