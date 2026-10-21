import 'package:flutter/material.dart';

import '../models/reader.dart';
import '../models/simple_query.dart';
import '../validation/validators.dart';
import '../widgets/choice_dropdown.dart';
import '../widgets/entity_table.dart';
import 'simple_list_screen.dart';

class ReaderListScreen extends StatelessWidget {
  const ReaderListScreen({super.key, required this.query});

  final SimpleQuery query;

  @override
  Widget build(BuildContext context) {
    return SimpleListScreen<Reader>(
      query: query,
      config: SimpleListConfig<Reader>(
        title: 'Читатели',
        path: '/readers',
        searchLabel: 'Поиск по фамилии, имени, почте или номеру билета',
        emptyMessage: 'Читатели не найдены. Измените поиск или фильтры.',
        addLabel: 'Добавить читателя',
        filterBuilder: (context, q, apply) => [
          ChoiceDropdown(
            label: 'Читательский билет',
            value: q.filter,
            choices: const [
              (value: 'active', label: 'Действует'),
              (value: 'expired', label: 'Просрочен'),
            ],
            onChanged: (value) => apply(q.copyWith(filter: value)),
          ),
        ],
        columns: (context) => [
          TableColumnSpec<Reader>(
            label: 'Фамилия',
            sortField: 'lastName',
            build: (r) => Text(r.lastName),
          ),
          TableColumnSpec<Reader>(
            label: 'Имя',
            build: (r) => Text(r.firstName),
          ),
          TableColumnSpec<Reader>(
            label: 'Почта',
            sortField: 'email',
            build: (r) => Text(r.email),
          ),
          TableColumnSpec<Reader>(
            label: 'Билет',
            build: (r) => Text(r.card.number),
          ),
          TableColumnSpec<Reader>(
            label: 'Действует до',
            sortField: 'expiresAt',
            build: (r) => Text(
              r.card.isExpiredAt(DateTime.now())
                  ? '${formatRuDate(r.card.expiresAt)} (просрочен)'
                  : formatRuDate(r.card.expiresAt),
            ),
          ),
        ],
        idOf: (r) => r.id,
        isDeleted: (r) => r.isDeleted,
        nameOf: (r) => r.fullName,
        subtitleOf: (r) =>
            '${r.email}\nБилет ${r.card.number} до ${formatRuDate(r.card.expiresAt)}',
      ),
    );
  }
}
