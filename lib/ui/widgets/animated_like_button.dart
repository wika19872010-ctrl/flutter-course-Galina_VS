// Файл кнопки избранного с анимацией увеличения сердечка при нажатии.

import 'package:flutter/material.dart';

/// Показывает кнопку лайка и ненадолго увеличивает сердечко при нажатии.
class AnimatedLikeButton extends StatefulWidget {
  // Показываем сердечко с коротким импульсом при нажатии.
  final bool isLiked; // Получаем состояние избранного из каталога.
  final VoidCallback onPressed; // Получаем действие сохранения лайка.
  /// Принимает текущее состояние лайка и действие, которое нужно выполнить при нажатии.
  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.onPressed,
  }); // Создаём кнопку.

  /// Создаёт объект состояния, который хранит изменяемые данные этого виджета.
  @override // Создаём локальное состояние анимации.
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

/// Управляет увеличением сердечка и освобождает анимацию при закрытии кнопки.
class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  // Здесь запускаем и останавливаем увеличение сердечка.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  ); // Ограничиваем импульс 320 миллисекундами.
  late final Animation<double> _scale =
      TweenSequence<double>([
        // Увеличиваем сердечко и возвращаем исходный размер.
        TweenSequenceItem(
          tween: Tween(
            begin: 1.0,
            end: 1.3,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 40,
        ), // Быстро увеличиваем сердечко.
        TweenSequenceItem(
          tween: Tween(
            begin: 1.3,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 60,
        ), // Плавно возвращаем исходный размер.
      ]).animate(
        _controller,
      ); // Размер сердечка меняется по мере выполнения анимации.

  /// Освобождает контроллеры при закрытии виджета, чтобы они больше не занимали ресурсы.
  @override // Освобождаем ресурсы при закрытии экрана.
  void dispose() {
    _controller.dispose(); // При закрытии кнопки останавливаем её анимацию.
    super.dispose();
  }

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override // Строим кнопку в текущем состоянии.
  Widget build(BuildContext context) => IconButton(
    padding: EdgeInsets.zero, // Убираем внутренние отступы.
    constraints:
        const BoxConstraints(), // Сохраняем ограничения исходной кнопки.
    onPressed: () {
      // Анимируем каждое нажатие, включая снятие лайка.
      if (!MediaQuery.disableAnimationsOf(context)) {
        // Учитываем системное отключение анимаций.
        _controller.forward(
          from: 0,
        ); // Перезапускаем импульс при повторном нажатии.
      }
      widget
          .onPressed(); // Сразу обновляем избранное через существующую логику.
    },
    icon: ScaleTransition(
      // Изменяем только размер сердечка, сохраняя размер области нажатия.
      scale: MediaQuery.disableAnimationsOf(context)
          ? const AlwaysStoppedAnimation(1.0)
          : _scale, // Отключаем движение по системной настройке.
      child: Icon(
        // Сохраняем исходные значки и цвета избранного.
        widget.isLiked ? Icons.favorite : Icons.favorite_border, // Выбираем заполненное или контурное сердце.
        color: widget.isLiked
            ? Colors.red
            : const Color.fromARGB(255, 97, 96, 96), // Показываем лайк красным.
      ),
    ),
  );
}
