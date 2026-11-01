// Файл автоматических проверок отображения страны, автора, года и иконки жанра.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/domain/book.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_metadata.dart';

void main() {
  testWidgets('Country is a caption below author and year, not a genre tag', (
    // Проверяем описанный пользовательский сценарий.
    tester,
  ) async {
    const book = Book(
      id: '1', // Сохраняем постоянный номер книги, чтобы её лайки не потерялись.
      title: 'Книга',
      publisherNickname: 'Читатель',
      author: 'Автор', // Передаём имя автора.
      year: 2026, // Передаём год издания; ноль означает, что год не указан.
      authorCountry: 'Корея', // Передаём страна автора.
    );
    await tester.pumpWidget(
      // Открываем экран для проверки.
      const MaterialApp(
        home: Scaffold(
          // Выбираем начальный экран приложения.
          body: Column(
            children: [
              BookHeading(
                book: book,
              ), // Создаём название, автора, год и страну книги.
              BookGenres(
                book: book,
              ), // Показываем жанры книги в цветных плашках.
            ],
          ),
        ),
      ),
    );
    expect(find.text('Опубликовал: Читатель'), findsOneWidget);
    final author = find.text('Автор,2026'); // Храним имя автора.
    final country = find.text(
      'Страна автора: Корея',
    ); // Показываем страну отдельной строкой под автором и годом.
    expect(
      // Проверяем ожидаемый результат.
      tester.getTopLeft(country).dy,
      greaterThan(tester.getTopLeft(author).dy),
    );
    expect(
      // Проверяем ожидаемый результат.
      tester.widget<Text>(country).style,
      tester.widget<Text>(author).style,
    );
    expect(
      // Проверяем ожидаемый результат.
      find.descendant(of: find.byType(BookGenres), matching: country),
      findsNothing,
    );
    expect(
      find.byIcon(Icons.category_outlined),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
  });
}
