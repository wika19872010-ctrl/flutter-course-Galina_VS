// Файл общего поля ввода для формы книги с подписью и подсказкой.

import '../theme/app_styles.dart';

import 'package:flutter/material.dart';

// Поле формы книги с общей подписью, оформлением и отступами.
/// Показывает поле ввода с подписью, подсказкой и общим оформлением формы.
class BookFormField extends StatelessWidget {
  final String label; // Подпись над полем.
  final String hintText; // Подсказка, видимая до ввода текста.
  /// Контроллер позволяет работать с текстом, который пользователь ввёл в поле.
  final TextEditingController controller;
  final TextInputType?
  keyboardType; // Храним тип системной клавиатуры для поля.
  final int maxLines; // Сколько строк можно показать в поле.
  final int? minLines; // Сколько строк занимает пустое многострочное поле.

  /// Принимает подпись, подсказку, контроллер текста и настройки поля ввода.
  const BookFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
  });

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppStyles.fieldLabel),
        const SizedBox(
          height: 8,
        ), // Оставляем промежуток между соседними элементами.
        TextField(
          // Добавляем поле для ввода текста.
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(), // При нажатии вне поля завершаем ввод и скрываем клавиатуру.
          controller: controller, // Запоминаем введённый текст, чтобы использовать его при сохранении.
          keyboardType: keyboardType, // Выбираем удобную клавиатуру; ввод с физической клавиатуры тоже работает.
          maxLines: maxLines, // Ограничиваем число строк текста.
          minLines: minLines, // Оставляем место для нескольких строк текста.
          decoration: InputDecoration(
            // Оформляем фон и рамку.
            hintText: hintText, // Подсказываем ожидаемый формат ввода.
            filled: true, // Закрашиваем фон поля ввода.
            fillColor: Colors.white, // Выбираем цвет поля ввода.
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ), // Настраиваем рамку элемента.
          ),
        ),
        const SizedBox(
          height: 20,
        ), // Оставляем промежуток между соседними элементами.
      ],
    );
  }
}
