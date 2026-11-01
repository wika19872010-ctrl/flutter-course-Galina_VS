// Файл выбора экрана по состоянию авторизации: закрывает каталог без входа и собирает его зависимости.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/login_service.dart';
import '../../data/favorites_store.dart';
import '../../data/firestore_book_repository.dart';
import '../navigation/quick_page_route.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'catalog_screen.dart';
import 'catalog_welcome_screen.dart';

/// Следит за входом в аккаунт: без входа закрывает доступ к каталогу.
class AuthGate extends StatelessWidget {
  final LoginService login;
  final FirebaseFirestore? firestore;
  final Stream<String?> _session;

  /// Получает сервис входа и запоминает поток сообщений о смене пользователя.
  AuthGate({super.key, required this.login, this.firestore})
    : _session = login.userIdChanges.distinct();

  /// Создаёт видимую часть экрана или виджета по текущим данным.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _session,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Не удалось проверить вход. Перезапустите приложение.',
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _AuthNavigation(
          login: login,
          firestore: firestore,
          userId: snapshot.data,
        );
      },
    );
  }
}

/// Помнит, что после выхода нужно открыть вход, а не первое приветствие.
class _AuthNavigation extends StatefulWidget {
  final LoginService login;
  final FirebaseFirestore? firestore;
  final String? userId;

  /// Принимает данные входа, чтобы выбрать нужный экран для текущего пользователя.
  const _AuthNavigation({
    required this.login,
    required this.firestore,
    required this.userId,
  });

  /// Создаёт объект, который запоминает переходы между входом и каталогом.
  @override
  State<_AuthNavigation> createState() => _AuthNavigationState();
}

/// Следит, какие экраны открывать при входе и выходе пользователя.
class _AuthNavigationState extends State<_AuthNavigation> {
  bool _returnToLogin = false;

  /// Подготавливает начальные значения один раз при создании экрана.
  @override
  void initState() {
    super.initState();
    _returnToLogin = widget.userId != null;
  }

  /// Проверяет новые данные от родительского виджета.
  /// Запоминает вход, чтобы после выхода показать форму входа.
  @override
  void didUpdateWidget(covariant _AuthNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != null) _returnToLogin = true;
  }

  /// Создаёт видимую часть экрана или виджета по текущим данным.
  @override
  Widget build(BuildContext context) {
    final userId = widget.userId;
    // При выходе удаляется весь стек каталога, включая детали и редактор.
    return Navigator(
      key: ValueKey(userId),
      onGenerateRoute: (_) => QuickPageRoute<void>(
        builder: (_) => userId != null
            ? CatalogWelcomeScreen(
                login: widget.login,
                userId: userId,
                catalogBuilder: (_) => CatalogScreen(
                  onSignOut: widget.login.signOut, // Передаём действие выхода из Firebase-аккаунта.
                  repository: FirestoreBookRepository(
                    // Подключаем чтение и сохранение общих книг.
                    db: widget.firestore ?? FirebaseFirestore.instance,
                    userId: userId, // Указываем текущего пользователя.
                    getNickname: () => widget.login.getNickname(userId),
                  ),
                  favorites: FirestoreFavoritesStore(
                    // Передаём хранилище избранного текущего UID.
                    userId: userId, // Указываем текущего пользователя.
                    db: widget.firestore ?? FirebaseFirestore.instance,
                  ),
                ),
              )
            : _returnToLogin
            ? LoginScreen(login: widget.login)
            : WelcomeScreen(login: widget.login),
      ),
    );
  }
}
