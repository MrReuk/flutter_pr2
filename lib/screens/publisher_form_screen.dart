import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/publisher.dart';
import '../repositories/entity_repository.dart';
import '../validation/validators.dart';
import '../widgets/entity_form.dart';
import 'entity_form_screen.dart';

class PublisherFormScreen extends StatelessWidget {
  const PublisherFormScreen({super.key, this.publisherId});

  final int? publisherId;

  @override
  Widget build(BuildContext context) {
    final publishers = context.read<PublisherRepository>();
    final id = publisherId;

    return EntityFormScreen<Publisher>(
      title: id == null ? 'Новое издательство' : 'Редактирование издательства',
      backPath: '/publishers',
      notFoundMessage: 'Издательство не найдено',
      savedMessage: id == null ? 'Издательство добавлено' : 'Изменения сохранены',
      loadItem: id == null ? null : () => publishers.findById(id),
      initialValues: (publisher) => {
        'name': publisher?.name ?? '',
        'country': publisher?.country ?? '',
        'foundedYear': publisher == null ? '' : '${publisher.foundedYear}',
        'email': publisher?.email ?? '',
      },
      fields: (publisher) => [
        FieldSpec.text(
          key: 'name',
          label: 'Название',
          required: true,
          maxLength: 80,
          validator: checks([notBlank(), minLength(2), maxLength(80)]),
        ),
        FieldSpec.text(
          key: 'country',
          label: 'Страна',
          required: true,
          maxLength: 60,
          validator: checks([notBlank(), minLength(2), maxLength(60), namePattern()]),
        ),
        FieldSpec.text(
          key: 'foundedYear',
          label: 'Год основания',
          required: true,
          keyboardType: TextInputType.number,
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
          validator: checks([
            notBlank(),
            integerInRange(1450, DateTime.now().year),
          ]),
        ),
        FieldSpec.text(
          key: 'email',
          label: 'Электронная почта',
          required: true,
          hint: 'info@example.com',
          keyboardType: TextInputType.emailAddress,
          maxLength: 100,
          validator: checks([notBlank(), maxLength(100), emailFormat()]),
        ),
      ],
      save: (values, existing) async {
        final draft = Publisher(
          id: existing?.id ?? 0,
          name: (values['name'] as String).trim(),
          country: (values['country'] as String).trim(),
          foundedYear: int.parse((values['foundedYear'] as String).trim()),
          email: (values['email'] as String).trim(),
          deletedAt: existing?.deletedAt,
        );
        if (existing == null) {
          await publishers.create(draft);
        } else {
          await publishers.update(draft);
        }
      },
    );
  }
}
