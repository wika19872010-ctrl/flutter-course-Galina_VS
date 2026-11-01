// Файл автоматических проверок диагонального отворота страницы и возврата из подробностей.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/ui/navigation/book_page_route.dart';

void main() {
  testWidgets(
    // Проверяем описанный пользовательский сценарий.
    'Разворачивание листа открывает подробности и сворачивает их при возврате',
    (tester) async {
      await tester.pumpWidget(
        // Открываем экран для проверки.
        MaterialApp(
          home: Builder(
            // Выбираем начальный экран приложения.
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    BookPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('Подробности')),
                    ),
                  ),
                  child: const Text('Открыть'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(
        find.text('Открыть'),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(
        find.text('Подробности'),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      expect(
        find.byKey(const ValueKey('book-page-curl')),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      expect(
        find.byType(ClipPath),
        findsWidgets,
      ); // Проверяем ожидаемый результат.
      final clipping = find
          .descendant(
            of: find.byKey(const ValueKey('book-page-curl')),
            matching: find.byType(ClipPath),
          )
          .first; // Находим обрезку раскрываемой страницы.
      final clip = tester
          .widget<ClipPath>(clipping)
          .clipper!
          .getClip(
            tester.getSize(clipping),
          ); // Получаем контур в середине перехода.
      final size = tester.getSize(clipping); // Считываем размер страницы.
      expect(
        clip.contains(Offset(1, size.height - 1)),
        isTrue,
      ); // Страница начинает открываться снизу слева.
      expect(
        clip.contains(const Offset(1, 1)),
        isFalse,
      ); // Верхний левый угол ещё закрыт диагональным сгибом.
      expect(
        clip.contains(Offset(size.width - 1, size.height - 1)),
        isFalse,
      ); // Правый край раскрывается позже левого.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(tester.takeException(), isNull); // Проверяем ожидаемый результат.
      final context = tester.element(find.text('Подробности'));
      Navigator.pop(context); // Закрываем текущий экран и возвращаемся назад.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        find.text('Открыть'),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      expect(
        find.text('Подробности'),
        findsNothing,
      ); // Проверяем ожидаемый результат.
      expect(tester.takeException(), isNull); // Проверяем ожидаемый результат.
    },
  );
}
