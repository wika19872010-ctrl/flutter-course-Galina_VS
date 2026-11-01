// Файл с методами регистрации, входа, выхода и получения токена текущего пользователя.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'nickname_store.dart';

/// Описывает действия входа, регистрации, выхода и получения имени пользователя.
abstract class LoginService {
  /// Сообщает об изменении входа: возвращает номер пользователя или null после выхода.
  Stream<String?> get userIdChanges;

  /// Выполняем вход по email и паролю.
  Future<void> signIn(String email, String password);

  /// Создаём Firebase-аккаунт по email и паролю.
  Future<void> register(String email, String password, String nickname);

  /// Читаем никнейм, который показывается рядом с опубликованными книгами.
  Future<String?> getNickname(String userId);

  /// Завершает сеанс Firebase; приложение получает событие выхода и открывает форму входа.
  Future<void> signOut();
}

/// Выполняет вход и регистрацию через Firebase и сохраняет имя пользователя.
class FirebaseLoginService implements LoginService {
  Completer<void>? _registration; // Не открываем каталог до сохранения имени.
  final FirebaseAuth _login; // Используем Firebase для входа и регистрации.
  /// Использует переданный сервис входа Firebase или стандартный сервис приложения.
  FirebaseLoginService({FirebaseAuth? login})
    : _login = login ?? FirebaseAuth.instance; // Используем запасное значение, если основное отсутствует.

  // SDK восстанавливает сохраненную сессию до первого события.
  /// Сообщает об изменении входа: возвращает номер пользователя или null после выхода.
  @override
  Stream<String?> get userIdChanges =>
      _login.authStateChanges().asyncMap((user) async {
        await _registration?.future;
        return _login.currentUser?.uid;
      }); // Преобразуем элементы коллекции в нужный формат.

  /// Выполняем вход по email и паролю.
  @override
  Future<void> signIn(String email, String password) async {
    await _login.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Создаём Firebase-аккаунт по email и паролю.
  @override
  Future<void> register(String email, String password, String nickname) async {
    final name = nickname.trim();
    // Повторяем проверку формы, чтобы сервис нельзя было вызвать с неверным именем.
    if (nicknameError(name) != null) {
      throw FirebaseAuthException(code: 'invalid-nickname');
    }
    final ready = Completer<void>();
    _registration = ready;
    try {
      final credential = await _login.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      final names = NicknameStore(
        db: FirebaseFirestore.instanceFor(app: _login.app),
      );
      bool reserved =
          false; // Освобождаем только имя, которое занял этот запрос.
      try {
        await names.reserve(
          name,
          user.uid,
        ); // Сервер исключает одновременное занятие имени.
        reserved = true;
        await credential.user!.updateDisplayName(name);
        await credential.user!.getIdToken(true);
      } catch (_) {
        // Не оставляем аккаунт без обязательного никнейма при сбое профиля.
        try {
          if (reserved) await names.release(name);
        } finally {
          // Удаляем созданный аккаунт, чтобы можно было повторить регистрацию с тем же email.
          try {
            await user.delete();
          } finally {
            await _login.signOut(); // Даже при сбое удаления не открываем незавершённую сессию.
          }
        }
        rethrow;
      }
    } finally {
      ready.complete();
      _registration = null;
    }
  }

  /// Ждёт завершения регистрации и возвращает имя указанного пользователя.
  /// Если это не текущий пользователь или имени нет, возвращает null.
  @override
  Future<String?> getNickname(String userId) async {
    await _registration?.future;
    final user = _login.currentUser;
    return user?.uid == userId ? user?.displayName : null;
  }

  /// Завершает сеанс Firebase; приложение получает событие выхода и открывает форму входа.
  @override
  Future<void> signOut() => _login.signOut();
}
