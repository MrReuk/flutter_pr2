import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/data/seed_data.dart';
import 'package:library_app/models/author.dart';
import 'package:library_app/models/book.dart';
import 'package:library_app/models/genre.dart';
import 'package:library_app/models/publisher.dart';
import 'package:library_app/models/reader.dart';

void main() {
  test('Книга переживает запись в JSON и чтение обратно', () {
    final book = seedBooks.first.copyWith(deletedAt: DateTime(2026, 1, 2, 3, 4));
    final restored = Book.fromJson(
      jsonDecode(jsonEncode(book.toJson())) as Map<String, dynamic>,
    );

    expect(restored.id, book.id);
    expect(restored.title, book.title);
    expect(restored.isbn, book.isbn);
    expect(restored.authorIds, book.authorIds);
    expect(restored.genreIds, book.genreIds);
    expect(restored.deletedAt, book.deletedAt);
  });

  test('Читатель с билетом переживает запись в JSON и чтение обратно', () {
    final reader = seedReaders.first;
    final restored = Reader.fromJson(
      jsonDecode(jsonEncode(reader.toJson())) as Map<String, dynamic>,
    );

    expect(restored.email, reader.email);
    expect(restored.card.number, reader.card.number);
    expect(restored.card.issuedAt, reader.card.issuedAt);
    expect(restored.card.expiresAt, reader.card.expiresAt);
  });

  test('Чтение терпимо к пропущенным и пустым полям', () {
    final book = Book.fromJson({'id': 5});
    expect(book.title, '');
    expect(book.year, 0);
    expect(book.authorIds, isEmpty);
    expect(book.deletedAt, isNull);

    final nulls = Book.fromJson({
      'id': null,
      'title': null,
      'authorIds': null,
      'genreIds': 'не список',
      'deletedAt': 'не дата',
    });
    expect(nulls.id, 0);
    expect(nulls.authorIds, isEmpty);
    expect(nulls.genreIds, isEmpty);
    expect(nulls.deletedAt, isNull);

    expect(Author.fromJson(const {}).fullName.trim(), '');
    expect(Genre.fromJson(const {'id': '7'}).id, 7);
    expect(Publisher.fromJson(const {'foundedYear': 1999.0}).foundedYear, 1999);

    final reader = Reader.fromJson(const {'id': 1});
    expect(reader.card.number, '');
    expect(reader.email, '');
  });
}
