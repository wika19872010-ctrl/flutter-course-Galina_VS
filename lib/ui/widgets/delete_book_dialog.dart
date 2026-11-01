// Файл диалога подтверждения удаления книги.

import 'package:flutter/material.dart';

import '../../domain/book.dart';

/// Просит пользователя подтвердить удаление книги.
/// Возвращает true при подтверждении; отмена и закрытие окна дают false.
Future<bool> confirmBookDeletion(BuildContext context, Book book) async =>
    await showDialog<bool>(
      context: context, // Используем контекст нужного экрана.
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить книгу?'),
        content: Text('Вы действительно хотите удалить книгу «${book.title}»?'),
        actions: [
          // Размещаем кнопки доступных действий.
          TextButton(
            // Создаём кнопку с надписью.
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            // Создаём кнопку с надписью.
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    ) ?? // Используем запасное значение, если основное отсутствует.
    false;
