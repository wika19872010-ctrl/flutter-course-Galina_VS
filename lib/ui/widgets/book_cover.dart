// Файл обложки книги с Hero-переходом, возрастной меткой и кнопкой личного лайка.

import 'package:flutter/material.dart';

import '../../domain/book.dart';
import 'animated_like_button.dart';
import 'book_image.dart';

/// Общая обложка с возрастным ограничением и кнопкой избранного.
class BookCover extends StatelessWidget {
  final Book book;
  final bool isLiked; // Запоминаем, понравилась ли книга текущему пользователю.
  final VoidCallback onLikeTap; // Храним действие переключения личного лайка.

  /// Принимает книгу, состояние лайка и действие при нажатии на сердечко.
  const BookCover({
    // Создаём обложку с лайком и возрастом.
    super.key,
    required this.book,
    required this.isLiked,
    required this.onLikeTap,
  });

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    // Stack позволяет накладывать обложку, возрастную метку и сердечко друг на друга.
    return Stack(
      children: [
        Hero(
          // Переносим одну и ту же обложку между каталогом и подробностями.
          tag: 'book-cover-${book.id}', // Связываем обложки стабильным уникальным ID книги.
          child: ClipRRect(
            // Обрезает изображение по заданной форме.
            borderRadius: BorderRadius.circular(
              12,
            ), // Сохраняем текущий радиус углов.
            child: BookImage(path: book.image), // Анимируем только картинку, оставляя лайк интерактивным на экране.
          ),
        ),
        // Показываем возрастной бейдж, только если есть возрастное ограничение.
        if (book.ageRating > 0)
          Positioned(
            // Размещает виджет внутри Stack.
            top: 5,
            left: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ), // Создаём отступы внутри блока.
              decoration: BoxDecoration(
                // Оформляем фон и рамку.
                color: const Color.fromARGB(255, 243, 133, 100),
                borderRadius: BorderRadius.circular(
                  25,
                ), // Делаем углы закруглёнными.
              ),
              child: Text(
                '${book.ageRating}+',
                style: const TextStyle(
                  // Выбираем оформление текста.
                  color: Colors.black,
                  fontWeight: FontWeight.bold, // Выбираем толщину букв.
                  fontSize: 7, // Выбираем размер текста.
                ),
              ),
            ),
          ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            width: 30, // Задаём ширину элемента.
            height: 30, // Задаём высоту элемента.
            decoration: const BoxDecoration(
              // Оформляем фон и рамку.
              color: Color.fromARGB(255, 226, 206, 206),
              shape: BoxShape.circle, // Сохраняем форму кнопки или карточки.
            ),
            child: AnimatedLikeButton(
              // Одинаково анимируем лайк на карточке и в подробностях.
              isLiked: isLiked, // Передаём актуальное состояние личного лайка.
              onPressed: onLikeTap, // Сохраняем существующую обработку и запись в Firestore.
            ),
          ),
        ),
      ],
    ); // Возвращаем обложку.
  }
}
