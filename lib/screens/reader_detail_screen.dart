import 'package:flutter/material.dart';

import '../models/reader.dart';
import '../validation/validators.dart';
import '../widgets/detail_layout.dart';
import 'entity_detail_screen.dart';

class ReaderDetailScreen extends StatelessWidget {
  const ReaderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EntityDetailScreen<Reader>(
      title: 'Карточка читателя',
      listPath: '/readers',
      listLabel: 'К списку читателей',
      notFoundMessage: 'Читатель не найден',
      editLocation: (reader) => '/readers/${reader.id}/edit',
      nameOf: (reader) => reader.fullName,
      isDeleted: (reader) => reader.isDeleted,
      fields: (context, reader) {
        final expired = reader.card.isExpiredAt(DateTime.now());
        return [
          DetailField(label: 'Почта', child: Text(reader.email)),
          DetailField(
            label: 'Телефон',
            child: Text(reader.phone.isEmpty ? '—' : reader.phone),
          ),
          DetailField(
            label: 'Читательский билет',
            child: Card.outlined(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reader.card.number),
                    const SizedBox(height: 4),
                    Text('Выдан: ${formatRuDate(reader.card.issuedAt)}'),
                    Text('Действует до: ${formatRuDate(reader.card.expiresAt)}'),
                    const SizedBox(height: 8),
                    Chip(label: Text(expired ? 'Срок действия истёк' : 'Действует')),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
    );
  }
}
