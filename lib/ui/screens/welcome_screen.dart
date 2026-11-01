// Файл приветственного экрана с названием приложения, рисунком книги и переходом к входу.

import 'package:flutter/material.dart';

import '../../data/login_service.dart';
import '../theme/app_styles.dart';
import '../navigation/quick_page_route.dart';
import 'login_screen.dart';

/// Показывает первое приветствие и кнопку открытия формы входа.
class WelcomeScreen extends StatelessWidget {
  final LoginService login; // Храним сервис входа и регистрации.

  /// Принимает сервис входа для передачи на экран авторизации.
  const WelcomeScreen({super.key, required this.login});

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Выбираем цвет фона.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32), // Создаём отступы внутри блока.
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ), // Ограничиваем размер содержимого.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // Создаём оформленный контейнер.
                    width: 200, // Задаём ширину элемента.
                    height: 200, // Задаём высоту элемента.
                    decoration: const BoxDecoration(
                      // Оформляем фон и рамку.
                      color: AppColors.surface,
                      shape: BoxShape
                          .circle, // Сохраняем форму кнопки или карточки.
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 120,
                      color: Color(0xFF304C78),
                      semanticLabel: 'Открытая книга',
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ), // Оставляем промежуток между соседними элементами.
                  const Text(
                    'Моя личная библиотека книг',
                    textAlign: TextAlign.center, // Задаём выравнивание текста.
                    style: TextStyle(
                      // Выбираем оформление текста.
                      fontSize: 32, // Выбираем размер текста.
                      fontWeight: FontWeight.bold, // Выбираем толщину букв.
                      color: Color(0xFF304C78),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ), // Оставляем промежуток между соседними элементами.
                  const Text(
                    'Собирайте книги, которые хочется прочитать, '
                    'и сохраняйте любимые в избранном.',
                    textAlign: TextAlign.center, // Задаём выравнивание текста.
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.5,
                    ), // Выбираем оформление текста.
                  ),
                  const SizedBox(
                    height: 40,
                  ), // Оставляем промежуток между соседними элементами.
                  SizedBox(
                    // Оставляем промежуток между соседними элементами.
                    width: double.infinity, // Задаём ширину элемента.
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        // Выбираем оформление текста.
                        backgroundColor: const Color(
                          0xFF304C78,
                        ), // Выбираем цвет фона.
                        foregroundColor:
                            Colors.white, // Задаём цвет текста и иконок.
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ), // Создаём отступы внутри блока.
                      ),
                      onPressed: () => Navigator.of(context).push<void>(
                        QuickPageRoute(
                          builder: (_) => LoginScreen(login: login),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Начать'),
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
}
