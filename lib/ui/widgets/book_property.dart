// Файл отображения отдельной характеристики книги и подписи при отсутствии значения.

import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

/// Показывает одну характеристику книги; если значения нет, выводит пояснение.
class BookProperty extends StatelessWidget {
  final String label; // Подпись над полем.
  final Object? value; // Храним текущее обрабатываемое значение.
  final String emptyText;

  /// Принимает название характеристики, её значение и текст на случай отсутствия значения.
  const BookProperty({
    // Показываем дополнительное сведение о книге.
    super.key,
    required this.label,
    required this.value,
    required this.emptyText,
  });

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    final text = value == null || value.toString().isEmpty ? emptyText : value;
    return Text('$label: $text', style: AppStyles.detail);
  }
}
