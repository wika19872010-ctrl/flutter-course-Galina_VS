// Файл диалога выбора обложки из assets или ввода ссылки на изображение.

import 'package:flutter/material.dart';

/// Возвращаем путь или ссылку, выбранные пользователем.
Future<String?> chooseBookCover(BuildContext context, String current) =>
    showDialog<String>(
      context: context, // Используем контекст нужного экрана.
      builder: (_) => _CoverPicker(current: current),
    );

/// Открывает окно выбора готовой обложки или ссылки на изображение.
class _CoverPicker extends StatefulWidget {
  final String current; // Находим последнюю сохранённую версию открытой книги.
  /// Принимает текущую обложку, чтобы показать её путь в окне выбора.
  const _CoverPicker({required this.current});

  /// Создаёт объект состояния, который хранит изменяемые данные этого виджета.
  @override
  State<_CoverPicker> createState() => _CoverPickerState();
}

/// Хранит введённый путь к обложке и возвращает выбор при подтверждении.
class _CoverPickerState extends State<_CoverPicker> {
  late final _path = TextEditingController(
    text: widget.current,
  ); // Запоминаем введённый путь к картинке или ссылку на неё.
  /// Освобождает контроллеры при закрытии виджета, чтобы они больше не занимали ресурсы.
  @override
  void dispose() {
    _path.dispose();
    super.dispose();
  }

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Выбрать обложку'),
    content: SizedBox(
      width: 360, // Задаём ширину элемента.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            // Создаём выпадающий список.
            decoration: const InputDecoration(
              labelText: 'Готовая обложка',
            ), // Оформляем фон и рамку.
            items: [
              for (
                var number = 1;
                number <= 6;
                number++
              ) // Проверяем записи по одной.
                DropdownMenuItem(
                  value: 'assets/tom$number.png',
                  child: Text('Том $number'),
                ),
            ],
            onChanged: (value) {
              // Обрабатываем изменение поля.
              if (value != null) _path.text = value;
            },
          ),
          const SizedBox(
            height: 16,
          ), // Оставляем промежуток между соседними элементами.
          TextField(
            // Добавляем поле для ввода текста.
            controller: _path, // Запоминаем введённый текст, чтобы использовать его при сохранении.
            decoration: const InputDecoration(
              // Оформляем фон и рамку.
              labelText: 'Путь к картинке или ссылка', // Задаём подпись поля.
              hintText: 'assets/tom1.png или https://…', // Подсказываем ожидаемый формат ввода.
            ),
          ),
        ],
      ),
    ),
    actions: [
      // Размещаем кнопки доступных действий.
      TextButton(
        // Создаём кнопку с надписью.
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
        // Создаём кнопку с цветным фоном.
        onPressed: () => Navigator.pop(context, _path.text.trim()),
        child: const Text('Выбрать'),
      ),
    ],
  );
}
