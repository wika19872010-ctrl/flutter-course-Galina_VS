// Файл анимации перехода между экранами с диагональным отворотом страницы.

import 'dart:math' as math;

import 'package:flutter/material.dart';

// Лист отворачивается от нижнего левого угла по диагонали к правой середине.
/// Открывает следующий экран с анимацией отворота книжной страницы.
class BookPageRoute<T> extends PageRouteBuilder<T> {
  /// Принимает функцию создания экрана и длительность анимации его открытия.
  BookPageRoute({
    required WidgetBuilder builder,
    Duration openingDuration = const Duration(milliseconds: 280),
  }) : super(
         transitionDuration: openingDuration,
         reverseTransitionDuration: const Duration(milliseconds: 220),
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           if (MediaQuery.disableAnimationsOf(context)) return child;
           final progress = animation.drive(
             CurveTween(curve: Curves.easeInOutCubic),
           );
           return AnimatedBuilder(
             animation: progress,
             child: RepaintBoundary(child: child),
             builder: (context, child) {
               if (progress.value == 1) return child!;
               return IgnorePointer(
                 child: CustomPaint(
                   key: const ValueKey('book-page-curl'),
                   foregroundPainter: _FoldPainter(progress.value),
                   child: ClipPath(
                     clipper: _PageClipper(progress.value),
                     child: child,
                   ),
                 ),
               );
             },
           );
         },
       );
}

// Геометрия загиба направлена от нижнего левого угла к середине правого края.
/// Вычисляет форму загиба страницы: его направление, положение и видимую область.
class _FoldGeometry {
  // Вычисляем общую геометрию обрезки и рисунка загиба.
  final Size size; // Храним размер экрана.
  final double progress; // Храним прогресс перехода.
  /// Запоминает размер экрана и степень раскрытия страницы для расчётов.
  const _FoldGeometry(this.size, this.progress);

  /// Находит направление движения загнутого уголка страницы.
  /// Возвращает вектор длиной один, который используется в расчётах.
  Offset get normal {
    // Находим единичное направление движения уголка.
    final direction = Offset(
      size.width,
      -size.height / 2,
    ); // Направляем уголок к правой середине.
    return direction /
        direction.distance; // Нормируем направление для расчётов в пикселях.
  }

  /// Вычисляет, насколько далеко точка находится вдоль направления сгиба.
  double projection(
    Offset point,
  ) => // Измеряем расстояние точки вдоль диагонали.
      point.dx * normal.dx +
      (point.dy - size.height) * normal.dy; // Считаем от нижнего левого угла.
  /// Определяем положение линии сгиба.
  double get edge =>
      progress *
      projection(
        Offset(size.width, 0),
      ); // Продолжаем диагональ до полного раскрытия экрана.
  /// Плавно увеличиваем и уменьшаем ширину отворота.
  double get width =>
      math.min(90.0, size.shortestSide * 0.22) *
      math.sin(math.pi * progress); // Избегаем скачков на концах анимации.

  /// Находит углы видимой части страницы после обрезки линией сгиба.
  List<Offset> polygon(double distance) {
    // Обрезаем прямоугольник диагональной линией.
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ]; // Обходим углы экрана.
    final result = <Offset>[]; // Собираем видимую часть страницы.
    var previous = corners.last; // Начинаем с последней стороны прямоугольника.
    for (final current in corners) {
      // Проверяем пересечение каждой стороны со сгибом.
      final a =
          projection(previous) - distance; // Измеряем положение начала стороны.
      final b =
          projection(current) - distance; // Измеряем положение конца стороны.
      if ((a <= 0) != (b <= 0)) {
        // При пересечении добавляем точку на линии сгиба.
        result.add(
          Offset.lerp(previous, current, a / (a - b))!,
        ); // Вычисляем точное пересечение.
      }
      if (b <= 0) {
        // Проверяем принадлежность угла раскрытой стороне.
        result.add(current); // Сохраняем угол на раскрытой стороне страницы.
      }
      previous = current; // Переходим к следующей стороне.
    }
    return result; // Возвращаем вершины видимой области.
  }

  /// Превращает углы видимой части страницы в замкнутый контур для рисования.
  Path path(double distance) {
    // Преобразуем вершины в замкнутый контур.
    final points = polygon(
      distance,
    ); // Получаем пересечение страницы с полуплоскостью.
    return points.isEmpty
        ? Path()
        : (Path()..addPolygon(
            points,
            true,
          )); // Возвращаем пустой либо замкнутый путь.
  }
}

