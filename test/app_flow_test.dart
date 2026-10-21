import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/app.dart';

import 'test_helpers.dart';

void _useLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Пустая форма книги показывает ошибки у обязательных полей', (tester) async {
    _useLargeScreen(tester);
    final repos = await makeRepositories();

    await tester.pumpWidget(
      LibraryApp(repositories: repos, initialLocation: '/books/new'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Новая книга'), findsOneWidget);

    await tester.ensureVisible(find.text('Сохранить'));
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Обязательное поле'), findsWidgets);
    expect(find.text('Выберите издательство'), findsOneWidget);
    expect(find.text('Выберите хотя бы одного автора'), findsOneWidget);
    expect(find.text('Выберите хотя бы один жанр'), findsOneWidget);
  });

  testWidgets('Удаление издательства с книгами отклоняется с указанием числа книг', (tester) async {
    _useLargeScreen(tester);
    final repos = await makeRepositories();

    await tester.pumpWidget(
      LibraryApp(repositories: repos, initialLocation: '/publishers'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Амфора'), findsWidgets);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
    await tester.pumpAndSettle();

    expect(find.text('Действие невозможно'), findsOneWidget);
    expect(find.textContaining('у него есть книги'), findsOneWidget);
  });

  testWidgets('Повреждённые данные не ломают запуск, пользователь видит сообщение', (tester) async {
    _useLargeScreen(tester);
    final repos = await makeRepositories({'books_v2': 'не json'});

    await tester.pumpWidget(LibraryApp(repositories: repos));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('повреждены'), findsOneWidget);
    expect(find.text('Книги'), findsWidgets);
  });

  testWidgets('Данные старого формата переносятся и показываются в списке', (tester) async {
    _useLargeScreen(tester);
    final repos = await makeRepositories({
      'genres_v1': jsonEncode([
        {'id': 1, 'name': 'Перенесённый жанр'},
      ]),
    });

    await tester.pumpWidget(
      LibraryApp(repositories: repos, initialLocation: '/genres'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Перенесённый жанр'), findsWidgets);
    expect(find.textContaining('перенесены'), findsOneWidget);
  });
}
