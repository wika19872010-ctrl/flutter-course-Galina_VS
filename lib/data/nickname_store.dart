// Проверка никнеймов и атомарное резервирование через Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Проверяем формат одинаково в форме регистрации и перед записью профиля.
String? nicknameError(String value) {
  final name = value.trim();
  if (name.isEmpty) return 'Введите никнейм.';
  if (name.length > 30) return 'Никнейм — не более 30 символов.';
  if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ0-9_.-]+$').hasMatch(name)) {
    return 'Используйте русские или латинские буквы, цифры, _, . и -.';
  }
  return null;
}

/// Регистр не влияет на уникальность: Reader и reader занимают одно имя.
String nicknameKey(String nickname) => 'n_${nickname.trim().toLowerCase()}';

/// Резервирует никнеймы в базе, чтобы два пользователя не заняли одинаковое имя.
class NicknameStore {
  final FirebaseFirestore db;

  /// Принимает подключение к базе, в которой будут храниться занятые никнеймы.
  NicknameStore({required this.db});

  /// Проверяет никнейм и закрепляет его за пользователем.
  /// Если имя уже занято или не удалось сохранить его в базе, сообщает об ошибке.
  Future<void> reserve(String nickname, String userId) async {
    if (nicknameError(nickname) != null) {
      throw FirebaseAuthException(code: 'invalid-nickname');
    }
    final ref = db.collection('nicknames').doc(nicknameKey(nickname));
    try {
      await db.runTransaction((transaction) async {
        final existing = await transaction.get(ref);
        if (existing.exists) {
          throw FirebaseAuthException(code: 'nickname-already-in-use');
        }
        transaction.set(ref, {'ownerId': userId, 'nickname': nickname.trim()});
      });
    } on FirebaseException catch (error) {
      if (error is FirebaseAuthException) rethrow;
      throw FirebaseAuthException(code: 'nickname-reservation-failed');
    }
  }

  /// Удаляет запись о занятом никнейме.
  /// Используется для отмены резервирования, если регистрацию не удалось завершить.
  Future<void> release(String nickname) async {
    try {
      await db.collection('nicknames').doc(nicknameKey(nickname)).delete();
    } on FirebaseException {
      throw FirebaseAuthException(code: 'nickname-reservation-failed');
    }
  }
}
