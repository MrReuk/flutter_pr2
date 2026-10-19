# library_app

Практическая работа 2. Каталог книг и авторов: поиск, фильтры, сортировка, пагинация, адрес как источник состояния. Данные хранятся в памяти.

## Запуск

```
flutter create . --project-name library_app --platforms web
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port=5555
```

Первая команда только добавляет папку `web/` и служебные файлы, код она не трогает.

## Структура

```
lib/
  models/        Book, Author, PageResult, BookQuery, AuthorQuery
  data/          начальные наборы (26 книг, 20 авторов)
  repositories/  интерфейсы и реализации в памяти
  state/         ChangeNotifier-ы для списков, карточек и справочников
  screens/       экраны списков, карточек, 404
  widgets/       EntityTable<T>, пагинация, панель поиска и фильтров и т.д.
  router.dart    go_router, условия отбора читаются из адреса
```

## Адреса

| Адрес | Что открывает |
|---|---|
| `/books` | список книг |
| `/books?search=папа&genreId=3&publisherId=2&yearFrom=1990&yearTo=2020&sort=year,desc&page=2&size=25&deleted=1` | список с условиями |
| `/books/5` | карточка книги |
| `/authors?search=япония&sort=birthYear,desc` | список авторов |
| `/authors/3` | карточка автора |

Поиск `!error` имитирует сбой репозитория, по нему делается снимок состояния ошибки.
