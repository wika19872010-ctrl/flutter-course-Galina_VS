// Файл автоматических проверок загрузки каталога, поиска, избранного и повторной загрузки после ошибки.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_dz_27092026/data/book_repository.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';

import 'support/book_fixtures.dart';
import 'support/fake_book_repository.dart';
import 'support/fake_favorites_store.dart';

void main() {
  testWidgets('Search combines with personal favorites', (tester) async {
    // Проверяем описанный пользовательский сценарий.
    final favorites =
        FakeFavoritesStore(); // Сохраняем лайки отдельно для текущего аккаунта.
    await tester.pumpWidget(
      // Открываем экран для проверки.
      MaterialApp(
        home: CatalogScreen(
          // Выбираем начальный экран приложения.
          repository: FakeBookRepository(
            books.take(2).toList(),
          ), // Передаём репозиторий выбранного каталога.
          favorites: favorites, // Передаём хранилище избранного текущего UID.
        ),
      ),
    );
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byType(BookCard),
      findsNWidgets(2),
    ); // Проверяем ожидаемый результат.
    final second = find.byWidgetPredicate(
      (widget) => widget is BookCard && widget.book.id == books[1].id,
    );
    await tester.tap(
      // Нажимаем кнопку, как это сделал бы пользователь.
      find.descendant(of: second, matching: find.byIcon(Icons.favorite_border)),
    );
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(favorites.ids, {books[1].id}); // Проверяем ожидаемый результат.
    await tester.tap(
      find.byTooltip('Показать только избранные'),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byType(BookCard),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
    expect(find.text('Книги к прочтению'), findsOneWidget);
    expect(find.text('Каталог книг'), findsNothing);
    await tester.enterText(
      // Вводим текст в поле.
      find.byType(TextField),
      '  ${books[1].title.toUpperCase()}  ',
    );
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byType(BookCard),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
    await tester.enterText(
      find.byType(TextField),
      'Нет такой книги',
    ); // Вводим текст в поле.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byType(BookCard),
      findsNothing,
    ); // Проверяем ожидаемый результат.
  });

  for (final error in [
    // Проверяем записи по одной.
    const CatalogException('Ошибка сервера'),
    const FormatException('bad'),
    TimeoutException('slow'),
    FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
  ]) {
    testWidgets('Catalog reports ${error.runtimeType} and can retry', (
      // Проверяем описанный пользовательский сценарий.
      tester,
    ) async {
      final repository = FakeBookRepository([books.first])
        ..loadError = error; // Здесь читаем и сохраняем общие книги.
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
        find.byType(BookCard),
        findsNothing,
      ); // Проверяем ожидаемый результат.
      expect(
        find.text('Обновить'),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      repository.loadError = null;
      await tester.tap(
        find.text('Обновить'),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      expect(
        find.byType(BookCard),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
    });
  }
}
