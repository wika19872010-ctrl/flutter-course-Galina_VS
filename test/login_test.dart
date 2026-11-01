// Файл автоматических проверок входа, регистрации, выхода и защиты каталога без авторизации.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_application_dz_27092026/data/login_service.dart';
import 'package:flutter_application_dz_27092026/main.dart';
import 'package:flutter_application_dz_27092026/core/login_error_messages.dart';
import 'package:flutter_application_dz_27092026/ui/screens/welcome_screen.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_screen.dart';
import 'package:flutter_application_dz_27092026/ui/screens/catalog_welcome_screen.dart';

class FakeLogin implements LoginService {
  bool signedIn;
  FakeLogin({this.signedIn = false});
  final changes = StreamController<String?>.broadcast();
  String uid = 'reader-a';
  String? errorCode;
  String? lastEmail;
  String? lastPassword;
  int registrations = 0;
  String? nickname;

  @override
  Future<String?> getNickname(String userId) async => nickname;

  @override
  Stream<String?> get userIdChanges async* {
    yield signedIn ? uid : null;
    yield* changes.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    // Выполняем вход по email и паролю.
    lastEmail = email;
    lastPassword = password;
    if (errorCode != null) throw FirebaseAuthException(code: errorCode!);
    signedIn = true;
    changes.add(uid);
  }

  @override
  Future<void> register(String email, String password, String nickname) async {
    this.nickname = nickname; // Создаём Firebase-аккаунт по email и паролю.
    registrations++;
    await signIn(email, password);
  }

  @override
  Future<void> signOut() async {
    if (errorCode != null) throw FirebaseAuthException(code: errorCode!);
    signedIn = false;
    changes.add(null);
  }
}

Future<void> fillCredentials(
  WidgetTester tester, {
  String password = 'secret123',
}) async {
  await tester.enterText(
    // Вводим текст в поле.
    find.widgetWithText(TextFormField, 'Email'),
    '  reader@example.com  ',
  );
  if (find.byKey(const ValueKey('nickname')).evaluate().isNotEmpty) {
    await tester.enterText(find.byKey(const ValueKey('nickname')), 'Читатель');
  }
  await tester.enterText(
    find.byType(TextFormField).last,
    password,
  ); // Вводим текст в поле.
}

Future<void> enterCatalog(WidgetTester tester) async {
  final button = find.text('Перейти в каталог');
  if (button.evaluate().isNotEmpty) {
    await tester.tap(button);
    await tester.pumpAndSettle();
  }
}

