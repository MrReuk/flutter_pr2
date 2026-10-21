import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../repositories/author_repository.dart';
import '../validation/validators.dart';
import '../widgets/entity_form.dart';
import 'entity_form_screen.dart';

class AuthorFormScreen extends StatelessWidget {
  const AuthorFormScreen({super.key, this.authorId});

  final int? authorId;

  @override
  Widget build(BuildContext context) {
    final authors = context.read<AuthorRepository>();
    final id = authorId;

    return EntityFormScreen<Author>(
      title: id == null ? 'Новый автор' : 'Редактирование автора',
      backPath: '/authors',
      notFoundMessage: 'Автор не найден',
      savedMessage: id == null ? 'Автор добавлен' : 'Изменения сохранены',
      loadItem: id == null ? null : () => authors.findById(id),
      initialValues: (author) => {
        'lastName': author?.lastName ?? '',
        'firstName': author?.firstName ?? '',
        'country': author?.country ?? '',
        'birthYear': author == null ? '' : '${author.birthYear}',
        'biography': author?.biography ?? '',
      },
      fields: (author) => [
        FieldSpec.text(
          key: 'lastName',
          label: 'Фамилия',
          required: true,
          maxLength: 50,
          validator: checks([notBlank(), minLength(2), maxLength(50), namePattern()]),
        ),
        FieldSpec.text(
          key: 'firstName',
          label: 'Имя',
          required: true,
          maxLength: 50,
          validator: checks([notBlank(), minLength(2), maxLength(50), namePattern()]),
        ),
        FieldSpec.text(
          key: 'country',
          label: 'Страна',
          required: true,
          maxLength: 60,
          validator: checks([notBlank(), minLength(2), maxLength(60), namePattern()]),
        ),
        FieldSpec.text(
          key: 'birthYear',
          label: 'Год рождения',
          required: true,
          keyboardType: TextInputType.number,
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
          validator: checks([
            notBlank(),
            integerInRange(1000, DateTime.now().year),
          ]),
        ),
        FieldSpec.text(
          key: 'biography',
          label: 'Биография',
          maxLength: 1000,
          maxLines: 6,
          validator: checks([maxLength(1000)]),
        ),
      ],
      save: (values, existing) async {
        final draft = Author(
          id: existing?.id ?? 0,
          lastName: (values['lastName'] as String).trim(),
          firstName: (values['firstName'] as String).trim(),
          country: (values['country'] as String).trim(),
          birthYear: int.parse((values['birthYear'] as String).trim()),
          biography: (values['biography'] as String).trim(),
          deletedAt: existing?.deletedAt,
        );
        if (existing == null) {
          await authors.create(draft);
        } else {
          await authors.update(draft);
        }
      },
    );
  }
}
