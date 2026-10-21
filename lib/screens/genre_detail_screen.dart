import 'package:flutter/material.dart';

import '../models/genre.dart';
import '../widgets/detail_layout.dart';
import 'books_count_field.dart';
import 'entity_detail_screen.dart';

class GenreDetailScreen extends StatelessWidget {
  const GenreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EntityDetailScreen<Genre>(
      title: 'Карточка жанра',
      listPath: '/genres',
      listLabel: 'К списку жанров',
      notFoundMessage: 'Жанр не найден',
      editLocation: (genre) => '/genres/${genre.id}/edit',
      nameOf: (genre) => genre.name,
      isDeleted: (genre) => genre.isDeleted,
      fields: (context, genre) => [
        DetailField(
          label: 'Описание',
          child: Text(genre.description.isEmpty ? '—' : genre.description),
        ),
        BooksCountField(
          count: (books) => books.countByGenre(genre.id),
          booksLocation: '/books?genreId=${genre.id}',
        ),
      ],
    );
  }
}
