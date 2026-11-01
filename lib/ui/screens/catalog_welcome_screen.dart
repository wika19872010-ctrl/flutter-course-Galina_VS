// Приветствие пользователя после входа и переход в общий каталог.
import 'package:flutter/material.dart';

import '../../data/login_service.dart';
import '../theme/app_styles.dart';
import '../navigation/quick_page_route.dart';

/// Показывает приветствие после входа и кнопку перехода в каталог.
class CatalogWelcomeScreen extends StatefulWidget {
  final LoginService login;
  final String userId;
  final WidgetBuilder catalogBuilder;

  /// Принимает пользователя, сервис входа и функцию открытия каталога.
  const CatalogWelcomeScreen({
    super.key,
    required this.login,
    required this.userId,
    required this.catalogBuilder,
  });

  /// Создаёт объект, который хранит данные приветствия между обновлениями экрана.
  @override
  State<CatalogWelcomeScreen> createState() => _CatalogWelcomeScreenState();
}

/// Хранит результат загрузки никнейма для приветствия пользователя.
class _CatalogWelcomeScreenState extends State<CatalogWelcomeScreen> {
  late final Future<String?> _nickname = widget.login.getNickname(
    widget.userId,
  );

  /// Создаёт видимую часть экрана или виджета по текущим данным.
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 105,
                    color: Color(0xFF304C78),
                  ),
                ),
                const SizedBox(height: 32),
                FutureBuilder<String?>(
                  future: _nickname,
                  builder: (context, snapshot) {
                    final name = snapshot.data?.trim();
                    return Text(
                      name != null && name.isNotEmpty
                          ? '$name, добро пожаловать в каталог книг!'
                          : 'Добро пожаловать в каталог книг!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF304C78),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Выбери, что тебе нравится, и добавь своё.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, height: 1.5),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF304C78),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushReplacement<void, void>(
                          QuickPageRoute(builder: widget.catalogBuilder),
                        ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Перейти в каталог'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
