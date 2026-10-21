import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reader.dart';
import '../repositories/entity_repository.dart';
import '../validation/validators.dart';
import '../widgets/entity_form.dart';
import 'entity_form_screen.dart';

class ReaderFormScreen extends StatelessWidget {
  const ReaderFormScreen({super.key, this.readerId});

  final int? readerId;

  @override
  Widget build(BuildContext context) {
    final readers = context.read<ReaderRepository>();
    final id = readerId;
    final today = DateTime.now();

    return EntityFormScreen<Reader>(
      title: id == null ? 'Новый читатель' : 'Редактирование читателя',
      backPath: '/readers',
      notFoundMessage: 'Читатель не найден',
      savedMessage: id == null ? 'Читатель добавлен' : 'Изменения сохранены',
      loadItem: id == null ? null : () => readers.findById(id),
      initialValues: (reader) => {
        'lastName': reader?.lastName ?? '',
        'firstName': reader?.firstName ?? '',
        'email': reader?.email ?? '',
        'phone': reader?.phone ?? '',
        'cardNumber': reader?.card.number ?? '',
        'cardIssuedAt': formatRuDate(reader?.card.issuedAt ?? today),
        'cardExpiresAt': reader == null
            ? formatRuDate(DateTime(today.year + 1, today.month, today.day))
            : formatRuDate(reader.card.expiresAt),
      },
      fields: (reader) => [
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
          key: 'email',
          label: 'Электронная почта',
          required: true,
          hint: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          maxLength: 100,
          validator: checks([notBlank(), maxLength(100), emailFormat()]),
        ),
        FieldSpec.text(
          key: 'phone',
          label: 'Телефон',
          hint: '+7 900 123-45-67',
          keyboardType: TextInputType.phone,
          validator: checks([phoneFormat()]),
        ),
        FieldSpec.group(
          title: 'Читательский билет',
          fields: [
            FieldSpec.text(
              key: 'cardNumber',
              label: 'Номер билета',
              required: true,
              hint: 'LC-2025-011',
              validator: checks([notBlank(), cardNumberFormat()]),
            ),
            FieldSpec.text(
              key: 'cardIssuedAt',
              label: 'Дата выдачи',
              required: true,
              hint: 'дд.мм.гггг',
              isDate: true,
              validator: checks([notBlank(), dateFormat()]),
            ),
            FieldSpec.text(
              key: 'cardExpiresAt',
              label: 'Действует до',
              required: true,
              hint: 'дд.мм.гггг',
              isDate: true,
              validator: (value, values) =>
                  checks([notBlank(), dateFormat()])(value, values) ??
                  expiryAfterIssueCheck(value, values),
            ),
          ],
        ),
      ],
      save: (values, existing) async {
        final draft = Reader(
          id: existing?.id ?? 0,
          lastName: (values['lastName'] as String).trim(),
          firstName: (values['firstName'] as String).trim(),
          email: (values['email'] as String).trim(),
          phone: (values['phone'] as String).trim(),
          card: LibraryCard(
            number: (values['cardNumber'] as String).trim(),
            issuedAt: parseRuDate(values['cardIssuedAt'] as String)!,
            expiresAt: parseRuDate(values['cardExpiresAt'] as String)!,
          ),
          deletedAt: existing?.deletedAt,
        );
        if (existing == null) {
          await readers.create(draft);
        } else {
          await readers.update(draft);
        }
      },
    );
  }
}
