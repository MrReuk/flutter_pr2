import '../models/author.dart';
import '../models/book.dart';
import '../models/genre.dart';
import '../models/publisher.dart';

const List<Genre> seedGenres = [
  Genre(1, 'Манга'),
  Genre(2, 'Фэнтези'),
  Genre(3, 'Финансы'),
  Genre(4, 'Саморазвитие'),
  Genre(5, 'Психология'),
  Genre(6, 'Контркультура'),
  Genre(7, 'Приключения'),
  Genre(8, 'Хоррор'),
  Genre(9, 'Постапокалипсис'),
];

const List<Publisher> seedPublishers = [
  Publisher(1, 'Истари Комикс'),
  Publisher(2, 'Попурри'),
  Publisher(3, 'МИФ'),
  Publisher(4, 'АСТ'),
  Publisher(5, 'Бомбора'),
  Publisher(6, 'Питер'),
  Publisher(7, 'Амфора'),
  Publisher(8, 'Рипол Классик'),
];

const List<Author> seedAuthors = [
  Author(id: 1, firstName: 'Кэнтаро', lastName: 'Миура', country: 'Япония', birthYear: 1966, biography: 'Японский мангака, автор тёмного фэнтези «Берсерк», над которым работал с 1989 года.'),
  Author(id: 2, firstName: 'Эйитиро', lastName: 'Ода', country: 'Япония', birthYear: 1975, biography: 'Японский мангака, автор «Ван-Пис» — самой продаваемой манги в истории.'),
  Author(id: 3, firstName: 'Суи', lastName: 'Исида', country: 'Япония', birthYear: 1986, biography: 'Японский мангака, автор мрачной манги «Токийский гуль».'),
  Author(id: 4, firstName: 'Хирому', lastName: 'Аракава', country: 'Япония', birthYear: 1973, biography: 'Японская мангака, автор «Стального алхимика».'),
  Author(id: 5, firstName: 'Тите', lastName: 'Кубо', country: 'Япония', birthYear: 1977, biography: 'Японский мангака, автор «Блич» о жнецах душ.'),
  Author(id: 6, firstName: 'Коёхару', lastName: 'Готогэ', country: 'Япония', birthYear: 1989, biography: 'Автор манги «Клинок, рассекающий демонов».'),
  Author(id: 7, firstName: 'Тацуки', lastName: 'Фудзимото', country: 'Япония', birthYear: 1992, biography: 'Японский мангака, автор «Человека-бензопилы».'),
  Author(id: 8, firstName: 'Акихито', lastName: 'Цукуси', country: 'Япония', birthYear: 1981, biography: 'Японский мангака, автор приключенческой манги «Созданный в Бездне».'),
  Author(id: 9, firstName: 'Роберт', lastName: 'Кийосаки', country: 'США', birthYear: 1947, biography: 'Американский предприниматель и писатель, автор серии «Богатый папа, бедный папа».'),
  Author(id: 10, firstName: 'Джеймс', lastName: 'Клир', country: 'США', birthYear: 1986, biography: 'Американский писатель, автор «Атомных привычек».'),
  Author(id: 11, firstName: 'Марк', lastName: 'Мэнсон', country: 'США', birthYear: 1984, biography: 'Американский блогер и писатель, автор «Тонкого искусства пофигизма».'),
  Author(id: 12, firstName: 'Наполеон', lastName: 'Хилл', country: 'США', birthYear: 1883, biography: 'Американский автор книг о достижении успеха, написал «Думай и богатей».'),
  Author(id: 13, firstName: 'Роберт', lastName: 'Грин', country: 'США', birthYear: 1959, biography: 'Американский автор книг о стратегии и психологии власти.'),
  Author(id: 14, firstName: 'Дейл', lastName: 'Карнеги', country: 'США', birthYear: 1888, biography: 'Американский писатель и лектор, автор книги «Как завоёвывать друзей и оказывать влияние на людей».'),
  Author(id: 15, firstName: 'Роберт', lastName: 'Чалдини', country: 'США', birthYear: 1945, biography: 'Американский психолог, исследователь психологии убеждения.'),
  Author(id: 16, firstName: 'Чак', lastName: 'Паланик', country: 'США', birthYear: 1962, biography: 'Американский писатель, автор романа «Бойцовский клуб».'),
  Author(id: 17, firstName: 'Чарльз', lastName: 'Буковски', country: 'США', birthYear: 1920, biography: 'Американский поэт и прозаик, мастер «грязного реализма», автор романа «Почтамт».'),
  Author(id: 18, firstName: 'Дмитрий', lastName: 'Глуховский', country: 'Россия', birthYear: 1979, biography: 'Российский писатель, автор постапокалиптического цикла «Метро».'),
  Author(id: 19, firstName: 'Анджей', lastName: 'Сапковский', country: 'Польша', birthYear: 1948, biography: 'Польский писатель, создатель цикла о ведьмаке Геральте.'),
  Author(id: 20, firstName: 'Кал', lastName: 'Ньюпорт', country: 'США', birthYear: 1982, biography: 'Американский писатель и профессор информатики, автор книги «Глубокая работа».'),
];

