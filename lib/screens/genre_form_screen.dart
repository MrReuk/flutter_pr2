import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/genre.dart';
import '../repositories/entity_repository.dart';
import '../validation/validators.dart';
import '../widgets/entity_form.dart';
import 'entity_form_screen.dart';

class GenreFormScreen extends StatelessWidget {
  const GenreFormScreen({super.key, this.genreId});

  final int? genreId;

  @override
  Widget build(BuildContext context) {
    final genres = context.read<GenreRepository>();
    final id = genreId;

    return EntityFormScreen<Genre>(
      title: id == null ? 'Новый жанр' : 'Редактирование жанра',
      backPath: '/genres',
      notFoundMessage: 'Жанр не найден',
      savedMessage: id == null ? 'Жанр добавлен' : 'Изменения сохранены',
      loadItem: id == null ? null : () => genres.findById(id),
      initialValues: (genre) => {
        'name': genre?.name ?? '',
        'description': genre?.description ?? '',
      },
      fields: (genre) => [
        FieldSpec.text(
          key: 'name',
          label: 'Название',
          required: true,
          maxLength: 40,
          validator: checks([notBlank(), minLength(2), maxLength(40)]),
        ),
        FieldSpec.text(
          key: 'description',
          label: 'Описание',
          maxLength: 300,
          maxLines: 4,
          validator: checks([maxLength(300)]),
        ),
      ],
      save: (values, existing) async {
        final draft = Genre(
          id: existing?.id ?? 0,
          name: (values['name'] as String).trim(),
          description: (values['description'] as String).trim(),
          deletedAt: existing?.deletedAt,
        );
        if (existing == null) {
          await genres.create(draft);
        } else {
          await genres.update(draft);
        }
      },
    );
  }
}
