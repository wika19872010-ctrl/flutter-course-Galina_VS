// Файл автоматических проверок редактирования книги и синхронизации списка с подробностями.

import 'package:flutter_application_dz_27092026/ui/widgets/book_cover.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';

import 'support/book_fixtures.dart';
import 'support/fake_book_repository.dart';
import 'support/fake_favorites_store.dart';

void main() {
  for (final save in [false, true]) {
    // Проверяем записи по одной.
    testWidgets('Editing updates details and list only on save=$save', (
      // Проверяем описанный пользовательский сценарий.
      tester,
    ) async {
      final repository = FakeBookRepository([
        books.first,
      ]); // Здесь читаем и сохраняем общие книги.
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
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        find.byTooltip('Удалить книгу'),
        findsOneWidget,
      ); // Кнопка удаления присутствует на своей карточке.
      expect(
        tester.getTopLeft(find.byType(BookCover)).dy,
        tester.getTopLeft(find.byType(BookHeading)).dy,
      ); // Выравниваем название с верхом обложки.
      await tester.tap(
        find.byType(BookCard),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        find.byTooltip('Удалить книгу'),
        findsOneWidget,
      ); // На подробностях своей книги также доступно удаление.
      expect(
        tester.getTopLeft(find.byType(BookCover)).dy,
        tester.getTopLeft(find.byType(BookHeading)).dy,
      ); // Проверяем выравнивание в подробностях.
      await tester.tap(
        find.byTooltip('Редактировать книгу'),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        find.widgetWithText(TextField, books.first.title),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      await tester.enterText(
        find.byType(TextField).first,
        'Новое название',
      ); // Вводим текст в поле.
      final button = find.text(save ? 'Сохранить изменения' : 'Отменить');
      await tester.scrollUntilVisible(
        // Прокручиваем форму до нужного элемента.
        button,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        button,
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        find.text('О книге'),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      expect(
        // Проверяем ожидаемый результат.
        find.text(save ? 'Новое название' : books.first.title),
        findsOneWidget,
      );
      expect(repository.saves, save ? 1 : 0); // Проверяем ожидаемый результат.
      await tester.pageBack(); // Проверяем возврат на предыдущий экран.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        // Проверяем ожидаемый результат.
        tester.widget<BookCard>(find.byType(BookCard)).book.title,
        save ? 'Новое название' : books.first.title,
      );
    });
  }
}
