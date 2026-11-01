import 'package:flutter/material.dart';

/// Короткие переходы между приветствием, входом и каталогом.
class QuickPageRoute<T> extends MaterialPageRoute<T> {
  /// Принимает функцию создания нового экрана и задаёт короткий переход к нему.
  QuickPageRoute({required super.builder});

  /// Возвращает длительность перехода при открытии нового экрана.
  @override
  Duration get transitionDuration => const Duration(milliseconds: 120);

  /// Возвращает длительность перехода при возврате на предыдущий экран.
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 100);
}
