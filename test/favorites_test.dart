import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/data/book_repository.dart';
import 'package:flutter_application_dz_27092026/data/favorites_store.dart';
import 'package:flutter_application_dz_27092026/data/firestore_book_repository.dart';
import 'package:flutter_application_dz_27092026/main.dart';
import 'package:flutter_application_dz_27092026/logic/catalog_cubit.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';

import 'login_test.dart' show FakeLogin, enterCatalog;
import 'support/book_fixtures.dart';
import 'support/fake_book_repository.dart';
import 'support/fake_favorites_store.dart';

void main() {
  testWidgets('Лайки A и B различаются и сохраняются при повторном входе', (
    tester,
  ) async {
    final login = FakeLogin(signedIn: true);
    addTearDown(login.changes.close);
    final db = FakeFirebaseFirestore();
    final saved = await FirestoreBookRepository(
      db: db,
      userId: 'legacy',
    ).saveBook(books.first.toJson());
    Future<void> open() async {
      await tester.pumpWidget(MyApp(login: login, firestore: db));
      await tester.pumpAndSettle();
      await enterCatalog(tester);
    }

    Future<void> toggle(IconData icon) async {
      await tester.tap(
        find.descendant(of: find.byType(BookCard), matching: find.byIcon(icon)),
      );
      await tester.pumpAndSettle();
      await enterCatalog(tester);
    }

    await open();
    expect(tester.widget<BookCard>(find.byType(BookCard)).isLiked, isFalse);
    await toggle(Icons.favorite_border);
    expect(find.text('В избранном: 1'), findsOneWidget);
    expect(find.text('Лайков: 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await open();
    expect(tester.widget<BookCard>(find.byType(BookCard)).isLiked, isTrue);
    await tester.tap(find.byType(BookCard));
    await tester.pumpAndSettle();
    await enterCatalog(tester);
    expect(find.text('О книге'), findsOneWidget);
    login.uid = 'reader-b';
    login.changes.add(login.uid);
    await tester.pumpAndSettle();
    await enterCatalog(tester);
    expect(find.text('О книге'), findsNothing);
    expect(tester.widget<BookCard>(find.byType(BookCard)).isLiked, isFalse);
    expect(find.text('Лайков: 1'), findsOneWidget);
    await toggle(Icons.favorite_border);
    expect(find.text('Лайков: 2'), findsOneWidget);
    login.uid = 'reader-a';
    login.changes.add(login.uid);
    await tester.pumpAndSettle();
    await enterCatalog(tester);
    expect(tester.widget<BookCard>(find.byType(BookCard)).isLiked, isTrue);
    await toggle(Icons.favorite);
    expect(find.text('Лайков: 1'), findsOneWidget);
    expect(
      await FirestoreFavoritesStore(db: db, userId: 'reader-a').loadIds(),
      isEmpty,
    );
    expect(
      await FirestoreFavoritesStore(db: db, userId: 'reader-b').loadIds(),
      {saved.id},
    );
  });

  test('Старые числовые ID и лайки сохраняются без миграции книг', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('sharedBooks').doc('old-book-document').set({
      ...books.first.toJson(),
      'id': 7,
      'ownerId': 'a',
    });
    await db.doc('users/a/favorites/7').set({'bookId': 7});
    await db.doc('bookLikes/7_b').set({'bookId': 7, 'userId': 'b'});
    final store = FirestoreFavoritesStore(db: db, userId: 'a');
    expect(
      (await FirestoreBookRepository(
        db: db,
        userId: 'a',
      ).loadBooks()).single.id,
      'old-book-document',
    );
    expect(await store.loadIds(), {'7'});
    expect(await store.loadLikeCounts(), {'7': 2});
    expect(await store.loadLikeCounts(), {'7': 2});
    expect((await db.collection('bookLikes').get()).docs, hasLength(2));
  });

  test(
    'Старое избранное связано с doc.id после входа и переименования',
    () async {
      final db = FakeFirebaseFirestore();
      await db.doc('sharedBooks/old-document').set({
        ...books.first.toJson(),
        'id': 7,
        'ownerId': 'a',
      });
      await db.doc('users/a/favorites/7').set({'bookId': 7});
      final repo = FirestoreBookRepository(db: db, userId: 'a');
      final store = FirestoreFavoritesStore(db: db, userId: 'a');
      final cubit = CatalogCubit(shared: repo, favorites: store);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.likedIds, {'old-document'});
      expect(cubit.state.likeCounts, {'old-document': 1});
      final book = cubit.state.books.single;
      await cubit.saveBook({
        ...book.toJson(),
        'title': 'Переименованная',
      }, id: book.id);
      expect((await db.doc('sharedBooks/old-document').get()).data()!['id'], 7);
      await cubit.load();
      expect(cubit.state.likedIds, {'old-document'});
      await cubit.toggleLike('old-document');
      expect(await store.loadIds(), isEmpty);
      expect((await db.collection('bookLikes').get()).docs, isEmpty);
      await cubit.toggleLike('old-document');
      await cubit.load();
      expect(cubit.state.likedIds, {'old-document'});
      expect(await store.loadIds(), {'7'});
    },
  );

  test(
    'Повторная запись не добавляет голос; удаление сохраняет чужой голос',
    () async {
      final db = FakeFirebaseFirestore();
      final a = FirestoreFavoritesStore(db: db, userId: 'a');
      final b = FirestoreFavoritesStore(db: db, userId: 'b');
      await a.setLiked('7', true);
      await a.setLiked('7', true);
      await b.setLiked('7', true);
      expect(await a.loadLikeCounts(), {'7': 2});
      await a.setLiked('7', false);
      expect(await a.loadIds(), isEmpty);
      expect(await b.loadIds(), {'7'});
      expect(await b.loadLikeCounts(), {'7': 1});
    },
  );

  test('Избранное не обрезается после 300 документов', () async {
    final db = FakeFirebaseFirestore();
    final batch = db.batch();
    for (var i = 0; i < 305; i++) {
      batch.set(db.doc('users/a/favorites/$i'), {'bookId': i});
    }
    await batch.commit();
    expect(
      await FirestoreFavoritesStore(db: db, userId: 'a').loadIds(),
      hasLength(305),
    );
  });

  testWidgets('Like failure restores both details and catalog', (tester) async {
    // Проверяем описанный пользовательский сценарий.
    final favorites =
        FakeFavoritesStore() // Сохраняем лайки отдельно для текущего аккаунта.
          ..error = const CatalogException('Не удалось сохранить лайк');
    await tester.pumpWidget(
      // Открываем экран для проверки.
      MaterialApp(
        home: CatalogScreen(
          // Выбираем начальный экран приложения.
          repository: FakeBookRepository([
            books.first,
          ]), // Передаём репозиторий выбранного каталога.
          favorites: favorites, // Передаём хранилище избранного текущего UID.
        ),
      ),
    );
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    await tester.tap(
      find.byType(BookCard),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    await tester.tap(
      find.byIcon(Icons.favorite_border),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byIcon(Icons.favorite_border),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
    await tester.pageBack(); // Проверяем возврат на предыдущий экран.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      tester.widget<BookCard>(find.byType(BookCard)).isLiked,
      isFalse,
    ); // Проверяем ожидаемый результат.
    expect(favorites.ids, isEmpty);
    expect(
      find.text('Лайков: 0'),
      findsOneWidget,
    ); // Ошибка откатывает и общий счётчик. // Проверяем ожидаемый результат.
  });
}
