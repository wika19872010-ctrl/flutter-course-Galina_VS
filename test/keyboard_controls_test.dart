// Файл автоматических проверок стандартной клавиатуры и ввода с физической клавиатуры.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_form_field.dart';

void main() {
  testWidgets('Native keyboard and physical editing remain enabled', (
    // Проверяем описанный пользовательский сценарий.
    tester,
  ) async {
    final controller =
        TextEditingController(); // Храним введённый в поле текст.
    addTearDown(
      controller.dispose,
    ); // После проверки закрываем созданные для неё объекты.
    await tester.pumpWidget(
      // Открываем экран для проверки.
      MaterialApp(
        home: Scaffold(
          // Выбираем начальный экран приложения.
          body: BookFormField(
            label: 'Title',
            hintText: 'Book title', // Подсказываем ожидаемый формат ввода.
            controller: controller, // Запоминаем введённый текст, чтобы использовать его при сохранении.
          ),
        ),
      ),
    );
    await tester.tap(
      find.byType(TextField),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester.pump();
    expect(
      // Проверяем ожидаемый результат.
      tester.testTextInput.setClientArgs!['inputType']['name'],
      'TextInputType.text',
    );
    expect(
      tester.testTextInput.isVisible,
      isTrue,
    ); // Проверяем ожидаемый результат.
    tester.testTextInput.enterText('Reader');
    await tester.pump();
    expect(controller.text, 'Reader'); // Проверяем ожидаемый результат.
    await tester.sendKeyEvent(
      LogicalKeyboardKey.arrowLeft,
    ); // Имитируем событие физической клавиатуры.
    await tester.sendKeyEvent(
      LogicalKeyboardKey.backspace,
    ); // Имитируем событие физической клавиатуры.
    expect(controller.text, 'Readr'); // Проверяем ожидаемый результат.
  });
}
