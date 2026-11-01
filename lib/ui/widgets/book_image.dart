// Файл отображения обложки из assets или по интернет-ссылке с заглушкой при ошибке.

import 'package:flutter/material.dart';

import 'book_cover_size.dart';

/// Показывает обложку из файлов приложения или по ссылке; при ошибке выводит значок книги.
class BookImage extends StatelessWidget {
  final String path; // Храним путь к asset либо HTTP-адрес картинки.
  /// Принимает путь к картинке из приложения или ссылку на изображение.
  const BookImage({super.key, required this.path}); // Создаём картинку обложки.
  /// Показываем заглушку, если обложка отсутствует.
  Widget _placeholder() => const SizedBox(
    width: bookCoverWidth, // Задаём ширину элемента.
    height: bookCoverHeight, // Задаём высоту элемента.
    child: ColoredBox(
      color: Colors.white,
      child: Icon(Icons.menu_book, size: 50, color: Colors.grey),
    ),
  );

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) return _placeholder();
    final cacheWidth = (bookCoverWidth * MediaQuery.devicePixelRatioOf(context))
        .ceil();
    final uri = Uri.tryParse(path); // Храним адрес HTTP-запроса.
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return Image.network(
        path,
        cacheWidth: cacheWidth,
        width: bookCoverWidth, // Задаём ширину элемента.
        height: bookCoverHeight, // Задаём высоту элемента.
        fit: BoxFit.cover, // Выбираем способ вписать изображение в обложку.
        errorBuilder: (_, error, stack) =>
            _placeholder(), // Показываем заглушку, если обложка отсутствует.
      );
    }
    return Image.asset(
      path,
      cacheWidth: cacheWidth,
      width: bookCoverWidth, // Задаём ширину элемента.
      height: bookCoverHeight, // Задаём высоту элемента.
      fit: BoxFit.cover, // Выбираем способ вписать изображение в обложку.
      errorBuilder: (_, error, stack) =>
          _placeholder(), // Показываем заглушку, если обложка отсутствует.
    );
  }
}
