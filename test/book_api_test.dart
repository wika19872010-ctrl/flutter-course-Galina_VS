import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/data/book_repository.dart';
import 'package:flutter_application_dz_27092026/data/firestore_book_repository.dart';

import 'support/book_fixtures.dart';

void main() {
  late FakeFirebaseFirestore db;
  FirestoreBookRepository repository(String uid) => FirestoreBookRepository(
    db: db,
    userId: uid,
    getNickname: () async => 'Читатель',
  );
  setUp(() => db = FakeFirebaseFirestore());

  test(
    'Сохранение, повторное чтение и редактирование сохраняют ID и никнейм',
    () async {
      final repo = repository('a');
      final saved = await repo.saveBook({
        ...books.first.toJson(),
        'publisherNickname': 'Подмена',
        'isLiked': true,
      });
      final restarted = repository('a');
      final reloaded = (await restarted.loadBooks()).single;
      expect(reloaded.id, saved.id);
      expect(reloaded.publisherNickname, 'Читатель');
      final edited = await restarted.saveBook({
        ...saved.toJson(),
        'description': 'Новое описание',
        'publisherNickname': 'Другой',
      }, id: saved.id);
      expect(edited.id, saved.id);
      expect(edited.publisherNickname, 'Читатель');
      expect(
        (await repository('b').loadBooks()).single.description,
        'Новое описание',
      );
      expect(
        (await db.collection('sharedBooks').get()).docs.single.data(),
        isNot(contains('isLiked')),
      );
    },
  );

  test('Обязательно только название, остальные поля получают значения по умолчанию', () async {
    final saved = await repository('a').saveBook({'title': 'Только название'});
    expect(saved.author, isEmpty);
    expect(saved.genres, isEmpty);
    expect(saved.year, 0);
    expect((await repository('b').loadBooks()).single.id, saved.id);
  });

  test('Одинаковые названия создают разные документы через add', () async {
    final a = await repository('a')
        .saveBook({'title': 'Моя книга', 'author': 'Автор'});
    final b = await repository('b')
        .saveBook({'title': 'Моя книга', 'author': 'Автор'});
    expect(a.id, isNot(b.id));
    final docs = (await db.collection('sharedBooks').get()).docs;
    expect(docs, hasLength(2));
    expect(docs.map((doc) => doc.id), containsAll([a.id, b.id]));
    expect(docs.every((doc) => !doc.data().containsKey('id')), isTrue);
  });

  test('Переименование не меняет документ и не теряет лайки', () async {
    final repo = repository('a');
    final first = await repo.saveBook(books[0].toJson());
    final renamed = await repo.saveBook({
      ...first.toJson(),
      'title': 'Новое название',
    }, id: first.id);
    expect(renamed.id, first.id);
    final doc = await db.collection('sharedBooks').doc(first.id).get();
    expect(doc.data()!['title'], 'Новое название');
    expect((await repo.loadBooks()).single.id, first.id);
  });

  test(
    'Устаревшее редактирование и удаление не затирают чужие изменения',
    () async {
      final writer = repository('a');
      final saved = await writer.saveBook(books.first.toJson());
      final stale = repository('a');
      await stale.loadBooks();
      await writer.saveBook({
        ...saved.toJson(),
        'description': 'Свежая версия',
      }, id: saved.id);
      await expectLater(
        stale.saveBook({
          ...saved.toJson(),
          'description': 'Старая версия',
        }, id: saved.id),
        throwsA(isA<CatalogException>()),
      );
      await expectLater(
        stale.deleteBook(saved.id),
        throwsA(isA<CatalogException>()),
      );
      expect(
        (await repository('b').loadBooks()).single.description,
        'Свежая версия',
      );
    },
  );

  test(
    'Изменение и удаление разрешены владельцу; повторное удаление распознаётся',
    () async {
      final owner = repository('a');
      final saved = await owner.saveBook(books.first.toJson());
      final other = repository('b');
      await other.loadBooks();
      expect(other.canManage(saved), isFalse);
      await expectLater(
        other.deleteBook(saved.id),
        throwsA(isA<CatalogException>()),
      );
      await expectLater(
        other.saveBook(saved.toJson(), id: saved.id),
        throwsA(isA<CatalogException>()),
      );
      final stale = repository('a');
      await stale.loadBooks();
      expect(await owner.deleteBook(saved.id), DeleteBookResult.deleted);
      expect(await stale.deleteBook(saved.id), DeleteBookResult.alreadyAbsent);
    },
  );

  test('Подписка получает изменения другого экземпляра репозитория', () async {
    final stream = repository('b').watchBooks();
    final expectation = expectLater(
      stream,
      emitsInOrder([
        isEmpty,
        predicate<List<dynamic>>(
          (items) => items.length == 1 && items.single.title == 'Из консоли',
        ),
      ]),
    );
    await Future<void>.delayed(Duration.zero);
    await repository('a').saveBook({'title': 'Из консоли'});
    await expectation;
  });

  test('Ошибка Firestore не выдаётся за успешное добавление', () async {
    db = FakeFirebaseFirestore(
      securityRules: """
      service cloud.firestore {
        match /databases/{database}/documents {
          match /{document=**} { allow read: if true; allow write: if false; }
        }
      }
    """,
    );
    await expectLater(
      repository('a').saveBook({'title': 'Новая'}),
      throwsException,
    );
    expect(db.dump(), isNot(contains('Новая')));
  });

  test('Пустое название не создаёт документ', () async {
    await expectLater(
      repository('a').saveBook({'title': '  '}),
      throwsA(isA<CatalogException>()),
    );
    expect((await db.collection('sharedBooks').get()).docs, isEmpty);
  });
}
