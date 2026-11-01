// Файл карточки книги в списке: обложка, краткие сведения, лайк и удаление своей книги.

import 'package:flutter/material.dart';

import '../../domain/book.dart';
import '../theme/app_styles.dart';
import 'book_cover.dart';
import 'book_metadata.dart';

/// Виджет карточки книги в каталоге.
class BookCard extends StatelessWidget {
  /// Информация о книге.
  final Book book;
  final int
  likeCount; // Показываем сумму лайков всех аккаунтов, включая текущий.
  /// Показывает, добавлена ли книга в избранное.
  final bool isLiked;

  /// Позволяет карточке реагировать на нажатие сердечка.
  final VoidCallback onLikeTap;

  /// Действие при нажатии на удаление; null скрывает кнопку.
  final VoidCallback? onDeleteTap;
  final VoidCallback onCardTap; // Храним переход к подробностям книги.
  /// Конструктор, через который карточка получает необходимые данные.
  const BookCard({
    super.key,
    required this.book,
    required this.isLiked,
    this.likeCount = 0,
    required this.onLikeTap,
    required this.onDeleteTap,
    required this.onCardTap,
  });

  /// Метод build создаёт интерфейс карточки книги.
  /// BuildContext содержит информацию о положении виджета в дереве Flutter.
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onCardTap, // Назначаем действие нажатия.
    child: Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Создаём отступы вокруг карточки.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Сохраняем форму кнопки или карточки.
      child: Padding(
        padding: const EdgeInsets.all(12), // Создаём отступы внутри блока.
        child: Column(
          // Размещаем действия над обложкой и текстом.
          children: [
            // Сначала показываем кнопки, затем содержимое карточки.
            Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onDeleteTap != null)
                    IconButton(
                      // Создаём кнопку со значком.
                      onPressed: onDeleteTap,
                      tooltip: 'Удалить книгу', // Поясняем назначение кнопки при долгом нажатии.
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Оставляем свободное место вокруг содержимого.
                  padding: EdgeInsets.zero, // Создаём отступы внутри блока.
                  child: BookCover(
                    book: book,
                    isLiked: isLiked, // Показываем, понравилась ли книга текущему пользователю.
                    onLikeTap: onLikeTap, // Передаём действие переключения личного лайка.
                  ),
                ),
                const SizedBox(
                  width: 12,
                ), // Оставляем промежуток между соседними элементами.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookHeading(
                        book: book,
                      ), // Создаём название, автора, год и страну книги.
                      const SizedBox(
                        height: 12,
                      ), // Оставляем промежуток между соседними элементами.
                      Text(
                        'Лайков: $likeCount',
                      ), // Счётчик доступен и без личного лайка.
                      const SizedBox(height: 8),
                      BookGenres(
                        book: book,
                      ), // Показываем жанры книги в цветных плашках.
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
