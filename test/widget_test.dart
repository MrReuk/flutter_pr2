import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/models/page_result.dart';
import 'package:library_app/widgets/debounced_text_field.dart';
import 'package:library_app/widgets/entity_table.dart';
import 'package:library_app/widgets/pagination_bar.dart';

void main() {
  testWidgets('Поле поиска вызывает обратный вызов только после паузы', (tester) async {
    final values = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DebouncedTextField(
            value: '',
            onChanged: values.add,
            decoration: const InputDecoration(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'в');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'во');
    await tester.pump(const Duration(milliseconds: 200));
    expect(values, isEmpty);

    await tester.pump(const Duration(milliseconds: 150));
    expect(values, ['во']);
  });

  testWidgets('Таблица показывает строки и сообщает о сортировке', (tester) async {
    String? sorted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityTable<int>(
            columns: [
              TableColumnSpec<int>(
                label: 'Число',
                sortField: 'value',
                numeric: true,
                build: (n) => Text('$n'),
              ),
            ],
            items: const [3, 1, 2],
            idOf: (n) => n,
            sortField: 'value',
            onSort: (field) => sorted = field,
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Число'));
    expect(sorted, 'value');
  });

  testWidgets('Панель страниц показывает номер и переключает страницы', (tester) async {
    int? requested;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaginationBar(
            result: const PageResult<int>(items: [], page: 2, size: 10, total: 25),
            onPage: (page) => requested = page,
            onSize: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Страница 2 из 3'), findsOneWidget);
    expect(find.text('Всего записей: 25'), findsOneWidget);

    await tester.tap(find.byTooltip('Следующая'));
    expect(requested, 3);

    await tester.tap(find.byTooltip('Последняя'));
    expect(requested, 3);

    await tester.tap(find.byTooltip('Первая'));
    expect(requested, 1);
  });
}
