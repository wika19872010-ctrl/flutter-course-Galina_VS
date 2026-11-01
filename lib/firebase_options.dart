// Файл настроек подключения к Firebase для каждой поддерживаемой платформы.

// Файл создан командой настройки FlutterFire.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Хранит настройки подключения приложения к Firebase для разных платформ.
class DefaultFirebaseOptions {
  /// Определяет, где запущено приложение, и возвращает настройки Firebase для этой платформы.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          // Сообщаем о проблеме, чтобы показать её пользователю.
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          // Сообщаем о проблеме, чтобы показать её пользователю.
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJY43Rlvs2bgcWsa-dPWR-47hDC4KvOJE', // Указываем ключ подключения этой версии приложения к Firebase.
    appId: '1:322144529456:web:da43b9dbd1b50d09d711f5', // Указываем номер приложения в настройках Firebase.
    messagingSenderId:
        '322144529456', // Указываем номер отправителя из настроек Firebase.
    projectId: 'flutter-book-catalog', // Выбираем проект Firebase, в котором хранится каталог.
    authDomain: 'flutter-book-catalog.firebaseapp.com', // Передаём домен Firebase Authentication.
    storageBucket: 'flutter-book-catalog.firebasestorage.app', // Адрес хранилища из настроек Firebase; обложки туда не загружаем.
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDA0n3iIQO6RFPhXHS-b_kR3QQqTOwp-G4', // Указываем ключ подключения этой версии приложения к Firebase.
    appId: '1:322144529456:android:6aa2440386f5ecf5d711f5', // Указываем номер приложения в настройках Firebase.
    messagingSenderId:
        '322144529456', // Указываем номер отправителя из настроек Firebase.
    projectId: 'flutter-book-catalog', // Выбираем проект Firebase, в котором хранится каталог.
    storageBucket: 'flutter-book-catalog.firebasestorage.app', // Адрес хранилища из настроек Firebase; обложки туда не загружаем.
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAUyBLfajZI1xPAHycw3YgeD71PoEwiC9s', // Указываем ключ подключения этой версии приложения к Firebase.
    appId: '1:322144529456:ios:64042b086aeb66e9d711f5', // Указываем номер приложения в настройках Firebase.
    messagingSenderId:
        '322144529456', // Указываем номер отправителя из настроек Firebase.
    projectId: 'flutter-book-catalog', // Выбираем проект Firebase, в котором хранится каталог.
    storageBucket: 'flutter-book-catalog.firebasestorage.app', // Адрес хранилища из настроек Firebase; обложки туда не загружаем.
    iosBundleId: 'com.example.flutterApplicationDz27092026', // Передаём идентификатор приложения Apple, совпадающий с настройкой Xcode.
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAUyBLfajZI1xPAHycw3YgeD71PoEwiC9s', // Указываем ключ подключения этой версии приложения к Firebase.
    appId: '1:322144529456:ios:64042b086aeb66e9d711f5', // Указываем номер приложения в настройках Firebase.
    messagingSenderId:
        '322144529456', // Указываем номер отправителя из настроек Firebase.
    projectId: 'flutter-book-catalog', // Выбираем проект Firebase, в котором хранится каталог.
    storageBucket: 'flutter-book-catalog.firebasestorage.app', // Адрес хранилища из настроек Firebase; обложки туда не загружаем.
    iosBundleId: 'com.example.flutterApplicationDz27092026', // Передаём идентификатор приложения Apple, совпадающий с настройкой Xcode.
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBJY43Rlvs2bgcWsa-dPWR-47hDC4KvOJE', // Указываем ключ подключения этой версии приложения к Firebase.
    appId: '1:322144529456:web:fbd87f1ef234d0f8d711f5', // Указываем номер приложения в настройках Firebase.
    messagingSenderId:
        '322144529456', // Указываем номер отправителя из настроек Firebase.
    projectId: 'flutter-book-catalog', // Выбираем проект Firebase, в котором хранится каталог.
    authDomain: 'flutter-book-catalog.firebaseapp.com', // Передаём домен Firebase Authentication.
    storageBucket: 'flutter-book-catalog.firebasestorage.app', // Адрес хранилища из настроек Firebase; обложки туда не загружаем.
  );
}
