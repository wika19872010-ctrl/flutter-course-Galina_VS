import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/data/nickname_store.dart';
import 'package:flutter_application_dz_27092026/core/login_error_messages.dart';

void main() {
  test('Проверка и нормализация никнейма', () {
    expect(nicknameKey(' Reader '), nicknameKey('reader'));
    expect(nicknameKey('ЧИТАТЕЛЬ'), nicknameKey('читатель'));
    for (final name in [' ', 'имя/путь', 'имя с пробелом']) {
      expect(nicknameError(name), isNotNull);
    }
    expect(nicknameError('Читатель_1'), isNull);
  });

  test('Занятое имя не меняет владельца; отмена освобождает имя', () async {
    final db = FakeFirebaseFirestore();
    final store = NicknameStore(db: db);
    await store.reserve('Читатель', 'a');
    await expectLater(
      store.reserve('ЧИТАТЕЛЬ', 'b'),
      throwsA(
        isA<FirebaseAuthException>().having(
          (e) => e.code,
          'code',
          'nickname-already-in-use',
        ),
      ),
    );
    expect(
      (await db.collection('nicknames').doc(nicknameKey('читатель')).get())
          .data()?['ownerId'],
      'a',
    );
    await store.release('Читатель');
    await store.reserve('читатель', 'b');
    expect(
      (await db.collection('nicknames').get()).docs.single.data()['ownerId'],
      'b',
    );
  });

  test('Ошибка доступа не выдаётся за занятый никнейм', () async {
    final db = FakeFirebaseFirestore();
    final ref = db.collection('nicknames').doc(nicknameKey('Reader'));
    whenCalling(Invocation.method(#get, null))
        .on(ref)
        .thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        );
    await expectLater(
      NicknameStore(db: db).reserve('Reader', 'a'),
      throwsA(
        isA<FirebaseAuthException>().having(
          (e) => e.code,
          'code',
          'nickname-reservation-failed',
        ),
      ),
    );
    expect(
      loginErrorMessage(FirebaseAuthException(code: 'nickname-already-in-use')),
      'Этот никнейм уже занят. Выберите другой. (nickname-already-in-use)',
    );
  });
}
