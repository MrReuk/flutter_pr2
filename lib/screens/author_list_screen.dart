import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/author_query.dart';
import '../state/author_list_notifier.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/entity_list_body.dart';
import '../widgets/entity_table.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/list_toolbar.dart';
import '../widgets/row_actions.dart';
import '../widgets/selection_bar.dart';

class AuthorListScreen extends StatefulWidget {
  const AuthorListScreen({super.key, required this.query});

  final AuthorQuery query;

  @override
  State<AuthorListScreen> createState() => _AuthorListScreenState();
}

class _AuthorListScreenState extends State<AuthorListScreen> {
  AuthorQuery get _query => widget.query;

  void _go(AuthorQuery next) => context.go(next.toLocation('/authors'));

  AuthorQuery get _resetQuery => AuthorQuery(
        size: _query.size,
        sortField: _query.sortField,
        sortAscending: _query.sortAscending,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthorListNotifier>().applyQuery(widget.query, force: true);
    });
  }

  @override
  void didUpdateWidget(AuthorListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AuthorListNotifier>().applyQuery(widget.query);
      });
    }
  }

  Future<void> _deleteSelected() async {
    final notifier = context.read<AuthorListNotifier>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await confirmAction(
      context,
      title: 'Удалить выбранные записи?',
      message:
          'Будет удалено записей: ${notifier.selected.length}. Их можно восстановить.',
    );
    if (!confirmed) return;
    final count = await notifier.deleteSelected();
    messenger.showSnackBar(SnackBar(content: Text('Удалено записей: $count')));
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final q = _query;

    return LibraryScaffold(
      title: 'Авторы',
      body: Column(
        children: [
          ListToolbar(
            search: q.search,
            searchLabel: 'Поиск по фамилии или стране',
            onSearch: (text) => _go(_query.copyWith(search: text)),
            activeFilterCount: q.activeFilterCount,
            initiallyOpen: q.activeFilterCount > 0,
            onReset: () => _go(_resetQuery),
            filters: [
              DeletedSwitch(
                value: q.includeDeleted,
                onChanged: (value) => _go(_query.copyWith(includeDeleted: value)),
              ),
            ],
          ),
          if (notifier.hasSelection)
            SelectionBar(
              count: notifier.selected.length,
              onDelete: _deleteSelected,
              onClear: notifier.clearSelection,
            ),
          Expanded(
            child: EntityListBody<Author>(
              status: notifier.status,
              error: notifier.error,
              result: notifier.result,
              onRetry: notifier.load,
              emptyMessage: 'Авторы не найдены. Измените поиск или фильтры.',
              onReset: q.search.isNotEmpty || q.activeFilterCount > 0
                  ? () => _go(_resetQuery)
                  : null,
              columns: [
                TableColumnSpec<Author>(
                  label: 'Фамилия',
                  sortField: 'lastName',
                  build: (a) => Text(a.lastName),
                ),
                TableColumnSpec<Author>(
                  label: 'Имя',
                  build: (a) => Text(a.firstName),
                ),
                TableColumnSpec<Author>(
                  label: 'Страна',
                  sortField: 'country',
                  build: (a) => Text(a.country),
                ),
                TableColumnSpec<Author>(
                  label: 'Год рождения',
                  sortField: 'birthYear',
                  numeric: true,
                  build: (a) => Text('${a.birthYear}'),
                ),
              ],
              idOf: (a) => a.id,
              isDeleted: (a) => a.isDeleted,
              selected: notifier.selected,
              onToggleSelect: notifier.toggleSelection,
              onSelectAll: notifier.setAllSelected,
              sortField: q.sortField,
              sortAscending: q.sortAscending,
              onSort: (field) => _go(
                _query.copyWith(
                  sortField: field,
                  sortAscending:
                      field == _query.sortField ? !_query.sortAscending : true,
                ),
              ),
              onOpen: (a) => context.push('/authors/${a.id}'),
              actions: (a) => buildRowActions(
                context,
                deleted: a.isDeleted,
                name: a.fullName,
                onSoftDelete: () => notifier.softDelete(a.id),
                onHardDelete: () => notifier.hardDelete(a.id),
                onRestore: () => notifier.restore(a.id),
              ),
              titleOf: (a) => a.fullName,
              subtitleOf: (a) => '${a.country} · ${a.birthYear} г. рождения',
              onPage: (page) => _go(_query.copyWith(page: page)),
              onSize: (size) => _go(_query.copyWith(size: size)),
            ),
          ),
        ],
      ),
    );
  }
}
