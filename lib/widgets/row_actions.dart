import 'package:flutter/material.dart';

import 'confirm_dialog.dart';

List<Widget> buildRowActions(
  BuildContext context, {
  required bool deleted,
  required String name,
  required Future<void> Function() onSoftDelete,
  required Future<void> Function() onHardDelete,
  required Future<void> Function() onRestore,
}) {
  return [
    if (deleted)
      IconButton(
        tooltip: 'Восстановить',
        icon: const Icon(Icons.restore),
        onPressed: onRestore,
      )
    else
      IconButton(
        tooltip: 'Удалить',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final confirmed = await confirmAction(
            context,
            title: 'Удалить запись?',
            message: '«$name» будет помечена как удалённая. Её можно восстановить.',
          );
          if (confirmed) await onSoftDelete();
        },
      ),
    IconButton(
      tooltip: 'Удалить навсегда',
      icon: Icon(
        Icons.delete_forever,
        color: Theme.of(context).colorScheme.error,
      ),
      onPressed: () async {
        final confirmed = await confirmAction(
          context,
          title: 'Удалить навсегда?',
          message: '«$name» будет стёрта без возможности восстановления.',
          confirmLabel: 'Удалить навсегда',
        );
        if (confirmed) await onHardDelete();
      },
    ),
  ];
}
