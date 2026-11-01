// Файл автоматических проверок Hero-перехода обложки и анимации нажатия на лайк.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/animated_like_button.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_image.dart';

import 'support/book_fixtures.dart';
import 'support/fake_book_repository.dart';
import 'support/fake_favorites_store.dart';

void main() {
  // Проверяем обе анимации из дополнительной опции задания.
  testWidgets('Cover flies between catalog and details and returns', (
    tester,
  ) async {
    // Проверяем настоящий маршрут и полёт обложки.
    await tester.pumpWidget(
      MaterialApp(
        home: CatalogScreen(
          repository: FakeBookRepository([books.first]),
          favorites: FakeFavoritesStore(),
        ),
      ),
    ); // Открываем каталог с одной книгой.
    await tester.pumpAndSettle(); // Дожидаемся загрузки каталога.
    final source = tester.getTopLeft(
      find.byType(BookImage),
    ); // Запоминаем положение обложки в списке.
    expect(
      tester
          .widget<Hero>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Hero &&
                  widget.tag == 'book-cover-${books.first.id}',
            ),
          )
          .tag,
      'book-cover-${books.first.id}',
    ); // Проверяем уникальный тег книги.
    await tester.tap(
      find.byType(BookCard),
    ); // Открываем подробности через реальный маршрут.
    await tester.pump(); // Запускаем переход и Hero-контроллер.
    await tester.pump(
      const Duration(milliseconds: 250),
    ); // Проверяем промежуточный кадр полёта.
    final flight = tester.getTopLeft(
      find.byType(BookImage),
    ); // Получаем позицию летящей обложки в Overlay.
    await tester.pumpAndSettle();
    final destination = tester.getTopLeft(
      find.byType(BookImage),
    ); // Получаем положение в подробностях.
    expect(
      flight,
      isNot(source),
    ); // Обложка действительно движется от карточки.
    expect(
      flight,
      isNot(destination),
    ); // В промежуточном кадре полёт ещё не завершён.
    expect(
      tester
          .widget<Hero>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Hero &&
                  widget.tag == 'book-cover-${books.first.id}',
            ),
          )
          .tag,
      'book-cover-${books.first.id}',
    ); // Подробности используют тот же тег.
    await tester.pageBack(); // Запускаем обратный полёт.
    await tester.pumpAndSettle(); // Дожидаемся возврата в каталог.
    expect(
      tester.getTopLeft(find.byType(BookImage)),
      source,
    ); // Обложка возвращается на прежнее место.
    expect(
      tester.takeException(),
      isNull,
    ); // Проверяем отсутствие ошибок Hero и разметки.
  });

  testWidgets('Like pulses once and settles without repeating the callback', (
    tester,
  ) async {
    // Проверяем импульс кнопки и однократное действие.
    var presses = 0; // Считаем вызовы сохранения лайка.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedLikeButton(isLiked: false, onPressed: () => presses++),
        ),
      ),
    ); // Открываем кнопку в тестовом приложении.
    await tester.tap(find.byType(IconButton)); // Нажимаем на сердечко.
    await tester.pump(); // Запускаем отсчёт анимации.
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // Проверяем фазу увеличения.
    expect(
      tester
          .widget<ScaleTransition>(
            find.descendant(
              of: find.byType(AnimatedLikeButton),
              matching: find.byType(ScaleTransition),
            ),
          )
          .scale
          .value,
      greaterThan(1),
    ); // Сердечко увеличивается.
    await tester.pumpAndSettle(); // Дожидаемся завершения импульса.
    expect(
      tester
          .widget<ScaleTransition>(
            find.descendant(
              of: find.byType(AnimatedLikeButton),
              matching: find.byType(ScaleTransition),
            ),
          )
          .scale
          .value,
      1,
    ); // Размер возвращается к исходному.
    expect(presses, 1); // Анимация не вызывает повторное сохранение лайка.
  });
}
