import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/data/firestore_book_repository.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/widgets/book_card.dart';

import 'support/book_fixtures.dart';
import 'support/fake_favorites_store.dart';

void main() {
  testWidgets(
    'Общий каталог двух аккаунтов; изменения базы видны без обновления',
    (tester) async {
      final db = FakeFirebaseFirestore();
      final writer = FirestoreBookRepository(db: db, userId: 'legacy');
      await writer.saveBook(books.first.toJson());
      Widget app(String uid) => MaterialApp(
        home: CatalogScreen(
          key: ValueKey(uid),
          favorites: FakeFavoritesStore(),
          repository: FirestoreBookRepository(db: db, userId: uid),
        ),
      );
      await tester.pumpWidget(app('a'));
      await tester.pumpAndSettle();
      expect(find.byType(BookCard), findsOneWidget);
      expect(find.byTooltip('Удалить книгу'), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.pumpWidget(app('b'));
      await tester.pumpAndSettle();
      expect(find.byType(BookCard), findsOneWidget);
      await writer.saveBook({'title': 'Новая книга из другого клиента'});
      await tester.pumpAndSettle();
      expect(find.byType(BookCard), findsNWidgets(2));
    },
  );
}