/// Обрезает экран по контуру страницы во время перехода.
class _PageClipper extends CustomClipper<Path> {
  // Раскрываем страницу от нижнего левого угла.
  final double progress; // Храним прогресс перехода.
  /// Запоминает степень раскрытия страницы, по которой рассчитывается обрезка.
  const _PageClipper(this.progress);

  /// Возвращает контур, внутри которого нужно показать экран на этом шаге анимации.
  @override
  Path getClip(Size size) =>
      size
          .isEmpty // Обрабатываем нулевой размер без деления на ноль.
      ? Path()
      : _FoldGeometry(size, progress).path(_FoldGeometry(size, progress).edge); // Обрезаем страницу диагональю.
  /// Обновляем контур при движении уголка.
  @override // Реализуем проверку необходимости обновления.
  bool shouldReclip(_PageClipper oldClipper) => oldClipper.progress != progress;
}

/// Рисует загнутый край страницы и тень, чтобы переход выглядел объёмным.
class _FoldPainter extends CustomPainter {
  // Рисуем светлый отворот и его тень вдоль диагонали.
  final double progress; // Храним прогресс перехода.
  /// Запоминает степень раскрытия страницы, по которой рисуется сгиб.
  const _FoldPainter(this.progress);

  /// Рисует край загнутой страницы и его тень на переданном холсте.
  @override // Реализуем рисование.
  void paint(Canvas canvas, Size size) {
    // Рисуем сгиб поверх раскрываемой страницы.
    if (progress <= 0 || progress >= 1 || size.isEmpty) {
      // Проверяем крайние состояния перехода.
      return; // Не рисуем загиб в крайних состояниях.
    }
    final geometry = _FoldGeometry(
      size,
      progress,
    ); // Используем ту же геометрию, что и обрезка.
    final fold = Path.combine(
      PathOperation.difference,
      geometry.path(geometry.edge),
      geometry.path(geometry.edge - geometry.width),
    ); // Выделяем узкую полосу отворота.
    final tip =
        Offset(0, size.height) +
        geometry.normal * geometry.edge; // Находим ведущую точку на диагонали.
    final paint =
        Paint() // Создаём краску для обратной стороны листа.
          ..shader =
              LinearGradient(
                // Придаём загибу объём с помощью света и тени.
                colors: const [
                  Color(0xFF9AA7BA),
                  Color(0xFFF8FAFF),
                  Color(0xFFD9E2EF),
                ], // Сохраняем оттенки исходной анимации.
                stops: const [
                  0,
                  0.65,
                  1,
                ], // Размещаем светлую часть у края отворота.
                begin: Alignment(
                  -geometry.normal.dx,
                  -geometry.normal.dy,
                ), // Направляем градиент поперёк сгиба.
                end: Alignment(
                  geometry.normal.dx,
                  geometry.normal.dy,
                ), // Совмещаем направление света с движением уголка.
              ).createShader(
                Rect.fromCircle(
                  center: tip - geometry.normal * geometry.width / 2,
                  radius: geometry.width / 2,
                ),
              ); // Ограничиваем градиент шириной загиба.
    canvas.save(); // Запоминаем состояние холста.
    canvas.clipRect(Offset.zero & size); // Ограничиваем рисование экраном.
    canvas.drawShadow(
      fold,
      Colors.black.withValues(alpha: 0.4),
      10,
      false,
    ); // Рисуем мягкую тень отворота.
    canvas.drawPath(fold, paint); // Рисуем обратную сторону загнутого листа.
    canvas.restore(); // Восстанавливаем состояние холста.
  }

  /// Возвращает true, если положение сгиба изменилось и рисунок нужно обновить.
  @override // Реализуем проверку необходимости перерисовки.
  bool shouldRepaint(_FoldPainter oldDelegate) =>
      oldDelegate.progress != progress; // Перерисовываем только при движении уголка.
}