void main() {
  late FakeFirebaseFirestore db;
  setUp(() => db = FakeFirebaseFirestore());
  testWidgets('После входа приветствуем по никнейму, затем открываем каталог', (
    tester,
  ) async {
    final login = FakeLogin()..nickname = 'Книголюб';
    addTearDown(login.changes.close);
    await tester.pumpWidget(MyApp(login: login, firestore: db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();
    await fillCredentials(tester);
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(
      find.text('Книголюб, добро пожаловать в каталог книг!'),
      findsOneWidget,
    );
    expect(find.byType(CatalogScreen), findsNothing);
    await enterCatalog(tester);
    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(find.byType(CatalogWelcomeScreen), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(CatalogScreen))).canPop(),
      isFalse,
    );
  });

  test('Ошибка настройки Firebase распознаётся и внутри internal-error', () {
    // Проверяем описанный пользовательский сценарий.
    for (final error in [
      // Проверяем записи по одной.
      FirebaseAuthException(code: 'configuration-not-found'),
      FirebaseAuthException(
        code: 'internal-error',
        message: '{"message":"CONFIGURATION_NOT_FOUND"}',
      ),
    ]) {
      expect(
        loginErrorMessage(error),
        allOf(contains('включите Email/Password'), contains('(${error.code})')),
      ); // Проверяем ожидаемый результат.
    }
  });

  testWidgets('С приветствия можно открыть вход и вернуться назад', (
    // Проверяем описанный пользовательский сценарий.
    tester,
  ) async {
    final login = FakeLogin(); // Храним сервис входа и регистрации.
    addTearDown(
      login.changes.close,
    ); // После проверки закрываем созданные для неё объекты.
    await tester.pumpWidget(
      MyApp(login: login, firestore: db),
    ); // Открываем экран для проверки.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byIcon(Icons.auto_stories_rounded),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
    await tester.tap(
      find.text('Начать'),
    ); // Нажимаем кнопку, как это сделал бы пользователь.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.byType(TextFormField),
      findsNWidgets(2),
    ); // Проверяем ожидаемый результат.
    await tester.pageBack(); // Проверяем возврат на предыдущий экран.
    await tester
        .pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
    expect(
      find.text('Начать'),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
  });

  testWidgets(
    // Проверяем описанный пользовательский сценарий.
    'Без входа каталог недоступен; вход, выход и восстановленная сессия',
    (tester) async {
      final login = FakeLogin(); // Храним сервис входа и регистрации.
      addTearDown(
        login.changes.close,
      ); // После проверки закрываем созданные для неё объекты.
      await (() async {
        await tester.pumpWidget(
          MyApp(login: login, firestore: db),
        ); // Открываем экран для проверки.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        expect(
          find.byType(CatalogScreen),
          findsNothing,
        ); // Проверяем ожидаемый результат.
        expect(
          find.byType(WelcomeScreen),
          findsOneWidget,
        ); // Проверяем ожидаемый результат.
        expect(
          find.byType(TextFormField),
          findsNothing,
        ); // Проверяем ожидаемый результат.
        await tester.tap(
          find.text('Начать'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        await fillCredentials(tester);
        await tester.tap(
          find.text('Войти'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        await enterCatalog(tester);
        expect(
          find.byType(CatalogScreen),
          findsOneWidget,
        ); // Проверяем ожидаемый результат.
        expect(
          login.lastEmail,
          'reader@example.com',
        ); // Проверяем ожидаемый результат.
        expect(
          login.lastPassword,
          'secret123',
        ); // Проверяем ожидаемый результат.
        // Новый экземпляр приложения получает сохраненное состояние сервиса.
        await tester.pumpWidget(
          const SizedBox(),
        ); // Открываем экран для проверки.
        await tester.pumpWidget(
          MyApp(login: login, firestore: db),
        ); // Открываем экран для проверки.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        await enterCatalog(tester);
        expect(
          find.byType(CatalogScreen),
          findsOneWidget,
        ); // Проверяем ожидаемый результат.
        await tester.tap(
          find.text('Выйти'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        expect(
          find.byType(CatalogScreen),
          findsNothing,
        ); // Проверяем ожидаемый результат.
        expect(
          find.text('Войти'),
          findsOneWidget,
        ); // Проверяем ожидаемый результат.
        await tester.pumpWidget(
          const SizedBox(),
        ); // Открываем экран для проверки.
        await tester.pumpWidget(
          MyApp(login: login, firestore: db),
        ); // Открываем экран для проверки.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        expect(
          find.byType(CatalogScreen),
          findsNothing,
        ); // Проверяем ожидаемый результат.
      })();
    },
  );

  testWidgets(
    // Проверяем описанный пользовательский сценарий.
    'Короткий пароль регистрации проверяется до запроса; регистрация открывает каталог',
    (tester) async {
      final login = FakeLogin(); // Храним сервис входа и регистрации.
      addTearDown(
        login.changes.close,
      ); // После проверки закрываем созданные для неё объекты.
      await (() async {
        await tester.pumpWidget(
          MyApp(login: login, firestore: db),
        ); // Открываем экран для проверки.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        await tester.tap(
          find.text('Начать'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        await tester.tap(
          find.text('Нет аккаунта? Зарегистрироваться'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        await tester.tap(find.text('Зарегистрироваться'));
        await tester.pumpAndSettle();
        expect(find.text('Введите никнейм.'), findsOneWidget);
        expect(login.registrations, 0);
        await fillCredentials(tester, password: '123');
        await tester.tap(
          find.text('Зарегистрироваться'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        expect(
          // Проверяем ожидаемый результат.
          find.text('Пароль должен содержать не менее 6 символов.'),
          findsOneWidget,
        );
        expect(login.registrations, 0); // Проверяем ожидаемый результат.
        await fillCredentials(tester);
        await tester.tap(
          find.text('Зарегистрироваться'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
        expect(login.registrations, 1);
        expect(login.nickname, 'Читатель'); // Проверяем ожидаемый результат.
        await enterCatalog(tester);
        expect(
          find.byType(CatalogScreen),
          findsOneWidget,
        ); // Проверяем ожидаемый результат.
      })();
    },
  );

  for (final code in [
    // Проверяем записи по одной.
    'wrong-password',
    'invalid-credential',
    'email-already-in-use',
    'weak-password',
    'nickname-already-in-use',
    'network-request-failed',
  ]) {
    testWidgets('Ошибка $code видна в форме и не открывает каталог', (
      // Проверяем описанный пользовательский сценарий.
      tester,
    ) async {
      final login = FakeLogin()
        ..errorCode = code; // Храним сервис входа и регистрации.
      addTearDown(
        login.changes.close,
      ); // После проверки закрываем созданные для неё объекты.
      await tester.pumpWidget(
        MyApp(login: login, firestore: db),
      ); // Открываем экран для проверки.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      await tester.tap(
        find.text('Начать'),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      if (code == 'email-already-in-use' ||
          code == 'weak-password' ||
          code == 'nickname-already-in-use') {
        await tester.tap(
          find.text('Нет аккаунта? Зарегистрироваться'),
        ); // Нажимаем кнопку, как это сделал бы пользователь.
        await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      }
      await fillCredentials(tester);
      await tester.tap(
        // Нажимаем кнопку, как это сделал бы пользователь.
        find.text(
          code == 'email-already-in-use' ||
                  code == 'weak-password' ||
                  code == 'nickname-already-in-use'
              ? 'Зарегистрироваться'
              : 'Войти',
        ),
      );
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      final expected = switch (code) {
        'nickname-already-in-use' => 'Этот никнейм уже занят. Выберите другой.',
        'email-already-in-use' =>
          'Этот email уже зарегистрирован. Попробуйте войти.',
        'weak-password' =>
          'Пароль слишком слабый. Используйте не менее 6 символов.',
        'network-request-failed' =>
          'Нет соединения с сервером. Проверьте интернет.',
        _ => 'Неверный email или пароль.',
      };
      expect(
        find.text('$expected ($code)'),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      expect(
        find.byType(CatalogScreen),
        findsNothing,
      ); // Проверяем ожидаемый результат.
    });
  }

  testWidgets('Ошибка выхода видна, сессия не теряется', (tester) async {
    // Проверяем описанный пользовательский сценарий.
    final login = FakeLogin(signedIn: true)
      ..errorCode =
          'network-request-failed'; // Храним сервис входа и регистрации.
    addTearDown(
      login.changes.close,
    ); // После проверки закрываем созданные для неё объекты.
    await (() async {
      await tester.pumpWidget(
        MyApp(login: login, firestore: db),
      ); // Открываем экран для проверки.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      await enterCatalog(tester);
      await tester.tap(
        find.text('Выйти'),
      ); // Нажимаем кнопку, как это сделал бы пользователь.
      await tester.pumpAndSettle(); // Ждём, пока экран загрузится и анимации закончатся.
      await enterCatalog(tester);
      expect(
        find.byType(CatalogScreen),
        findsOneWidget,
      ); // Проверяем ожидаемый результат.
      expect(
        // Проверяем ожидаемый результат.
        find.text(
          'Нет соединения с сервером. Проверьте интернет. (network-request-failed)',
        ),
        findsOneWidget,
      );
    })();
  });

  testWidgets('Во время инициализации Firebase каталог закрыт', (tester) async {
    // Проверяем описанный пользовательский сценарий.
    await tester.pumpWidget(const MyApp()); // Открываем экран для проверки.
    await tester.pump();
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    ); // Проверяем ожидаемый результат.
    expect(
      find.byType(CatalogScreen),
      findsNothing,
    ); // Проверяем ожидаемый результат.
  });
}
