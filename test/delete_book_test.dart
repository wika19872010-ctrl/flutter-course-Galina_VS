// Файл автоматических проверок удаления книги, подтверждения, отмены и ошибок сервера.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/data/book_repository.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';

import 'support/book_fixtures.dart';
import 'support/fake_book_repository.dart';
import 'support/fake_favorites_store.dart';

void main() {
  for (final scenario in ['delete', 'absent', 'failure', 'cancel']) {
    // Проверяем записи по одной.
    testWidgets('Confirmed deletion: $scenario', (tester) async {
      // Проверяем описанный пользовательский сценарий.
      final repository =
          FakeBookRepository([
              books.first,
            ]) // Здесь читаем и сохраняем общие книги.
            ..alreadyAbsent = scenario == 'absent'
            ..deleteError = scenario == 'failure'
                ? const CatalogException('Ошибка удаления')
                : null;
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
      await tester.tap(
        find.byTooltip('Удалить книгу'),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(repository.deletes, 0); // Проверяем ожидаемый результат.
      await tester.tap(
        find.text(scenario == 'cancel' ? 'Отмена' : 'Удалить'),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        // Проверяем ожидаемый результат.
        find.byType(BookCard),
        scenario == 'delete' || scenario == 'absent'
            ? findsNothing
            : findsOneWidget,
      );
      expect(
        repository.deletes,
        scenario == 'cancel' ? 0 : 1,
      ); // Проверяем ожидаемый результат.
    });
  }
}
