// Файл автоматических проверок состояний Cubit, загрузки, фильтров, лайков и изменений книг.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/data/book_repository.dart';
import 'package:flutter_application_dz_27092026/domain/book.dart';
import 'package:flutter_application_dz_27092026/logic/books_cubit.dart';

import 'support/fake_book_repository.dart';
import 'support/fake_favorites_store.dart';
import 'package:flutter_application_dz_27092026/logic/books_state.dart';

void main() {
  const first = Book(id: '1', title: 'Первая книга');
  const second = Book(id: '2', title: 'Вторая книга');

  test('Подписка обновляет книги, сохраняет поиск и лайки, закрывается вместе с Cubit', () async {
    var cancellations = 0;
    final updates = StreamController<List<Book>>.broadcast(
      onCancel: () => cancellations++,
    );
    addTearDown(updates.close);
    final cubit = CatalogCubit(
      shared: FakeBookRepository([first])..updates = updates.stream,
      favorites: FakeFavoritesStore({'1'}),
    );
    await cubit.load();
    cubit.search('Первая');
    cubit.toggleFilter();
    updates.add([first, second]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.books, hasLength(2));
    expect(cubit.state.visibleBooks.single.id, '1');
    expect(cubit.state.likedIds, {'1'});
    await cubit.load();
    expect(cancellations, 1);
    updates.addError(const CatalogException('Ошибка потока'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.status, CatalogStatus.failure);
    expect(cubit.state.error, 'Ошибка потока');
    await cubit.load();
    updates.add([second]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.status, CatalogStatus.ready);
    expect(cubit.state.books.single.id, '2');
    await cubit.close();
    expect(cancellations, 3);
    expect(updates.hasListener, isFalse);
  });

  test('Счётчик учитывает чужие голоса и откатывается при ошибке', () async {
    final favorites = FakeFavoritesStore()..otherCounts['1'] = 3;
    final cubit = CatalogCubit(
      shared: FakeBookRepository([first]),
      favorites: favorites,
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.likeCounts['1'], 3);
    await cubit.toggleLike('1');
    expect(cubit.state.likeCounts['1'], 4);
    await cubit.load(); // Повторная загрузка не добавляет второй голос того же аккаунта.
    expect(cubit.state.likeCounts['1'], 4);
    favorites.error = const CatalogException('Нет сети');
    await cubit.toggleLike('1');
    expect(cubit.state.likeCounts['1'], 4);
    expect(cubit.state.likedIds, contains('1'));
    favorites.error = null;
    await cubit.toggleLike('1');
    expect(cubit.state.likeCounts['1'], 3);
  });

  test('Cubit exposes loading, data, failure and retry', () async {
    // Проверяем описанный пользовательский сценарий.
    final repository =
        FakeBookRepository([first]) // Здесь читаем и сохраняем общие книги.
          ..loadError = const CatalogException('Нет сети');
    final cubit = CatalogCubit(
      // Получаем общие данные списка и подробностей.
      shared: repository, // Передаём репозиторий общего каталога.
      favorites:
          FakeFavoritesStore(), // Передаём хранилище избранного текущего UID.
    );
    addTearDown(
      cubit.close,
    ); // После проверки закрываем созданные для неё объекты.
    expect(
      cubit.state, isA<CatalogLoadInProgress>()
    ); // Проверяем ожидаемый результат.
    await cubit.load();
    expect(
      cubit.state, isA<CatalogLoadFailure>(),
    ); // Проверяем ожидаемый результат.
    expect(cubit.state.error, 'Нет сети'); // Проверяем ожидаемый результат.
    repository.loadError = null;
    await cubit.load();
    expect(
      cubit.state, isA<CatalogLoadSuccess>()
    ); // Проверяем ожидаемый результат.
    expect(cubit.state.books.single.id, '1'); // Проверяем ожидаемый результат.
  });

  test('Search and favorites are combined in Cubit state', () async {
    // Проверяем описанный пользовательский сценарий.
    final cubit = CatalogCubit(
      // Получаем общие данные списка и подробностей.
      shared: FakeBookRepository([
        first,
        second,
      ]), // Передаём репозиторий общего каталога.
      favorites: FakeFavoritesStore({
        '2',
      }), // Передаём хранилище избранного текущего UID.
    );
    addTearDown(
      cubit.close,
    ); // После проверки закрываем созданные для неё объекты.
    await cubit.load();
    cubit.toggleFilter(); // Переключаем показ всех книг или только понравившихся.
    cubit.search(
      '  ВТОРАЯ  ',
    ); // Запоминаем текст поиска и обновляем список книг.
    expect(
      cubit.state.visibleBooks.single.id,
      '2',
    ); // Проверяем ожидаемый результат.
    cubit.search('Первая'); // Запоминаем текст поиска и обновляем список книг.
    expect(cubit.state.visibleBooks, isEmpty); // Проверяем ожидаемый результат.
    cubit.toggleFilter(); // Переключаем показ всех книг или только понравившихся.
    expect(
      cubit.state.visibleBooks.single.id,
      '1',
    ); // Проверяем ожидаемый результат.
    expect(
      () => cubit.state.books.clear(),
      throwsUnsupportedError,
    ); // Проверяем ожидаемый результат.
  });

  test('A failed like rolls back without losing another saved like', () async {
    // Проверяем описанный пользовательский сценарий.
    final favorites =
        FakeFavoritesStore({
            '2',
          }) // Сохраняем лайки отдельно для текущего аккаунта.
          ..error = const CatalogException('Нет сети');
    final cubit = CatalogCubit(
      // Получаем общие данные списка и подробностей.
      shared: FakeBookRepository([
        first,
        second,
      ]), // Передаём репозиторий общего каталога.
      favorites: favorites, // Передаём хранилище избранного текущего UID.
    );
    addTearDown(
      cubit.close,
    ); // После проверки закрываем созданные для неё объекты.
    await cubit.load();
    expect(
      await cubit.toggleLike('1'),
      isFalse,
    ); // Проверяем ожидаемый результат.
    expect(cubit.state.likedIds, {'2'}); // Проверяем ожидаемый результат.
    expect(cubit.state.busyLikes, isEmpty); // Проверяем ожидаемый результат.
    expect(cubit.state.notice, 'Нет сети'); // Проверяем ожидаемый результат.
  });

  test(
    // Проверяем описанный пользовательский сценарий.
    'A title-only addition appears in data and does not keep a stale filter',
    () async {
      final cubit = CatalogCubit(
        // Получаем общие данные списка и подробностей.
        shared: FakeBookRepository(), // Передаём репозиторий общего каталога.
        favorites:
            FakeFavoritesStore(), // Передаём хранилище избранного текущего UID.
      );
      addTearDown(
        cubit.close,
      ); // После проверки закрываем созданные для неё объекты.
      await cubit.load();
      cubit.search(
        'Старый поиск',
      ); // Запоминаем текст поиска и обновляем список книг.
      cubit.toggleFilter(); // Переключаем показ всех книг или только понравившихся.
      final saved = await cubit.saveBook({
        'title': 'Новая книга',
      }); // Храним книга, подтверждённая хранилищем.
      expect(
        cubit.state.visibleBooks.single.id,
        saved.id,
      ); // Проверяем ожидаемый результат.
      expect(cubit.state.savingBook, isFalse); // Проверяем ожидаемый результат.
      expect(saved.author, isEmpty); // Проверяем ожидаемый результат.
    },
  );

  test('Failed save keeps data intact and clears busy state', () async {
    // Проверяем описанный пользовательский сценарий.
    final repository =
        FakeBookRepository([first]) // Здесь читаем и сохраняем общие книги.
          ..saveError = const CatalogException('Нет сети');
    final cubit = CatalogCubit(
      // Получаем общие данные списка и подробностей.
      shared: repository, // Передаём репозиторий общего каталога.
      favorites:
          FakeFavoritesStore(), // Передаём хранилище избранного текущего UID.
    );
    addTearDown(
      cubit.close,
    ); // После проверки закрываем созданные для неё объекты.
    await cubit.load();
    await expectLater(
      cubit.saveBook({
        'title': 'Другая',
      }), // Сохраняем книгу и возвращаем подтверждённые данные.
      throwsA(isA<CatalogException>()),
    );
    expect(cubit.state.books.single.id, '1'); // Проверяем ожидаемый результат.
    expect(cubit.state.savingBook, isFalse); // Проверяем ожидаемый результат.
  });

  test('Delete failure keeps the card; success removes it', () async {
    // Проверяем описанный пользовательский сценарий.
    final repository =
        FakeBookRepository([first]) // Здесь читаем и сохраняем общие книги.
          ..deleteError = const CatalogException('Нет сети');
    final cubit = CatalogCubit(
      // Получаем общие данные списка и подробностей.
      shared: repository, // Передаём репозиторий общего каталога.
      favorites:
          FakeFavoritesStore(), // Передаём хранилище избранного текущего UID.
    );
    addTearDown(
      cubit.close,
    ); // После проверки закрываем созданные для неё объекты.
    await cubit.load();
    expect(
      await cubit.deleteBook(first),
      isFalse,
    ); // Проверяем ожидаемый результат.
    expect(cubit.state.books, hasLength(1)); // Проверяем ожидаемый результат.
    repository.deleteError = null;
    expect(
      await cubit.deleteBook(first),
      isTrue,
    ); // Проверяем ожидаемый результат.
    expect(cubit.state.books, isEmpty); // Проверяем ожидаемый результат.
  });

  test(
    // Проверяем описанный пользовательский сценарий.
    'Closing during a request does not emit into a disposed Cubit',
    () async {
      final pending = Completer<List<Book>>();
      final cubit = CatalogCubit(
        // Получаем общие данные списка и подробностей.
        shared: FakeBookRepository()
          ..onLoad = () =>
              pending.future, // Передаём репозиторий общего каталога.
        favorites:
            FakeFavoritesStore(), // Передаём хранилище избранного текущего UID.
      );
      final load = cubit.load();
      await cubit.close();
      pending.complete([first]);
      await load;
      expect(cubit.isClosed, isTrue); // Проверяем ожидаемый результат.
    },
  );
}
