import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';
import 'package:flutter_application_dz_27092026/core/api_constants.dart';
import 'package:flutter_application_dz_27092026/domain/data/local_books.dart';

void main() {
  // ============================================================
  // ТЕСТ 1. GET, лайки, поиск и избранное
  // ============================================================

  testWidgets(
    'GET, лайки, поиск и избранное работают совместно',
    (tester) async {
      await http.runWithClient(
        () async {
          // Открываем каталог
          await tester.pumpWidget(
            const MaterialApp(
              home: CatalogScreen(),
            ),
          );

          // Проверяем индикатор загрузки
          expect(
            find.byType(CircularProgressIndicator),
            findsOneWidget,
          );

          // Ждём получения данных
          await tester.pumpAndSettle();

          // Проверяем количество книг
          expect(
            find.byType(BookCard),
            findsNWidgets(2),
          );

          debugPrint('GET: загружены две книги');

          // Проверяем сортировку: книга с ID 2 должна быть первой
          final cards = tester.widgetList<BookCard>(
            find.byType(BookCard),
          ).toList();

          expect(cards.first.book.id, 2);
          expect(cards.last.book.id, 1);

          debugPrint('Сортировка: книга с ID 2 находится первой');

          // Находим карточку книги с ID 2
          final book2Finder = find.byWidgetPredicate(
            (widget) =>
                widget is BookCard && widget.book.id == 2,
          );

          expect(book2Finder, findsOneWidget);

          // Добавляем книгу с ID 2 в избранное
          await tester.tap(
            find.descendant(
              of: book2Finder,
              matching: find.byIcon(Icons.favorite_border),
            ),
          );

          await tester.pump();

          debugPrint('Избранное: нажали на сердечко книги ID 2');

          // Включаем фильтр избранного
          await tester.tap(
            find.byTooltip('Показать только избранные'),
          );

          await tester.pump();

          // Должна остаться одна книга
          expect(
            find.byType(BookCard),
            findsOneWidget,
          );

          // Проверяем, что это именно книга ID 2
          final favoriteCard = tester.widget<BookCard>(
            find.byType(BookCard),
          );

          expect(favoriteCard.book.id, 2);

          debugPrint('Избранное: отображается книга ID 2');

          // Проверяем поиск несуществующей книги
          await tester.enterText(
            find.byType(TextField),
            '  НЕСУЩЕСТВУЮЩАЯ  ',
          );

          await tester.pump();

          expect(
            find.byType(BookCard),
            findsNothing,
          );

          debugPrint('Поиск: несуществующая книга не найдена');

          // Ищем книгу "Том 2"
          await tester.enterText(
            find.byType(TextField),
            '  ТОМ 2  ',
          );

          await tester.pump();

          // Проверяем результат поиска
          expect(
            find.byType(BookCard),
            findsOneWidget,
          );

          final foundCard = tester.widget<BookCard>(
            find.byType(BookCard),
          );

          expect(foundCard.book.id, 2);

          debugPrint('Поиск: книга "Том 2" найдена');

          debugPrint('Первый тест успешно завершён');
        },

        // Подменяем настоящий сервер тестовым
        () => MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), booksUrl);

          // Возвращаем две книги с ID 1 и 2
          return http.Response(
            jsonEncode(
              books
                  .take(2)
                  .map(
                    (book) => {
                      ...book.toJson(),
                      'id': book.id.toString(),
                      'title': 'Том ${book.id}',
                    },
                  )
                  .toList(),
            ),
            200,
            headers: {
              'content-type': 'application/json; charset=utf-8',
            },
          );
        }),
      );
    },
  );

  // ============================================================
  // ТЕСТЫ 2–6. Обработка ошибок и повторная загрузка
  // ============================================================

  for (final scenario in [
    'http',
    'json',
    'model',
    'network',
    'timeout',
  ]) {
    testWidgets(
      'Ошибка $scenario завершает загрузку, повтор восстанавливает список',
      (tester) async {
        var attempts = 0;

        final pending = Completer<http.Response>();

        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              const MaterialApp(
                home: CatalogScreen(),
              ),
            );

            await tester.pump();

            // Проверка тайм-аута
            if (scenario == 'timeout') {
              await tester.pump(
                const Duration(seconds: 11),
              );

              await tester.pump();
            }

            // Загрузка завершилась
            expect(
              find.byType(CircularProgressIndicator),
              findsNothing,
            );

            // Появилась кнопка повторной загрузки
            expect(
              find.text('Повторить загрузку'),
              findsOneWidget,
            );

            // Книги отсутствуют
            expect(
              find.byType(BookCard),
              findsNothing,
            );

            // Повторяем запрос
            await tester.tap(
              find.text('Повторить загрузку'),
            );

            await tester.pumpAndSettle();

            // Загрузка завершилась успешно
            expect(
              find.byType(CircularProgressIndicator),
              findsNothing,
            );

            // Сообщение об ошибке исчезло
            expect(
              find.text('Повторить загрузку'),
              findsNothing,
            );

            // Появилась одна книга
            expect(
              find.byType(BookCard),
              findsOneWidget,
            );

            if (!pending.isCompleted) {
              pending.complete(
                http.Response('[]', 200),
              );
            }

            await tester.pump();
          },

          () => MockClient((request) async {
            // При повторном запросе возвращаем успешный ответ
            if (attempts++ > 0) {
              return http.Response(
                jsonEncode([
                  {
                    ...books.first.toJson(),
                    'id': '1',
                  },
                ]),
                200,
                headers: {
                  'content-type': 'application/json; charset=utf-8',
                },
              );
            }

            // Первая попытка возвращает ошибку
            switch (scenario) {
              case 'http':
                return http.Response('Unavailable', 503);

              case 'json':
                return http.Response('invalid json', 200);

              case 'model':
                return http.Response('[{"id":"1"}]', 200);

              case 'network':
                throw http.ClientException('offline');

              default:
                return pending.future;
            }
          }),
        );
      },
    );
  }
}