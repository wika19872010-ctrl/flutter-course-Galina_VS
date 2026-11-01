// Файл автоматических проверок формы книги, обязательного названия и сохранения выбранной обложки.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';

import 'support/fake_book_repository.dart';
import 'support/fake_favorites_store.dart';

void main() {
  testWidgets('Only title is required, and selected cover persists', (
    // Проверяем описанный пользовательский сценарий.
    tester,
  ) async {
    final repository =
        FakeBookRepository(); // Здесь читаем и сохраняем общие книги.
    await tester.pumpWidget(
      // Открываем экран для проверки.
      MaterialApp(
        home: CatalogScreen(
          // Выбираем начальный экран приложения.
          repository: repository, // Передаём репозиторий выбранного каталога.
          favorites: FakeFavoritesStore(), // Передаём хранилище избранного текущего UID.
        ),
      ),
    );
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    await tester.tap(
      find.byTooltip('Добавить новую книгу'),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    final save = find.text('Добавить книгу');
    await tester.scrollUntilVisible(
      // Прокручиваем форму до нужного элемента.
      save,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(repository.saves, 0); // Проверяем ожидаемый результат.
    expect(
      // Проверяем ожидаемый результат.
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Введите название книги'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      // Прокручиваем форму до нужного элемента.
      find.byType(TextField).first,
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byType(TextField).first,
      'Только название',
    ); // Вводим текст в поле.
    await tester.scrollUntilVisible(
      // Прокручиваем форму до нужного элемента.
      find.widgetWithText(TextButton, 'Выбрать обложку'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.widgetWithText(TextButton, 'Выбрать обложку'),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    await tester.enterText(
      find.byType(TextField).last,
      'assets/tom2.png',
    ); // Вводим текст в поле.
    await tester.tap(
      find.text('Выбрать'),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    await tester.scrollUntilVisible(
      // Прокручиваем форму до нужного элемента.
      save,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byType(BookCard),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
    expect(
      repository.books.single.author,
      isEmpty,
    ); // Проверяем ожидаемый результат.
    expect(
      repository.books.single.image,
      'assets/tom2.png',
    ); // Проверяем ожидаемый результат.
  });
}
