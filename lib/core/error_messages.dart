// Файл преобразования ошибок запросов и данных в сообщения для пользователя.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../data/book_repository.dart';

/// Выбираем понятное сообщение о сетевой ошибке или формате данных.
String requestErrorMessage(
  Object error, {
  required String fallback,
  int timeoutSeconds = 10,
}) {
  if (error is CatalogException) return error.message;
  if (error is TimeoutException) {
    final seconds =
        error.duration?.inSeconds ??
        timeoutSeconds; // Берём фактический тайм-аут запроса, если он известен.
    return 'Сервер не ответил за $seconds секунд. Попробуйте ещё раз.'; // Показываем пользователю точное время ожидания.
  }
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'Нет доступа к данным. Попробуйте войти снова.';
    }
    if (error.code == 'unauthenticated') {
      return 'Сессия завершена. Войдите снова.';
    }
    if (![
      'unavailable',
      'deadline-exceeded',
      'network-request-failed',
    ].contains(error.code)) {
      return fallback;
    }
    return 'Не удалось подключиться к серверу. '
        'Проверьте интернет-соединение и повторите загрузку.';
  }
  if (error is FormatException ||
      error is TypeError ||
      error is ArgumentError) {
    return 'Сервер вернул данные в неподдерживаемом формате. '
        'Попробуйте ещё раз позже.';
  }
  return fallback;
}
