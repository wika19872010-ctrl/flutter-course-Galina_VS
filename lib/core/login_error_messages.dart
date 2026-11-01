// Файл с понятными сообщениями об ошибках входа и регистрации.

import 'package:firebase_auth/firebase_auth.dart';

/// Переводим ошибку авторизации в понятный русский текст.
String loginErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Не удалось выполнить запрос. Попробуйте ещё раз.';
  }
  return '${_firebaseLoginMessage(error)} (${error.code})';
}

/// Подбирает понятный русский текст по коду ошибки Firebase.
/// Объясняет, например, неверный пароль, занятый адрес или отсутствие сети.
String _firebaseLoginMessage(FirebaseAuthException error) {
  // На Apple-платформах причина может приходить внутри internal-error.
  final details = '${error.code} ${error.message ?? ''}'.toUpperCase();
  if (details.contains('CONFIGURATION_NOT_FOUND') ||
      error.code == 'configuration-not-found') {
    return 'Регистрация и вход пока не настроены. '
        'В Firebase Console откройте Authentication → Get started '
        'и включите Email/Password.';
  }
  return switch (error.code) {
    //коды ошибок и ответы
    // Отдельно объясняем занятое имя и ошибку резервирования в Firestore.
    'nickname-already-in-use' => 'Этот никнейм уже занят. Выберите другой.',
    'invalid-nickname' => 'Никнейм: до 30 букв, цифр или символов _, . и -.',
    'nickname-reservation-failed' =>
      'Не удалось зарезервировать никнейм. Попробуйте ещё раз.',
    'invalid-email' => 'Введите корректный email.',
    'email-already-in-use' =>
      'Этот email уже зарегистрирован. Попробуйте войти.',
    'weak-password' =>
      'Пароль слишком слабый. Используйте не менее 6 символов.',
    'wrong-password' ||
    'user-not-found' ||
    'invalid-credential' ||
    'INVALID_LOGIN_CREDENTIALS' => 'Неверный email или пароль.',
    'user-disabled' => 'Эта учётная запись отключена.',
    'too-many-requests' =>
      'Слишком много попыток. Подождите и попробуйте снова.',
    'network-request-failed' =>
      'Нет соединения с сервером. Проверьте интернет.',
    'operation-not-allowed' => 'В Firebase не включён вход по email и паролю.',
    'invalid-api-key' || 'app-not-authorized' =>
      'Приложение не авторизовано в Firebase. Проверьте настройки проекта.',
    _ => 'Не удалось выполнить запрос. Попробуйте ещё раз.',
  };
}
