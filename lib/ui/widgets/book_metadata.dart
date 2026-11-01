// Файл оформления названия, автора, года, страны и жанров книги.

import 'package:flutter/material.dart';

import '../../domain/book.dart';
import '../theme/app_styles.dart';
import 'book_genre_labels.dart';

/// Показывает название книги, автора, год, страну и имя опубликовавшего пользователя.
class BookHeading extends StatelessWidget {
  final Book book;

  /// Принимает книгу, краткие сведения которой будут показаны.
  const BookHeading({
    super.key,
    required this.book,
  }); // Создаём название, автора, год и страну книги.
  static const captionStyle = TextStyle(
    // Храним единый стиль автора, года и страны.
    fontSize: 14, // Выбираем размер текста.
    color: Color.fromARGB(255, 32, 24, 135),
    fontStyle: FontStyle.italic, // Показываем текст курсивом.
  );

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        book.title,
        maxLines: 5, // Ограничиваем число строк текста.
        overflow: TextOverflow
            .ellipsis, // Сокращаем слишком длинный текст многоточием.
        style: const TextStyle(
          // Выбираем оформление текста.
          fontSize: 16, // Выбираем размер текста.
          fontWeight: FontWeight.bold, // Выбираем толщину букв.
          height: 1, // Задаём высоту элемента.
        ),
      ),
      const SizedBox(
        height: 8,
      ), // Оставляем промежуток между соседними элементами.
      Text(
        '${book.author.isEmpty ? 'Автор не указан' : book.author}${book.year > 0 ? ',${book.year}' : ''}',
        style: captionStyle, // Выбираем оформление текста.
      ),
      Text(
        'Страна автора: ${book.authorCountry?.trim().isNotEmpty == true ? book.authorCountry : 'Не указана'}', // Показываем страну отдельной строкой под автором и годом.
        style: captionStyle, // Выбираем оформление текста.
      ),
      Text(
        'Опубликовал: ${book.publisherNickname?.trim().isNotEmpty == true ? book.publisherNickname : 'Не указан'}',
        style: captionStyle,
      ),
    ],
  );
}

/// Показывает названия жанров книги в отдельных цветных плашках.
class BookGenres extends StatelessWidget {
  final Book book;

  /// Принимает книгу, жанры которой будут показаны в плашках.
  const BookGenres({
    super.key,
    required this.book,
  }); // Показываем жанры книги в цветных плашках.
  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, // Задаём промежутки между элементами.
    runSpacing: 6, // Задаём промежутки между рядами плашек.
    children: [
      if (book.genres.isEmpty) _tag('Жанр не указан'),
      for (final genre in book.genres)
        _tag(genre.displayName), // Проверяем записи по одной.
    ],
  );

  /// Строим плашку со значком категории и названием жанра.
  Widget _tag(String name) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ), // Создаём отступы внутри блока.
    decoration: BoxDecoration(
      // Оформляем фон и рамку.
      color: AppColors.tag,
      borderRadius: BorderRadius.circular(20), // Делаем углы закруглёнными.
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.category_outlined, size: 12),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            name,
            style: const TextStyle(fontSize: 10, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