const List<Book> seedBooks = [
  Book(id: 1, title: 'Берсерк. Том 1', isbn: '978-5-6040-0001-1', year: 1990, pages: 224, publisherId: 1, authorIds: [1], genreIds: [1, 2], copiesTotal: 6, copiesAvailable: 4),
  Book(id: 2, title: 'Ван-Пис. Том 1', isbn: '978-5-6040-0002-8', year: 1997, pages: 208, publisherId: 1, authorIds: [2], genreIds: [1, 7], copiesTotal: 8, copiesAvailable: 5),
  Book(id: 3, title: 'Токийский гуль. Том 1', isbn: '978-5-6040-0003-5', year: 2011, pages: 224, publisherId: 1, authorIds: [3], genreIds: [1, 8], copiesTotal: 5, copiesAvailable: 2),
  Book(id: 4, title: 'Стальной алхимик. Том 1', isbn: '978-5-17-100004-2', year: 2001, pages: 192, publisherId: 4, authorIds: [4], genreIds: [1, 2], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 5, title: 'Блич. Том 1', isbn: '978-5-17-100005-9', year: 2001, pages: 192, publisherId: 4, authorIds: [5], genreIds: [1, 2], copiesTotal: 4, copiesAvailable: 3),
  Book(id: 6, title: 'Клинок, рассекающий демонов. Том 1', isbn: '978-5-6040-0006-6', year: 2016, pages: 192, publisherId: 1, authorIds: [6], genreIds: [1, 2], copiesTotal: 7, copiesAvailable: 6),
  Book(id: 7, title: 'Человек-бензопила. Том 1', isbn: '978-5-6040-0007-3', year: 2018, pages: 192, publisherId: 1, authorIds: [7], genreIds: [1, 8], copiesTotal: 6, copiesAvailable: 1),
  Book(id: 8, title: 'Созданный в Бездне. Том 1', isbn: '978-5-17-100008-0', year: 2012, pages: 160, publisherId: 4, authorIds: [8], genreIds: [1, 7], copiesTotal: 3, copiesAvailable: 3),
  Book(id: 9, title: 'Богатый папа, бедный папа', isbn: '978-985-15-0009-7', year: 1997, pages: 336, publisherId: 2, authorIds: [9], genreIds: [3, 4], copiesTotal: 10, copiesAvailable: 6),
  Book(id: 10, title: 'Квадрант денежного потока', isbn: '978-985-15-0010-3', year: 1998, pages: 368, publisherId: 2, authorIds: [9], genreIds: [3], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 11, title: 'Атомные привычки', isbn: '978-5-00146-011-4', year: 2018, pages: 320, publisherId: 3, authorIds: [10], genreIds: [4], copiesTotal: 9, copiesAvailable: 3),
  Book(id: 12, title: 'Тонкое искусство пофигизма', isbn: '978-5-04-100012-1', year: 2016, pages: 224, publisherId: 5, authorIds: [11], genreIds: [4, 5], copiesTotal: 6, copiesAvailable: 2),
  Book(id: 13, title: 'Думай и богатей', isbn: '978-985-15-0013-4', year: 1937, pages: 336, publisherId: 2, authorIds: [12], genreIds: [3, 4], copiesTotal: 5, copiesAvailable: 4),
  Book(id: 14, title: '48 законов власти', isbn: '978-5-386-10014-8', year: 1998, pages: 640, publisherId: 8, authorIds: [13], genreIds: [5], copiesTotal: 4, copiesAvailable: 1),
  Book(id: 15, title: 'Как завоёвывать друзей и оказывать влияние на людей', isbn: '978-985-15-0015-8', year: 1936, pages: 352, publisherId: 2, authorIds: [14], genreIds: [4, 5], copiesTotal: 6, copiesAvailable: 5),
  Book(id: 16, title: 'Психология влияния', isbn: '978-5-496-00016-5', year: 1984, pages: 336, publisherId: 6, authorIds: [15], genreIds: [5], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 17, title: 'Бойцовский клуб', isbn: '978-5-17-100017-2', year: 1996, pages: 288, publisherId: 4, authorIds: [16], genreIds: [6], copiesTotal: 5, copiesAvailable: 3),
  Book(id: 18, title: 'Почтамт', isbn: '978-5-367-00018-9', year: 1971, pages: 288, publisherId: 7, authorIds: [17], genreIds: [6], copiesTotal: 3, copiesAvailable: 2),
  Book(id: 19, title: 'Метро 2033', isbn: '978-5-17-100019-6', year: 2005, pages: 544, publisherId: 4, authorIds: [18], genreIds: [9], copiesTotal: 8, copiesAvailable: 5),
  Book(id: 20, title: 'Ведьмак. Последнее желание', isbn: '978-5-17-100020-2', year: 1993, pages: 352, publisherId: 4, authorIds: [19], genreIds: [2], copiesTotal: 7, copiesAvailable: 4),
  Book(id: 21, title: 'Ведьмак. Меч предназначения', isbn: '978-5-17-100021-9', year: 1992, pages: 384, publisherId: 4, authorIds: [19], genreIds: [2], copiesTotal: 6, copiesAvailable: 6),
  Book(id: 22, title: 'Ведьмак. Кровь эльфов', isbn: '978-5-17-100022-6', year: 1994, pages: 384, publisherId: 4, authorIds: [19], genreIds: [2], copiesTotal: 6, copiesAvailable: 3),
  Book(id: 23, title: 'Метро 2034', isbn: '978-5-17-100023-3', year: 2009, pages: 384, publisherId: 4, authorIds: [18], genreIds: [9], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 24, title: 'Глубокая работа', isbn: '978-5-00146-024-4', year: 2016, pages: 296, publisherId: 3, authorIds: [20], genreIds: [4], copiesTotal: 4, copiesAvailable: 0),
  Book(id: 25, title: 'Богатый папа. Руководство по инвестированию', isbn: '978-985-15-0025-7', year: 2000, pages: 400, publisherId: 2, authorIds: [9], genreIds: [3], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 26, title: 'Берсерк. Том 2', isbn: '978-5-6040-0026-4', year: 1990, pages: 224, publisherId: 1, authorIds: [1], genreIds: [1, 2], copiesTotal: 6, copiesAvailable: 5),
];
