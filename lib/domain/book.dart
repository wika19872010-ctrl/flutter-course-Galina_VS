// Файл модели книги: хранит её поля, перечень жанров и преобразования в JSON и обратно.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель книги — описывает, какие данные содержит каждая книга.
class Book {
  /// Строковый ID документа книги в Firestore.
  final String id;

  /// Старый числовой номер в виде строки; нужен для сохранения прежних лайков.
  final String? legacyId;

  /// Ключ личного избранного: старый номер или ID документа для новых книг.
  String get favoriteId => legacyId ?? id;

  /// Название книги.
  final String title;

  /// Имя автора книги.
  final String author;

  /// Список жанров книги.
  final List<BookGenre> genres;

  /// Год издания; ноль означает, что год не указан.
  final int year;

  /// Путь к обложке из assets или ссылка на изображение.
  final String image;

  /// Описание книги; знак ? допускает строку или null.
  final String? description;

  /// Возрастное ограничение книги.
  final int ageRating;

  /// Число страниц, если оно известно.
  final int? pages;

  /// Название издательства.
  final String? publisher;

  /// Размеры книги.
  final String? dimensions;

  /// Международный номер ISBN.
  final String? isbn;

  /// Страна автора.
  final String? authorCountry;

  /// Никнейм пользователя, опубликовавшего книгу.
  final String? publisherNickname;

  /// Номер пользователя, который добавил книгу.
  final String? ownerId;

  /// Конструктор — создаёт объект Book с указанными данными.
  const Book({
    required this.id,
    this.legacyId,
    required this.title,
    this.author = '',
    this.genres = const [],
    this.year = 0,
    this.image = '',
    this.description,
    this.ageRating = 0,
    this.pages,
    this.publisher,
    this.dimensions,
    this.isbn,
    this.authorCountry,
    this.ownerId,
    this.publisherNickname,
  });

  /// Берёт ID из имени документа, а старый номер сохраняет для совместимости лайков.
  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw const FormatException('Книга не найдена.');
    return Book.fromJson({
      ...data,
      'id': doc.id,
      'legacyId': data['id']?.toString(),
    });
  }

  /// Преобразует JSON с сервера в объект Book и проверяет наличие названия.
  factory Book.fromJson(Map<String, dynamic> json) {
    if (json['title'] is! String) {
      throw const FormatException(
        'У книги отсутствует название.',
      ); // Сообщаем о проблеме, чтобы показать её пользователю.
    }
    return Book(
      id: json['id'].toString(),
      legacyId: json['legacyId'] as String?,
      title:
          json['title'] as String, // Получаем название и проверяем тип String.
      author: json['author'] as String? ?? '', // Передаём имя автора.
      genres:
          (json['genres'] as List? ?? []) // Передаём список жанров книги.
              .map(
                (value) => BookGenre.values.byName(value as String),
              ) // Преобразуем элементы коллекции в нужный формат.
              .toList(), // Собираем подходящие записи в один список.
      year:
          (json['year'] as num?)?.toInt() ??
          0, // Передаём год издания; ноль означает, что год не указан.
      image:
          json['image'] as String? ??
          '', // Передаём путь к обложке или адрес картинки.
      description:
          json['description'] as String?, // Передаём подробное описание книги.
      ageRating:
          (json['ageRating'] as num?)?.toInt() ??
          0, // Передаём возрастное ограничение.
      pages: int.tryParse(
        '${json['pages']}',
      ), // Передаём число страниц, если оно известно.
      publisher:
          json['publisher'] as String?, // Передаём название издательства.
      dimensions: json['dimensions'] as String?, // Передаём размер книги.
      isbn: json['isbn']?.toString(), // Передаём международный номер ISBN.
      authorCountry:
          json['authorCountry'] as String?, // Передаём страна автора.
      publisherNickname: json['publisherNickname'] as String?,
      ownerId: json['ownerId'] as String?, // Запоминаем, кто добавил книгу.
    );
  }

  /// Преобразует объект Book в JSON для сохранения на сервере.
  /// ID не отправляется: при создании документа Firestore выдаёт его сам.
  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author, // Передаём имя автора.
    'genres': genres
        .map((genre) => genre.name)
        .toList(), // Передаём список жанров книги.
    'year': year, // Передаём год издания; ноль означает, что год не указан.
    'image': image, // Передаём путь к обложке или адрес картинки.
    'description': description ?? '', // Передаём подробное описание книги.
    'ageRating': ageRating, // Передаём возрастное ограничение.
    'pages': pages, // Передаём число страниц, если оно известно.
    'publisher': publisher ?? '', // Передаём название издательства.
    'dimensions': dimensions ?? '', // Передаём размер книги.
    'isbn': isbn ?? '', // Передаём международный номер ISBN.
    'authorCountry': authorCountry ?? '', // Передаём страна автора.
  };
}

/// Жанры, с которыми сравниваем значения из JSON через byName.
enum BookGenre { fantasy, novella, noRomance, friendship }
