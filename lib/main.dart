// Файл запуска приложения: подключает Firebase, восстанавливает сессию и открывает начальный экран.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/login_service.dart';
import 'firebase_options.dart';
import 'ui/screens/auth_gate.dart';
import 'ui/theme/app_styles.dart';

/// Подготавливает Flutter и запускает приложение.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Создаёт приложение и открывает экран подготовки Firebase или проверки входа.
class MyApp extends StatelessWidget {
  final LoginService? login; // Храним сервис входа и регистрации.
  final FirebaseFirestore? firestore;

  /// Создаёт приложение; переданные сервисы позволяют проверять его в тестах.
  const MyApp({super.key, this.login, this.firestore});

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Убираем служебную ленту DEBUG из интерфейса.
      home: login != null
          ? AuthGate(login: login!, firestore: firestore)
          : const _FirebaseStartup(), // Выбираем начальный экран приложения.
    );
  }
}

/// Показывает подготовку подключения к Firebase перед открытием приложения.
class _FirebaseStartup extends StatefulWidget {
  /// Создаёт экран ожидания подключения к Firebase.
  const _FirebaseStartup();

  /// Создаёт объект состояния, который хранит изменяемые данные этого виджета.
  @override
  State<_FirebaseStartup> createState() => _FirebaseStartupState();
}

/// Запускает подключение к Firebase и позволяет повторить его после ошибки.
class _FirebaseStartupState extends State<_FirebaseStartup> {
  late Future<LoginService> _initialization =
      _initialize(); // Инициализируем Firebase и восстанавливаем сессию.

  /// Инициализируем Firebase и восстанавливаем сессию.
  Future<LoginService> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // На iOS/Android сессия сохраняется SDK автоматически.
    if (kIsWeb) await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    return FirebaseLoginService();
  }

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LoginService>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background, // Выбираем цвет фона.
            appBar: AppBar(
              title: const Text('Подключение Firebase'),
            ), // Создаём верхнюю панель экрана.
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  24,
                ), // Создаём отступы внутри блока.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Не удалось подключиться к сервису входа. Проверьте интернет и повторите попытку.',
                      textAlign:
                          TextAlign.center, // Задаём выравнивание текста.
                    ),
                    const SizedBox(
                      height: 16,
                    ), // Оставляем промежуток между соседними элементами.
                    FilledButton(
                      // Создаём кнопку с цветным фоном.
                      onPressed: () => setState(
                        () => _initialization = _initialize(),
                      ), // Обновляем поля и кнопки на этом экране.
                      child: const Text('Повторить подключение'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return AuthGate(login: snapshot.data!);
      },
    );
  }
}
