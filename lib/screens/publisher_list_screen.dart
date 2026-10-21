import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publisher.dart';
import '../models/simple_query.dart';
import '../state/reference_notifier.dart';
import '../widgets/choice_dropdown.dart';
import '../widgets/entity_table.dart';
import 'simple_list_screen.dart';

class PublisherListScreen extends StatelessWidget {
  const PublisherListScreen({super.key, required this.query});

  final SimpleQuery query;

  @override
  Widget build(BuildContext context) {
    return SimpleListScreen<Publisher>(
      query: query,
      config: SimpleListConfig<Publisher>(
        title: 'Издательства',
        path: '/publishers',
        searchLabel: 'Поиск по названию, стране или почте',
        emptyMessage: 'Издательства не найдены. Измените поиск или фильтры.',
        addLabel: 'Добавить издательство',
        filterBuilder: (context, q, apply) {
          final countries = context.watch<ReferenceNotifier>().countries;
          return [
            ChoiceDropdown(
              label: 'Страна',
              value: q.filter,
              choices: [
                for (final country in countries) (value: country, label: country),
              ],
              onChanged: (value) => apply(q.copyWith(filter: value)),
            ),
          ];
        },
        columns: (context) => [
          TableColumnSpec<Publisher>(
            label: 'Название',
            sortField: 'name',
            build: (p) => Text(p.name),
          ),
          TableColumnSpec<Publisher>(
            label: 'Страна',
            sortField: 'country',
            build: (p) => Text(p.country),
          ),
          TableColumnSpec<Publisher>(
            label: 'Год основания',
            sortField: 'foundedYear',
            numeric: true,
            build: (p) => Text('${p.foundedYear}'),
          ),
          TableColumnSpec<Publisher>(
            label: 'Почта',
            build: (p) => Text(p.email),
          ),
        ],
        idOf: (p) => p.id,
        isDeleted: (p) => p.isDeleted,
        nameOf: (p) => p.name,
        subtitleOf: (p) => '${p.country} · основано в ${p.foundedYear} г.\n${p.email}',
      ),
    );
  }
}
